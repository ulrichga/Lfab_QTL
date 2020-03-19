# Linkage mapping
To perform this part of the analysis, execute the following steps
## Step 1
Run the R-script 00_make_MSTinfile.R. It uses the SNP tables constructed during SNP filtering to filter markers for the following three criteria:
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
dos2unix ./analysis/2-5_linkagemap/00_make_MSTinfile.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-5_linkagemap/00_make_MSTinfile.R > out"
```
## Step 2
Run the 01_MSTmapping.sh script, which combines the MSTpara and MSTdata files to get an input file for MSTmap prior to running MSTmap in a batch job.
```
dos2unix ./analysis/2-5_linkagemap/01_MSTmapping.sh
chmod +x ./analysis/2-5_linkagemap/01_MSTmapping.sh
./analysis/2-5_linkagemap/01_MSTmapping.sh
```
