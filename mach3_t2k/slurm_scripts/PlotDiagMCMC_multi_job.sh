#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-5
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

echo Job started at $HOSTNAME

export MACH3_DL=/home/dlangrid/MaCh3_T2K/MaCh3_OAR11B
source ${MACH3_DL}/DLsetup.sh
cd ${MACH3_DL}/build

INPUT=(
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Chains/OAR11B_P7E_v12_Data_MCMC_0_MCMC_Diag.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/EdTuning/Chains/OAR11B_P7E_v12_Data_MCMC_EdTuning_0_MCMC_Diag.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Chains/OAR11B_P7E_v12_Data_MCMC_0_MCMC_Diag.root /home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/EdTuning/Chains/OAR11B_P7E_v12_Data_MCMC_EdTuning_0_MCMC_Diag.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Chains/OAR11B_P7E_v12_Data_MCMC_0_MCMC_Diag.root /home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/EdTuning/Chains_v2/OAR11B_P7E_v12_Data_MCMC_EdTuning_0_MCMC_Diag.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Chains/OAR11B_P7E_v12_Data_MCMC_0_MCMC_Diag.root /home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/EdTuning/Chains/OAR11B_P7E_v12_Data_MCMC_EdTuning_0_MCMC_Diag.root /home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/EdTuning/Chains_v2/OAR11B_P7E_v12_Data_MCMC_EdTuning_0_MCMC_Diag.root"
)

./bin/PlotMCMCDiag ${INPUT[$SLURM_ARRAY_TASK_ID]}