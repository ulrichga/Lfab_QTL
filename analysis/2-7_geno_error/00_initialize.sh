## Create an output directory
if [ ! -e ./results/geno_error ]  ; then mkdir ./results/geno_error ; fi

## Start a batch job to reduce the vcf file with control individuals to only the
## 1835 SNPs that are used in the QTL mapping
bsub -W 1:00 -R "rusage[mem=20]" -J filter_control "module load gcc/4.8.2 gdc perl/5.18.4 zlib/1.2.8 vcftools/0.1.16
vcftools --gzvcf ./results/SNPfilter/n2.control.hcbs.recode.vcf.gz --positions ./results/prepQTL/QTL_markers --recode --recode-INFO-all --out ./results/geno_error/control_QTL_markers"
