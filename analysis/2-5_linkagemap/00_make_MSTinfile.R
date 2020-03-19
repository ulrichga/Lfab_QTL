##############################
#
# Script to put SNP-tables together and prepare input for MSTmap
#
# The primary goal is to have a MSTmap input file that says for each SNP
# in the haploid samples, whether it comes from the mother or the father or whether this is unknown.
# The input SNPs for MSTmap shall be filtered for the following criteria (kept if they meet those criteria):
#    being known in both parents,
#    being homozygous in the mother,
#    being biallelic,
#    being >50% known and
#    not being segregation distorted.
# Also only keep individuals with >50% known genotypes.
#
# A secondary goal is to produce a list of SNPs and one of individuals, that are used as MSTmap input.
#
##############################

# set working directory if running on a local system
# setwd("./Lfab_QTL")

# make sure the output directory is there, if not, create it
if(!("./results/linkage_mapping" %in% list.dirs("."))){
  dir.create("./results/linkage_mapping")
}

# read SNP-table data frames + the list of SNPs
SNPlist <- read.table("./results/SNPfilter/HCBS_list", header=F)
SNPs_n1 <- read.table("./results/SNPfilter/SNPs_n1", header=T)
SNPs_n2 <- read.table("./results/SNPfilter/SNPs_n2", header=T)

# check data frames
str(SNPlist)
str(SNPs_n1)
str(SNPs_n2)

# specify as character variables:
# -> SNPlist: scaffold number "tig00000xxx"
SNPlist[,1] <- as.character(SNPlist[,1])
# -> SNPs_n1: every variable
for (i in 1:ncol(SNPs_n1)){
  SNPs_n1[,i] <- as.character(SNPs_n1[,i])
}
# -> SNPs_n2: every variable
for (i in 1:ncol(SNPs_n2)){
  SNPs_n2[,i] <- as.character(SNPs_n2[,i])
}

# check data frames again
str(SNPlist)
str(SNPs_n1)
str(SNPs_n2)

# replace all occurrences of "/" in the SNPs_n2 data frame with "|"
for (i in 1:ncol(SNPs_n2)){
  SNPs_n2[,i] <- gsub("/", "|", SNPs_n2[,i])
}

# replace all occurrences of "." in the SNPs_n2 data frame with ".|."
for (i in 1:ncol(SNPs_n2)){
  SNPs_n2[which(nchar(SNPs_n2[,i])==1),i] <- ".|."
}

# make a new data frame containing only the two parent individuals and make the variables character
parents <- data.frame(cbind(SNPs_n2$P_1_f, SNPs_n1$P_1_m))
colnames(parents) <- c("P_1_f","P_1_m")
for (i in 1:ncol(parents)){
  parents[,i] <- as.character(parents[,i])
}

# find markers with missing genotypes in the two parents
missingsite <- sapply(1:nrow(parents), FUN=function(x){length(grep("\\.",unlist(strsplit(gsub("\\|","",paste0(parents[x,], collapse="")),""))))>0})

# find SNPs that are homozygous in the mother and found in an alternative state in the father
# those are homozygous in the female and have 2 alleles across the male and the female.
homo.fem <- sapply(1:nrow(parents), FUN=function(x){length(unique(unlist(strsplit(gsub("\\|","",paste0(parents[x,1], collapse="")),""))))==1})
two.alleles <- sapply(1:nrow(parents), FUN=function(x){length(unique(unlist(strsplit(gsub("\\|","",paste0(parents[x,], collapse="")),""))))==2})

# make a variable that lists SNPs as 1 for passing and 0 for failing the following criteria
# 1. There are no unknown genotypes in the two parent individuals for that SNP
# 2. The female parent is homozygous
# 3. The SNP is biallelic among the two parents
parents.pass.filt <- as.numeric(!missingsite & homo.fem & two.alleles)

# find which SNPs and individuals should be filtered out concerning the data frame of haploids
# first make a subset that contains only the mapping population (F2 males)
mapping.pop <- SNPs_n1[,grep("F2", colnames(SNPs_n1))]

# assign for each individual in the mapping data set, whether it carries the maternal (A) or
# paternal (B) allele in each marker or whether this is unknown (U).
# a function is made for this purpose. It should do the following:
# take SNPs of a mapping pop individual and check three things
check <- mapping.pop[1,1]
# 1. if it is unknown
unknown <- check == "."
# 2. if it is in the mother
inmother <- any(check == unlist(strsplit(parents[1,1],"")))
# 3. if it is in the father
infather <- check == parents[1,2]
# -> return A if it is in the mother and not in the father
if(inmother==T & infather==F){"A"}
# -> return B if it is in the father and not in the mother
if(inmother==F & infather==T){"B"}
# -> return U if it is in both (U stands for unknown)
if(inmother==T & infather==T){"U"}
# -> also return U if it is in neither of them (U stands for unknown)
if(inmother==F & infather==F){"U"}
# -> return U if it is unknown
if(unknown==T){"U"}
# now write it as a function of column and row number in the mapping population data frame
check.segr <- function(row, col){
  check <- mapping.pop[row,col]
  unknown <- check == "."
  inmother <- any(check == unlist(strsplit(parents[row,1],"")))
  infather <- check == parents[row,2]
  if(inmother==T & infather==F){answer <- "A"}
  if(inmother==F & infather==T){answer <- "B"}
  if(inmother==T & infather==T){answer <- "U"}
  if(inmother==F & infather==F){answer <- "U"}
  if(unknown==T){answer <- "U"}
  answer
}

# try the function
check.segr(row=1, col=1)
# it works only for single entries, no multiple rows and columns...
# however this is enough to use it with apply-type functions like so:
sapply(1:nrow(mapping.pop), FUN=function(x){check.segr(row=x,col=1)})

# make a copy of the mapping pop data frame and overwrite its content with the output of this above function for each individual
segregation <- mapping.pop
for(i in 1:ncol(mapping.pop)){
  segregation[,i] <- sapply(1:nrow(mapping.pop), FUN=function(x){check.segr(row=x,col=i)})
}

# find for each marker in the mapping population the proportion of missing data (="U")
missing.dat <- sapply(1:nrow(segregation),FUN=function(x){length(grep("U",unlist(strsplit(paste0(segregation[x,], collapse=""),""))))/ncol(segregation)})

# find markers with >50% missingness i.e. make a vector with 1 for passing and 0 for failing this criterion
mapping.SNP.filt <- as.numeric(missing.dat < 0.5)

## find SNPs that show significant segregation distortion and mark them for filtering
# count the number of A's and B's for each SNP
nSNPs.A <- sapply(1:nrow(segregation),FUN=function(x){length(grep("A",unlist(strsplit(paste0(segregation[x,], collapse=""),""))))})
nSNPs.B <- sapply(1:nrow(segregation),FUN=function(x){length(grep("B",unlist(strsplit(paste0(segregation[x,], collapse=""),""))))})
# conduct a chisquare test with 50:50 expectation for each SNP and output a p-value
expected <- (nSNPs.A+nSNPs.B)/2
chisquare <- (((nSNPs.A-expected)^2)/expected) + (((nSNPs.B-expected)^2)/expected) # don't worry about NaNs (will be removed due to >50% missingness)
pvalue <- sapply(chisquare, FUN=function(x){1-pchisq(x,1)})
# conduct bonferroni correction to tag SNPs that deviate significantly from the expectation and
# make a 0/1 vector for failing/passing the segregation filter
segrdist.SNP.filt <- as.numeric(pvalue > (0.05/length(pvalue)))
# recode the NAs as failing the filter because they are either invariant or unknown in all individuals
segrdist.SNP.filt[is.na(segrdist.SNP.filt)] <- 0

# filter the segregation data frame keeping only SNPs that pass the parental segregation filter (AA / B
# + no unknown variable in parents), the mapping population filter (only SNPs with < 50% missingness) and
# the filter for segregation distortion
# merge the filtering criteria with the SNPlist
SNPlist.filter <- cbind(SNPlist, parents.pass.filt, mapping.SNP.filt, segrdist.SNP.filt)
# and filter for passing all 3 criteria
segregation <- segregation[(SNPlist.filter[,3]+SNPlist.filter[,4]+SNPlist.filter[,5])==3,]

# find for each individual in the mapping population the proportion of missing data
missing.ind <- sapply(1:ncol(segregation),FUN=function(x){length(grep("U",unlist(strsplit(paste0(segregation[,x], collapse=""),""))))/nrow(segregation)})
names(missing.ind) <- colnames(segregation)

# find individuals with >50% missingness i.e. make a named vector with 1 for passing and 0 for failing this criterion
mapping.ind.filt <- as.numeric(missing.ind < 0.5)
names(mapping.ind.filt) <- colnames(mapping.pop)

# make a list of SNPs that are kept
# first merge the filtering criteria with the SNPlist
SNPlist.filter <- cbind(SNPlist, parents.pass.filt, mapping.SNP.filt, segrdist.SNP.filt)
# keep only SNPs that pass the parental segregation filter (AA / B + no unknown variable in parents), the 
# mapping population filter (only SNPs with < 50% missingness) and the filter for segregation distortion
SNPlist.filter <- SNPlist.filter[(SNPlist.filter[,3]+SNPlist.filter[,4]+SNPlist.filter[,5])==3,]
# output a SNP list as a 2-col tsv with chromosome and position as only variables
write.table(SNPlist.filter[,c(1,2)], "./results/linkage_mapping/mapping_SNPs", quote=F, sep="\t", row.names=F, col.names=F)

# make a list of individuals that are kept
kept_ind <- data.frame(names(which(mapping.ind.filt==1)))
write.table(kept_ind, "./results/linkage_mapping/mapping_ind", quote=F, sep="\t", row.names=F, col.names=F)

# subset the segregation data frame to contain only the individuals that are kept
segregation <- segregation[,colnames(segregation) %in% as.character(kept_ind[,1])]

# count the number of SNPs and individuals that will be used for linkage mapping
n_SNP <- dim(segregation)[1]
n_ind <- dim(segregation)[2]

# construct the input file for MSTmap
# for a template, see http://www.mstmap.org/sample_input.txt
# construct it as a data frame.
# create the variable that will be a header
locus_name <- paste(SNPlist.filter[,1], SNPlist.filter[,2], sep="_")
# attach the header to the filtered A-B-U assignment
MSTdata <- cbind(locus_name, segregation)

# the MST input still lacks a header. This header contains the parameters for MSTmap.
# for now we are filling in parameters that avoid splitting anything into chromosomes and keep all the loci.
# the parameters will then be fine-tuned to meet expectations / use the same parameters as Dennis et al. (in prep)
para.name <- c("population_type", "population_name", "distance_function", "cut_off_p_value", "no_map_dist", "no_map_size", "missing_threshold", "estimation_before_clustering", "detect_bad_data", "objective_function", "number_of_loci", "number_of_individual")
parameter <- c("DH", "LG", "kosambi", "0.000001", "15.0", "2", "0.25", "no", "yes", "COUNT", as.character(n_SNP), as.character(n_ind))
MSTpara <- cbind(para.name, parameter)

# before writing output, rewrite the input variables as characters.
for (i in 1:ncol(MSTdata)){
  MSTdata[,i] <- as.character(MSTdata[,i])
}

# write MSTmap input as a parameters table and a data table
write.table(MSTpara, "./results/linkage_mapping/MSTpara", quote=F, sep="\t", row.names=F, col.names=F)
write.table(MSTdata, "./results/linkage_mapping/MSTdata", quote=F, sep="\t", row.names=F, col.names=T)
