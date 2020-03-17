# SNP calling
To run this part of the analysis follow the steps described here. The analysis was executed on the Euler cluster and pulls dependencies from it. To run it on another cluster, some changes to the code may be necessary. For all the steps the current directory should be the Lfab_QTL directory.
## Step 1
Make sure the necessary raw data are are available.
* The reference genome ./data/genome/Lf_genome_V1.0.fa
* The quality filtered .bam files in ./results/mapped/samplesQ10/ that were produced during mapping.
* The samples list ./results/demultiplexed/samples that was produced during mapping.

The analysis also requires two additional scripts for splitting the reference genome which are pulled form Euler-internal repositories:
* fasta_generate_regions.py which is part of the freebayes distribution and also available on [GitHub](https://github.com/ekg/freebayes/blob/master/scripts/fasta_generate_regions.py)
* split.freebayes.regions.file.pl which was provided by Niklaus Zemp (GDC at ETH Zürich)
## Step 2
Make the 00_initialize.sh script executable and run it. This script creates the directories that are necessary for the analysis. Additionally it initiates a batch job for indexing sorted .bam files. It is safe to run this script on a login node.
```
dos2unix ./analysis/2-3_SNPcall/00_initialize.sh
chmod +x ./analysis/2-3_SNPcall/00_initialize.sh
./analysis/2-3_SNPcall/00_initialize.sh
```
## Step 3
Run the 01_index_bamfiles.lsf script to index quality filtered .bam files that were produced during mapping. **This script should only be executed if the batch job created in step 2 is finished**.
```
dos2unix ./analysis/2-3_SNPcall/01_index_bamfiles.lsf
bsub < ./analysis/2-3_SNPcall/01_index_bamfiles.lsf
```
## Step 4
Run the 02_freebayes.lsf script to call SNPs. **This script should only be executed if steps 2 and 3 are finished**.
```
dos2unix ./analysis/2-3_SNPcall/02_freebayes.lsf
bsub < ./analysis/2-3_SNPcall/02_freebayes.lsf
```
## Step 5
Run the 03_merge_vcfs.lsf script to merge the vcf files produced under step 4. The resulting raw vcf file is then compressed with gzip. **This script should only be executed if step 4 is finished**.
```
dos2unix ./analysis/2-3_SNPcall/03_merge_vcfs.lsf
bsub < ./analysis/2-3_SNPcall/03_merge_vcfs.lsf
```
## Step 6
Run the 04_cleanup.sh script to delete vcf and log files as well as directories that will not be used in further steps. This includes regions and indexing files of the reference genome. It is safe to run this on a login node. **This script should only be executed if step 5 is finished**.
```
dos2unix ./analysis/2-3_SNPcall/04_cleanup.sh
chmod +x ./analysis/2-3_SNPcall/04_cleanup.sh
./analysis/2-3_SNPcall/04_cleanup.sh
```
