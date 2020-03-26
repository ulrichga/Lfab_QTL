# QTL analysis with R/qtl
To run this part of the analysis, execute the following steps. The thitel may be slightly misleading since this part does not only run QTL analysis but first it re-estimates intermarker dinstances using R/qtl to get a linkage map in cM, not in the output format of MSTmap.
## Step 1
Make sure the necessary input data are available:
* R/qtl input file ./results/prepQTL/Rqtlin_filtered.csv
* The mean genotyping error, which is found in ./results/geno_error/individual_genotype_comparisons.txt
## Step 2
Re-estimate intermarker distances by running the script 01_interdist.R.
```
dos2unix ./analysis/2-8_QTLanalysis/01_interdist.R
bsub -W 1:00 -R "rusage[mem=1000]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-8_QTLanalysis/01_interdist.R > out"
```
This script outputs five files:
* A plot of recombination fractions ./results/QTLanalysis/recombination_fractions.pdf
* A plot representing the new linkage map ./results/QTLanalysis/linkagemap.pdf
* A summary table of the new linkage map ./results/QTLanalysis/linkagemap_summary.txt
* The actual new linkage map as a table ./results/QTLanalysis/linkagemap_cM.txt
* The updated R/qtl input file ./results/QTLanalysis/Rqtlin_final.csv
