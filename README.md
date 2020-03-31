# Lfab_QTL
This repository is part of a research project on the genomic architecture of symbiont-conferred resistance in _Lysiphlebus fabarum_. The purpose of this repository is to provide a reproducible analysis pipeline for for this project. The manuscript and results of this analysis will be sent for publication during 2020. More information will be included here upon publication.

## General info
The scripts of these analyses are optimized to run on the [ETH Euler cluster](https://scicomp.ethz.ch/wiki/Euler). Reproducing the analysis on Euler should therefore work smoothly, while adaptation for other platforms may require modification of the scripts. All scripts assume that your current directory is Lfab_QTL. Therefore, all scripts and README.md files refer to a file within Lfab_QTL as "./file".

## Reproducing the analysis
To reproduce these analyses do the following:
1. Copy the Lfab_QTL directory to a system where you want to reproduce the analyses (preferentially Euler or a similar HPC cluster).
2. Make sure you have the necessary raw data available in a directory called ./data (For an overview of these files, see [Required data](https://github.com/ulrichga/Lfab_QTL#Required-data)).
3. Run the analyses by follwing the steps described in the README.md files (For the correct order of README.md files, see [Manuals to follow](https://github.com/ulrichga/Lfab_QTL#Manuals-to-follow))

### Required data
The analysis can only be reproduced if the required raw data are available in an additional directory within Lfab_QTL, called ./data. Most of the raw data are currently **not** publicly available. However, they will be at some point. Here is an overview of the raw data required:
* ./data/01.Linkage_groups.txt (from [Dennis et al. (2020, preprint)](https://www.biorxiv.org/content/10.1101/841288v1.full.pdf), provided by Alice Dennis)
* ./data/dominance_first_gen.txt (own raw data; obtained in the first experiment on dominance relationships)
* ./data/dominance_second_gen.txt (own raw data; obtained in the first experiment on dominance relationships)
* ./data/barcodes/barcodes_pool_*.txt (own raw data; 12 files with bardoces for each sequenced individual)
* ./data/crossing_data/\*.txt (own raw data; 4 files obtained in the mapping experiment)
* ./data/Dennis_et_al_2017/01.Lfab.Trinity.denovo.fasta (transcripts from [Dennis et al. (2017)](https://onlinelibrary.wiley.com/doi/pdf/10.1111/evo.13333))
* ./data/Dennis_et_al_2017/evo13333-sup-0005-datas2.H76vsH-\_comparison (comparisons of transcript expression between H76 and H- adapted wasp lines from [Dennis et al. (2017)](https://onlinelibrary.wiley.com/doi/pdf/10.1111/evo.13333))
* ./data/genome/Lf_genome_V1.0.fa (reference genome described in [Dennis et al. (2020, preprint)](https://www.biorxiv.org/content/10.1101/841288v1.full.pdf))
* ./data/rawreads/20191118.A-GU_ddRAD_ID_*.fastq.gz (own raw data; 24 files of Illumina sequences from 384 wasp samples)
* ./data/waspbase/OGS1.0_20170110.gff3 (annotations from [waspbase](http://www.insect-genome.com/waspbase/))
* ./data/waspbase/OGS1.0_20170110_transcripts.fa (transcripts from [waspbase](http://www.insect-genome.com/waspbase/))

### Manuals to follow
The descriptions in the following README.md files should be executed in the following order:
1. ./analysis/1-1_dominance/README.md
2. ./analysis/2-1_demultiplex/README.md
3. ./analysis/2-2_mapping/README.md
4. ./analysis/2-3_SNPcall/README.md
5. ./analysis/2-4_SNPfilter/README.md
6. ./analysis/2-5_linkagemap/README.md
7. ./analysis/2-6_prepQTL/README.md
8. ./analysis/2-7_geno_error/README.md
9. ./analysis/2-8_QTLanalysis/README.md
10. ./analysis/2-9_genesearch/README.md

### Results
By follwing the descriptions in the README.md files, results will be created. They will be located in a ./results directory.
