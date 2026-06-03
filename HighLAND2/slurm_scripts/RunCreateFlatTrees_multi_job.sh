#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%j_%a.out
#SBATCH --array=0-99
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! RunCreateFlatTrees job script !
# For recreating flattrees with updated highland / psyche settings

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# Flattree input and output directories
FLATTREE_DIR=/home/dlangrid/scratch/FlatTrees/Prod7E/highland2Master_3.19/sand/P7V14
OUTPUT_DIR=/home/dlangrid/scratch/NDinputs/NDCov/v11_MpiMSDialFix/Sand

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

FLATTREE_FILE=""

if [ ! -f "$FLATTREE_DIR" ]; then
  echo "Input is not a file: will treat it as a directory of files"
  FILELIST=($FLATTREE_DIR/*)
  FLATTREE_FILE=${FILELIST[$SLURM_ARRAY_TASK_ID]}
  if [ $SLURM_ARRAY_TASK_ID -ge ${#FILELIST[@]} ]; then
    echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
    echo "Other jobs probably finished fine, but I'll exit this one"
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

OUTPUT_FILE=$OUTPUT_DIR/$(basename ${FLATTREE_FILE})

echo "Running RunCreateFlatTrees"
echo "  File:           $FLATTREE_FILE"
echo "  Outputting to   $OUTPUT_FILE"

RunCreateFlatTrees -i $FLATTREE_FILE -o $OUTPUT_FILE

}