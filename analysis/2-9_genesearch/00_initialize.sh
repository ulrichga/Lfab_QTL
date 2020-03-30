###############################################################################
#### Create output directory
###############################################################################

## Create an output direcotry for this part of the analysis
if [ ! -e ./results/genesearch ]  ; then mkdir ./results/genesearch ; fi

###############################################################################
#### Subset the transcripts from Dennis et al. (2017)
###############################################################################

## For assigning genes to the transcripts from Dennis et al. (2017), we will run a batch job  using BLAST later on.
## To run it as parallel jobs, the fasta file with transcripts is split into files of 1000 sequences each.
## This is done in the additional directory ./data/Dennis_et_al_2017/fragments

## Define input file and output directory
in="./data/Dennis_et_al_2017/01.Lfab.Trinity.denovo.fasta"
out="./data/Dennis_et_al_2017/fragments"

## Create the directory to store subsets in
if [ ! -e $out ]  ; then mkdir $out ; fi

## Save line numbers where transcripts start or end in the 01.Lfab.Trinity.denovo.fasta-file.
## Starting lines are saved as froms
grep -nr ">" $in | cut -d":" -f1 > froms
## Ending lines are saved as tos (transcripts end on the line before the next starts and
## the last transcript is the last line of the input file)
more froms | awk '{$1-=1}1' | sed 1d > tos
wc -l $in | awk '{print $1}' >> tos

## Get the total number of transcripts and save it as $ntrans
ntrans=`wc -l froms | awk '{print $1}'`

## Define the number of transcripts per file as $perfile
## (we set it to 1000)
perfile=1000

## Get the number of resulting files and save it as $nfiles
## nfiles = ceiling( ntrans / perfile ) = floor( ntrans + perfile -1 ) / perfile
nfiles=`echo "($ntrans + $perfile -1) / $perfile" | bc`

## Subset the transcripts into smaller files of $perfile transcripts each, using a for-loop
## For each of the $nfiles files
for (( i=1; i<=$nfiles; i++ ))
do
  ## Find the transcript number to start with and save it as $from
  ## from = ( i - 1 ) * perfile + 1
  from=`echo "( $i - 1 ) * $perfile + 1" | bc`
  ## Find the transcript number to end with and save it as $to
  ## to = i * perfile
  to=`expr $i \* $perfile`
  ## For the last file, set the $to variable equal to  $ntrans
  if [ "$i" -eq "$nfiles" ] ; then to="$ntrans" ; fi
  ## Find the line number in 01.Lfab.Trinity.denovo.fasta that corresponds to the transcript number $from
  ## and save it as the variable $cutfrom
  cutfrom=`sed "${from}q;d" froms`
  ## Find the line number in 01.Lfab.Trinity.denovo.fasta that corresponds to the transcript number $to
  ## and save it as the variable $cutto
  cutto=`sed "${to}q;d" tos`
  ## Do the subsetting with awk
  awk "NR==$cutfrom, NR==$cutto" $in > ${out}/transcripts_${i}_${from}_to_${to}.fa
done

## Create a file list and put it in ${out}
ls ${out} | grep ".fa" > ${out}/file_list

## Cleanup by removing froms and tos
rm froms
rm tos

###############################################################################
#### Start a batch job for formatting OGS1.0_20170110_transcripts.fa as database
###############################################################################

bsub -W 1:00 -R "rusage[mem=64]" -J make_blast_db "module load gcc/4.8.2 gdc blast/2.3.0
makeblastdb -in ./data/waspbase/OGS1.0_20170110_transcripts.fa -dbtype nucl -parse_seqids"
