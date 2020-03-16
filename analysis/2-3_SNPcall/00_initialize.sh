#### Create necessary folders

## Create regions folder for the genome
if [ ! -e ./data/genome/regions ]  ; then mkdir ./data/genome/regions ; fi

## Create results folders
if [ ! -e ./results/SNPcall ]  ; then mkdir ./results/SNPcall ; fi
if [ ! -e ./results/SNPcall/vcf ]  ; then mkdir ./results/SNPcall/vcf ; fi

#### Split the genome into smaller pieces to call SNPs piecewise

## Copy the necessary scripts to ./data/genome/regions (only makes sense if running on Euler)
## The script fasta_generate_regions.py is part of the freebayes distribution and can be found here: https://github.com/ekg/freebayes/blob/master/scripts/fasta_generate_regions.py
## The script split.freebayes.regions.file.pl was provided by Niklaus Zemp (GDC).
cp /cluster/apps/gdc/freebayes/1.1.0/scripts/fasta_generate_regions.py ./data/genome/regions/
cp /cluster/project/gdc/shared/scripts/submitscripts/FREEBAYES/split.freebayes.regions.file.pl ./data/genome/regions/

## Create a batch job to split the genome into regions of 1000000 bp size
bsub -W 4:00 "module load gcc/4.8.2 gdc perl/5.18.4 samtools/1.9
samtools faidx Lf_genome_V1.0.fa
./data/genome/regions/fasta_generate_regions.py ./data/genome/Lf_genome_V1.0.fa 1000000 > ./data/genome/regions/regions.txt
./data/genome/regions/split.freebayes.regions.file.pl  ./data/genome/regions/regions.txt 1000000
mv regions_* ./data/genome/regions/"

#### Prepare SNPcalling with freebayes

## Make a list of bamfiles to process with freebayes
ls ./results/mapped/samplesQ10/*.bam > ./results/SNPcall/bamfiles.txt

## Make a .txt file indicating the population (P / F1 / F2 / CV17-84) of each individual
cat ./results/demultiplexed/samples | tr _ " " | cut -d" " -f1 > ./results/demultiplexed/pops_only
paste ./results/demultiplexed/samples ./results/demultiplexed/pops_only | column -s $'\t' -t > ./results/SNPcall/pops.txt
rm ./results/demultiplexed/pops_only

## Make a .txt file indicating the ploidy (2 for females 1 for males) of each individual
cat ./results/demultiplexed/samples | awk '{print substr($0,length,1)}' | sed 's/[0123456789f]/2/g' | sed 's/[m]/1/g' > ./results/demultiplexed/ploidy_only
paste ./results/demultiplexed/samples ./results/demultiplexed/ploidy_only | column -s $'\t' -t > ./results/SNPcall/ploidy.txt
rm ./results/demultiplexed/ploidy_only
