## Remove intermediate vcf files and the directory that contained them
rm ./results/SNPcall/vcf/*
rmdir ./results/SNPcall/vcf/

## Remove logfiles
rm lsf.*

## Remove the regions files and genome indexing files
rm ./data/genome/regions/*
rmdir ./data/genome/regions
rm ./data/genome/*.amb ./data/genome/*.ann ./data/genome/*.bwt ./data/genome/*.fai ./data/genome/*.pac ./data/genome/*.sa
