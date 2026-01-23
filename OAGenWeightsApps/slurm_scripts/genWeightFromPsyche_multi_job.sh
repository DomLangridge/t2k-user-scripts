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

# ! genWeightFromPsyche_multi_job script !
# ! Step 2 of ND covariance matrix pipeline !

# ! Needs to be run separately for each folder of throws !
# ! Make sure the amount of jobs in the array will catch all files in the relevant input directory !

# ! You can check how large an array is needed by running 'ls <input_file_location> | wc -l' !
# ! (e.g.: if 'ls <input_file_location> | wc -l' returns 60, there are 60 files, so slurm array should be set to 0-59) !

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# NDCOV_DIR is general location of ND covariance production and MC / Sand toys
NDCOV_DIR=/home/dlangrid/scratch/NDinputs/NDCov/v11_MpiMSDialFix/Sand

# Subfolder will either be based on run name (for MC) or mode (for Sand) - pls don't put any slashes in this string :(

# MC
# SUBFOLDER=run2_air_p7_mcp_fhc
# SUBFOLDER=run2_water_p7_mcp_fhc
# SUBFOLDER=run3_air_p7_mcp_fhc
# SUBFOLDER=run4_air_p7_mcp_fhc
# SUBFOLDER=run4_water_p7_mcp_fhc
# SUBFOLDER=run5_water_p7_mcp_rhc
# SUBFOLDER=run6_air_p7_mcp_rhc
# SUBFOLDER=run7_water_p7_mcp_rhc
# SUBFOLDER=run8_air_p7_mcp_fhc
# SUBFOLDER=run8_water_p7_mcp_fhc
# SUBFOLDER=run9_water_p7_mcp_rhc

# Sand
# SUBFOLDER=fhc_run4
# SUBFOLDER=fhc_run8
SUBFOLDER=rhc

# Config file to use
CONFIG_FILE=${OAGenWeightsApps_DIR}/app/Configs/2024/PsycheToy_O2024_Config.toml

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

cd $NDCOV_DIR/RunSystBinCorr/$SUBFOLDER
INPUT_FILES=(*)
# OUTPUT_NAME=PsycheThrows_Weighted_${SUBFOLDER}_${SLURM_ARRAY_TASK_ID}.root
OUTPUT_NAME=Weighted_${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}

if [ $SLURM_ARRAY_TASK_ID -ge ${#INPUT_FILES[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

echo "Running genWeightFromPsyche : "$SUBFOLDER"_"$SLURM_ARRAY_TASK_ID
echo "  From "${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}
echo "  To   "$OUTPUT_NAME

if [ -d "$NDCOV_DIR/genWeightFromPsyche/$SUBFOLDER" ]; then
  echo "  Directory "$NDCOV_DIR"/genWeightFromPsyche/"$SUBFOLDER" already exists"
else
  echo "  Creating "$NDCOV_DIR"/genWeightFromPsyche/"$SUBFOLDER
  mkdir $NDCOV_DIR"/genWeightFromPsyche/"$SUBFOLDER
fi

cd ${OAGenWeightsApps_DIR}/build

./app/ND280/genWeightFromPsyche -i ${NDCOV_DIR}/RunSystBinCorr/$SUBFOLDER/${INPUT_FILES[$SLURM_ARRAY_TASK_ID]} -o ${NDCOV_DIR}/genWeightFromPsyche/$SUBFOLDER/${OUTPUT_NAME} -c ${CONFIG_FILE}

}