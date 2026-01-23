#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/makeND280SystSplines/%x_%j_%a.out
#SBATCH --array=0-94
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! makeND280SystSplines_multi_job script !
# ! Step 2 of input generation pipeline !

# ! Needs to be run separately for each folder in ND280GenWeights !
# ! Make sure the amount of jobs in the array will catch all files in the relevant input directory !

# ! You can check how large an array is needed by running 'll <input_file_location> | wc -l' !
# ! (Note: this will include the 'total' line from the ll command, so subtract one from this to get the required array size) !
# ! (e.g.: if 'ls <input_file_location> | wc -l' returns 60, there are 60 files, so slurm array should be set to 0-59) !

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# Spline directory - general location of MC / Sand production, specific location is handled by jobscript and SUBFOLDER
SPLINE_DIR=/home/dlangrid/scratch/Splines/Prod7E/OAGenWeightsAppsOutputs/v11_MpiMSDialFix/MC_mirrored

# Subfolder is either run name (for MC) or mode (for Sand) - pls don't put any slashes in this string :(
SUBFOLDER=run9_water_p7_mcp_rhc

# Config file to use
CONFIG_FILE=${OAGenWeightsApps_DIR}/app/Configs/2024/NDSyst_OA2024Selections.toml

# --- RUN JOB ---

INPUT_NAME=XSecWeighted_${SUBFOLDER}_${SLURM_ARRAY_TASK_ID}.root
OUTPUT_NAME=SystWeighted_${SUBFOLDER}_${SLURM_ARRAY_TASK_ID}.root

echo Job started at $HOSTNAME
cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

echo "Running makeND280SystSplines : "$SUBFOLDER"_"$SLURM_ARRAY_TASK_ID
echo $INPUT_NAME"  ->  "$OUTPUT_NAME

if [ -d "$SPLINE_DIR/makeND280SystSplines/$SUBFOLDER" ]; then
  echo "  Directory "$SPLINE_DIR"/makeND280SystSplines/"$SUBFOLDER" already exists"
else
  echo "  Creating "$SPLINE_DIR"/makeND280SystSplines/"$SUBFOLDER
  mkdir $SPLINE_DIR"/makeND280SystSplines/"$SUBFOLDER
fi

./app/ND280/makeND280SystSplines -i ${SPLINE_DIR}/ND280GenWeights/$SUBFOLDER/${INPUT_NAME} -o ${SPLINE_DIR}/makeND280SystSplines/$SUBFOLDER/${OUTPUT_NAME} -c $CONFIG_FILE