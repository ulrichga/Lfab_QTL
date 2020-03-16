# Mapping
To run this part of the analysis follow the steps described here. The analysis was executed on the Euler cluster and pulls dependencies from it. To run it on other cluster, some changes to the code may be necessary. For all the steps the current directory should be the Lfab_QTL directory.
## Step 1
Make sure the necessary raw data are available:
* ./data/genome/Lf_genome_V1.0.fa
* All fq.gz files in ./results/demultiplexed/ that were produced during demultiplexing
## Step 2
Make the 00_initialize.sh script executable and run it. This script creates the directories that are necessary for the analysis. Additionally it initiates a batch job for indexing the reference genome. It is safe to run this script on a login node.
```
dos2unix ./analysis/2-2_mapping/00_initialize.sh
chmod +x ./analysis/2-2_mapping/00_initialize.sh
./analysis/2-2_mapping/00_initialize.sh
```
## Step 3
Run the 01_mapping.lsf script to map reads against the reference genome with *BWA-MEM*. It also performs quality filtering for a quality score of 10 and creates necessary directories. At the end, it summarizes the coverage information for each individual. **This script should only be executed if the batch job created in step 2 is finished**.
```
dos2unix ./analysis/2-2_mapping/01_mapping.lsf
bsub < ./analysis/2-2_mapping/01_mapping.lsf
```
## Step 4
Run the 02_summarize_mapping.sh script to obtain numbers of mapped and quality filtered reads. This script can safely be executed on a login node. **This script should only be executed if step 3 is finished**.
```
dos2unix ./analysis/2-2_mapping/02_summarize_mapping.sh
chmod +x ./analysis/2-2_mapping/02_summarize_mapping.sh
./analysis/2-2_mapping/02_summarize_mapping.sh
```
## Step 5
Run the 03_summarize_coverage.lsf script to summarize coverage data. The summaries created in this step are essential for estimating the numbers of sequenced ddRAD loci. **This script should only be executed if step 3 is finished**.
```
dos2unix ./analysis/2-2_mapping/03_summarize_coverage.lsf
bsub < ./analysis/2-2_mapping/03_summarize_coverage.lsf
```
## Step 6
Run the 04_summarize_insertsize.lsf script to summarize mean and sd of ddRAD locus size. **This script should only be executed if step 3 is finished**.
```
dos2unix ./analysis/2-2_mapping/04_summarize_insertsize.lsf
bsub < ./analysis/2-2_mapping/04_summarize_insertsize.lsf
```
## Step 7
Tun the 05_cleanup.sh script to remove superfluous data and obtain final summary dataframes. It is not necessary (but recommended) to run this step as it only produces a summary of the mapping and removes data that are not needed in the further analysis. This script can safely be executed on a login node. **This script should only be executed if steps 1-6 are finished**.
```
dos2unix ./analysis/2-2_mapping/05_cleanup.sh
chmod +x ./analysis/2-2_mapping/05_cleanup.sh
./analysis/2-2_mapping/05_cleanup.sh
```
