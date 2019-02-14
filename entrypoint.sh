# Made by Erick Castro
# CSCI 191T Bioinformatics
# This bash script takes in as input: gene annotation file, ids of genes,
# exon annotation file, and the chr1.fa file.
#   ex: ./entrypoint.sh gene_annot ids exon_annot_chr1 chr1.fa

# Set variables from user input files
genes=$1
ids=$2
exons=$3
chr1=$4
field='$4'

echo "Gene ids found:"
cat $ids
printf "\n"

echo -n "Extract everything? [y\n]: "
read ext_all

# Does operation for every ID in ids file
for id in $(cat $ids);
do
  echo "Searching for $id in gene annotation file..."

  # Looks for any row in genes file containing gene id
  # - Parses row and sets variables
  curr_id=$(awk "$field ~ /^$id/" $genes)
  if [ ! -z "$curr_id" ]; then
    chr=$(printf "$curr_id" | cut -f1)
    start=$(printf "$curr_id" | cut -f2)
    end=$(printf "$curr_id" | cut -f3)
    length=`expr $end - $start`
    dir=$(printf "$curr_id" | cut -f6)

    # Prints out data found for gene
    echo "Found data"
    echo "----------------"
    echo "Chromosome: $chr"
    echo "Start index: $start"
    echo "End index: $end"
    echo "Length: $length"
    echo "Direction: $dir"

    if [[ $ext_all == 'n' ]]; then
      echo -n "Do you want to extract gene? [y/n]: "
      read ans
    else
      ans='y'
    fi

    if [[ $ans == 'y' ]]; then
      echo "Extracting gene..."
      chr_string=$(perl -pe 's/\n//' < $chr1) # Converts file with line breaks into single string and store in variable
      mkdir -p genes # Creates 'genes' folder if it doesn't exist
      echo ${chr_string:$start:$length} > ./genes/$id # Extracts gene from chr1.fa file into separate file
    fi

    if [[ $ext_all == 'n' ]]; then
      echo -n "Do you want to extract exons? [y/n]: "
      read ans
    fi

    # Searches for gene's exons in exon annotation file is option is 'y'
    if [[ $ans == 'y' ]]; then
      echo "Searching for $id exons in exon annotation file..."
      exon_list=$(awk "$field ~ /^$id/" $exons) # Same type of lookup as gene
      if [ ! -z "$exon_list" ]; then
        echo "Found exons! Extracting..."
        printf "$exon_list \n\n" > ./genes/${id}_exons

        if [[ $ext_all == 'n' ]]; then
          echo -n "Do you want to mask gene with exons? [y/n]: "
          read ans
        fi

        if [[ $ans == 'y' ]]; then
          echo "Masking ${id} with exons..."
          ./extract_mask.sh ./genes/$id ./genes/${id}_exons $dir $start $end $chr
          printf "Saved to ${id}_masked\n\n"
        else
          printf "\n"
        fi
      else
        echo "Error: No exons found for $id"
      fi

    else
      printf "\n"
    fi

  else
    echo "Error: didn't find $id in gene annotation file."
  fi

  rm ./gene_temp_rev &> /dev/null
  rm ./gene_temp &> /dev/null

done

if [ -d "./genes" ]; then
  echo -n "Do you want to combine masked gene files? [y/n]:"
  read ans

  if [[ $ans == 'y' ]]; then
    masked_files=$(find ./genes -name "*masked" -print | cut -d'/' -f3)
    echo "Combining files:"
    for file in $masked_files;
    do
      echo $file
      file_path='./genes/'${file}
      cat $file_path >> masked_genes.fa
    done
    echo "Saved data to masked_genes.fa"
  fi
fi
