IFS=$'\n'

gene=$1
exons=$2
direction=$3
g_start=$4
g_end=$5
g_chr=$6
field="$1"

[ -e ${exons}_startend ] && rm ${exons}_startend

for exon in $(cat $exons);
do
  echo $exon | cut -f2-3 >> ${exons}_startend

  id=$(printf "$exon" | cut -f4)
  chr=$(printf "$exon" | cut -f1)
  start=$(printf "$exon" | cut -f2)
  end=$(printf "$exon" | cut -f3)
  length=`expr $end - $start`
  dir=$(printf "$exon" | cut -f6)
  #
  # echo "Exon id: $id"
  # echo "Chromosome: $chr"
  # echo "Start index: $start"
  # echo "End index: $end"
  # echo "Length: " $length
  # printf "Direction: $dir \n\n"

done

python3 ./extract.py $gene ${exons}_startend $direction $g_start $g_end $g_chr
