#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=0-03:59
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-59
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# Modification fo Ewan's script to combine steps 1 and 2 (and psyche throws!) of spline generation
#
# WARNING: Max limit of slurm jobs is 900 (0-899)
#          If you have more files, you may have to run this multiple times

echo Job started at $HOSTNAME
eval date
echo

OAGW_DIR=$PWD

HL_VERSION=5.25

INPUT_LOC=/scratch/dlangrid/flattrees/HL${HL_VERSION}/converted_from_HL5.20/
cd $INPUT_LOC
FILE_LIST=(*.root)

OUTPUT_LOC=/scratch/dlangrid/UpgradeValidations/HL${HL_VERSION}

NDGENWEIGHTS_CONFIG=${OAGW_DIR}/app/Configs/ND280_Upgrade/ND280_Upgrade_Config_NoMirroring.toml
DETSPLINE_CONFIG=${OAGW_DIR}/app/Configs/ND280_Upgrade/NDSyst_UpgradeSelections.toml

XSEC_OUTPUT_LOC=$OUTPUT_LOC/ND280GenWeights/
ND_OUTPUT_LOC=$OUTPUT_LOC/makeND280SystSplines/
THROW_OUTPUT_LOC=$OUTPUT_LOC/throwPsycheSplineToys/

FILE=${FILE_LIST[${SLURM_ARRAY_TASK_ID}]}

if [ ! -f "$INPUT_LOC/$FILE" ]; then
  echo "ERROR: Input file is not a file"
  echo "       ($INPUT_LOC/$FILE)"
  echo "       Exiting..."
  exit 1
fi

XSEC_OUTPUT_NAME=Output_ND280GenWeights_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root
ND_OUTPUT_NAME=Output_makeND280SystSplines_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root
THROW_OUTPUT_NAME=Output_throwPsycheSplineToys_HL${HL_VERSION}_${SLURM_ARRAY_TASK_ID}.root


echo "=============================="
echo ""
echo "Info: running with input file"
echo "$INPUT_LOC/$FILE"
echo ""
echo "Info: will outputs to"
echo "$XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME"
echo "$ND_OUTPUT_LOC/$ND_OUTPUT_NAME"
echo "$THROW_OUTPUT_LOC/$THROW_OUTPUT_NAME"
echo ""
echo "=============================="

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh -v ${HL_VERSION}

# ----- ND280GenWeights -----

if [ -f $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME ]; then
  echo "output '$XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME' already exists -> removing before running"
  rm $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME
fi

echo "=====> Running ND280GenWeights <====="
ND280GenWeights -i $INPUT_LOC/$FILE -o $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME -c $NDGENWEIGHTS_CONFIG
echo "=====> Finished ND280GenWeights <====="


# ----- makeND280SystSplines -----

if [ -f $ND_OUTPUT_LOC/$ND_OUTPUT_NAME ]; then
  echo "output '$ND_OUTPUT_LOC/$ND_OUTPUT_NAME' already exists -> removing before running"
  rm $ND_OUTPUT_LOC/$ND_OUTPUT_NAME
fi

echo "=====> Running makeND280SystSplines <====="
makeND280SystSplines -i $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME -o $ND_OUTPUT_LOC/$ND_OUTPUT_NAME -c $DETSPLINE_CONFIG
echo "=====> Finished makeND280SystSplines <====="


# ----- throwPsycheSplineToys -----

if [ -f $THROW_OUTPUT_LOC/$THROW_OUTPUT_NAME ]; then
  echo "output '$THROW_OUTPUT_LOC/$THROW_OUTPUT_NAME' already exists -> removing before running"
  rm $THROW_OUTPUT_LOC/$THROW_OUTPUT_NAME
fi

echo "=====> Running throwPsycheSplineToys <====="
throwPsycheSplineToys -i $ND_OUTPUT_LOC/$ND_OUTPUT_NAME -o $THROW_OUTPUT_LOC/$THROW_OUTPUT_NAME -c $DETSPLINE_CONFIG
echo "=====> Finished throwPsycheSplineToys <====="