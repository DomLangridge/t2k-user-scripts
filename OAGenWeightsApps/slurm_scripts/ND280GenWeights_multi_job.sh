#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/ND280GenWeights/%x_%j_%a.out
#SBATCH --array=0-0
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! ND280GenWeights_multi_job script !
# ! Step 1 of input generation pipeline !

# ! Needs to be run separately for each folder of Flattrees !
# ! Make sure the amount of jobs in the array will catch all files in the relevant input directory !

# ! You can check how large an array is needed by running 'll <input_file_location> | wc -l' !
# ! (Note: this will include the 'total' line from the ll command, so subtract one from this to get the required array size) !
# ! (e.g.: if 'ls <input_file_location> | wc -l' returns 60, there are 60 files, so slurm array should be set to 0-59) !

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# Flattree input and spline output directories - should be general locations, specific locations are handled by jobscript and SUBFOLDER
# SPLINE_DIR is general location of MC / Sand production
FLATTREE_DIR=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/FlatTrees/Prod7E/v4_newSystCorrections/with_corrections/MC
SPLINE_DIR=/home/dlangrid/scratch/SplineFactory/v12_Highland_3.22.4/XSec/with_corrections/MC/

# Subfolder will either be based on run name (for MC) or mode (for Sand) - pls don't put any slashes in this string :(
SUBFOLDER=run9_water_p7_mcp_rhc

# Config file to use - mainly for if using mirroring or not
CONFIG_FILE=${OAGenWeightsApps_DIR}/app/Configs/2024/ND280_OA2024_Config_Mirroring.toml

# --- RUN JOB ---

INPUT_FILES=($FLATTREE_DIR/$SUBFOLDER/*)
OUTPUT_NAME=XSecWeighted_${SUBFOLDER}_${SLURM_ARRAY_TASK_ID}.root

if [ $SLURM_ARRAY_TASK_ID -ge ${#INPUT_FILES[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

echo Job started at $HOSTNAME
cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

echo "Running ND280GenWeights : "$SUBFOLDER"_"$SLURM_ARRAY_TASK_ID
echo ${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}"  ->  "$OUTPUT_NAME

if [ -d "$SPLINE_DIR/ND280GenWeights/$SUBFOLDER" ]; then
  echo "  Directory "$SPLINE_DIR"/ND280GenWeights/"$SUBFOLDER" already exists"
else
  echo "  Creating "$SPLINE_DIR"/ND280GenWeights/"$SUBFOLDER
  mkdir $SPLINE_DIR"/ND280GenWeights/"$SUBFOLDER
fi

./app/ND280/ND280GenWeights -i ${INPUT_FILES[$SLURM_ARRAY_TASK_ID]} -o ${SPLINE_DIR}/ND280GenWeights/$SUBFOLDER/${OUTPUT_NAME} -c $CONFIG_FILE