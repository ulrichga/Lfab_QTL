# Estimating genotyping error rate
To run this part of the analysis execute the following steps.
## Step 1
Make sure the necessary input data are available
* The gzvcf file with control individuals and filtered SNPs ./results/SNPfilter/n2.control.hcbs.recode.vcf.gz
* The list of SNPs that will be used for QTL mapping ./results/prepQTL/QTL_markers
## Step 2
Initialize the analysis by running 00_initialize.sh. This script creates the output directory ./results/geno_error and runs a batch job to filter the SNPs in the vcf file with control individuals to keep only those that are used for QTL mapping. The new vcf file is saved as ./results/geno_error/control_QTL_markers.recode.vcf.
```
dos2unix ./analysis/2-7_geno_error/00_initialize.sh
chmod +x ./analysis/2-7_geno_error/00_initialize.sh
./analysis/2-7_geno_error/00_initialize.sh
```
## Step 3
Create a SNP table from the new vcf file by running 01_SNPtable.lsf. The script creates the SNP table ./results/geno_error/ctrlSNPs_n2. **This should only be executed if the batch job created under step 2 is completed**.
```
dos2unix ./analysis/2-7_geno_error/01_SNPtable.lsf
bsub < ./analysis/2-7_geno_error/01_SNPtable.lsf
```
## Step 4
Run the 02_estimate_geno_error.R script. This script commpares the genotpyes of CV17-84 control individuals. It creates two output tables. The output file ./results/geno_error/all_genotype_comparisons.txt contains all pairwise coparisons and the fraction of matches and mismatches. The output file ./results/geno_error/all_genotype_comparisons.txt contains the mean fraction of matches and mismatches per control individual and an overall mean. **This should only be executed if step 3 is completed**.
```
dos2unix ./analysis/2-7_geno_error/02_estimate_geno_error.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-7_geno_error/02_estimate_geno_error.R > out"
```
## Step 5
Run the 03_cleanup.sh script to remove superfluous files. This removes lsf-logfiles, R-console output and vcf files that will no longer be used. **This should only be executed if step 4 is completed**.
```
dos2unix ./analysis/2-7_geno_error/03_cleanup.sh
chmod +x ./analysis/2-7_geno_error/03_cleanup.sh
./analysis/2-7_geno_error/03_cleanup.sh
```
