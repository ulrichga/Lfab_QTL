##############################
#
# This script performs some sanity checks on the Rqtlin.csv file.
# It also outputs a list of SNPs that will be used for QTL analysis.
#
##############################

# Set working directory to Lfab_QTL if running on a local system
# setwd("./Lfab_QTL")

# Load the qtl package
library("qtl")

# Load the Rqtlin data
qtlin <- read.cross("csv", "./results/prepQTL", "Rqtlin.csv")

# Convert the cross type to riself (recombinant-inbred by selfing). This cross type is appropriate because it
# assumes a 50:50 distribution of maternal:paternal or A:B alleles and does not expect heterozygous individuals.
qtlin <- convert2riself(qtlin)

# Do a check for segregation distortion.
# Obtain the genotype table
gt_qtlin <- geno.table(qtlin)
# Check if there is significant deviation from the expected genotype frequencies
gt_qtlin[gt_qtlin$P.value < 0.05/totmar(qtlin),] # No segregation distorted markers detected.

# Find individuals with > 50% missing genotypes
length(ntyped(qtlin)) # 351 individuals
qtlin <- subset(qtlin, ind=(ntyped(qtlin)/totmar(qtlin)>0.5)) # Apply the filter
length(ntyped(qtlin)) # 351 individuals kept, no change

# Find markers with > 50% missing individuals in the wtt dataset
length(ntyped(qtlin, "mar")) # 1835 markers
nt.bymar <- ntyped(qtlin, "mar") # Get the number of genotyped individuals for each marker
todrop <- names(nt.bymar[nt.bymar < (nind(qtlin)/2)]) # Make a list of markers that should be filtered out
qtlin <- drop.markers(qtlin, todrop) # Apply the filter
length(ntyped(qtlin, "mar")) # 1835 markers kept because none are missing in >50% of individuals

# Check if there are genotype duplicates in qtlin
cg <- comparegeno(qtlin)
hist(cg[lower.tri(cg)], breaks=seq(0, 1, len=101), xlab="No. matching genotypes")
rug(cg[lower.tri(cg)])
wh <- which(cg > 0.9, arr=TRUE)
wh <- wh[wh[,1] < wh[,2],]
wh # there are no individuals with > 90% of their genotypes being equal to another individual.

# Save the new filtered Rqtl input file (although the markers and individuals were not changed)
write.cross(qtlin, format="csv", filestem="./results/prepQTL/Rqtlin_filtered")

# Also save a table of markers that are included in the Rqtlin_filtered.csv file
scaffold <- sapply(markernames(qtlin), FUN=function(x){
  strsplit(x, "_")[[1]][1]
})
position <- sapply(markernames(qtlin), FUN=function(x){
  strsplit(x, "_")[[1]][2]
})
usedmarkers <- data.frame(scaffold, position)
write.table(usedmarkers, "./results/prepQTL/QTL_markers", col.names=FALSE, quote=FALSE, row.names=FALSE, sep="\t")
