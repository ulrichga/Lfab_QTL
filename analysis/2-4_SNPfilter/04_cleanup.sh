## move the files that should be kept temporarily out of the SNPfilter directory
mv ./results/SNPfilter/*.gz ./results/
mv ./results/SNPfilter/filter_summary.txt ./results/
mv ./results/SNPfilter/SNPs_n* ./results/

## Delete all files in the mv ./results/SNPfilter directory
rm ./results/SNPfilter/*

## Move the files that should be kept back to the SNPfilter directory
mv ./results/*.gz ./results/SNPfilter/
mv ./results/filter_summary.txt ./results/SNPfilter/
mv ./results/SNPs_n* ./results/SNPfilter/

## Delete lsf logfiles
rm lsf*
