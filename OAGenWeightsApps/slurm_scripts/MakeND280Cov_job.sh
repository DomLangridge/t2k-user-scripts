#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=60G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%j_%a.out
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! MakeND280Cov_job script !
# ! Step 3 of ND covariance matrix pipeline !

# ! Only needs to be run once !
# ! Make sure input .txt file includes all required NIWG weighted throws !

# --- JOB CONFIG ---

HL_VERSION=5.25.1

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

PSYCHE_TOYS_DIR=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/RunSystBinCorr
NIWG_TOYS_DIR=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/genWeightFromPsyche

OUTPUT_LOC=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/

# Toys list file
PSYCHE_TOYS_LIST=${OAGenWeightsApps_DIR}/PsycheToysList.txt
NIWG_TOYS_LIST=${OAGenWeightsApps_DIR}/NIWGToysList.txt

# Config file to use
BINNING_CONFIG=${OAGenWeightsApps_DIR}/app/Configs/ND280_Upgrade/ND_Binning_Upgrade.toml

# Output file (without .root suffix)
OUTPUT_NAME=NDCov_HL${HL_VERSION}

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

if [ -f "$PSYCHE_TOYS_LIST" ]; then
  echo "Psyche toys: $PSYCHE_TOYS_LIST already exists"
  echo "  -> using as psyche toys list"
else 
  echo "Psyche toys: $PSYCHE_TOYS_LIST does not exist"
  echo "  -> creating psyche toys list using following toys:"
  touch ${PSYCHE_TOYS_LIST}

  echo "  in $PSYCHE_TOYS_DIR"
  find ${PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}
fi

if [ -f "$NIWG_TOYS_LIST" ]; then
  echo "NIWG toys: $NIWG_TOYS_LIST already exists"
  echo "  -> using as NIWG toys list"
else 
  echo "NIWG toys: $NIWG_TOYS_LIST does not exist"
  echo "  -> creating NIWG toys list using following toys:"
  touch ${NIWG_TOYS_LIST}

  echo "  in $NIWG_TOYS_DIR"
  find ${NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}
fi

MakeND280Cov ${BINNING_CONFIG} ${PSYCHE_TOYS_LIST} ${NIWG_TOYS_LIST} ${OUTPUT_LOC}/${OUTPUT_NAME}

}