#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END


# DL: Add line '#SBATCH --gres=gpu:h100:1' to use GPU

# DL:
# ND280_X job script
# Set up for ND280_EventRates

##### CONFIG #####

# General

export MACH3_DIR=$PWD
BUILD_DIR_NAME=build_cpu

CONFIG_FILE=${MACH3_DIR}/$BUILD_DIR_NAME/Configs/ND280_SFG_CCinc.yaml

# DL: set YAML_OVERRIDE entry to 'false' if you don't want to provide one
YAML_OVERRIDE=(
  false
)

# Output

OUTPUT_LABEL=(
  "SFG_CCinc_P8V17_Test"
)

OUTPUT_FILE=/scratch/dlangrid/Outputs/MaCh3_SFG_CCinc/PreFit/ND280_EventRates/ND280_EventRates_${OUTPUT_LABEL[$SLURM_ARRAY_TASK_ID]}.root

##### RUN JOB #####

time -p {

echo Job started at $HOSTNAME
eval date

source ${MACH3_DIR}/DLsetup.sh -t $BUILD_DIR_NAME -c $BUILD_DIR_NAME
cd ${MACH3_DIR}/$BUILD_DIR_NAME

if [ "${YAML_OVERRIDE[$SLURM_ARRAY_TASK_ID]}" == false ]; then
  ND280_EventRates ${CONFIG_FILE} General:OutputFile:\"${OUTPUT_FILE}\"
else
  ND280_EventRates ${CONFIG_FILE} General:OutputFile:\"${OUTPUT_FILE}\" ${YAML_OVERRIDE[$SLURM_ARRAY_TASK_ID]}
fi

}