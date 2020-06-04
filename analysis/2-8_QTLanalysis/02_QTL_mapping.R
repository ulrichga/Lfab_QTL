##############################
#
# Script for conducting QTL mapping
#
##############################

# Set a seed for reproducibility (permutation tests and genotype simulations are random processes)
set.seed(27032020)

# Set working directory if running on a local system
# setwd("./Lfab_QTL")

# Load the qtl package
library("qtl")

# Load the edited Rqtlin data, accounting for the changed genotype encoding
qtlin <- read.cross("csv", "./results/QTLanalysis", "Rqtlin_final.csv", genotypes=c("AA","AB","BB","DD","CC"))

# Get the mean genotyping error from the summary file
genoerror <- read.table("./results/geno_error/individual_genotype_comparisons.txt", header=TRUE)
genoerror <- genoerror[12,3]

# Convert the cross type to riself (recombinant-inbred by selfing). This cross type is appropriate because it
# assumes a 50:50 distribution of maternal:paternal or A:B alleles and does not expect heterozygous individuals.
qtlin <- convert2riself(qtlin)

# Calculate conditional genotype probabilities with a step size of 0.1 cM.
qtlin <- calc.genoprob(qtlin, step=.1, error.prob=genoerror)

# Perform genome scan with a single-QTL nonparametric model using the EM algorithm.
qtlin_em <- scanone(qtlin, model="np")

# Determine a significance threshold using a permutation test
qtlin_perm <- scanone(qtlin, model="np", n.perm=1000, verbose=TRUE)
sigthres_0.05 <- summary(qtlin_perm, alpha=c(0.05))[1]

# Plot all chromosomes with significance threshold as pdf file
pdf("./results/QTLanalysis/lod_LGall.pdf", width = 14)
plot(qtlin_em, col="#08306B", ylab="LOD score", xlab="Linkage group")
abline(h=sigthres_0.05)
dev.off()

# Get confidence intervals for the chromosome with the peak lod score (1.5 lod interval and 0.95 approx. bayes interval)
peakchr <- qtlin_em[which.max(qtlin_em[,"lod"]),"chr"]
pos1 <- lodint(qtlin_em, peakchr, 1.5)[1,2]
pos2 <- lodint(qtlin_em, peakchr, 1.5)[3,2]
lodint_markers <- qtlin_em[qtlin_em[,"chr"]==peakchr&qtlin_em[,"pos"]>=pos1&qtlin_em[,"pos"]<=pos2,]
pos1 <- bayesint(qtlin_em, peakchr, 0.95)[1,2]
pos2 <- bayesint(qtlin_em, peakchr, 0.95)[3,2]
bayesint_markers <- qtlin_em[qtlin_em[,"chr"]==peakchr&qtlin_em[,"pos"]>=pos1&qtlin_em[,"pos"]<=pos2,]

# Plot the peak chromosome with the bayesian confidence interval and export it as a pdf file
pdf("./results/QTLanalysis/lod_LGmax_bayesint.pdf")
plot(qtlin_em, chr=peakchr, type="n", frame=F, incl.markers=F, ylab="LOD score")
polygon(c(bayesint_markers[1,2],bayesint_markers[,2],bayesint_markers[nrow(bayesint_markers),2]), c(-3,bayesint_markers[,3],-3), border="#9ECAE1", col="#9ECAE1")
plot(qtlin_em, chr=peakchr, frame=F, add=T, lwd=1)
mars <- qtlin_em[grep("tig",rownames(qtlin_em)),]
mars <- mars[mars[,1]==2,2]
rug(mars)
box()
plot(qtlin_em, chr=peakchr, add=TRUE, incl.markers=F, col="#08306B")
abline(h=sigthres_0.05)
dev.off()

# Plot all chromosomes but with highlighting the bayesian confidence interval and export it as a pdf file
pdf("./results/QTLanalysis/lod_LGall_bayesint.pdf", width = 14)
# Construct the plot without content
plot(qtlin_em, ylab="LOD score", xlab="Linkage group", type="n", incl.markers = FALSE)
# Calculate offset for each chromosome as a vector. this vector contains the starting point of each chromosome
# Offset is (spacer)*(chromosome_id-1)+sum_of_previous_chr_sizes
spacer <- 25
offset <- rep(NA, nchr(qtlin))
chr_sizes <- c()
for(i in 1:nchr(qtlin)){
  chr_sizes <- c(chr_sizes, qtlin_em[qtlin_em[,"pos"]==max(qtlin_em[as.numeric(qtlin_em$chr) == i,"pos"]),"pos"])
}
for (i in 1:nchr(qtlin)){
  if(i==1){
    offset[i] <- 0
  }
  if(i>1){
    sum_of_previous_chr_sizes <- sum(chr_sizes[0:(i-1)])
    offset[i] <- spacer*(i-1)+sum_of_previous_chr_sizes
  }
}
# Add the (bayes 95%) confidence interval as a polygon with x and y corrdinates called xcoords and ycoords
xcoords <- qtlin_em[qtlin_em[,"pos"]>=pos1 & qtlin_em[,"pos"]<=pos2 & qtlin_em[,"chr"]==peakchr, "pos"]
xcoords <- c(min(xcoords), xcoords, max(xcoords))
xcoords <- xcoords + offset[as.numeric(peakchr)]
ycoords <- qtlin_em[qtlin_em[,"pos"]>=pos1 & qtlin_em[,"pos"]<=pos2 & qtlin_em[,"chr"]==peakchr, "lod"]
ycoords <- c(-10, ycoords, -10)
polygon(xcoords, ycoords, border="#9ECAE1", col="#9ECAE1")
# overlay the lod-scores and sig-threshold
plot(qtlin_em, col="#08306B", add=TRUE)
box()
abline(h=sigthres_0.05)
# include marker positions
realmarkers <- qtlin_em[grep("tig", row.names(qtlin_em)),]
markerpos_plot <- realmarkers$pos + offset[as.numeric(realmarkers$chr)]
rug(markerpos_plot)
# Add a "legend" to indicate map scale
x <- (offset[6]+chr_sizes[6]/2)-100
y <- 3.5
arrows(x, y, x+100, y, angle=90, length=0.05, code=3)
text(x+50, y, "100 cM", pos=1)
dev.off()

# Estimate the variance explained by the peak position
peakpos <- as.numeric(summary(qtlin_em, perms=qtlin_perm, alpha=0.05, pvalues = T)[,2]) # save the peak position
qtlin <- sim.geno(qtlin, step=0.1, n.draws=256, error.prob=genoerror)
qtl <- makeqtl(qtlin, chr=peakchr, pos=peakpos)
out.fq <- fitqtl(qtlin, qtl=qtl, formula=y~Q1)
sink("./results/QTLanalysis/explained_variance.txt")
summary(out.fq)
sink()

# Plot the phenotype x genotype interaction at the marker position with the maximum LOD score
markersonly <- qtlin_em[grep("tig", rownames(qtlin_em)),] # get only the entries with markers
peakmar <- rownames(markersonly[which.max(markersonly[,"lod"]),])
pdf("./results/QTLanalysis/peak_PxG.pdf")
plotPXG(qtlin, peakmar, ylab="Phenotype")
dev.off()

# Output a summary table that will later be used to filter genes in the candidate region
# Put the table together
marker_summary <- qtlin_em
marker_summary$sig_0.05 <- as.numeric(marker_summary$lod>sigthres_0.05)
marker_summary$lodint_1.5 <- as.numeric(rownames(marker_summary) %in% rownames(lodint_markers))
marker_summary$bayesint_0.95 <- as.numeric(rownames(marker_summary) %in% rownames(bayesint_markers))
marker_summary$scaffold <- sapply(rownames(marker_summary), function(x){if(length(grep("tig", x))==0){NA} else{strsplit(x,"_")[[1]][1]}})
marker_summary$position_bp <- as.numeric(sapply(rownames(marker_summary), function(x){if(length(grep("tig", x))==0){NA} else{strsplit(x,"_")[[1]][2]}}))
marker_summary <- marker_summary[,c("scaffold", "position_bp", "chr", "pos", "lod", "sig_0.05", "lodint_1.5", "bayesint_0.95")]
names(marker_summary) <- c("scaffold", "position_bp", "linkage_group", "position_cM", "lod", "sig_0.05", "lodint_1.5", "bayesint_0.95")
marker_summary[,"linkage_group"] <- as.numeric(marker_summary[,"linkage_group"])
# Output the summary table
write.table(marker_summary, "./results/QTLanalysis/QTL_table.txt", row.names=FALSE, sep="\t")
