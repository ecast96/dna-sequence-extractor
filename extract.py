# Made by Erick Castro
# CSCI 191T Bioinformatics
# This python program does intron masking by:
# - Creating label using args passed in
# - Creates list of pairs of start/end index for exons for gene
# - Program will replace characters with '=' if not within the start/end range
# - Jumps to end+1 index of each exon if it reaches the start of an exon start index


import subprocess
import sys
import os

# Read file and return start & end as columns with values
def read_file(file_name):
    with open(file_name, 'r') as data:
        start = []
        end = []
        for line in data:
            p = line.split()
            start.append(int(p[0]))
            end.append(int(p[1]))

    return start, end

def mask_intron(gene, exon_startend, dir, label):
    start, end = read_file(exon_startend)

    base = start[0]
    start[:] = [i - base for i in start]
    end[:] = [i - base for i in end]

    # Creates list of pairs of start & end indexs for exons
    pairs = []
    for x, y in zip(start, end):
        pairs.append((x, y))

    # Read gene data and set to variable
    with open(gene, 'r') as myfile:
        data=myfile.read().replace('\n', '')

    index = 0
    data = list(data)  # Convert the string to a list
    while index < len(data):
        if pairs:
            if index < pairs[0][0] : # replaces chars if less than the start of an exon start index stored in list
                # print ("replacing with =")
                data[index] = "="
                index += 1
            else: # jumps to next exon end+1 index to start replacing with '='
                # print("error: in exon range")
                index = pairs[0][1]
                pairs = pairs[1:]
        else:
            data[index] = "="
            index += 1


    data = "".join(data)  # Change the list back to string, by using 'join' method of strings.
    # print (data)

    # Saves masked gene file for reverse-complement preparation
    with open('gene_temp', "w") as text_file:
        if dir == "+":
            text_file.write(label)
        text_file.write(data)


    gene_masked = gene+'_masked'
    if dir == '-': # Does reverse-complement if direction is '-'
        subprocess.call("cat gene_temp | rev | tr ATGCatgc TACGtacg > gene_temp_rev".format(gene_masked), shell=True)
        with open('gene_temp_rev', "r+") as text_file:
            text_file.seek(0,0)
            text_file.write(label)
        subprocess.call("cat gene_temp_rev > {0}".format(gene_masked), shell=True)
    else: # Saves data if direction is '+'
        subprocess.call("cat gene_temp > {0}".format(gene_masked), shell=True)

# Removes prefix './genes/' from any string
def remove_prefix(text):
    if text.startswith('./genes/'):
        return text[len('./genes/'):]
    return text

def main(argv):
    # Sets variables from user input to create label
    chr = argv[6]
    exon_startend = argv[2]
    start = argv[4]
    end = argv[5]
    gene = argv[1]
    direction = argv[3]

    label = ">{0}.{1}.{2}.{3}.{4}\n".format(chr, start, end, remove_prefix(gene), direction)
    mask_intron(gene, exon_startend, direction, label)

if __name__ == '__main__':
    main(sys.argv)
