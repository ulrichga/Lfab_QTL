# Lfab_QTL
This repository is part of a research project on the genomic architecture of symbiont-conferred resistance in _Lysiphlebus fabarum_. The purpose of this repository is to provide a reproducible analysis pipeline for for this project. A version of it will be available on Dryad and one is available on [GitHub](https://github.com/ulrichga/Lfab_QTL).

## General info
The scripts of these analyses are optimized to run on the [ETH Euler cluster](https://scicomp.ethz.ch/wiki/Euler). Reproducing the analysis on Euler should therefore work smoothly, while adaptation for other platforms may require modification of the scripts. All scripts assume that your current directory is Lfab_QTL.

## Reproducing the analysis
To reproduce these analyses do the following:
1. Copy the Lfab_QTL directory to a system where you want to reproduce the analyses (preferentially Euler or a similar HPC cluster).
2. Make sure you have the necessary raw data available in ./data and/or ./results (For an overview of these files, see [Required files](https://github.com/ulrichga/Lfab_QTL#Required-files)).
3. Run the analyses by follwing the steps described in the README.md files (For the correct order of README.md files, see [Manuals to follow](https://github.com/ulrichga/Lfab_QTL#Manuals-to-follow))

### Required files
The analysis can only be reproduced if the required raw data are available in an additional directory within Lfab_QTL. The multiplexed raw reads that would be used to reproduce the demuliplexing are not publicly available. The following list includes all raw data that can be used to reproduce analyses. Some are not publicly available.
#### Included own datasets
* ./data/dominance_first_gen.txt (raw data from the first experiment on dominance relationships)
* ./data/dominance_second_gen.txt (raw data from the first experiment on dominance relationships)
* ./data/barcodes/barcodes_pool_\*.txt (12 files with barcodes for each sequenced individual, used for demultiplexing)
* ./data/crossing_data/\*.txt (raw data from the second experiment, 4 files with information on wasp crossing for QTL mapping)
#### Available own datasets
* ./results/demultiplexed/\*.fq.gz (These 384 files of demultiplexed Illumina raw reads from 384 wasp samples are available under PRJEB39724 in the [European Nucleotide Archive](https://www.ebi.ac.uk/ena/browser/home))
#### Currently not publicly available
* ./data/rawreads/20191118.A-GU_ddRAD_ID_\*.fastq.gz (These 24 files of undemultiplexed Illumina raw reads from 384 wasp samples are only necessary to reproduce the demultiplexing)
* ./data/genome/regions/split.freebayes.regions.file.pl (script used to generate genomic regions prior to SNP calling)
#### Available from other authors
* ./data/01.Linkage_groups.txt ([additional file 3](https://static-content.springer.com/esm/art%3A10.1186%2Fs12864-020-6764-0/MediaObjects/12864_2020_6764_MOESM3_ESM.xlsx) from [Dennis et al. (2020)](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-020-6764-0), in tab-separated txt-file format)
* ./data/genome/Lf_genome_V1.0.fa (reference genome described in [Dennis et al. (2020)](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-020-6764-0) and available on [bipaa](https://bipaa.genouest.org/sp/lysiphlebus_fabarum/download/genome/v1.0/))
* ./data/waspbase/OGS1.0_20170110.gff3 (annotations from [bipaa](https://bipaa.genouest.org/sp/lysiphlebus_fabarum/download/annotation/v1.0/))
* ./data/genome/regions/fasta_generate_regions.py (script from the freebayes distribution [(Garrison and Marth 2012)](https://arxiv.org/abs/1207.3907) available on [GitHub](https://github.com/ekg/freebayes/blob/master/scripts/fasta_generate_regions.py))

### Additional files
The following files (results) are additionally included to aid reproducibility and use of the data.
* ./results/QTLanalysis/linkagemap_cM.txt (linkage map / distance matrix with mapping unit in cM)
* ./results/QTLanalysis/Rqtlin_final.csv (table with genotypes and phenotypes used for the QTL analysis with the script ./analysis/2-8_QTLanalysis/02_QTL_mapping.R)
* ./results/genesearch/candidate_genes.txt (table with genes in the candidate region)

### Manuals to follow
The descriptions in the following README.md files should be executed in the following order:
1. ./analysis/1-1_dominance/README.md
2. ./analysis/2-1_demultiplex/README.md (Can be skipped. Requires undemultiplexed raw reads which are not publicly available)
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
