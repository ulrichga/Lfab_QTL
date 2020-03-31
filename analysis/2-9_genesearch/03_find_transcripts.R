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

# Load the transcript assignments by looping through the BLAST outputs
genesearch_files <- list.files("./results/genesearch")
assignments <- genesearch_files[grep("transcripts", genesearch_files)]
assignments <- assignments[grep(".tab", assignments)]
nr <- unname(sapply(assignments, FUN=function(x){(as.numeric(strsplit(x, "_")[[1]][2]))}))
files <- data.frame(assignments, nr)
files <- files[order(files$nr),]
files$assignments <- as.character(files$assignments)
# Loop through the file number to put a complete dataframe together
for (i in files$nr){
  if(i == 1){
    assignments <- read.table(paste0("./results/genesearch/", files[files[,"nr"]==i, "assignments"]))
  }
  if(i != 1){
    assignments <- rbind(assignments, read.table(paste0("./results/genesearch/", files[files[,"nr"]==i, "assignments"])))
  }
}
# Add column names
colnames(assignments) <- c("query_id", "subject_id", "%_identity", "aln_length", "n_of_mismatches", "gap_openings", "q_start", "q_end", "s_start", "s_end", "e_value", "bit_score")
# Change the first two variables to character
assignments$query_id <- as.character(assignments$query_id)
assignments$subject_id <- as.character(assignments$subject_id)

# Save the combined data frame of transcript assignments
write.table(assignments, "./results/genesearch/transcripts_vs_OGS.txt", sep="\t", quote=FALSE, row.names=FALSE)

# Reduce the assignments to only the genes and transcript IDs
assignments <- assignments[,c("query_id", "subject_id")]
assignments$subject_id <- unname(sapply(assignments$subject_id, FUN=function(x){strsplit(x, "-")[[1]][1]}))

# Load the candidate genes
candidate_genes <- read.table("./results/genesearch/candidate_genes.txt", header=TRUE, colClasses = c("character", "integer", "integer", "character", "numeric", "numeric"))

# Reduce the assignments to only the genes that are included in candidate_genes
assignments <- assignments[assignments$subject_id %in% candidate_genes$attributes,]

# Load the differential expression data frame from Dennis et al. (2017)
diffex <- read.table("./data/Dennis_et_al_2017/evo13333-sup-0005-datas2.H76vsH-_comparison.txt", header=TRUE, colClasses=rep("character", 12))
colnames(diffex)[1] <- "transcript_id"

# Reduce the differential expression data frame to only the transcripts that were assigned to candidate genes
diffex_candidates <- diffex[diffex$transcript_id %in% assignments$query_id,]
nrow(diffex_candidates)
diffex_candidates[1:20, 1:8]

# Add the information in the candidate_genes data frame to the differentially expressed transcripts data frame
gene_id <- unname(sapply(diffex_candidates$transcript_id, FUN=function(x){unique(assignments[assignments[,"query_id"]==x,"subject_id"])}))
for(i in 1:length(gene_id)){
  if(i == 1){
    candidate_transcripts <- candidate_genes[candidate_genes[,"attributes"]==gene_id[i],]
  }
  if(i != 1){
    candidate_transcripts <- rbind(candidate_transcripts, candidate_genes[candidate_genes[,"attributes"]==gene_id[i],])
  }
}
candidate_transcripts <- cbind(candidate_transcripts, diffex_candidates)

# Save the candidate_transcripts data frame
write.table(candidate_transcripts, "./results/genesearch/candidate_transcripts.txt", quote=FALSE, sep="\t", row.names = FALSE)
