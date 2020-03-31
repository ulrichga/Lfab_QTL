## Remove the .tab files produced by 02_assign_transcripts.lsf
rm ./results/genesearch/*.tab

## Remove the fragments of the transcripts from Dennis et al. (2017)
rm ./data/Dennis_et_al_2017/fragments/*
rmdir ./data/Dennis_et_al_2017/fragments

## Remove the BLAST-index files
rm ./data/waspbase/*.fa.*

## Remove R-console output and lsf-logfiles
rm lsf*
rm out
