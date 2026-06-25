#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# --- JOB CONFIG ---

echo Job started at $HOSTNAME
eval date
echo

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps/OAGenWeightsApps_UpgradeDev

INPUT_LOC=/scratch/dlangrid/UpgradeValidations/HL5.21/throwPsycheSplineToys/

OUTPUT_PREFIX=/scratch/dlangrid/UpgradeValidations/HL5.21/plotMultiInd/Output_plotMultiInd_HL5.21_

CONFIG=$OAGW_DIR/app/Configs/ND280_Upgrade/NDSyst_UpgradeSelections.toml

# --- RUN JOB ---

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh -v 5.21

COMMAND="plotMultiInd -o $OUTPUT_PREFIX -c $CONFIG"
    
for file in $INPUT_LOC/*; do

  COMMAND=${COMMAND}" "${file}
  echo "$file added to arg list"

done

echo "Running: $COMMAND"
eval $COMMAND