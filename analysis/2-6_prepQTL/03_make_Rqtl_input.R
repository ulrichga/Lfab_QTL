##############################
#
# This script uses the MSTmap-produced linkage map, the MSTmap input and the
# phenotype data to construct an input file for analysing with R/qtl
#
##############################

# Set working directory to Lfab_QTL if running on a local system
# setwd("./Lfab_QTL")

# Load linkage map, MSTinput and phenotype data
linkage <- read.table("./results/linkage_mapping/MSToutput_edited.txt", header=TRUE)
MSTinput <- read.table("./results/linkage_mapping/MSTinput.txt", skip=12, header=TRUE)
pheno <- read.table("./results/prepQTL/phenotypes_corrected.txt", header=TRUE)

# Correct data format of input files
str(linkage)
linkage$scaffold <- as.character(linkage$scaffold)
str(MSTinput)
for(i in 1:ncol(MSTinput)){
  MSTinput[,i] <- as.character(MSTinput[,i])
}
str(pheno)
for(i in 1:ncol(pheno)){
  pheno[,i] <- as.character(pheno[,i])
}

# Remove markers from MSTinput that were excluded during linkage mapping
# Make a vector of markers in the linkage map
mappedmarkers <- paste(linkage$scaffold, linkage$position, sep="_")
# Keep only the markers of MSTinput that are in the linkage map
MSTinput <- MSTinput[MSTinput$locus_name %in% mappedmarkers,]

# Make sure the order of markers in MSTinput is the same as in the linkagemap
markerorder <- sapply(1:length(mappedmarkers), FUN=function(x){which(MSTinput$locus_name==mappedmarkers[x])})
MSTinput <- MSTinput[markerorder,]

# Replace the scaffold and position variables in the linkage map with a single variable called marker
marker <- mappedmarkers
linkage <- cbind(marker, linkage[,c(-1,-2)])

# Merge the linkagemap with the MSTinput and transpose to get the genotypes part of the R/qtl file
genotypes <- cbind(linkage, MSTinput)
any(genotypes$marker!=genotypes$locus_name) # Check: FALSE means the merger was successful

# Remove the locus_name variable from genotypes and transform the non-character variables to character
genotypes <- genotypes[,-4]
for(i in 1:3){
  genotypes[,i] <- as.character(genotypes[,i])
}

# Transpose the data frame and transform all variables to character again
genotypes <- as.data.frame(t(genotypes))
for(i in 1:ncol(genotypes)){
  genotypes[,i] <- genotypes[,i]
}

# The genotypes part is now done and the phenotypes part will be prepared next

# Bring the phenotypes in the correct order. There are individuals for which there are genotypes but no phenotypes.
# Those should be included in the phenotypes with NA. Thus, loop through the row names of genotypes, and create
# a entry in a new phenotypes data frame for each entry in genotypes. If the phenotype is known, enter the phenotype,
# if the phenotype is unknown, enter NA.

# Extract the individual names from genotypes
geno_ind <- row.names(genotypes)[-c(1:3)]

# Create a phenotypes data frame, which starts with 3 empty lines and will be followed by phenotypes for all genotyped individuals
phenotypes <- data.frame(F2_father = rep("", 3), residuals = rep("", 3), binary_offspring = rep("", 3))
# Loop through the names of genotyped individuals
for(F2_father in geno_ind){ # For each genotyped individual name (i.e. F2_father)
  if(F2_father %in% pheno[,"F2_father"]){ # If this name has an entry in the pheno(types) data frame...
    phenotype <- pheno[pheno[,"F2_father"] == F2_father,] # ...save the entry as phenotype
  }
  else{ # Otherwise...
    phenotype <- data.frame(F2_father = F2_father, residuals = NA, binary_offspring=NA)# ...save NA as phenotype (using the same column names as in pheno)
  }
  # Append the "phenotype" variables created above in a "phenotypes" data frame
  phenotypes <- rbind(phenotypes, phenotype) # Attach the phenotype line at the end of phenotypes
}

# Merge the phenotypes and genotypes data frames to create a data frame of the appropriate input format for R/qtl
Rqtlin <- cbind(phenotypes, genotypes)

# Transform all columns in Rqtlin to characters
for(i in 1:ncol(Rqtlin)){
  Rqtlin[,i] <- as.character(Rqtlin[,i])
}

# Enter names for the phenotypes in Rqtlin
Rqtlin[1,2] <- "residuals"
Rqtlin[1,3] <- "binary_offspring"

# Remove the F2_father entry from Rqtlin
Rqtlin <- Rqtlin[,-1]

# Replace all NA's and U's with "-"
for(i in 1:ncol(Rqtlin)){
  Rqtlin[which(is.na(Rqtlin[,i])),i] <- "-"
  Rqtlin[which(Rqtlin[,i]=="U"),i] <- "-"
}

# Write the table as a CSV for later analysis with R/qtl
write.table(Rqtlin, "./results/prepQTL/Rqtlin.csv", sep=",", quote=FALSE, row.names=FALSE, col.names=FALSE)
