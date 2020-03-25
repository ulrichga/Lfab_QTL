##############################
#
# This script calculates a corrected version of the phenotype and saves a new version of the phenotype data frame
#
##############################

# Set working directory to Lfab_QTL if running on a local system
# setwd("./Lfab_QTL")

# Load necessary packages
library("pscl")
library("mpath")

# Load the data frame
pheno <- read.table("./results/prepQTL/phenotypes_reduced.txt", header=T)

# Transform n_wasps_added into a factorial variable and F2_father into a character variable
pheno$n_wasps_added <- as.factor(pheno$n_wasps_added)
pheno$F2_father <- as.character(pheno$F2_father)

# Conduct zero-inflated poisson regression with a full model explaining n_offspring
full <- zeroinfl(n_offspring ~ n_nymphs + n_wasps_added + all_removed + any_found_dead + any_in_tube | n_nymphs + n_wasps_added + all_removed + any_found_dead + any_in_tube, data=pheno, dist="poisson")

# Use backwards elimination to reduce the full model to a minimal model
reduced <- zeroinfl(formula(be.zeroinfl(full, data=pheno, dist="poisson")), data=pheno, dist="poisson")
formula(reduced)
summary(reduced)

# Write the formula and summary of the final model to a file
sink("./results/prepQTL/zeroinfl_model.txt")
cat("####    ~~~~~~~~~~~~~    Formula    ~~~~~~~~~~~~~    ####\n")
formula(reduced)
cat("\n")
cat("####    ~~~~~~~~~~~~~    Model summary    ~~~~~~~~~~~~~    ####\n")
summary(reduced)
sink()

# Calculate residuals and attach them to the phenotypes data frame
pheno$residuals <- NA
rows <- as.numeric(names(residuals(reduced)))
pheno[rows, "residuals"] <- residuals(reduced)

# Reduce the phenotypes data frame to only F2_father and residuals
pheno <- pheno[,c("F2_father", "residuals")]
pheno

# Save the new phenotypes data frame
write.table(pheno, "./results/prepQTL/phenotypes_corrected.txt", sep="\t", row.names=FALSE, quote=FALSE)
