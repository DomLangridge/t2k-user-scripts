#!/bin/bash

# DL: Super simple script to make file list for use in highland2 analyses, because I'm lazy (efficient)?
#     Use as: ./MakeFileListStructure.sh <where_to_build_structure> (<some_string>)
#
#     if <some_string> is provided, script will also run MakeListLists.sh to populate lists

FILE_TYPE=(
  "Cosmics"
  "Data"
  "MC"
  "Sand"
)

mkdir $1
cd $1

for (( i=0; i<${#FILE_TYPE[@]}; i++ )); do
  mkdir ${FILE_TYPE[$i]}
  mkdir ${FILE_TYPE[$i]}/split_lists

  if [ ! -z "$2" ]; then

    SPLIT_COUNT=100
    TEST_COUNT=10

    echo "Making file lists for ${FILE_TYPE[$i]}..."
    if [ "${FILE_TYPE[$i]}" == "Cosmics" ]; then 
      ND280_PROD_FILES=$ND280_COSMICS
      SPLIT_COUNT=5
    elif [ "${FILE_TYPE[$i]}" == "Data" ]; then
      ND280_PROD_FILES=$ND280_DATA
    elif [ "${FILE_TYPE[$i]}" == "MC" ]; then
      ND280_PROD_FILES=$ND280_MC
    elif [ "${FILE_TYPE[$i]}" == "Sand" ]; then
      ND280_PROD_FILES=$ND280_SAND
    fi

    if [ $SPLIT_COUNT -lt $TEST_COUNT ]; then
      TEST_COUNT=$SPLIT_COUNT
    fi

    echo "  Making full list of ${FILE_TYPE[$i]} files"
    ~/CC_Systematics/useful_scripts/MakeFileList.sh ${ND280_PROD_FILES} ${FILE_TYPE[$i]}/${FILE_TYPE[$i]}.list

    echo "  Making test list of $TEST_COUNT ${FILE_TYPE[$i]} files"
    ~/CC_Systematics/useful_scripts/MakeFileList.sh ${ND280_PROD_FILES} ${FILE_TYPE[$i]}/Test_${FILE_TYPE[$i]}.list $TEST_COUNT

    echo "  Splitting full list of ${FILE_TYPE[$i]} files into smaller lists of $SPLIT_COUNT files each"
    
    split -d -l $SPLIT_COUNT ${FILE_TYPE[$i]}/${FILE_TYPE[$i]}.list ${FILE_TYPE[$i]}/split_lists/${FILE_TYPE[$i]}_
  fi

done