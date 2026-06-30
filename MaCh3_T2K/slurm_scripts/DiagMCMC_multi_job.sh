#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=23:59:59
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-5
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

echo Job started at $HOSTNAME

export MACH3_DL=$PWD
source ${MACH3_DL}/DLsetup.sh -t build_cpu -b

DIAG_CONFIG=bin/TutorialDiagConfig.yaml

CHAINFILE=(
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_SmallTuning.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_BigTuning.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VerySmallTuning.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VeryBigTuning.root"

)

./bin/DiagMCMC ${CHAINFILE[$SLURM_ARRAY_TASK_ID]} $DIAG_CONFIG