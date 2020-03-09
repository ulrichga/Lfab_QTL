# Remove the err.* and log.* files.
rm err.*
rm log.*

# Remove the removed (*.rem.*) and unidentified (NA_*) reads from each pool.
for pl in 1 2 3 4 5 6 9 10 11 12 13 14
do
rm ./results/demultiplexed/pool_${pl}/*.rem.*
rm ./results/demultiplexed/pool_${pl}/NA_*
done

# Some samples are present in pool_6 AND pool_12. Those are moved in a separate directory within pool_6 and pool_12 respectively.
for name in F2_295_m F2_296_m F2_297_m F2_298_m F2_299_m F2_300_m F1_57_f F2_301_m F2_302_m F2_303_m F2_304_m F2_305_m CV17-84_6 F2_306_m F2_307_m F2_308_m F2_309_m F2_310_m F2_311_m F2_312_m F2_313_m F2_314_m F2_315_m F2_316_m
do
mv ./results/demultiplexed/pool_6/${name}* ./results/demultiplexed/pool_6/duplicates/
mv ./results/demultiplexed/pool_12/${name}* ./results/demultiplexed/pool_12/duplicates/
done

# Move all individual *.fq.gz files to ./results/demultiplexed/, except the duplicates.
for pl in 1 2 3 4 5 6 9 10 11 12 13 14
do
mv ./results/demultiplexed/pool_${pl}/*.fq.gz ./results/demultiplexed/
done

# Merge and move the duplicate individuals.
for name in F2_295_m F2_296_m F2_297_m F2_298_m F2_299_m F2_300_m F1_57_f F2_301_m F2_302_m F2_303_m F2_304_m F2_305_m CV17-84_6 F2_306_m F2_307_m F2_308_m F2_309_m F2_310_m F2_311_m F2_312_m F2_313_m F2_314_m F2_315_m F2_316_m
do
cat ./results/demultiplexed/pool_6/duplicates/${name}.1.fq.gz ./results/demultiplexed/pool_12/duplicates/${name}.1.fq.gz > ./results/demultiplexed/${name}.1.fq.gz
cat ./results/demultiplexed/pool_6/duplicates/${name}.2.fq.gz ./results/demultiplexed/pool_12/duplicates/${name}.2.fq.gz > ./results/demultiplexed/${name}.2.fq.gz
done

# Remove log files from each pool.
for pl in 1 2 3 4 5 6 9 10 11 12 13 14
do
rm ./results/demultiplexed/pool_${pl}/*.log
done

# Remove pool directories and the duplicates directories within. For the duplicates directries, also delete contents.
rm ./results/demultiplexed/pool_6/duplicates/*
rmdir ./results/demultiplexed/pool_6/duplicates
rm ./results/demultiplexed/pool_12/duplicates/*
rmdir ./results/demultiplexed/pool_12/duplicates
rmdir results/demultiplexed/pool_1
rmdir results/demultiplexed/pool_2
rmdir results/demultiplexed/pool_3
rmdir results/demultiplexed/pool_4
rmdir results/demultiplexed/pool_5
rmdir results/demultiplexed/pool_6
rmdir results/demultiplexed/pool_9
rmdir results/demultiplexed/pool_10
rmdir results/demultiplexed/pool_11
rmdir results/demultiplexed/pool_12
rmdir results/demultiplexed/pool_13
rmdir results/demultiplexed/pool_14

# Rename the raw reads such that they are as before the demultiplexing.
mv ./data/rawreads/pool_1_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_1-36_S1_R1.fastq.gz
mv ./data/rawreads/pool_1_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_1-36_S1_R2.fastq.gz
mv ./data/rawreads/pool_2_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_37-72_S2_R1.fastq.gz
mv ./data/rawreads/pool_2_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_37-72_S2_R2.fastq.gz
mv ./data/rawreads/pool_3_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_73-108_S3_R1.fastq.gz
mv ./data/rawreads/pool_3_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_73-108_S3_R2.fastq.gz
mv ./data/rawreads/pool_4_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_109-144_S4_R1.fastq.gz
mv ./data/rawreads/pool_4_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_109-144_S4_R2.fastq.gz
mv ./data/rawreads/pool_5_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_145-180_S5_R1.fastq.gz
mv ./data/rawreads/pool_5_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_145-180_S5_R2.fastq.gz
mv ./data/rawreads/pool_6_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_181-216_S6_R1.fastq.gz
mv ./data/rawreads/pool_6_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_181-216_S6_R2.fastq.gz
mv ./data/rawreads/pool_13_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_217-252_S7_R1.fastq.gz
mv ./data/rawreads/pool_13_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_217-252_S7_R2.fastq.gz
mv ./data/rawreads/pool_14_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_253-288_S8_R1.fastq.gz
mv ./data/rawreads/pool_14_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_253-288_S8_R2.fastq.gz
mv ./data/rawreads/pool_9_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_289-324_S9_R1.fastq.gz
mv ./data/rawreads/pool_9_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_289-324_S9_R2.fastq.gz
mv ./data/rawreads/pool_10_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_325-360_S10_R1.fastq.gz
mv ./data/rawreads/pool_10_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_325-360_S10_R2.fastq.gz
mv ./data/rawreads/pool_11_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_361-384_S11_R1.fastq.gz
mv ./data/rawreads/pool_11_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_361-384_S11_R2.fastq.gz
mv ./data/rawreads/pool_12_R1.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_193-216_S12_R1.fastq.gz
mv ./data/rawreads/pool_12_R2.fastq.gz ./data/rawreads/20191118.A-GU_ddRAD_ID_193-216_S12_R2.fastq.gz
