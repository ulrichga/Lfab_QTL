##############################
#
# Script for filtering genes from a gff3 file down to genes included in a QTL-mapping confidence interval
#
##############################

# Set working directory if running on a local system
# setwd("./Lfab_QTL")

# Create ouput directory, if it is not there yet
if(!("./results/genesearch" %in% list.dirs("."))){
  dir.create("./results/genesearch")
}

# Load the gff3 file
gff3 <- read.table("./data/waspbase/OGS1.0_20170110.gff3", col.names=c("seqid", "source", "type", "start", "end", "score", "strand", "phase", "attributes"),
                   colClasses=c("character", "factor", "factor", "integer", "integer", "character", "factor", "factor", "character"))

# Reduce the gff3 file down to only genes
gff3 <- gff3[gff3[,"type"]=="gene",]

# Reduce the gff3-attributes column down to only the gene-ID
gff3$attributes <- sapply(gff3$attributes, FUN=function(x){strsplit(strsplit(x,";")[[1]][1],"=")[[1]][2]})

# Reduce the gff3 file down to only the columns sequid, start, end and attributes
gff3 <- gff3[,c("seqid", "start", "end", "attributes")]

# Load the QTL summary table
QTL <- read.table("./results/QTLanalysis/QTL_table.txt", header=TRUE, colClasses=c("character", "integer", "integer", "numeric", "numeric", rep("integer", 3)))

# Reduce the QTL table down to only real markers
QTL <- QTL[!is.na(QTL[,"scaffold"]),]

# Get the scaffolds that touch the confidence region (95% bayes interval)
touchregion <- unique(QTL[QTL[,"bayesint_0.95"]==1,"scaffold"])

# Subset the gff3 file to genes that are on the scaffold(s) that thouch the confidence region,
# to get "candidate" genes
candidate_genes <- gff3[gff3[,"seqid"] %in% touchregion,]

# Calculate the midpoint for each "candidate" gene
candidate_genes$midpoint <- (candidate_genes$start + candidate_genes$end)/2

# Find for each midpoint the closest marker in the QTL table and get its LOD score
candidate_genes$LOD_closest <- sapply(1:nrow(candidate_genes), FUN=function(x){
  samescaffoldmarkers <- QTL[QTL[,"scaffold"] == candidate_genes[x,"seqid"],]
  samescaffoldmarkers[which.min(abs(samescaffoldmarkers[,"position_bp"] - candidate_genes[x,"midpoint"])),c("lod")]
})

# The confidence region touches only one scaffold. On that scaffold, the only flanking marker is at tig00000002 311170.
# All positinos upward of it are in the candidate region.
QTL[QTL[,"scaffold"]=="tig00000002",]

# Subset the candidate genes to those upstream of tig00000002 311170
candidate_genes <- candidate_genes[candidate_genes[,"midpoint"] > 311170,]

# Output the candidate genes list
write.table(candidate_genes, "./results/genesearch/candidate_genes.txt", col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
