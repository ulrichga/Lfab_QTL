## Combine the parameters and the dataset to make an input data frame for MSTmap
dos2unix ./results/linkage_mapping/MSTpara
dos2unix ./results/linkage_mapping/MSTdata
cat ./results/linkage_mapping/MSTpara <(echo) ./results/linkage_mapping/MSTdata > ./results/linkage_mapping/MSTinput.txt

## Run MSTmap with the MSTinput.txt file
bsub -W 1:00 -J MSTmapping -R "rusage[mem=100]" "/cluster/project/gdc/shared/tools/MSTmap/MSTmap ./results/linkage_mapping/MSTinput.txt ./results/linkage_mapping/MSToutput.txt"
