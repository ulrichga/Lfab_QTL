# Linkage mapping
To perform this part of the analysis, execute the following steps.
## Step 1
Make sure the necessary raw data are available.
* The reference genome ./data/genome/Lf_genome_V1.0.fa
* List of SNPs that survived all previous filtering steps ./results/SNPfilter/HCBS_list
* Genotypes of haploid individuals ./results/SNPfilter/SNPs_n1
* Genotypes of diploid individuals (not including CV17-84 samples) ./results/SNPfilter/SNPs_n2
* The linkage map of Dennis et al. (2019) ./data/01.Linkage_groups.txt
## Step 2
Run the script 00_initialize.sh to set up a results directory and create a summary of the reference genome. This is safe to run on a login node.
```
dos2unix ./analysis/2-5_linkagemap/00_initialize.sh
chmod +x ./analysis/2-5_linkagemap/00_initialize.sh
./analysis/2-5_linkagemap/00_initialize.sh
```
## Step 3
Run the R-script 01_make_MSTinfile.R. It uses the SNP tables constructed during SNP filtering to filter markers for the following three criteria:
1. Being traceable in the F2 population. I.e. they are known in both P-generation individuals, homozygous in the P-generation mother and in an alternative state in the P-generation father.
2. Not being segregation distorted. In theory 50% of alleles in the F2 population should come from the P-generation father and 50% from the P-generation mother. Segregation distorted loci differ from this 50:50 distribution (based on chi-square test with Bonferroni correction on an alpha of 5%).
3. Being genotyped (i.e. known) in > 50% of F2 Individuals

The script then filters individuals out for which > 50% of alleles could not be assigned to maternal or paternal origin. Finally, the script outputs
* A list of SNPs that are contained in the input file for linkage mapping
* A list of individuals that are contained in the input file for linkage mapping
* The parameters for linkage mapping with MSTmap
* The input data frame for MSTmap

To run the script on the Euler cluster, do the following:
```
dos2unix ./analysis/2-5_linkagemap/01_make_MSTinfile.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-5_linkagemap/01_make_MSTinfile.R > out"
```
## Step 4
Run the 02_MSTmapping.sh script, which combines the MSTpara and MSTdata files to get an input file for MSTmap prior to running MSTmap in a batch job. It is safe to run it on a login node. **This script should only be executed if the batch job created under step 3 is finished**.
```
dos2unix ./analysis/2-5_linkagemap/02_MSTmapping.sh
chmod +x ./analysis/2-5_linkagemap/02_MSTmapping.sh
./analysis/2-5_linkagemap/02_MSTmapping.sh
```
## Step 5
Run the 03_check_linkagemap.R script. This compares the new linkage map to the earlier linkage map by Dennis et al. (2019), makes sure to use corresponding linkage group IDs and orientations and outputs two files. An edited linkage map (./results/linkage_mapping/MSToutput_edited.txt) and an additional summary file ./results/linkage_mapping/linkagemap_summary.txt. Do the following to run it on the Euler cluster. **This script should only be executed if the batch job created under step 4 is finished**.
```
dos2unix ./analysis/2-5_linkagemap/03_check_linkagemap.R
bsub -W 1:00 -R "rusage[mem=100]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-5_linkagemap/03_check_linkagemap.R > out"
```
## Step 6
Run the 04_cleanup.sh script to delete files that are not relevant in the following.
```
dos2unix ./analysis/2-5_linkagemap/04_cleanup.sh
chmod +x ./analysis/2-5_linkagemap/04_cleanup.sh
./analysis/2-5_linkagemap/04_cleanup.sh
```
