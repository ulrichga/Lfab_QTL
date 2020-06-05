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

# Visualize the transformation
# First with a plot comparing offspring-numbers and residuals (point size is proportional to the number of nymphs, red
# indicates that there were still wasps in the tube, solid points indicate that not all wasps could be removed and
# overlayed crosses indicate that only one wasp was added)
pdf("./results/prepQTL/offspringnumbers_vs_residuals.pdf")
plot(pheno$n_offspring, pheno$residuals, cex=pheno$n_nymphs/50, col=pheno$any_in_tube, xlab="Offspring number", ylab="Residuals i.e. corrected phenotype")
pheno_singlewasp <- pheno[pheno[,"n_wasps_added"]==1,]
pheno_notallremoved <- pheno[pheno[,"all_removed"]=="n",]
points(pheno_notallremoved$n_offspring, pheno_notallremoved$residuals, cex=pheno_notallremoved$n_nymphs/50, bg=pheno_notallremoved$any_in_tube, col=pheno_notallremoved$any_in_tube, pch=21)
points(pheno_singlewasp$n_offspring, pheno_singlewasp$residuals, pch=4)
dev.off()
# Second with a plot visualizing the model where the distance of each point to it's corresponding line is it's residual
# For meanings of lines; see prediction-comments after lines-commands
pdf("./results/prepQTL/zeroinfl_model_visualization.pdf")
plot(pheno$n_nymphs, pheno$n_offspring, cex=pheno$n_nymphs/50, col=pheno$any_in_tube, xlab="Nymphs provided", ylab="Offspring number")
points(pheno_notallremoved$n_nymphs, pheno_notallremoved$n_offspring, cex=pheno_notallremoved$n_nymphs/50, bg=pheno_notallremoved$any_in_tube, col=pheno_notallremoved$any_in_tube, pch=21)
points(pheno_singlewasp$n_nymphs, pheno_singlewasp$n_offspring, pch=4)
newdata_bs  <- data.frame(n_nymphs=10:75, all_removed=rep(factor("y", levels=c("n", "y")), 66), any_in_tube=rep(factor("n", levels=c("n", "y")), 66), n_wasps_added=rep(factor("2", levels=c("1", "2")), 66))
newdata_rs  <- data.frame(n_nymphs=10:75, all_removed=rep(factor("y", levels=c("n", "y")), 66), any_in_tube=rep(factor("y", levels=c("n", "y")), 66), n_wasps_added=rep(factor("2", levels=c("1", "2")), 66))
newdata_bda <- data.frame(n_nymphs=10:75, all_removed=rep(factor("n", levels=c("n", "y")), 66), any_in_tube=rep(factor("n", levels=c("n", "y")), 66), n_wasps_added=rep(factor("2", levels=c("1", "2")), 66))
newdata_bdo <- data.frame(n_nymphs=10:75, all_removed=rep(factor("y", levels=c("n", "y")), 66), any_in_tube=rep(factor("n", levels=c("n", "y")), 66), n_wasps_added=rep(factor("1", levels=c("1", "2")), 66))
lines(10:75, predict(reduced, newdata=newdata_bs), col="black")                # prediction for all_removed:y, any_in_tube:n, n_wasps_added:2 (open black circles)
lines(10:75, predict(reduced, newdata=newdata_rs), col="red")                  # prediction for all_removed:y, any_in_tube:y, n_wasps_added:2 (open red circles)
lines(10:75, predict(reduced, newdata=newdata_bda), col="black", lty="dashed") # prediction for all_removed:n, any_in_tube:n, n_wasps_added:2 (solid black circles)
lines(10:75, predict(reduced, newdata=newdata_bdo), col="black", lty="dotted") # prediction for all_removed:y, any_in_tube:n, n_wasps_added:1 (crosses)
dev.off()

# Reduce the phenotypes data frame to only F2_father and residuals
pheno <- pheno[,c("F2_father", "residuals")]
pheno

# Save the new phenotypes data frame
write.table(pheno, "./results/prepQTL/phenotypes_corrected.txt", sep="\t", row.names=FALSE, quote=FALSE)
