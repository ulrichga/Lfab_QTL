# Initialize the demultiplexing by creating necessary directories.
for pl in 1 2 3 4 5 6 9 10 11 12 13 14
do
if [ ! -e ./results/demultiplexed/pool_${pl} ]  ; then mkdir ./results/demultiplexed/pool_${pl} ; fi
done
if [ ! -e ./results/demultiplexed/pool_6/duplicates ]  ; then mkdir ./results/demultiplexed/pool_6/duplicates ; fi
if [ ! -e ./results/demultiplexed/pool_12/duplicates ]  ; then mkdir ./results/demultiplexed/pool_12/duplicates ; fi

# Change the names of the raw read to make their handling easier.
mv ./data/rawreads/*ID_1-36*R1* ./data/rawreads/pool_1_R1.fastq.gz
mv ./data/rawreads/*ID_1-36*R2* ./data/rawreads/pool_1_R2.fastq.gz
mv ./data/rawreads/*ID_37-72*R1* ./data/rawreads/pool_2_R1.fastq.gz
mv ./data/rawreads/*ID_37-72*R2* ./data/rawreads/pool_2_R2.fastq.gz
mv ./data/rawreads/*ID_73-108*R1* ./data/rawreads/pool_3_R1.fastq.gz
mv ./data/rawreads/*ID_73-108*R2* ./data/rawreads/pool_3_R2.fastq.gz
mv ./data/rawreads/*ID_109-144*R1* ./data/rawreads/pool_4_R1.fastq.gz
mv ./data/rawreads/*ID_109-144*R2* ./data/rawreads/pool_4_R2.fastq.gz
mv ./data/rawreads/*ID_145-180*R1* ./data/rawreads/pool_5_R1.fastq.gz
mv ./data/rawreads/*ID_145-180*R2* ./data/rawreads/pool_5_R2.fastq.gz
mv ./data/rawreads/*ID_181-216*R1* ./data/rawreads/pool_6_R1.fastq.gz
mv ./data/rawreads/*ID_181-216*R2* ./data/rawreads/pool_6_R2.fastq.gz
mv ./data/rawreads/*ID_217-252*R1* ./data/rawreads/pool_13_R1.fastq.gz
mv ./data/rawreads/*ID_217-252*R2* ./data/rawreads/pool_13_R2.fastq.gz
mv ./data/rawreads/*ID_253-288*R1* ./data/rawreads/pool_14_R1.fastq.gz
mv ./data/rawreads/*ID_253-288*R2* ./data/rawreads/pool_14_R2.fastq.gz
mv ./data/rawreads/*ID_289-324*R1* ./data/rawreads/pool_9_R1.fastq.gz
mv ./data/rawreads/*ID_289-324*R2* ./data/rawreads/pool_9_R2.fastq.gz
mv ./data/rawreads/*ID_325-360*R1* ./data/rawreads/pool_10_R1.fastq.gz
mv ./data/rawreads/*ID_325-360*R2* ./data/rawreads/pool_10_R2.fastq.gz
mv ./data/rawreads/*ID_361-384*R1* ./data/rawreads/pool_11_R1.fastq.gz
mv ./data/rawreads/*ID_361-384*R2* ./data/rawreads/pool_11_R2.fastq.gz
mv ./data/rawreads/*ID_193-216*R1* ./data/rawreads/pool_12_R1.fastq.gz
mv ./data/rawreads/*ID_193-216*R2* ./data/rawreads/pool_12_R2.fastq.gz
