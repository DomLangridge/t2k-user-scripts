#!/bin/bash -l
#SBATCH --account=rpp-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:h100:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# DL:
# JointFit job script

##### CONFIG #####

# General

export MACH3_DIR=/home/dlangrid/MaCh3_T2K/MaCh3_OAR11B
BUILD_DIR=build_gpu
BASECONFIGFILE=${MACH3_DIR}/build/configs/JointFit2024_DL.yaml

# Output

# OUTPUT_FILE=OAR11B_P7E_v12_Data_MCMC_EdTuning_${SLURM_ARRAY_TASK_ID}.root

##### RUN JOB #####

time -p {

echo Job started at $HOSTNAME
eval date

source ${MACH3_DIR}/DLsetup.sh -b $BUILD_DIR
cd ${MACH3_DIR}/$BUILD_DIR

JOB_CONFIG=tempConfig_JointFit_${SLURM_ARRAY_TASK_ID}.yaml
cp $BASECONFIGFILE $JOB_CONFIG

# COMMAND="sed -i 's/<OUTPUT_FILE>/$OUTPUT_FILE/' $JOB_CONFIG"
# eval $COMMAND

eval ./bin/JointFit $JOB_CONFIG

}
