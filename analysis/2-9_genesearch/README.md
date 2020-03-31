# Gene search
This part of the analysis searches for candidate genes and transcripts in the confidence region that was found in the QTLanalysis. To run this part of the analysis, execute the following steps.
## Step 1
Make sure that all input files are available.
* The transcripts from Dennis et al. (2017) ./data/Dennis_et_al_2017/01.Lfab.Trinity.denovo.fasta
* The table of expression fold change for the transcripts from Dennis et al. (2017) ./data/Dennis_et_al_2017/evo13333-sup-0005-datas2.H76vsH-\_comparison.txt (comparison between the H76 and H- adapted wasps when reared on H- aphids).
* The transcripts database from waspbase ./data/waspbase/OGS1.0_20170110_transcripts.fa
* A gff3 file of genes from waspbase ./data/waspbase/OGS1.0_20170110.gff3
* The QTL mapping table ./results/QTLanalysis/QTL_table.txt

## Step 2
Run the 00_initialize.sh script. This creates output directories and cuts the transcripts from Dennis et al. (2017) into smaller files for later processing with BLST in a batch job. It also initializes a batch job for constructing a blast database from the transcripts file (./data/waspbase/OGS1.0_20170110_transcripts.fa.) It is safe to run this script on a login node (takes a few seconds).
```
dos2unix ./analysis/2-9_genesearch/00_initialize.sh
chmod +x ./analysis/2-9_genesearch/00_initialize.sh
./analysis/2-9_genesearch/00_initialize.sh
```
## Step 3
Run the 01_find_genes.R script. This R script uses the table with lod scores ./results/QTLanalysis/QTL_table.txt and ./data/waspbase/OGS1.0_20170110.gff3 to output the file ./results/genesearch/candidate_genes.txt, which is a list of candidate genes. The list contains all genes that are on the scaffolds that thouch the 95% approximate Bayes confidence region for QTL location. Additionally it includes LOD scores of the marker closest to the midpoint of the each gene.
```
dos2unix ./analysis/2-9_genesearch/01_find_genes.R
bsub -W 1:00 -R "rusage[mem=200]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-9_genesearch/01_find_genes.R > out"
```
## Step 4
Run the 02_assign_transcripts.lsf script. This initializes a job array to assign gene IDs to the transcripts from Dennis et al. (2017). The output is saved as 80 tab-separated tables in ./results/genesearch. **This should only be executed, if step 2 is finished**.
```
dos2unix ./analysis/2-9_genesearch/02_assign_transcripts.lsf
bsub < ./analysis/2-9_genesearch/02_assign_transcripts.lsf
```
## Step 5
Run the 03_find_transcripts.R script. This filters the transcripts in ./data/Dennis_et_al_2017/evo13333-sup-0005-datas2.H76vsH-\_comparison.txt to output those that correspond to genes on scaffolds touching the confidence regions. The output ./results/genesearch/candidate_transcripts.txt contains additional information for each transcript that is also contained in ./results/genesearch/candidate_genes.txt. The script uses the assignments made in step 4 as well as the list of candidate genes made in step 3. An additional output of this script is ./results/genesearch/transcripts_vs_OGS.txt, which is simply the combination of the tables produced in step 2. **This should only be executed, if steps 3 and 4 are finished**.
```
dos2unix ./analysis/2-9_genesearch/03_find_transcripts.R
bsub -W 1:00 -R "rusage[mem=250]" "module load new gcc/4.8.2 r/3.5.1
R --vanilla --slave < ./analysis/2-9_genesearch/03_find_transcripts.R > out"
```
## Step 6
Run the 04_cleanup.sh script. This removes intermediate files and directories, like logfiles and .tab files created in step 2. Also the fragments of ./data/waspbase/OGS1.0_20170110_transcripts.fa are removed. It is safe to run this on a login node. **This should only be executed, if step 5 is finished**.
```
dos2unix ./analysis/2-9_genesearch/04_cleanup.sh
chmod +x ./analysis/2-9_genesearch/04_cleanup.sh
./analysis/2-9_genesearch/04_cleanup.sh
```
