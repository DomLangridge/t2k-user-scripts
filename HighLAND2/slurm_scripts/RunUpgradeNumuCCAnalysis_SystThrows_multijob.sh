#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=23:59:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-7
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! RunCreateFlatTrees job script !
# For recreating flattrees with updated highland / psyche settings

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=$PWD

HL_VERSION=5.27.1
MODE=all

# Flattree input and output directories
# If you provide the path to an individual file in FLATTREE_DIR it will just run over that one file
INPUT=/scratch/dlangrid/flattrees/HL5.27/Lists/FlatTreeList_${MODE}_HL5.27_converted_from_HL5.25.1.txt
# INPUT=/scratch/dlangrid/flattrees/HL${HL_VERSION}/Lists/FlatTreeList_${MODE}_HL${HL_VERSION}_converted_from_HL5.25.1.txt

SYST=(
  "BFieldDist"          # 0
  "MomRes"              # 1
  "MomScale"            # 2
  "TPCPID"              # 3
  "HATPID"              # 4
  "ToFResol"            # 5
  "MomBiasSfg"          # 6
  "SFGdEdxMVAMomResol"  # 7
)

PARAMETER_BASE=${OAGenWeightsApps_DIR}/HL_parameter_files/SystThrow.parameters.dat

OUTPUT=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}/UpgradeNumuCCAnalysis/SystThrows/Output_UpgradeNumuCCAnalysis_${SYST[$SLURM_ARRAY_TASK_ID]}_${MODE}_HL${HL_VERSION}.root

PARAMETER_TEMP=${OAGenWeightsApps_DIR}/HL_parameter_files/Temp/SystThrow_${SYST[$SLURM_ARRAY_TASK_ID]}.parameters.dat


# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh -v ${HL_VERSION}

cp $PARAMETER_BASE $PARAMETER_TEMP

for systname in ${SYST[@]}; do
  if [ $systname == ${SYST[$SLURM_ARRAY_TASK_ID]} ]; then
    # Activate desired systematic
    eval "sed -i 's/< baseUpgradeAnalysis.Variations.Enable'$systname' = 0 >/< baseUpgradeAnalysis.Variations.Enable'$systname' = 1 >/' $PARAMETER_TEMP"
  else
    # Deactivate other systematics
    eval "sed -i 's/< baseUpgradeAnalysis.Variations.Enable'$systname' = 1 >/< baseUpgradeAnalysis.Variations.Enable'$systname' = 0 >/' $PARAMETER_TEMP"
  fi
done

echo "Running RunUpgradeNumuCCAnalysis.exe"
echo "  Input:  $INPUT"
echo "  Output: $OUTPUT"
echo "  For Syst: ${SYST[$SLURM_ARRAY_TASK_ID]}"
echo "    Parameter base file: $PARAMETER_BASE"
echo ""
echo "=================================================="
echo "Printing modded parameter file: $PARAMETER_TEMP"
echo "=================================================="
echo "$(<$PARAMETER_TEMP)"
echo "=================================================="
echo "    Parameter modded file:  $PARAMETER_TEMP"

if [ -f $OUTPUT ]; then
  echo "WARNING: '$OUTPUT' already exists -> removing before running"
  rm $OUTPUT
fi

RunUpgradeNumuCCAnalysis.exe $INPUT -o $OUTPUT -p $PARAMETER_TEMP

}