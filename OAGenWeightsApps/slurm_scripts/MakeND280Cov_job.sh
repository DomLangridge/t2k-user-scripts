#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=60G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-2
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! MakeND280Cov_job script !
# ! Step 3 of ND covariance matrix pipeline !

# ! Only needs to be run once !
# ! Make sure input .txt file includes all required NIWG weighted throws !

# --- JOB CONFIG ---

HL_VERSION=5.27.1

MODE=(
  "all"
  "neut"
  "sand"
)

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

OUTPUT_LOC=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}

PSYCHE_TOYS_DIR=$OUTPUT_LOC/RunSystBinCorr/${MODE[$SLURM_ARRAY_TASK_ID]}
NIWG_TOYS_DIR=$OUTPUT_LOC/genWeightFromPsyche/${MODE[$SLURM_ARRAY_TASK_ID]}

# Toys list file
PSYCHE_TOYS_LIST=$OUTPUT_LOC/Lists/PsycheToysList_${MODE[$SLURM_ARRAY_TASK_ID]}.txt
NIWG_TOYS_LIST=$OUTPUT_LOC/Lists/NIWGToysList_${MODE[$SLURM_ARRAY_TASK_ID]}.txt

# Config file to use
BINNING_CONFIG=${OAGenWeightsApps_DIR}/app/Configs/ND280_SFGinc/ND_Binning_SFGincOnly_SampleBinning.toml

# Output file (without .root suffix)
OUTPUT_NAME=MakeND280Cov/NDCov_HL${HL_VERSION}_${MODE[$SLURM_ARRAY_TASK_ID]}

### Syst Throw Settings ###
throwSyst=true

# targetSyst=BFieldDist                  # Upgrade
# targetSyst=MomResol                    # Upgrade
# targetSyst=MomRangeResol
# targetSyst=MomBiasFromVertexMigration
# targetSyst=MomScale                    # Upgrade
# targetSyst=TpcPid                      # Upgrade
# targetSyst=FgdPid
# targetSyst=ToFResol                    # Upgrade
# targetSyst=ECalMomScale
# targetSyst=ECalMomResol
targetSyst=HATPID                      # Upgrade
# targetSyst=MomBiasSfg                  # Upgrade
# targetSyst=SFGdEdxMVAMomResol          # Upgrade

if [ "$throwSyst" == true ]; then

  if [ ! -d "$OUTPUT_LOC/Lists/$targetSyst" ]; then
    echo "Making directory: $OUTPUT_LOC/Lists/$targetSyst"
    mkdir $OUTPUT_LOC/Lists/$targetSyst
  fi

  PSYCHE_TOYS_LIST=$OUTPUT_LOC/Lists/$targetSyst/PsycheToysList_${targetSyst}_${MODE[$SLURM_ARRAY_TASK_ID]}.txt
  NIWG_TOYS_LIST=$OUTPUT_LOC/Lists/$targetSyst/NIWGToysList_${targetSyst}_${MODE[$SLURM_ARRAY_TASK_ID]}.txt

  PSYCHE_TOYS_DIR=$OUTPUT_LOC/RunSystBinCorr/${MODE[$SLURM_ARRAY_TASK_ID]}/$targetSyst
  NIWG_TOYS_DIR=$OUTPUT_LOC/genWeightFromPsyche/${MODE[$SLURM_ARRAY_TASK_ID]}/$targetSyst

  if [ ! -d "$OUTPUT_LOC/MakeND280Cov/$targetSyst" ]; then
    echo "Making directory: $OUTPUT_LOC/MakeND280Cov/$targetSyst"
    mkdir $OUTPUT_LOC/MakeND280Cov/$targetSyst
  fi

  OUTPUT_NAME=MakeND280Cov/$targetSyst/NDCov_HL${HL_VERSION}_${targetSyst}_${MODE[$SLURM_ARRAY_TASK_ID]}
fi

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

# Check if psyche toys list exists
if [ -f "$PSYCHE_TOYS_LIST" ]; then
  echo "Psyche toys: $PSYCHE_TOYS_LIST exists"
  echo "  -> using as psyche toys list"

# If not, make toy list
else
  echo "Psyche toys: $PSYCHE_TOYS_LIST does not exist"
  echo "  -> creating psyche toys list using following toys:"
  touch ${PSYCHE_TOYS_LIST}

  # Make list for all modes (neut and sand)
  if [ "${MODE[$SLURM_ARRAY_TASK_ID]}" == "all" ]; then
    NEUT_PSYCHE_TOYS_DIR=$OUTPUT_LOC/RunSystBinCorr/neut
    SAND_PSYCHE_TOYS_DIR=$OUTPUT_LOC/RunSystBinCorr/sand
    if [ "$throwSyst" == true ]; then
      NEUT_PSYCHE_TOYS_DIR=$NEUT_PSYCHE_TOYS_DIR/$targetSyst
      SAND_PSYCHE_TOYS_DIR=$SAND_PSYCHE_TOYS_DIR/$targetSyst
    fi
    echo " in neut dir:  $NEUT_PSYCHE_TOYS_DIR"
    echo " and sand dir: $SAND_PSYCHE_TOYS_DIR"
    find ${NEUT_PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}
    find ${SAND_PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}

  # Make list for specific mode
  else
    echo "  in $PSYCHE_TOYS_DIR"
    find ${PSYCHE_TOYS_DIR} -name '*.root' >> ${PSYCHE_TOYS_LIST}
  fi
fi

# Check if NIWG toys list exists
if [ -f "$NIWG_TOYS_LIST" ]; then
  echo "NIWG toys: $NIWG_TOYS_LIST exists"
  echo "  -> using as NIWG toys list"

# If not, make toy list
else
  echo "NIWG toys: $NIWG_TOYS_LIST does not exist"
  echo "  -> creating NIWG toys list using following toys:"
  touch ${NIWG_TOYS_LIST}

  # Make list for all modes (neut and sand)
  if [ "${MODE[$SLURM_ARRAY_TASK_ID]}" == "all" ]; then
    NEUT_NIWG_TOYS_DIR=$OUTPUT_LOC/genWeightFromPsyche/neut
    SAND_NIWG_TOYS_DIR=$OUTPUT_LOC/genWeightFromPsyche/sand
    if [ "$throwSyst" == true ]; then
      NEUT_NIWG_TOYS_DIR=$NEUT_NIWG_TOYS_DIR/$targetSyst
      SAND_NIWG_TOYS_DIR=$SAND_NIWG_TOYS_DIR/$targetSyst
    fi
    echo " in neut dir:  $NEUT_NIWG_TOYS_DIR"
    echo " and sand dir: $SAND_NIWG_TOYS_DIR"
    find ${NEUT_NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}
    find ${SAND_NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}

  # Make list for specific mode
  else
    echo "  in $NIWG_TOYS_DIR"
    find ${NIWG_TOYS_DIR} -name '*.root' >> ${NIWG_TOYS_LIST}
  fi
fi

# Run MakeND280Cov with using psyche and NIWG toys lists
MakeND280Cov ${BINNING_CONFIG} ${PSYCHE_TOYS_LIST} ${NIWG_TOYS_LIST} ${OUTPUT_LOC}/${OUTPUT_NAME}

}