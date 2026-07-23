#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-59
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! RunCreateFlatTrees job script !
# For recreating flattrees with updated highland / psyche settings

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

HL_VERSION=5.25

# Flattree input and output directories
# If you provide the path to an individual file in FLATTREE_DIR it will just run over that one file
FLATTREE_DIR=/scratch/dlangrid/flattrees/HL5.20/flattrees_neut_mc_v17_hl5.20/
OUTPUT_DIR=/scratch/dlangrid/flattrees/HL${HL_VERSION}/converted_from_HL5.20/

OUTPUT_TAG=converted_to_HL${HL_VERSION}

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v $HL_VERSION

FLATTREE_FILE=""

if [ ! -f "$FLATTREE_DIR" ]; then
  echo "Input is not a file: will treat it as a directory of files"
  FILELIST=($FLATTREE_DIR/*)
  FLATTREE_FILE=${FILELIST[$SLURM_ARRAY_TASK_ID]}

  if [ $SLURM_ARRAY_TASK_ID -ge ${#FILELIST[@]} ]; then
    echo "WARNING: Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
    echo "         Other jobs probably finished fine, but I'll exit this one"
    exit 1
  fi

  if [ ${FLATTREE_FILE##*.} != "root" ]; then
    echo "ERROR: File is not a root file"
    echo "       Exiting script"
    exit 1
  fi

else
  echo "Input is a single file: if you've run this as a multi job, we'll only run the 0th instance"
  if [ $SLURM_ARRAY_TASK_ID != 0 ]; then
    echo "  Task ID = $SLURM_ARRAY_TASK_ID -> exiting job"
    exit 0
  fi
  FLATTREE_FILE=$FLATTREE_DIR
fi

OUTPUT_FILE=$OUTPUT_DIR/$(basename ${FLATTREE_FILE%.*})_$OUTPUT_TAG.root

echo "Running RunCreateFlatTree.exe"
echo "  File:           $FLATTREE_FILE"
echo "  Outputting to   $OUTPUT_FILE"

if [ -f $OUTPUT_FILE ]; then
  echo "output '$OUTPUT_FILE' already exists -> removing before running"
  rm $OUTPUT_FILE
fi

RunCreateFlatTree.exe $FLATTREE_FILE -o $OUTPUT_FILE

}