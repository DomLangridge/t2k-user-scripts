#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-1
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

time -p {

echo Job started at $HOSTNAME
eval date

export MACH3_DL=/home/dlangrid/MaCh3_T2K/MaCh3_OA2024
source ${MACH3_DL}/DLsetup.sh
cd ${MACH3_DL}/build

INPUTS=(
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_SigmaVar.root"
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_mirrored_SigmaVar.root"
)

eval ./nd280_utils/CompareSigmaVariation ${INPUTS[$SLURM_ARRAY_TASK_ID]} nd280_utils/ND280_Utils.toml

}