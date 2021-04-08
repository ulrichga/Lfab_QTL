##############################
#
# This script performs the following tasks before saving an edited version of the phenotype data:
# 1. Removing phenotype data that are not used in the analysis (e.g. plant sowing date)
# 2. Simplifying some factorial variables (e.g. discriminating between only two factors for female_location
#    by replacing it with any_in_tube indicating with a two-level-factor, whether one or more wasps were still
#    in the tube at the time when wasps were removed)
# 3. Removing phenotypes for which no genotype data were obtained
# 4. Merging duplicate observations.
#
##############################

# Set working directory to Lfab_QTL if running on a local system
# setwd("./Lfab_QTL")

# Chek if the output directory is present, if not, create it
if(!("./results/prepQTL" %in% list.dirs("."))){
  dir.create("./results/prepQTL")
}

# Load the phenotypes raw data
pheno <- read.table("./data/crossing_data/F3_colonies_25-04-2019.txt", header=T)

# Load the MSTmap input file and obtain a list of genotyped individuals
MSTin <- read.table("./results/linkage_mapping/MSTinput.txt", skip=12, header=T)
genotyped_ind <- colnames(MSTin)[grep("F2", colnames(MSTin))]
rm(MSTin)

# 1. Remove variables that are not used in the analysis #####################################################################

# Subset the phenotypes to keep only some of the variables
pheno <- pheno[,c(2, 3, 11, 13, 15, 17, 18)]

# 2. Edit some variables of the phenotype dataset ###########################################################################

# Sort the data frame after female_origin (this variable corresponds to the names of the genotpyed individuals)
pheno <- pheno[order(pheno$female_origin),]

# Replace the number in female_origin with the name of the F2 father (genotyped individual). Also change the column name
pheno[,2] <- as.character(paste("F2", pheno[,2], "m", sep="_"))
colnames(pheno)[2] <- "F2_father"

# Simplify the female_location variable to any_in_tube:
# Rename it to any_in_tube and replace T, TT, and TP with y and P or PP with n
colnames(pheno)[6] <- "any_in_tube"
levels(pheno$any_in_tube) <- c("n", "n", "y", "y", "y")

# Simplify the female_status varible and rename it to any_found_dead
# In this new variable aa and a is recoded as n and aD is recoded as y
colnames(pheno)[5] <- "any_found_dead"
levels(pheno$any_found_dead) <- c("n", "n", "y")

# Replace the n_females_removed variable with all_removed
# This variable should be y if all wasps could be removed and n if not
colnames(pheno)[4] <- "all_removed"
pheno$all_removed <- as.factor(pheno$n_wasps_added - pheno$all_removed)
levels(pheno$all_removed) <- c("y", "n")

# 3. Only keep phenotype data from individuals for which there are genotype data ############################################
pheno <- pheno[pheno$F2_father %in% genotyped_ind,]

# 4. Combine phenotype observations with identical F2_father ################################################################
# Combining integers will be done by taking their mean and rounding the result to the next integer
# For the factor variables, it will be done as follows:
# all_removed:    y & y -> y
#                 n & n -> n
#                 n & y -> n (n "wins")
# any_found_dead: y & y -> y
#                 n & n -> n
#                 n & y -> y (y "wins")
# any_in_tube:    y & y -> y
#                 n & n -> n
#                 n & y -> y (y "wins")
# Write functions for combining y / n factors as above
nwins <- function(a, b){
  if(a == "n" | b == "n"){return("n")}
  if(a == "y" & b == "y"){return("y")}
}
ywins <- function(a, b){
  if(a == "y" | b == "y"){return("y")}
  if(a == "n" & b == "n"){return("n")}
}

# Find which entries in the phenotypes are duplicated and save their F2_father identity in a vector
duplicates <- sapply(pheno$F2_father, FUN=function(x){
  sum(pheno$F2_father == x)
})
duplicates <- unique(names(duplicates[which(duplicates > 1)]))

# Write a function that takes duplicate entries (lines of the pheno dataset) and returns a single replacement line
redup <- function(df){
  result <- rbind(df, data.frame(
    n_nymphs = as.integer(ceiling(mean(df$n_nymphs))),
    F2_father = as.character(df[1,"F2_father"]),
    n_wasps_added = as.integer(ceiling(mean(df$n_wasps_added))),
    all_removed = as.factor(nwins(df[1,"all_removed"], df[2,"all_removed"])),
    any_found_dead = as.factor(ywins(df[1,"any_found_dead"], df[2,"any_found_dead"])),
    any_in_tube = as.factor(ywins(df[1,"any_in_tube"], df[2,"any_in_tube"])),
    n_offspring = as.integer(ceiling(mean(df$n_offspring)))
  ))
  result[3,]
}

# Make a replacement data frame (repdf) with all duplicates
repdf <- redup(pheno[pheno[,"F2_father"]==duplicates[1],])
for(i in 2:length(duplicates)){
  repdf <- rbind(repdf, redup(pheno[pheno[,"F2_father"]==duplicates[i],]))
}
repdf

# Remove the duplicates from the pheno data frame and include repdf rows instead
pheno <- pheno[!(pheno$F2_father %in% duplicates),]
pheno <- rbind(pheno, repdf)

# Sort by F2_father identity
pheno <- pheno[order(as.numeric(sapply(pheno$F2_father, FUN=function(x){strsplit(x, "_")[[1]][2]}))),]

# Add a binary variable that indicates whether offspring occurred (binary_offspring)
pheno$binary_offspring <- as.numeric(pheno$n_offspring > 0)

# Add a variable that indicates whether an entry is made from merging observations or not
pheno$is_merged <- as.factor(pheno$F2_father %in% duplicates)
levels(pheno$is_merged) <- c("n", "y")

# Output the edited version of the phenotypes data frame
write.table(pheno, "./results/prepQTL/phenotypes_reduced.txt", sep="\t", row.names=FALSE, quote=FALSE)
