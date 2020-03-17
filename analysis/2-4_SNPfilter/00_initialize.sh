## Create a directory for SNP filtering results
if [ ! -e ./results/SNPfilter ]  ; then mkdir ./results/SNPfilter ; fi

## Use the ploidy file to create lists of haploid and diploid individuals
more ./results/SNPcall/ploidy.txt | grep " 2" | awk '{print $1}' > ./results/SNPfilter/diploids
more ./results/SNPcall/ploidy.txt | grep " 1" | awk '{print $1}' > ./results/SNPfilter/haploids
grep "CV" ./results/SNPfilter/diploids > ./results/SNPfilter/control

## Separate the vcf file into two files, one for diploids, one for haploids
## Make a batch job for each of the two steps
bsub -W 1:00 -R "rusage[mem=2200]" -J separate_diploids "module load gcc/4.8.2 gdc perl/5.18.4 zlib/1.2.8 vcftools/0.1.16
vcftools --gzvcf ./results/SNPcall/raw.vcf.gz --keep ./results/SNPfilter/diploids --recode --recode-INFO-all --out ./results/SNPfilter/n2"
bsub -W 1:00 -R "rusage[mem=7000]" -J separate_haploids "module load gcc/4.8.2 gdc perl/5.18.4 zlib/1.2.8 vcftools/0.1.16
vcftools --gzvcf ./results/SNPcall/raw.vcf.gz --keep ./results/SNPfilter/haploids --recode --recode-INFO-all --out ./results/SNPfilter/n1"
