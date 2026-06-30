#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=64G
#SBATCH --time=23:59:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=7
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

time -p {

echo Job started at $HOSTNAME
eval date

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
#
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM.root 'Well-tuned Chain' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_SmallTuning.root 'Small step size' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_BigTuning.root 'Large step size'"
  "/scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_AdaptiveRM.root 'Well-tuned Chain' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VerySmallTuning.root 'Small step size' /scratch/dlangrid/Chains/MaCh3_Tutorial/MaCh3_Tutorial_MCMC_VeryBigTuning.root 'Large step size'"
)

COMMAND="./bin/ProcessMCMC $DIAG_CONFIG "${CHAINFILE[$SLURM_ARRAY_TASK_ID]}

echo "running: "$COMMAND

eval $COMMAND

}