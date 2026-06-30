#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-7
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

echo Job started at $HOSTNAME

export MACH3_DL=/home/dlangrid/MaCh3_Core/MaCh3Tutorial
source ${MACH3_DL}/DLsetup.sh -t build_cpu -b 

INPUT=(
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_MCMC_Diag.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM_MCMC_Diag.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_BigTuning_MCMC_Diag.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_SmallTuning_MCMC_Diag.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VeryBigTuning_MCMC_Diag.root"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VerySmallTuning_MCMC_Diag.root"
#
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM_MCMC_Diag.root 'Well tuned Chain' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_SmallTuning_MCMC_Diag.root 'Small step size' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_BigTuning_MCMC_Diag.root 'large step size'"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM_MCMC_Diag.root 'Well tuned Chain' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VerySmallTuning_MCMC_Diag.root 'Small step size' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VeryBigTuning_MCMC_Diag.root 'large step size'"
)

./bin/PlotMCMCDiag ${INPUT[$SLURM_ARRAY_TASK_ID]}