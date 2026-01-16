#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-3
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

PLOT_ARGS=(
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_LLHscan.root -l 'v12' -o output/v12_Highland_3.22.4/OAR11B_P7E_v12_PlotLLH.pdf"
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_mirrored_LLHscan.root -l 'v12 mirrored' -o output/v12_Highland_3.22.4/OAR11B_P7E_v12_mirrored_PlotLLH.pdf"
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_LLHscan.root output/v12_Highland_3.22.4/OAR11B_P7E_v12_mirrored_LLHscan.root -l 'v12;v12 mirrored' -o output/v12_Highland_3.22.4/OAR11B_P7E_v12_unmirrored_vs_mirrored_PlotLLH.pdf"
  "output/v12_Highland_3.22.4/OAR11B_P7E_v12_LLHscan.root output/v11_MpiMSDialFix/OAR11B_P7E_v11_v6NDCov_LLHscan.root -l 'v12 (with WC);v11 (v6 ND Cov)' -o output/v12_Highland_3.22.4/OAR11B_P7E_v11_vs_v12_PlotLLH.pdf"
)

time -p {

echo Job started at $HOSTNAME
eval date

export MACH3_DL=/home/dlangrid/MaCh3_T2K/MaCh3_OA2024
source ${MACH3_DL}/DLsetup.sh
cd ${MACH3_DL}/build

eval ./bin/PlotLLH ${PLOT_ARGS[$SLURM_ARRAY_TASK_ID]}

}