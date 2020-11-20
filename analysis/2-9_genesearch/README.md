# Gene search
This part of the analysis searches for candidate genes and transcripts in the confidence region that was found in the QTLanalysis. To run this part of the analysis, execute the following steps.
## Step 1
Make sure that all input files are available.
* A gff3 file of genes from waspbase ./data/waspbase/OGS1.0_20170110.gff3
* The QTL mapping table ./results/QTLanalysis/QTL_table.txt

## Step 2
Run the 00_initialize.sh script. This creates output directories.
```
dos2unix ./analysis/2-9_genesearch/00_initialize.sh
chmod +x ./analysis/2-9_genesearch/00_initialize.sh
./analysis/2-9_genesearch/00_initialize.sh
```
## Step 3
Run the 01_find_genes.R script. This R script uses the table with lod scores ./results/QTLanalysis/QTL_table.txt and ./data/waspbase/OGS1.0_20170110.gff3 to output the file ./results/genesearch/candidate_genes.txt, which is a list of candidate genes. The list contains all genes that are on the scaffold that thouches the 95% approximate Bayes confidence region, upwards of position of the flanking marker at position 311170. Additionally it includes LOD scores of the marker closest to the midpoint of the each gene.
```
dos2unix ./analysis/2-9_genesearch/01_find_genes.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-9_genesearch/01_find_genes.R > out"
```
