#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=2
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

time -p {

echo Job started at $HOSTNAME
eval date

export MACH3_DL=/home/dlangrid/MaCh3_T2K/MaCh3_OA2024
source ${MACH3_DL}/DLsetup.sh
cd ${MACH3_DL}/build

PREDFILE=(
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Predictives/Xsec_Only/OAR11B_P7E_v12_Data_MCMC_PostPredStoreW2_FixedFlux_FixedDet_SampLLHBarlow-Beeston_procsW2.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Predictives/Flux_Only/OAR11B_P7E_v12_Data_MCMC_PostPredStoreW2_FixedXSec_FixedDet_SampLLHBarlow-Beeston_procsW2.root"
  "/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Data/Predictives/Det_Only/OAR11B_P7E_v12_Data_MCMC_PostPredStoreW2_FixedXSec_FixedFlux_SampLLHBarlow-Beeston_procsW2.root"
)

COMMAND="./nd280_utils/PlotPredictive nd280_utils/ND280_Utils.toml "${PREDFILE[$SLURM_ARRAY_TASK_ID]}

echo "running: "$COMMAND

eval $COMMAND

}
