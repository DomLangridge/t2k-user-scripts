#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=0-03:59
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-139
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# Ewan's script to combine steps 1 and 2 (and psyche throws!) of spline generation
# Relies on .txt file lists, but is *significantly* quicker than my scripts
#
# Total amount of jobs required for MC (1206) is larger than slurm allows
# Therefore submit job twice:
# First: 0-899
# Second: 900-1205
#
# For Sand, just use 0-299

# 0 - 139 for 2a & 5 MC only

echo Job started at $HOSTNAME
eval date
echo

INPUT_LOC=/home/dlangrid/scratch/ND280_Inputs/FlatTrees/Prod7E/v4_newSystCorrections/with_corrections/
FILE_LIST=($(< ${INPUT_LOC}/../filenames_MC.txt))
# FILE_LIST=($(< ${INPUT_LOC}/../filenames_Data.txt))

OUTPUT_LOC=/home/dlangrid/scratch/Outputs_OAGenWeightsApps/Prod7E/v13Test_HadronicW_2a_5/

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps/OAGenWeightsApps
# NDGENWEIGHTS_CONFIG=${OAGW_DIR}/app/Configs/2024/ND280_OA2024_Config_NoMirroring.toml
NDGENWEIGHTS_CONFIG=${OAGW_DIR}/app/Configs/2024/ND280_OA2024_Config_Mirroring.toml
DETSPLINE_CONFIG=${OAGW_DIR}/app/Configs/2024/NDSyst_OA2024Selections.toml

XSEC_OUTPUT_LOC=$OUTPUT_LOC/Xsec_Weighted/
ND_OUTPUT_LOC=$OUTPUT_LOC/NDS_and_Xsec_Weighted/
# THROW_OUTPUT_LOC=$OUTPUT_LOC/ToyThrows/

FILE=${FILE_LIST[${SLURM_ARRAY_TASK_ID}]}

if [ ! -f "$INPUT_LOC/$FILE" ]; then
  echo "ERROR: Input file is not a file"
  echo "       ($INPUT_LOC/$FILE)"
  echo "       Exiting..."
  exit 1
fi

OUTFILE_PATH=${FILE%/*}
RUN_SUBDIR=$(basename ${OUTFILE_PATH})
XSEC_OUTPUT_NAME=$OUTFILE_PATH/XSec_Weighted_${RUN_SUBDIR}_${SLURM_ARRAY_TASK_ID}.root
ND_OUTPUT_NAME=$OUTFILE_PATH/NDS_and_XSec_Weighted_${RUN_SUBDIR}_${SLURM_ARRAY_TASK_ID}.root

echo "=============================="
echo ""
echo "Info: running with input file"
echo "$INPUT_LOC/$FILE"
echo ""
echo "Info: will outputs to"
echo "$XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME"
echo "$ND_OUTPUT_LOC/$ND_OUTPUT_NAME"
# echo "$THROW_OUTPUT_LOC/$FILE"
echo ""
echo "=============================="

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh

# ----- ND280GenWeights -----

if [ -f $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME ]; then
  echo "output '$XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME' already exists -> removing before running"
  rm $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME
fi

echo "=====> Running ND280GenWeights <====="
ND280GenWeights -i $INPUT_LOC/$FILE -o $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME -c $NDGENWEIGHTS_CONFIG
# ND280GenWeights -i $INPUT_LOC/$FILE -o $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME -c $NDGENWEIGHTS_CONFIG -t 2000


# ----- makeND280SystSplines -----

if [ -f $ND_OUTPUT_LOC/$ND_OUTPUT_NAME ]; then
  echo "output '$ND_OUTPUT_LOC/$ND_OUTPUT_NAME' already exists -> removing before running"
  rm $ND_OUTPUT_LOC/$ND_OUTPUT_NAME
fi

echo "=====> Runing makeND280SystSplines<====="
makeND280SystSplines -i $XSEC_OUTPUT_LOC/$XSEC_OUTPUT_NAME -o $ND_OUTPUT_LOC/$ND_OUTPUT_NAME -c $DETSPLINE_CONFIG


# ----- throwPsycheSplineToys -----

# throwPsycheSplineToys -i $ND_OUTPUT_LOC$FILE -o $THROW_OUTPUT_LOC$FILE -c $DETSPLINE_CONFIG