# SNP filtering
To run this part of the analysis follow the steps described here. The analysis was executed on the Euler cluster and pulls dependencies from it. To run it on another cluster, some changes to the code may be necessary. For all the steps the current directory should be the Lfab_QTL directory.
## Step 1
Make sure the necessary raw data are are available.
* gzipped raw vcf file ./results/SNPcall/raw.vcf
* txt file indicating ploidy of individuals ./results/SNPcall/ploidy.txt
