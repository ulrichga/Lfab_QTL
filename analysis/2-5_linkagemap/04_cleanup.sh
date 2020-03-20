## Remove unnecessary files from ./results/linkage_mapping
mv ./results/linkage_mapping/linkagemap_summary.txt ./results/linkagemap_summary.txt
mv ./results/linkage_mapping/MSTinput.txt ./results/MSTinput.txt
mv ./results/linkage_mapping/MSToutput_edited.txt ./results/MSToutput_edited.txt
rm ./results/linkage_mapping/*
mv ./results/linkagemap_summary.txt ./results/linkage_mapping/linkagemap_summary.txt
mv ./results/MSTinput.txt ./results/linkage_mapping/MSTinput.txt
mv ./results/MSToutput_edited.txt ./results/linkage_mapping/MSToutput_edited.txt

## Remove the scaffoldsize.txt file from ./data/genome
rm ./data/genome/*.txt

## Remove lsf logfiles
rm lsf*

## Remove superfluous R-output
rm *.pdf
rm out
