#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-4
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# DL:
# ND280_MCMC job script
# Differs from LLHscan and SigmaVar job scripts
# Each array value will correspond to the same configuration
# The setup values below allow for these different configurations

##### CONFIG #####

# General

export MACH3_DIR=/home/dlangrid/MaCh3_T2K/MaCh3_OA2024
BASECONFIGFILE=${MACH3_DIR}/build/configs/p7_2024a_ND_AsimovFit.yaml

# Output

OUTPUT_FILE=OAR11B_P7E_v12_Asimov_MCMC_SaveNom_PlotByMode_${SLURM_ARRAY_TASK_ID}.root

##### RUN JOB #####

time -p {

echo Job started at $HOSTNAME
eval date

source ${MACH3_DIR}/DLsetup.sh
cd ${MACH3_DIR}/build

JOB_CONFIG=tempConfig_MCMC_Asimov_${SLURM_ARRAY_TASK_ID}.yaml
cp $BASECONFIGFILE $JOB_CONFIG

COMMAND="sed -i 's/<OUTPUT_FILE>/$OUTPUT_FILE/' $JOB_CONFIG"
eval $COMMAND

eval ./bin/ND280_MCMC $JOB_CONFIG

}