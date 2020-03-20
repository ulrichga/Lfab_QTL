## Make sure the results directory is there
if [ ! -e ./results/linkage_mapping ]  ; then mkdir ./results/linkage_mapping ; fi

## Construct a data frame with the size of each scaffold from the reference genome
grep ">" ./data/genome/Lf_genome_V1.0.fa | awk '{print $1, $2}' | cut -d ">" -f 2 | awk '{sub(/.{4}/,"",$2)}1' > ./data/genome/scaffoldsize.txt
