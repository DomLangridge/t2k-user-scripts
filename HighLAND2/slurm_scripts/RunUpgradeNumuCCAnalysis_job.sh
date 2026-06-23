#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! RunCreateFlatTrees job script !
# For recreating flattrees with updated highland / psyche settings

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps/OAGenWeightsApps_UpgradeDev

# Flattree input and output directories
# If you provide the path to an individual file in FLATTREE_DIR it will just run over that one file
INPUT=/scratch/dlangrid/flattrees/HL5.21/FlatTreeList_HL5.21_converted_from_HL5.20.txt
OUTPUT=/scratch/dlangrid/UpgradeValidations/HL5.21/Output_UpgradeNumuCCAnalysis_HL5.21.root

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

echo "Running RunUpgradeNumuCCAnalysis.exe"
echo "  Input:  $INPUT"
echo "  Output: $OUTPUT"

if [ -f $OUTPUT ]; then
  echo "WARNING: '$OUTPUT' already exists -> removing before running"
  rm $OUTPUT
fi

RunUpgradeNumuCCAnalysis.exe $INPUT -o $OUTPUT

}