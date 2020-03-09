# Initialize the demultiplexing by creating necessary directories.
for pl in 1 2 3 4 5 6 9 10 11 12 13 14
do
if [ ! -e ./results/demultiplexed/pool_${pl} ]  ; then mkdir ./results/demultiplexed/pool_${pl} ; fi
done
if [ ! -e ./results/demultiplexed/pool_6/duplicates ]  ; then mkdir ./results/demultiplexed/pool_6/duplicates ; fi
if [ ! -e ./results/demultiplexed/pool_12/duplicates ]  ; then mkdir ./results/demultiplexed/pool_12/duplicates ; fi
