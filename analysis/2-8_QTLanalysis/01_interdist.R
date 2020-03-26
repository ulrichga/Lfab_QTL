##############################
#
# Script for re-estimating intermarker distances in the R/qtl input file
#
##############################

# Set working directory if running on a local system
# setwd("./Lfab_QTL")

# Create ouput directory, if it is not there yet
if(!("./results/QTLanalysis" %in% list.dirs("."))){
  dir.create("./results/QTLanalysis")
}

# Load the qtl package
library("qtl")

# Load the edited Rqtlin data, accounting for the changed genotype encoding
qtlin <- read.cross("csv", "./results/prepQTL", "Rqtlin_filtered.csv", genotypes=c("AA","AB","BB","DD","CC"))

# Get the mean genotyping error from the summary file
genoerror <- read.table("./results/geno_error/individual_genotype_comparisons.txt", header=TRUE)
genoerror <- genoerror[12,3]

# Convert the cross type to riself (recombinant-inbred by selfing). This cross type is appropriate because it
# assumes a 50:50 distribution of maternal:paternal or A:B alleles and does not expect heterozygous individuals.
qtlin <- convert2riself(qtlin)

# Estimate recombination fractions and perform a sanity check with checkAlleles
qtlin <- est.rf(qtlin)
checkAlleles(qtlin) # No apparent problems

# Output a pdf of the recombination fractions
pdf("./results/QTLanalysis/recombination_fractions.pdf") 
plotRF(qtlin)
dev.off()

# Re-estimate intermarker distances with est.map.
newmap <- est.map(qtlin, error.prob=genoerror, map.function="kosambi", verbose=TRUE, tol=1e-4)

# Output the newly estimated linkage map as a pdf plot
pdf("./results/QTLanalysis/linkagemap.pdf") 
plotMap(newmap)
dev.off()

# Output a summary of the new map
mapsummary <- summaryMap(newmap)
linkagegroup <- row.names(summaryMap(newmap))
mapsummary <- cbind(linkagegroup, summaryMap(newmap))
write.table(mapsummary, "./results/QTLanalysis/linkagemap_summary.txt", sep="\t", row.names=FALSE, quote=FALSE)

# Output the new map as a table
options(scipen=999)
scaffold <- c()
position <- c()
linkage_group <- c()
mapping_pos <- c()
for(i in 1:nchr(newmap)){
  scaffold <- c(scaffold, unname(sapply(names(newmap[[i]][1:length(newmap[[i]])]), function(x){strsplit(x, "_")[[1]][1]})))
  position <- c(position, as.numeric(unname(sapply(names(newmap[[i]][1:length(newmap[[i]])]), function(x){strsplit(x, "_")[[1]][2]}))))
  linkage_group <- c(linkage_group, rep(i,length(newmap[[i]])))
  mapping_pos <- c(mapping_pos, unname(newmap[[i]][1:length(newmap[[i]])]))
}
newmap_table <- data.frame(scaffold, position, linkage_group, mapping_pos)
write.table(newmap_table, "./results/QTLanalysis/linkagemap_cM.txt", sep="\t", row.names=FALSE, quote=FALSE)

# Replace the old map with the new map
qtlin <- replace.map(qtlin, newmap)

# Save the R/qtl input file that now includes a new linkage map
write.cross(qtlin, format="csv", filestem="./results/QTLanalysis/Rqtlin_final")
