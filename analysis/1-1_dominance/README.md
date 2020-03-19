# Analysis of dominance relationships
To run this part of the analysis, either execute the R-script "01_dominance.R" on a local system or on a cluster. It requires the follwoing raw data file:
* dominance_first_gen.txt

To run it on Euler make sure your current working directory is ./Lfab_QTL and do the following:
```
dos2unix ./analysis/1-1_dominance/01_dominance.R
bsub -W 1:00 -R "rusage[mem=100]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/1-1_dominance/01_dominance.R > out"
```
