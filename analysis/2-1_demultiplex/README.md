# Demultiplexing
To run this part of the analysis follow the steps described here. The analysis was executed on the Euler cluster and pulls dependencies from it. To run it on other cluster, some changes to the code may be necessary. For all the steps you should be in the Lfab_QTL directory.
## Step 1
Make sure the necessary raw data are available:
* The rawreads in ./data/rawreads/
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_1-36_S1_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_1-36_S1_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_37-72_S2_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_37-72_S2_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_73-108_S3_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_73-108_S3_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_109-144_S4_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_109-144_S4_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_145-180_S5_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_145-180_S5_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_181-216_S6_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_181-216_S6_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_217-252_S7_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_217-252_S7_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_253-288_S8_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_253-288_S8_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_289-324_S9_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_289-324_S9_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_325-360_S10_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_325-360_S10_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_361-384_S11_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_361-384_S11_R2.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_193-216_S12_R1.fastq.gz
  * ./data/rawreads/20191118.A-GU_ddRAD_ID_193-216_S12_R2.fastq.gz
* The individual barcodes for each pool
  * ./data/barcodes/barcodes_pool_1.txt
  * ./data/barcodes/barcodes_pool_2.txt
  * ./data/barcodes/barcodes_pool_3.txt
  * ./data/barcodes/barcodes_pool_4.txt
  * ./data/barcodes/barcodes_pool_5.txt
  * ./data/barcodes/barcodes_pool_6.txt
  * ./data/barcodes/barcodes_pool_9.txt
  * ./data/barcodes/barcodes_pool_10.txt
  * ./data/barcodes/barcodes_pool_11.txt
  * ./data/barcodes/barcodes_pool_12.txt
  * ./data/barcodes/barcodes_pool_13.txt
  * ./data/barcodes/barcodes_pool_14.txt
Note that it is not a mistake that pools 7 and 8 are missing. This is an artefact of the naming scheme in the wetlab.
## Step 2
Make the 00_initialize.sh script executable and run it. This script creates the directories that are necessary for the analysis. It is safe to run this script on a login node.
```
dos2unix ./analysis/2-1_demultiplex/00_initialize.sh
chmod +x ./analysis/2-1_demultiplex/00_initialize.sh
./analysis/2-1_demultiplex/00_initialize.sh
```
## Step 3
Run the 01_demultiplexing.lsf script. This script performs the demultiplexing of the raw reads using the *process_radtags* function of the STACKS package.
```
dos2unix ./analysis/2-1_demultiplex/01_demultiplexing.lsf
bsub < ./analysis/2-1_demultiplex/01_demultiplexing.lsf
```
## Step 4
Run the 02_cleanup.sh script. This script moves all the individual fastq files to ./results/demultiplexed. It also merges samples that were contained in multiple pools and removes barcodes that could not be allocated to individual samples. It is safe to run this script on a login node. It is necessary to **wait until the .lsf script of step 3 is completely done** before running step 4.
```
dos2unix ./analysis/2-1_demultiplex/02_cleanup.sh
chmod +x ./analysis/2-1_demultiplex/02_cleanup.sh
./analysis/2-1_demultiplex/02_cleanup.sh
```
