## Cleanup script after mapping + summary. This is under construction.

#### Obtain a summary dataframe of the mapping

## Create a file with rownames
more ./results/mapped/stats/stat_total.txt | awk -F" " '{print $1}' | awk -F"/" '{print $5}' | sed 's/_stat//' > name
echo "MEAN" >> name
echo "TOTAL" >> name
echo "SHARED_25%" >> name
echo "SHARED_50%" >> name
echo "SHARED_75%" >> name
echo "SHARED_90%" >> name
echo "SHARED_99%" >> name

## Create files with mapping statistics (each file is a variable)
more ./results/mapped/stats/stat_total.txt | awk -F" " '{print $2}' > reads_total
more ./results/mapped/stats/stat_mapped.txt | awk -F" " '{print $2}' > reads_mapped
more ./results/mapped/statsQ10/statQ10_mapped.txt | awk -F" " '{print $2}' > reads_mappedQ10
paste reads_total reads_mappedQ10 | awk '{print($2/$1*100)}' > %_mapped_Q10
more ./results/mapped/samplesQ10/insertsize_avg.txt | awk -F"\t" '{print $3}' > ins_size_avg
more ./results/mapped/samplesQ10/insertsize_sd.txt | awk -F"\t" '{print $3}' > ins_size_sd
more ./results/mapped/filtered_intervals_cov3_summary.txt | awk -F" " '{print $1}' > intervals_cov3
more ./results/mapped/filtered_intervals_cov6_summary.txt | awk -F" " '{print $1}' > intervals_cov6
more ./results/mapped/filtered_intervals_cov10_summary.txt | awk -F" " '{print $1}' > intervals_cov10
more ./results/mapped/filtered_intervals_cov15_summary.txt | awk -F" " '{print $1}' > intervals_cov15

## Remove the last entry of each coverage-variable
sed -i '$ d' intervals_cov3
sed -i '$ d' intervals_cov6
sed -i '$ d' intervals_cov10
sed -i '$ d' intervals_cov15

## Calculate means for each of the variables and append to the end of the file
more reads_total | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_total
more reads_mapped | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_mapped
more reads_mappedQ10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_mappedQ10
more %_mapped_Q10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> %_mapped_Q10
more ins_size_avg | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> ins_size_avg
more ins_size_sd | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> ins_size_sd
more intervals_cov3 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov3
more intervals_cov6 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov6
more intervals_cov10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov10
more intervals_cov15 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov15

## Append empty entries to the end of each variable for which we do not have an entry in TOTAL and SHARED_XX%
echo -en '\n \n \n \n \n \n ' >> reads_total
echo -en '\n \n \n \n \n \n ' >> reads_mapped
echo -en '\n \n \n \n \n \n ' >> reads_mappedQ10
echo -en '\n \n \n \n \n \n ' >> %_mapped_Q10
echo -en '\n \n \n \n \n \n ' >> ins_size_avg
echo -en '\n \n \n \n \n \n ' >> ins_size_sd

## Append shared filtered intervals to the end of each coverage-variable
more ./results/mapped/filtered_intervals/shared_filtered_intervals_cov3_summary.txt | awk -F" " '{print $1}' >> intervals_cov3
more ./results/mapped/filtered_intervals/shared_filtered_intervals_cov6_summary.txt | awk -F" " '{print $1}' >> intervals_cov6
more ./results/mapped/filtered_intervals/shared_filtered_intervals_cov10_summary.txt | awk -F" " '{print $1}' >> intervals_cov10
more ./results/mapped/filtered_intervals/shared_filtered_intervals_cov15_summary.txt | awk -F" " '{print $1}' >> intervals_cov15

## Append the SHARED_XX% statistics to the end of each coverage-variable
more ./results/mapped/filtered_intervals/sharedonly_filtered_intervals_summary.txt | grep cov3 | awk -F" " '{print $1}' >> intervals_cov3
more ./results/mapped/filtered_intervals/sharedonly_filtered_intervals_summary.txt | grep cov6 | awk -F" " '{print $1}' >> intervals_cov6
more ./results/mapped/filtered_intervals/sharedonly_filtered_intervals_summary.txt | grep cov10 | awk -F" " '{print $1}' >> intervals_cov10
more ./results/mapped/filtered_intervals/sharedonly_filtered_intervals_summary.txt | grep cov15 | awk -F" " '{print $1}' >> intervals_cov15

## Paste the summary statistics together to have a single summary data frame.
paste name reads_total reads_mapped reads_mappedQ10 %_mapped_Q10 ins_size_avg ins_size_sd intervals_cov3 intervals_cov6 intervals_cov10 intervals_cov15 > ./results/mapped/mapping_summary.txt

## Remove the intermediary files
rm name reads_total reads_mapped reads_mappedQ10 %_mapped_Q10 ins_size_avg ins_size_sd intervals_cov3 intervals_cov6 intervals_cov10 intervals_cov15

#### Delete unnecessary folders and contents

## Remove folder contents
rm ./results/mapped/coverage/*
rm ./results/mapped/filtered_intervals/*
rm ./results/mapped/intervals/*
rm ./results/mapped/samples/*
rm ./results/mapped/stats/*
rm ./results/mapped/statsQ10/*

## Remove empty directories
rmdir ./results/mapped/coverage
rmdir ./results/mapped/filtered_intervals
rmdir ./results/mapped/intervals
rmdir ./results/mapped/samples
rmdir ./results/mapped/stats
rmdir ./results/mapped/statsQ10

## Remove filtered intervals summaries
rm ./results/mapped/filtered_intervals*.txt

## Remove insertsize avg and sd summaries
rm ./results/mapped/samplesQ10/*.txt

## Remove lsf-logfiles
rm lsf.o*
