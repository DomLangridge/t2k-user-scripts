#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=1-12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=1
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# DL:
# ND280_X job script
# Set up for Sigma Variation
# Each array value will correspond to a different configuration
# The setup arrays below allow for these different configurations

##### CONFIG #####

# General

export MACH3_DIR=/home/dlangrid/MaCh3_T2K/MaCh3_OA2024
ND280JOBTYPE=SigmaVar
BASECONFIGFILE=${MACH3_DIR}/build/configs/p7_2024a_ND_Prefit.yaml

# Output

OUTPUT_LABEL=(
  "v12"
  "v12_mirrored"
)
OUTPUT_FILE=OAR11B_P7E_${OUTPUT_LABEL[$SLURM_ARRAY_TASK_ID]}_${ND280JOBTYPE}.root

##### RUN JOB #####

time -p {

echo Job started at $HOSTNAME
eval date

source ${MACH3_DIR}/DLsetup.sh
cd ${MACH3_DIR}/build

JOB_CONFIG=tempConfig_${ND280JOBTYPE}_${SLURM_ARRAY_TASK_ID}.yaml
cp $BASECONFIGFILE $JOB_CONFIG

COMMAND="sed -i 's/<OUTPUT_FILE>/$OUTPUT_FILE/' $JOB_CONFIG"
eval $COMMAND

eval ./bin/ND280_$ND280JOBTYPE $JOB_CONFIG

}