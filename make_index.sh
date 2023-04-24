#!/bin/bash

#====================== GET OPTIONS

#-------- Get option
ROOT="/home/aurelien/Documents/Audrey/git_radomska" # no slash in the end
MENU="/home/aurelien/Documents/Audrey/git_radomska/index_builder/site-index.html"
IGNORE="index_builder|index.html"
OUTPUT="/home/aurelien/Documents/Audrey/git_radomska/index.html"

while getopts r:m:i:o: flag
do
    case "${flag}" in
        r) ROOT=${OPTARG};;
        m) MENU=${OPTARG};;
        i) IGNORE=${OPTARG};;
        o) OUTPUT=${OPTARG};;
    esac
done

#====================== BUILD INDEX PAGE

/home/aurelien/Documents/Audrey/git_radomska/index_builder/make_tree.sh \
-r $ROOT \
-o $MENU \
-i $IGNORE

# Generate index
cat /home/aurelien/Documents/Audrey/git_radomska/index_builder/index_top.html > $OUTPUT
sed -i -e '$a\' $OUTPUT
cat $MENU >> $OUTPUT
sed -i -e '$a\' $OUTPUT
cat /home/aurelien/Documents/Audrey/git_radomska/index_builder/index_bottom.html >> $OUTPUT
