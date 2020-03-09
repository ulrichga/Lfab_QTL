# Create folders for the mapping results and summary statistics.
if [ ! -e ./results/mapped ]  ; then mkdir ./results/mapped ; fi
if [ ! -e ./results/mapped/intervals ]  ; then mkdir ./results/mapped/intervals ; fi
if [ ! -e ./results/mapped/filtered_intervals ]  ; then mkdir ./results/mapped/filtered_intervals ; fi
if [ ! -e ./results/mapped/coverage ]  ; then mkdir ./results/mapped/coverage ; fi

# Make a list of samples and move it to the mapping folder.
ls ./results/demultiplexed/*.fq.gz | sed 's/.fq.gz//' | grep "\\.1" | sed 's/..$//' > ./results/mapped/samples

# Create a batch job to index the reference genome.
bsub -W 1:00 -R "rusage[mem=2000]" "module load gcc/4.8.2 gdc bwa/0.7.17
bwa index -p ./data/genome/Lf_genome_V1.0.fa -a is ./data/genome/Lf_genome_V1.0.fa"
