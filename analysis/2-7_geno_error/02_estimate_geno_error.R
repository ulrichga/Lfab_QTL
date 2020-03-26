##############################
#
# The purpose of this script is to measure genotyping error using the SNPlist of control individuals.
#
# Some more details:
# 11 out of 12 sequenced pools contained a control DNA sample. Control DNA was obtained from 30 CV17-84
# wasps. The CV17-84 strain is an all-female parthenogenetic strain. In theory these wasps are gentically
# identical. Therefore they can be used to assess genotyping error.
#
##############################

# 0. Set working directory and load the SNP table

#    Set working directory if running on a local system
# setwd("./Lfab_QTL")

#    Load the SNP table
ctrlSNPs <- read.table("./results/geno_error/ctrlSNPs_n2", header=T)

#    Change the colnames from CV17.84_xx to CV17-84_xx
colnames(ctrlSNPs) <- gsub("\\.", "-", colnames(ctrlSNPs))

# 1. check the SNPtable, transform it's entries to character, replace "/" with "|" and replace "." with ".|."
str(ctrlSNPs)
for (i in 1:ncol(ctrlSNPs)){
  ctrlSNPs[,i] <- as.character(ctrlSNPs[,i])
}

#    replace all occurrences of "/" in the SNPs_n2 data frame with "|"
for (i in 1:ncol(ctrlSNPs)){
  ctrlSNPs[,i] <- gsub("/", "|", ctrlSNPs[,i])
}

#    replace all occurrences of "." in the SNPs_n2 data frame with ".|."
for (i in 1:ncol(ctrlSNPs)){
  ctrlSNPs[which(nchar(ctrlSNPs[,i])==1),i] <- ".|."
}

# 2. Set up a function, that takes two genotypes as input, compares them and responds in boolean if the genotypes match.
#    The function should have an option as to whether comparisons with dots "." are treated as mismatches or not. By
#    default, it should not treat them as mismatches. Further, the function should not be phase-sensitive i.e. when
#    comparing A|C to C|A, it should not be counted as a mismatch.
samegeno <- function(genoA, genoB, dotismismatch=F){
  if(genoA==genoB){TRUE} # check if the two genotypes are literally the same and return TRUE if so (A|T vs A|T = TRUE)
  else{
    if(paste0(rev(strsplit(genoA,"")[[1]]),collapse="")==genoB){TRUE} # if not, revert one and test again (T|A vs A|T = TRUE)
    else{
      if(dotismismatch==T | length(grep("\\.", c(genoA,genoB)))==0){FALSE} # if dot is counted as a mismatch or if there is no dot in the genotypes, there are now no more possibilities to return TRUE
      else{ # however, continue if dot is not counted as a mismatch and there is a dot in the genotypes
        if(genoA==".|." | genoB==".|."){TRUE} # if any of the two genotypes is ".|.", return TRUE
        else{
          genos <- c(strsplit(genoA,"")[[1]], strsplit(genoB,"")[[1]]) # make a vector of all characters in both genotypes
          if(length((unique(genos[-which(genos=="."|genos=="|")])))<3){TRUE} # return true if the number of non "." and non "|" unique characters in both is <3
          else{FALSE} # if we did not figure out yet whether they are the same, they are not the same i.e. return FALSE
        }
      }
    }
  }
}

#    try the function with some examples (we will not count dots as mismatch)
samegeno("A|T", "A|T")
samegeno("A|T", "T|A")
samegeno("A|T", "A|.")
samegeno("A|T", "A|G")
samegeno(".|A", ".|.")
samegeno("G|A", ".|T")
samegeno("G|A", ".|A")
samegeno("T|G", "G|G")

# 3. Write a function that takes two vectors of genotypes and returns the percentage of corresponding genotypes
#    using the function created above.
samegenos <- function(individualA, individualB, ...){
  sum(sapply(1:length(individualA), FUN=function(x){samegeno(individualA[x], individualB[x], ...)}))/length(individualA)
}

#    Try the function. It returns the percentage of matching genotypes
samegenos(ctrlSNPs[,"CV17-84_10"],ctrlSNPs[,"CV17-84_11"])

# 4. For all pairs of control individuals, apply the function defined above.
combos <- combn(1:ncol(ctrlSNPs), 2)
same <- sapply(1:ncol(combos), function(x){samegenos(ctrlSNPs[,combos[1,x]], ctrlSNPs[,combos[2,x]])})

# 5. summarize the result and calculate the error rate

#    put the results togehter with the column IDs that were compared
comparisons <- rbind(combos, same)

#    for each ID (1-11) return the mean correspondence considering all comparisons
smry <- c()
for(i in 1:11){
  smry <- c(smry, mean(same[which(combos[1,]==i | combos[2,]==i)]))
}

#    name the vector after the colnames ID to have a summary of pairwise correspondence per control individual
names(smry) <- colnames(ctrlSNPs)

mean(same)# the pairwise correspondence between control samples is 98.79 %
1-mean(same)# therefore, the error rate is 1.207 %

# 6. Output genotyping error statistics

# OUtput a summary for all comparisons
comparisons <- rbind(comparisons, 1-comparisons[3,])
rownames(comparisons) <- c("sample_A", "sample_B", "matches", "mismatches")
colnames(comparisons) <- paste("comparison", 1:ncol(comparisons), sep="_")
comparisons <- as.data.frame(t(as.matrix(comparisons)))
# Give the compared individuals the proper names
comparisons[,1] <- as.character(comparisons[,1])
comparisons[,2] <- as.character(comparisons[,2])
for(i in 1:length(colnames(ctrlSNPs))){
  comparisons[comparisons[,1]==as.character(i),1] <- colnames(ctrlSNPs)[i]
  comparisons[comparisons[,2]==as.character(i),2] <- colnames(ctrlSNPs)[i]
}
# Generate the output
write.table(comparisons, "./results/geno_error/all_genotype_comparisons.txt", sep="\t", row.names=FALSE, quote=FALSE)

# Output a summary for each control individual including an overall mean
mean_matches <- smry
mean_mismatches <- 1-smry
comp_ind <- data.frame(sample=names(smry), mean_matches, mean_mismatches)
comp_ind <- rbind(comp_ind, data.frame(sample="MEAN", mean_matches=mean(comp_ind$mean_matches), mean_mismatches=mean(comp_ind$mean_mismatches)))
# Generate the output
write.table(comp_ind, "./results/geno_error/individual_genotype_comparisons.txt", sep="\t", row.names=FALSE, quote=FALSE)
