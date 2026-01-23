#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=64G
#SBATCH --time=12:00:00
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

PRIORFILE=(
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Asimov/OAR11B_P7E_v12_Asimov_MCMC_PriorPredStoreW2_SampLLHBarlow-Beeston_procsW2.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/OAR11B_P7E_v12_Data_MCMC_PriorPredStoreW2_SampLLHBarlow-Beeston_procsW2.root"
)

POSTFILE=(
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Asimov/OAR11B_P7E_v12_Asimov_MCMC_PostPredStoreW2_SampLLHBarlow-Beeston_procsW2.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/OAR11B_P7E_v12_Data_MCMC_PostPredStoreW2_SampLLHBarlow-Beeston_procsW2.root"
)

./nd280_utils/OverlayPriorPosteriorPredictive ${PRIORFILE[$SLURM_ARRAY_TASK_ID]} ${POSTFILE[$SLURM_ARRAY_TASK_ID]}

}