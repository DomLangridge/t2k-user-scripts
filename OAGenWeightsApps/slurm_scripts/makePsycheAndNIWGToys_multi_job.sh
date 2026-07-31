#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-59
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

HL_VERSION=5.25.1

INPUT_LOC=/scratch/dlangrid/flattrees/HL${HL_VERSION}/converted_from_HL5.20/
cd $INPUT_LOC
FILE_LIST=(*.root)

OUTPUT_LOC=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}

GENWEIGHT_CONFIG=${OAGenWeightsApps_DIR}/app/Configs/ND280_Upgrade/PsycheToy_Upgrade_Config.toml

SYSTBINCORR_OUTPUT_LOC=$OUTPUT_LOC/RunSystBinCorr/
GENWEIGHT_OUTPUT_LOC=$OUTPUT_LOC/genWeightFromPsyche/

SYSTBINCORR_OUTPUT_NAME=Output_RunSystBinCorr_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root
GENWEIGHT_OUTPUT_NAME=Output_genWeightFromPsyche_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

FILE=${FILE_LIST[${SLURM_ARRAY_TASK_ID}]}

if [ ! -f "$INPUT_LOC/$FILE" ]; then
  echo "ERROR: Input file is not a file"
  echo "       ($INPUT_LOC/$FILE)"
  echo "       Exiting..."
  exit 1
fi

if [ $SLURM_ARRAY_TASK_ID -ge ${#INPUT_FILES[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#INPUT_FILES[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

# ----- RunSystBinCorr -----

if [ -f $SYSTBINCORR_OUTPUT_LOC/$SYSTBINCORR_OUTPUT_NAME ]; then
  echo "output '$SYSTBINCORR_OUTPUT_LOC/$SYSTBINCORR_OUTPUT_NAME' already exists -> removing before running"
  rm $SYSTBINCORR_OUTPUT_LOC/$SYSTBINCORR_OUTPUT_NAME
fi

echo "=====> Running RunSystBinCorr <====="
ND280GenWeights -i $INPUT_LOC/$FILE -o $SYSTBINCORR_OUTPUT_LOC/$SYSTBINCORR_OUTPUT_NAME
echo "=====> Finished RunSystBinCorr <====="

# ----- genWeightFromPsyche -----

if [ -f $GENWEIGHT_OUTPUT_LOC/$GENWEIGHT_OUTPUT_NAME ]; then
  echo "output '$GENWEIGHT_OUTPUT_LOC/$GENWEIGHT_OUTPUT_NAME' already exists -> removing before running"
  rm $GENWEIGHT_OUTPUT_LOC/$GENWEIGHT_OUTPUT_NAME
fi

echo "=====> Running genWeightFromPsyche <====="
ND280GenWeights -i $SYSTBINCORR_OUTPUT_LOC/$SYSTBINCORR_OUTPUT_NAME -o $GENWEIGHT_OUTPUT_LOC/$GENWEIGHT_OUTPUT_NAME -c $GENWEIGHT_CONFIG
echo "=====> Finished genWeightFromPsyche <====="

}