# Parepare input for QTL-analysis with R/qtl
To run this part of the analysis execute the following steps.
## Step 1
Make sure the necessary input data are available _(this List is incomplete)_
* Phenotype data ./data/crossing_data/F3_colonies_25-04-2019.txt
* The MSTinput file ./results/linkage_mapping/MSTinput.txt
## Step 2
Install the R-packages that are necessary for this analysis. The following R-packages will be used:
* [pscl](https://github.com/atahk/pscl/) (Jackman, 2020)
* [mpath](https://CRAN.R-project.org/package=mpath) (Wang, 2020)
* [qtl](https://doi.org/10.1093/bioinformatics/btg112) (Broman et al., 2003)

If running the analysis on Euler, these are not pre-installed. To install them, do the following:
1. Start an interactive job by typing
```
bsub -W 1:00 -Is bash
```
2. Once the interactive job is running, type
```
module load new gcc/4.8.2 r/3.5.1
R
install.packages(c("pscl", "mpath", "qtl"))
```
3. Type **y** if the following warning appears:
```
Warning in install.packages(c("pscl", "mpath", "qtl")) :
  'lib = "/cluster/apps/r/3.5.1_openblas/x86_64/lib64/R/library"' is not writable
Would you like to use a personal library instead? (yes/No/cancel)
```
4. Type **y** if being asked:
```
Would you like to create a personal library
‘~/R/x86_64-slackware-linux-gnu-library/3.5’
to install packages into? (yes/No/cancel)
```
5. After being notified that the installation is done, leave the R-session and exit the interactive job by typing:
```
q()
exit
```
## Step 3
Run the 01_reduce_phenotypes.R script. This scripts saves an edited version of the raw phenotype data (./data/mapping_crosses/F3_colonies_25-04-2019).
```
dos2unix ./analysis/2-6_prepQTL/01_reduce_phenotypes.R
bsub -W 1:00 -R "rusage[mem=100]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-6_prepQTL/01_reduce_phenotypes.R > out"
```
It performs the following tasks:
1. Removing phenotype data that are not used in the analysis (e.g. plant sowing date)
2. Simplifying some factorial variables (e.g. discriminating between only two factors for female_location by replacing it with any_in_tube indicating with a two-level-factor, whether one or more wasps were still in the tube at the time when wasps were removed)
3. Removing phenotypes for which no genotype data were obtained
4. Merging duplicate observations.

The resulting phenotype data frame is saved as ./results/prepQTL/phenotypes_reduced.txt
## Step 4
Run the 02_analyse_phenotypes.R script. This script is used to calculate a corrected phenotype variable. A new version of the phenotype data is then saved as ./results/prepQTL/phenotypes_corrected.txt. It additionally outputs a summary of the model used to calculate the residuals which are considered corrected phenotype as ./results/prepQTL/zeroinfl_model.
```
dos2unix ./analysis/2-6_prepQTL/02_analyse_phenotypes.R
bsub -W 1:00 -R "rusage[mem=300]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-6_prepQTL/02_analyse_phenotypes.R > out"
```
## Step 5
Run the 03_make_Rqtl_input.R script. This script uses the edited linkage map, the input file for MSTmap (MSTinput.txt) and the corrected phenotypes to make an input file that can be used for analysis with R/qtl (./results/prepQTL/Rqtlin.csv).
```
dos2unix ./analysis/2-6_prepQTL/03_make_Rqtl_input.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-6_prepQTL/03_make_Rqtl_input.R > out"
```
