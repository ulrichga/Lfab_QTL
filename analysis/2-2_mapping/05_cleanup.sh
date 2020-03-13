## Cleanup script after mapping + summary. This is under construction.

more stat_total.txt | awk -F" " '{print $1}' | awk -F"/" '{print $3}' | sed 's/_stat//' > name
echo "MEAN" >> name
echo "TOTAL" >> name
echo "SHARED_25%" >> name
echo "SHARED_50%" >> name
echo "SHARED_75%" >> name
echo "SHARED_90%" >> name
echo "SHARED_99%" >> name

more stat_total.txt | awk -F" " '{print $2}' > reads_total
more stat_mapped.txt | awk -F" " '{print $2}' > reads_mapped
more statQ10_mapped.txt | awk -F" " '{print $2}' > reads_mappedQ10
paste reads_total reads_mappedQ10 | awk '{print($2/$1*100)}' > %_mapped_Q10
more insertsize_avg.txt | awk -F"\t" '{print $3}' > ins_size_avg
more insertsize_sd.txt | awk -F"\t" '{print $3}' > ins_size_sd

more reads_total | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_total
more reads_mapped | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_mapped
more reads_mappedQ10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> reads_mappedQ10
more %_mapped_Q10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> %_mapped_Q10
more ins_size_avg | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> ins_size_avg
more ins_size_sd | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> ins_size_sd

echo -en '\n \n \n \n \n \n ' >> reads_total
echo -en '\n \n \n \n \n \n ' >> reads_mapped
echo -en '\n \n \n \n \n \n ' >> reads_mappedQ10
echo -en '\n \n \n \n \n \n ' >> %_mapped_Q10
echo -en '\n \n \n \n \n \n ' >> ins_size_avg
echo -en '\n \n \n \n \n \n ' >> ins_size_sd

more filtered_intervals_cov3_summary.txt | awk -F" " '{print $1}' > intervals_cov3
sed -i '$ d' intervals_cov3
more intervals_cov3 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov3
more shared_filtered_intervals_cov3_summary.txt | awk -F" " '{print $1}' >> intervals_cov3
more sharedonly_filtered_intervals_summary.txt | grep cov3 | awk -F" " '{print $1}' >> intervals_cov3

more filtered_intervals_cov6_summary.txt | awk -F" " '{print $1}' > intervals_cov6
sed -i '$ d' intervals_cov6
more intervals_cov6 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov6
more shared_filtered_intervals_cov6_summary.txt | awk -F" " '{print $1}' >> intervals_cov6
more sharedonly_filtered_intervals_summary.txt | grep cov6 | awk -F" " '{print $1}' >> intervals_cov6

more filtered_intervals_cov10_summary.txt | awk -F" " '{print $1}' > intervals_cov10
sed -i '$ d' intervals_cov10
more intervals_cov10 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov10
more shared_filtered_intervals_cov10_summary.txt | awk -F" " '{print $1}' >> intervals_cov10
more sharedonly_filtered_intervals_summary.txt | grep cov10 | awk -F" " '{print $1}' >> intervals_cov10

more filtered_intervals_cov15_summary.txt | awk -F" " '{print $1}' > intervals_cov15
sed -i '$ d' intervals_cov15
more intervals_cov15 | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' >> intervals_cov15
more shared_filtered_intervals_cov15_summary.txt | awk -F" " '{print $1}' >> intervals_cov15
more sharedonly_filtered_intervals_summary.txt | grep cov15 | awk -F" " '{print $1}' >> intervals_cov15

paste name reads_total reads_mapped reads_mappedQ10 %_mapped_Q10 ins_size_avg ins_size_sd intervals_cov3 intervals_cov6 intervals_cov10 intervals_cov15 > mapping_summary.txt
