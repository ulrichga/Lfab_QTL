## move the files that should be kept temporarily out of the SNPfilter directory
mv ./results/SNPfilter/*.gz ./results/
mv ./results/SNPfilter/filter_summary.txt ./results/
mv ./results/SNPfilter/SNPs_n* ./results/
mv ./results/SNPfilter/HCBS_list ./results/

## Delete all files in the mv ./results/SNPfilter directory
rm ./results/SNPfilter/*

## Move the files that should be kept back to the SNPfilter directory
mv ./results/*.gz ./results/SNPfilter/
mv ./results/filter_summary.txt ./results/SNPfilter/
mv ./results/SNPs_n* ./results/SNPfilter/
mv ./results/HCBS_list ./results/SNPfilter/HCBS_list

## Delete lsf logfiles
rm lsf*
