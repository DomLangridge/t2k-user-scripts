#!/bin/bash

# DL: Super simple script to make file list for use in highland2 analyses, because I'm lazy (efficient?)
#     Use as: ./MakeFileList.sh <path_to_files> <output_filename> (<number_of_files>)
#
#     Only grabs .root files, as some folders contain bash scripts or txt files for some reason

if [ -z "$3" ]; then
  ls $1/* | grep .root > $2
else
  ls $1/* | grep .root | head -n $3 > $2
fi

# DL: Files end with a '*' for some reason which breaks highland2 run scripts, so we'll remove this
sed -i 's/*//g' $2