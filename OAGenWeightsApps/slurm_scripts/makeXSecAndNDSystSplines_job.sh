#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=0-03:59
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-899
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

echo Job started at $HOSTNAME
eval date
echo

# INPUT_LOC=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/FlatTrees/Prod7E/v4_newSystCorrections/
INPUT_LOC=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/CovMatrix/psyche_throws_Highland_3.19/with_corrections/
FILE_LIST=($(< /home/dlangrid/sft/OAGenWeightsApps/PsycheToys_filenames_MC.txt))

# INPUT_LOC=/home/dlangrid/scratch/FlatTrees/Prod7E/highland2Master_3.19/
# FILE_LIST=($(< /home/dlangrid/scratch/FlatTrees/Prod7E/highland2Master_3.19/filenames_Sand.txt))

# OUTPUT_LOC=/home/dlangrid/scratch/Splines/Prod7E/OAGenWeightsAppsOutputs/v12_Highland_3.22.4_mirrored/
OUTPUT_LOC=/home/dlangrid/scratch/OAGenWeightsApps_Outputs/PsycheToys/For_pvalues/

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps
# NDGENWEIGHTS_CONFIG=${OAGW_DIR}/app/Configs/2024/ND280_OA2024_Config_NoMirroring.toml
NDGENWEIGHTS_CONFIG=${OAGW_DIR}/app/Configs/2024/ND280_OA2024_Config_Mirroring.toml
DETSPLINE_CONFIG=${OAGW_DIR}/app/Configs/2024/NDSyst_OA2024Selections.toml

XSEC_OUTPUT_LOC=$OUTPUT_LOC/Xsec_Weighted/
ND_OUTPUT_LOC=$OUTPUT_LOC/Xsec_and_NDS_Weighted/
# THROW_OUTPUT_LOC=$OUTPUT_LOC/ToyThrows/

FILE=${FILE_LIST[${SLURM_ARRAY_TASK_ID}]}

echo Info: running with input file
echo $INPUT_LOC$FILE
echo 
echo Info: will outputs to
echo $XSEC_OUTPUT_LOC/$FILE
# echo $ND_OUTPUT_LOC/$FILE
# echo $THROW_OUTPUT_LOC/$FILE

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh

ND280GenWeights -i $INPUT_LOC/$FILE -o $XSEC_OUTPUT_LOC/$FILE -c $NDGENWEIGHTS_CONFIG -t 2000

# makeND280SystSplines -i $XSEC_OUTPUT_LOC$FILE -o $ND_OUTPUT_LOC$FILE -c $DETSPLINE_CONFIG

# throwPsycheSplineToys -i $ND_OUTPUT_LOC$FILE -o $THROW_OUTPUT_LOC$FILE -c $DETSPLINE_CONFIG