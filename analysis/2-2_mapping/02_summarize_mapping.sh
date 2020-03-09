# Obtain summary statistics from the mapped reads
grep "in total" ./results/mapped/stats/* | tr : " " | cut -d" " -f1,2 > ./results/mapped/stats/stat_total.txt
grep "in total" ./results/mapped/statsQ10/* | tr : " " | cut -d" " -f1,2 > ./results/mapped/statsQ10/statQ10_total.txt
grep "mapped (" ./results/mapped/stats/* | tr : " " | cut -d" " -f1,2 > ./results/mapped/stats/stat_mapped.txt
grep "mapped (" ./results/mapped/statsQ10/* | tr : " " | cut -d" " -f1,2 > ./results/mapped/statsQ10/statQ10_mapped.txt
