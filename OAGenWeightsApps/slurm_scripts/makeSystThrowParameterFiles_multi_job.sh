#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

HL_VERSION=5.27.1

SYST=(
  "BFieldDist"                  # Upgrade
  "MomResol"                    # Upgrade
  "MomRangeResol"
  "MomBiasFromVertexMigration"
  "MomScale"                    # Upgrade
  "TpcPid"                      # Upgrade
  "FgdPid"
  "ToFResol"                    # Upgrade
  "ECalMomScale"
  "ECalMomResol"
  "HATPID"                      # Upgrade
  "MomBiasSfg"                  # Upgrade
  "SFGdEdxMVAMomResol"          # Upgrade
)

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

FILE=${FILE_LIST[${SLURM_ARRAY_TASK_ID}]}

if [ ! -f "$INPUT_LOC/$FILE" ]; then
  echo "ERROR: Input file is not a file"
  echo "       ($INPUT_LOC/$FILE)"
  echo "       Exiting..."
  exit 1
fi

if [ $SLURM_ARRAY_TASK_ID -ge ${#FILE_LIST[@]} ]; then
  echo "Slurm array task ID "$SLURM_ARRAY_TASK_ID" larger than needed for number of input files ("${#FILE_LIST[@]}")"
  echo "Other jobs probably finished fine, but I'll exit this one"
  exit 1
fi

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

# Create backup of default psycheSteering parameters file

psycheSteeringFile=$PSYCHESTEERINGROOT/parameters/psycheSteering.parameters.dat
psycheSteeringBackup=$PSYCHESTEERINGROOT/parameters/psycheSteering.parameters_BackupForSystThrows.dat

cp $psycheSteeringFile $psycheSteeringBackup

# ========== Begin loop for each systematic ==========

for targetSyst in ${SYST[@]}; do

  # Create psycheSteering parameter file for syst throw
  psycheSteeringSyst=$PSYCHESTEERINGROOT/parameters/psycheSteering.parameters_throw_${targetSyst}.dat
  cp $psycheSteeringBackup $psycheSteeringSyst

  echo "=============================="
  echo "Editing: $psycheSteeringSyst"
  echo "=============================="

  for systname in ${SYST[@]}; do
    if [ $systname == $targetSyst ]; then
      # Activate desired systematic
      eval "sed -i 's/< psycheSteering.Variations.Enable'$systname' *= 0 >/< psycheSteering.Variations.Enable'$systname' = 1 >/' $psycheSteeringSyst"
    else
      # Deactivate other systematics
      eval "sed -i 's/< psycheSteering.Variations.Enable'$systname' *= 1 >/< psycheSteering.Variations.Enable'$systname' = 0 >/' $psycheSteeringSyst"
    fi
  done

  echo "$(<$psycheSteeringSyst)"
  echo "=============================="

done

}