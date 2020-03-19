#################################################################################################################################
#
# Analysis of the dominance relationships experiment.
# 
#################################################################################################################################

# 0. Set Lfab_QTL as working directory if necessary #############################################################################
# setwd("./Lfab_QTL")

# 1. Open the dominance_first_gen dataset #######################################################################################
gen1 <- read.table("./data/dominance_first_gen.txt", header=TRUE)

# 2. Subset the data frame... ###################################################################################################
#    ...to only contain the variables "treatment", "n_daughters", "n_sons" and "n_nymphs" and the observations where
#    actually wasps were added ("treatment" != "NONE")
gen1 <- gen1[gen1[,"treatment"]!="NONE", c("treatment", "n_daughters", "n_sons", "n_nymphs")]

# 3. Plot and output descriptive statistics #####################################################################################

#    Obtain and plot means
means <- aggregate(gen1[,-c(1,4)], list(gen1$treatment), mean) # get a table of mean offspring numbers
rownames(means) <- means$Group.1 # include the first variable (treatment) as row names
means <- means[,-1] # exclude the first variable (which is now equivalent to row names)
barplot(t(means)[c("n_daughters", "n_sons"),], ylim=c(0,12), beside=T) # barplot mean offspring numbers

#    Obtain and plot standard errors
sems <- aggregate(gen1[,-c(1,4)], list(gen1$treatment), function(x) {sd(x)/sqrt(length(x))})
rownames(sems) <- sems$Group.1
sems <- sems[,-1]
foo <- barplot(t(means)[c("n_daughters", "n_sons"),], ylim=c(0,12), beside=T, ylab="Mean offspring number per wasp pair", xlab="Cross", col=c("gray20","gray80"))
legend("topright",legend=c("daughters","sons"), pch=22, pt.bg=c("gray20","gray80"), pt.cex=2, bty="n")
arrows(x0=foo,y0=t(means)+t(sems),y1=t(means)-t(sems),angle=90,code=3,length=0.1)

#    Output mean offspring barplot as PDF but first make sure the ./results/ folder is actually there
if(!("./results" %in% list.dirs("."))){
  dir.create("./results")
}
pdf("./results/dominance_offspringbarplot.pdf")
barplot(t(means)[c("n_daughters", "n_sons"),], ylim=c(0,12), beside=T) # barplot mean offspring numbers
legend("topright",legend=c("daughters","sons"), pch=22, pt.bg=c("gray20","gray80"), pt.cex=2, bty="n")
arrows(x0=foo,y0=t(means)+t(sems),y1=t(means)-t(sems),angle=90,code=3,length=0.1)
dev.off()

#    Obtain median offspring numbers
medians <- aggregate(gen1[,-c(1,4)], list(gen1$treatment), median) # get a table of median offspring numbers
rownames(medians) <- medians$Group.1 # include the first variable (treatment) as row names
medians <- medians[,-1] # exclude the first variable (which is now equivalent to row names)

#    Obtain sample size
lengths <- aggregate(gen1[,-c(1,4)], list(gen1$treatment), length) # get a table of length offspring numbers
lengths <- lengths[,-3] # exclude the last variable (n_sons is equal to n_daughters)
colnames(lengths) <- c("cross", "N_crosses")

#    Obtain numbers of colonies with female / male offspring
offspring_in_N <- aggregate(gen1[,-c(1,4)], list(gen1$treatment), FUN=function(x){sum(x>0)}) # get a table of median offspring numbers
rownames(offspring_in_N) <- offspring_in_N$Group.1 # include the first variable (treatment) as row names
offspring_in_N <- offspring_in_N[,-1] # exclude the first variable (which is now equivalent to row names)

#    Combine the descriptive statistics to a single summary
firstgen_summary <- cbind(lengths,
                          offspring_in_N$n_daughters, means$n_daughters, sems$n_daughters, medians$n_daughters,
                          offspring_in_N$n_sons, means$n_sons, sems$n_sons, medians$n_sons)
colnames(firstgen_summary) <- c("cross", "n_crosses", "n_with_female_offspring", "mean_female_offspring", "sem_female_offspring", "median_female_offspring",
                                "n_with_male_offspring", "mean_male_offspring", "sem_male_offspring", "median_male_offspring")

#    Output the summary dataset
write.table(firstgen_summary, file="./results/dominance_firstgen_summary.txt", quote=FALSE, row.names=FALSE, sep="\t")

# 4. Compare offspring numbers between crosses ##################################################################################

#    Compare female offspring numbers among all crosses
female.wilcox.pval <- data.frame(RRxR=c(NA,NA,NA,NA), RRxS=c(NA,NA,NA,NA), SSxR=c(NA,NA,NA,NA), SSxS=c(NA,NA,NA,NA))
rownames(female.wilcox.pval) <- c("RRxR", "RRxS", "SSxR", "SSxS")
for(i in rownames(female.wilcox.pval)){ # compare all rows
  for(j in colnames(female.wilcox.pval)){ # with all columns
    # Save the P-values in the data frame female.wilcox.pval (comparing two groups of 0's returns NaN)
    female.wilcox.pval[i,j] <- wilcox.test(gen1[gen1[,"treatment"]==i,"n_daughters"], gen1[gen1[,"treatment"]==j,"n_daughters"])$p.value
  }
}

#    Output p-values
write.table(female.wilcox.pval, file="./results/dominance_firstgen_wilcoxtests.txt", quote=FALSE, row.names=FALSE, sep="\t")

# 5. Compare sex ratio between crosses with offspring ###########################################################################
#    Subset the data frame to contain only data from colonies with offspring
sex_ratio_data <- gen1[gen1[,"n_daughters"]+gen1[,"n_sons"]>0,]

#    Construct a response variable for a binomial model (two columns added together to a matrix)
y_mtrx <- as.matrix(sex_ratio_data[,c("n_daughters", "n_sons")])

#    Do a binomial regression with treatment as only explanatory variable
sglm1 <- glm(y_mtrx ~ sex_ratio_data$treatment, family="binomial")
summary(sglm1) # treatment effect on sex ratio is nonsignificant but the model is overdispersed

#    Repeat for quasibinomial
sglm2 <- glm(y_mtrx ~ sex_ratio_data$treatment, family="quasibinomial")
summary(sglm2) # still not significant

#    Output summary of the quasibinomial model to analyse sex ratio
sink("./results/dominance_firstgen_sexglm.txt")
summary(sglm2)
sink()
