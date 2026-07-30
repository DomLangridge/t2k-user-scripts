#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-59
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
OAGenWeightsApps_DIR=$PWD

HL_VERSION=5.25.1

INPUT_DIR=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/RunSystBinCorr
OUTPUT_DIR=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/genWeightFromPsyche

# Config file to use
CONFIG_FILE=${OAGenWeightsApps_DIR}/app/Configs/ND280_Upgrade/PsycheToy_Upgrade_Config.toml

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd $INPUT_DIR
INPUT_FILES=(*)

OUTPUT_NAME=NIWGweighted_${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}

if [ $SLURM_ARRAY_TASK_ID -ge ${#INPUT_FILES[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

echo "Running genWeightFromPsyche..."
echo "  From "${INPUT_FILES[$SLURM_ARRAY_TASK_ID]}
echo "  To   "$OUTPUT_NAME

if [ -f ${OUTPUT_DIR}/${OUTPUT_NAME} ]; then
  echo "output '${OUTPUT_DIR}/${OUTPUT_NAME}' already exists -> removing before running"
  rm ${OUTPUT_DIR}/${OUTPUT_NAME}
fi

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

genWeightFromPsyche -i ${INPUT_DIR}/${INPUT_FILES[$SLURM_ARRAY_TASK_ID]} -o ${OUTPUT_DIR}/${OUTPUT_NAME} -c ${CONFIG_FILE}

}