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

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# NDCOV_DIR is general location of ND covariance production
NDCOV_DIR=/home/dlangrid/scratch/NDinputs/NDCov/v11_MpiMSDialFix/

# MC Toys
MC_PSYCHE_TOYS_DIR=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/CovMatrix/psyche_throws_Highland_3.19/with_corrections/MC/
MC_NIWG_TOYS_DIR=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/CovMatrix/psyche_throws_with_NIWG_Highland_3.19/with_corrections/MC/

# Sand Toys
SAND_ENABLED=true
SAND_PSYCHE_TOYS_DIR=/home/dlangrid/scratch/NDinputs/NDCov/v11_MpiMSDialFix/Sand/RunSystBinCorr/
SAND_NIWG_TOYS_DIR=/home/dlangrid/scratch/NDinputs/NDCov/v11_MpiMSDialFix/Sand/genWeightFromPsyche/

# Toys list file
PSYCHE_TOYS_LIST=${OAGenWeightsApps_DIR}/PsycheToysList.txt
NIWG_TOYS_LIST=${OAGenWeightsApps_DIR}/NIWGToysList.txt

# Config file to use
# BINNING_CONFIG=${OAGenWeightsApps_DIR}/app/Configs/2024/ND_Binning_4pi.toml
BINNING_CONFIG=${OAGenWeightsApps_DIR}/app/Configs/2024/ND_Binning_4pi_SampleBinning.toml


# Output file (without .root suffix)
OUTPUT_NAME=P7E_v11_NDCovMatrix_withSand_SampleBinning

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

if [ -f "$PSYCHE_TOYS_LIST" ]; then
  echo "Psyche toys: $PSYCHE_TOYS_LIST already exists"
  echo "  -> using as psyche toys list"
else 
  echo "Psyche toys: $PSYCHE_TOYS_LIST does not exist"
  echo "  -> creating psyche toys list using following toys:"
  touch ${PSYCHE_TOYS_LIST}

  echo "     MC:   $MC_PSYCHE_TOYS_DIR"
  find ${MC_PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}

  if [ "$SAND_ENABLED" = true ] ; then
    echo "     Sand: $SAND_PSYCHE_TOYS_DIR"
    find ${SAND_PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}
  else
    echo "     (Sand is disabled)"
  fi
fi

if [ -f "$NIWG_TOYS_LIST" ]; then
  echo "NIWG toys: $NIWG_TOYS_LIST already exists"
  echo "  -> using as NIWG toys list"
else 
  echo "NIWG toys: $NIWG_TOYS_LIST does not exist"
  echo "  -> creating NIWG toys list using following toys:"
  touch ${NIWG_TOYS_LIST}

  echo "     MC:   $MC_NIWG_TOYS_DIR"
  find ${MC_NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}

  if [ "$SAND_ENABLED" = true ] ; then
    echo "     Sand: $SAND_NIWG_TOYS_DIR"
    find ${SAND_NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}
  else
    echo "     (Sand is disabled)"
  fi
fi

./app/ND280/MakeND280Cov ${BINNING_CONFIG} ${PSYCHE_TOYS_LIST} ${NIWG_TOYS_LIST} ${NDCOV_DIR}/${OUTPUT_NAME}

}