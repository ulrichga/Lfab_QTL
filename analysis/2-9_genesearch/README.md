# Gene search
This part of the analysis searches for candidate genes and transcripts in the confidence region that was found in the QTLanalysis. To run this part of the analysis, execute the following steps.
## Step 1
Make sure _input files_
* The transcripts from Dennis et al. (2017) ./data/Dennis_et_al_2017/01.Lfab.Trinity.denovo.fasta
* The transcripts database from waspbase ./data/waspbase/OGS1.0_20170110_transcripts.fa
* A gff3 file of genes from waspbase ./data/waspbase/OGS1.0_20170110.gff3
* The QTL mapping table ./results/QTLanalysis/QTL_table.txt

## Step 2
Run the 00_initialize.sh script. This creates output directories and cuts the transcripts from Dennis et al. (2017) into smaller files for later processing with BLST in a batch job. It also initializes a batch job for constructing a blast database from the transcripts file (./data/waspbase/OGS1.0_20170110_transcripts.fa.) It is safe to run this script on a login node (takes ~10 seconds).
```
dos2unix ./analysis/2-9_genesearch/00_initialize.sh
chmod +x ./analysis/2-9_genesearch/00_initialize.sh
./analysis/2-9_genesearch/00_initialize.sh
```
## Step 3
R script
## Step 4
BLAST
```
dos2unix ./analysis/2-9_genesearch/02_assign_transcripts.lsf
bsub < ./analysis/2-9_genesearch/02_assign_transcripts.lsf
```
