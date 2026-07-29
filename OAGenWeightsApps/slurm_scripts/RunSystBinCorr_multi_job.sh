#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=34,56,35
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! RunSystBinCorr_multi_job script !
# ! Step 1 of ND covariance matrix pipeline !

# ! Needs to be run separately for each folder of Flattrees !
# ! Make sure the amount of jobs in the array will catch all files in the relevant input directory !

# ! You can check how large an array is needed by running 'ls <input_file_location> | wc -l' !
# ! (e.g.: if 'ls <input_file_location> | wc -l' returns 60, there are 60 files, so slurm array should be set to 0-59) !

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

# Flattree input and throw output directories - should be general locations, specific locations are handled by jobscript and SUBFOLDER
# OUTPUT_DIR is general location of ND covariance production and MC / Sand toys
# FLATTREE_DIR=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/FlatTrees/Prod7E/v4_newSystCorrections/with_corrections/MC
FLATTREE_DIR=/scratch/dlangrid/flattrees/HL5.25.1/converted_from_HL5.20
OUTPUT_DIR=/scratch/dlangrid/UpgradeValidations/HL5.25.1

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

HL_VERSION=5.25.1

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

cd $FLATTREE_DIR
INPUT_FILES=(*)
OUTPUT_NAME=Output_RunSystBinCorr_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root

if [ $SLURM_ARRAY_TASK_ID -ge ${#INPUT_FILES[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

echo "Running RunSystBinCorr : "$SLURM_ARRAY_TASK_ID
echo "  From "${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}
echo "  To   "$OUTPUT_NAME

if [ -d "$OUTPUT_DIR/RunSystBinCorr" ]; then
  echo "  Directory "$OUTPUT_DIR"/RunSystBinCorr already exists"
else
  echo "  Creating "$OUTPUT_DIR"/RunSystBinCorr"
  mkdir $OUTPUT_DIR"/RunSystBinCorr"
fi

RunSystBinCorr.exe -i ${FLATTREE_DIR}/${INPUT_FILES[$SLURM_ARRAY_TASK_ID]} -o ${OUTPUT_DIR}/RunSystBinCorr/${OUTPUT_NAME}

}