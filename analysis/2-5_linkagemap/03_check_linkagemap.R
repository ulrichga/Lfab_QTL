##############################
#
# Script to analyse and compare our MSTmap-produced linkage map with an earlier one by Dennis et al. (2019, preprint).
#
# The goal is to have the new map in a similar format as the earlier one with corresponding linkage-group numbers and
# orientations.
#
##############################

# Set working directory if running on a local system
# setwd("./Lfab_QTL")

# Read linkage maps
new <- read.table("./results/linkage_mapping/MSToutput.txt", fill=T) # the newly constructed linkage map
old <- read.table("./data/01.Linkage_groups.txt", fill=T, header=T) # the linkage map from Dennis et al. (2019, preprint)

# Transform all variables to characters
for (i in 1:ncol(new)){
  new[,i] <- as.character(new[,i])
}
for (i in 1:ncol(old)){
  old[,i] <- as.character(old[,i])
}

# Reduce the old linkage map to contain only relevant parts and name the columns accordingly
old <- old[,c(1:4)]
for (i in 2:4){
  old[,i] <- as.numeric(old[,i])
}
colnames(old) <- c("scaffold", "position", "linkage_group", "mapping_pos")

# Remove the _a or _b appendages in the scaffold names of the old map
old[,1] <- sapply(old[,1], FUN=function(x){strsplit(x, "_")[[1]][1]})

# Make a function to return a linkage map in the format as the one by Dennis et al. from a MSTmap output file
MSTformat <- function(x){
  froms <- which(x[,1]==";BEGINOFGROUP")+1 # get coordinates of beginnings of linkage groups
  tos   <- which(x[,1]==";ENDOFGROUP")-1 # get coordinates of endings of linkage groups
  lgroups  <- length(froms) # get the number of linkage groups
  out <- data.frame(# define the format for an output data frame
    scaffold=character(), # the scaffold ID should be a acharacter variable
    position=numeric(), # the SNP-positiion on the scaffold should be numeric
    linkage_group=numeric(), # the linkage group number should be numeric
    mapping_pos=numeric() # the mapping position should be numeric
  )
  for (i in 1:lgroups){ # for each linkage group
    lgr <-  x[froms[i]:tos[i],c(1,2)] # subset the data frame to the relevant columns and only the rows with the current linkage group
    tig <- sapply(1:length(strsplit(lgr[,1],"_")), FUN=function(x){strsplit(lgr[,1],"_")[[x]][1]}) # take the scaffold ID
    loc <- sapply(1:length(strsplit(lgr[,1],"_")), FUN=function(x){strsplit(lgr[,1],"_")[[x]][2]}) # take the scaffold position
    lgr <- data.frame(# put output data frame together, making sure the variable types and rownames match the output format
      scaffold=as.character(tig), # the scaffold ID should be a acharacter variable
      position=as.numeric(loc), # the SNP-positiion on the scaffold should be numeric
      linkage_group=as.numeric(rep(i,nrow(lgr))), # the linkage group number should be numeric
      mapping_pos=as.numeric(lgr[,2]) # the mapping position should be numeric
    )
    out <- rbind(out,lgr)
  }
  out[,1] <- as.character(out[,1])
  out
}

# Change the format of the new linkage map with the above function
new <- MSTformat(new)

# Remove isolated markers from the new linkage map (those were placed in linkage groups with <= 2 markers)
for(i in 1:max(new[,"linkage_group"])){ # For each linkage group in the new linkage map
  lg_length <- nrow(new[new[,"linkage_group"]==i,]) # Get the number of markers contained in it
  if(lg_length<=2){ # If this number is less than or equal to 2...
    new <- new[!(new[,"linkage_group"]==i),] # ...exclude the linkage group from the map
  }
}

# Find corresponding linkage gropus in the new and old linkage maps and rename the linkage groups in the new one
# First find for each marker in the new map, which of the markers on the same scaffold in the old map is closest
# For this a function is made that takes a line number of the new map as input and outputs the line number of the
# closest marker on the same scaffold in the old map
corresp_marker <- function(x){
  sametig <- old[which(old[,1]==new[x,1]),]
  sametig <- sametig[which.min(abs(sametig[,2]-new[x,2])),]
  which(old[,1]==sametig[,1]&old[,2]==sametig[,2])
}
# Then the function is applied over all rows of the new linkage map to get the row number of the corresponding
# marker in the old linkage map
corresponding <- sapply(1:nrow(new), FUN=corresp_marker)
# In the list of corresponding lines, replace all entries of length 0 with NA (those are markers on scaffolds
# in the new map which are not included in the old map)
corresponding <- sapply(1:length(corresponding), FUN=function(x){ # For each entry in the "corresponding" list
  ncor <- length(corresponding[[x]]) # Check the length of the entry
  if(ncor>=1){ # If there are one or more intries...
    return(corresponding[[x]][1]) # ..return the first
  }
  if(ncor<1){ # If there are less than one...
    return(NA) # ...return NA
  }
})
# Find for each row in the new linkage map the corresponding scaffold, position linkage group and mapping position
# in the old map
corresponding <- old[corresponding,]
# Rename the corresponding data frame and combine it with the new linkage map
colnames(corresponding) <- c("cortig", "corpos", "corLG", "corMP")
new_cor <- cbind(new, corresponding)
# Count for each linkage group in the new map how often it corresponds to any linkage group in the old map
new_cor <- na.omit(new_cor)
LGnew <- unique(new[,"linkage_group"])
LGold <- unique(old[,"linkage_group"])
comparison_new <- c()
comparison_old <- c()
matching_markers <- c()
for(i in min(LGnew):max(LGnew)){
  for(j in min(LGold):max(LGold)){
    comparison_new <- c(comparison_new,i)
    comparison_old <- c(comparison_old,j)
    matches <- nrow(new_cor[new_cor[,"linkage_group"]==i & new_cor[,"corLG"]==j,])
    matching_markers <- c(matching_markers,matches)
  }
}
# Make a table showing the number of matches for each combination of linkage gropus in the old and new linkage map
LG_comparison <- data.frame(comparison_new,
                            comparison_old,
                            matching_markers)
# Replace the linkage group ID in the new linkage map with the linkage group ID in the old map that matches best
# Also replace it in the new_cor data frame
for(i in min(LGnew):max(LGnew)){
  sameLG <- LG_comparison[LG_comparison[,"comparison_new"]==i,]
  new[new[,"linkage_group"]==i,"linkage_group"] <- sameLG[which.max(sameLG[,"matching_markers"]),"comparison_old"]
  new_cor[new_cor[,"linkage_group"]==i,"linkage_group"] <- sameLG[which.max(sameLG[,"matching_markers"]),"comparison_old"]
}

# Find out which linkage groups in the new map are flipped around compared to the old linkage map
# If the correlation of mapping positions in matching linkage groups is positive, it is not flipped,
# if it is negative, it is flipped.
isflipped <- c()
for(i in min(LGold):max(LGold)){
  isflipped <- c(isflipped, cor(new_cor[new_cor[,"linkage_group"]==i & new_cor[,"corLG"]==i,"mapping_pos"],
                                new_cor[new_cor[,"linkage_group"]==i & new_cor[,"corLG"]==i,"corMP"])<0)
}

# One can plot the mapping positions of corresponding linkage groups against one another to visually
# inspect the comparison
for(i in 1:6){
  plot(new_cor[new_cor[,"linkage_group"]==i & new_cor[,"corLG"]==i,"mapping_pos"],
       new_cor[new_cor[,"linkage_group"]==i & new_cor[,"corLG"]==i,"corMP"], main=paste("LG", as.character(i), paste0(" (flipped = ", as.character(isflipped[i]), ")")),
       ylab="Old map position", xlab="New map position")
}

# Flip the linkage groups in the new map that are flipped compared to the old map
for(i in unique(new[,"linkage_group"])){
  if(isflipped[i]){
    new[new[,"linkage_group"]==i,"mapping_pos"] <- abs(new[new[,"linkage_group"]==i,"mapping_pos"] - max(new[new[,"linkage_group"]==i,"mapping_pos"]))
    new[new[,"linkage_group"]==i,]
  }
}
# Sort the new linkage map
new <- new[order(new$mapping_pos),]
new <- new[order(new$linkage_group),]

# Output the linkage map
write.table(new, "./results/linkage_mapping/MSToutput_edited.txt", sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE)

# Create a summary of this new linkage map
# Load the data frame on size of scaffolds that was produced by 00_initalize.sh
scaffoldsize <- read.table("./data/genome/scaffoldsize.txt", header=F)
colnames(scaffoldsize) <- c("scaffold", "size")
scaffoldsize[,1] <- as.character(scaffoldsize[,1])
genome_size <- sum(scaffoldsize$size)
scaffolds_new <- unique(new$scaffold)
length(scaffolds_new) # 352 scaffolds are contained in the linkage map
length(scaffoldsize$scaffold) # 1698 scaffolds are contained in the genome
length(scaffolds_new)/length(scaffoldsize$scaffold) # Thus, 20.73027% of scaffolds are contained in the linkage map
sum(scaffoldsize[which(scaffoldsize$scaffold %in% new$scaffold),"size"]) # 84.337426 kbp are contained in the linkage map
84337426/genome_size # which corresponds to 59.93893% of the genome
# Write these findings to a summary file
writeLines(c(paste0("Genome size: ", genome_size, " bp"),
             paste0("Scaffolds in genome: ", length(scaffoldsize$scaffold)),
             paste0("Scaffolds in new linkage map: ", length(scaffolds_new)),
             paste0("Percentage of scaffolds in new linkage map: ", length(scaffolds_new)/length(scaffoldsize$scaffold)*100, "%"),
             paste0("Base pairs in new linkage map: ", sum(scaffoldsize[which(scaffoldsize$scaffold %in% new$scaffold),"size"]), " bp"),
             paste0("Percentage of Base pairs in new linkage map: ", sum(scaffoldsize[which(scaffoldsize$scaffold %in% new$scaffold),"size"])/genome_size*100, "%")
             ), con="./results/linkage_mapping/linkagemap_summary.txt")
