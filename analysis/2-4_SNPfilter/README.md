# SNP filtering
To run this part of the analysis follow the steps described here. The analysis was executed on the Euler cluster and pulls dependencies from it. To run it on another cluster, some changes to the code may be necessary. For all the steps the current directory should be the Lfab_QTL directory.
## Step 1
Make sure the necessary raw data are are available.
* gzipped raw vcf file ./results/SNPcall/raw.vcf
* txt file indicating ploidy of individuals ./results/SNPcall/ploidy.txt
## Step 2
Make the 00_initialize.sh script executable and run it. This script creates the directories that are necessary for the analysis.
```
dos2unix ./analysis/2-4_SNPfilter/00_initialize.sh
chmod +x ./analysis/2-4_SNPfilter/00_initialize.sh
./analysis/2-4_SNPfilter/00_initialize.sh
```
## Step 3
Filter the diploid dataset (mostly) following the [dDocent filtering tutorial](https://www.ddocent.com/filtering/) with minor adaptations. To do so, run the script 01_SNPfilter.lsf. The obtained high-confidence biallelic SNPs are kept in the haploid and diploid samples as well as in the control individuals. **This script should only be executed if the batch jobs created under step 2 are finished**.
```
dos2unix ./analysis/2-4_SNPfilter/01_SNPfilter.lsf
bsub < ./analysis/2-4_SNPfilter/01_SNPfilter.lsf
```
In this step the following important files are produced:
* ./results/SNPfilter/n2.control.hcbs.recode.vcf - a vcf with high-confidence biallelic SNPs (HCBS) and all CV17-84 individuals. This will later be used to estimate genotyping error rate
* ./results/SNPfilter/n2.samples.hcbs.recode.vcf - a vcf with HCBS and all diploid sample individuals
* ./results/SNPfilter/n1.samples.hcbs.recode.vcf - a vcf with HCBS and all haploid sample individuals
* ./results/SNPfilter/HCBS_list - a list of all HCBS that are kept after filtering polymorphic sites in the diploid dataset
_This script is under construction..._
