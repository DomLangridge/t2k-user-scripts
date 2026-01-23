#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%j_%a.out
#SBATCH --array=0-10
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! GetPOTweight_multi_job script !
# ! Step 4 of input generation pipeline !

# ! Should only need to be run once !
# ! Runs separate job for each run !
# ! MAKE SURE NUMBER OF JOBS IN JOB ARRAY MATCHES NUMBER OF ENTRIES IN CONFIG ARRAYS !

# --- JOB CONFIG ---

# OAGenWeightsApps directory
OAGenWeightsApps_DIR=/home/dlangrid/sft/OAGenWeightsApps

# Location of Data inputs used for POT weight - usually the same production & version as MC / Sand being produced
DATA_DIR=/home/dlangrid/projects/def-blairt2k/shared/OA2024_Inputs/ND280/Splines/Prod7E/v10_Highland_3.22.1/Data

DATA_FILES=(
  run2aDataSplines.root
  run2wDataSplines.root
  run3DataSplines.root
  run4aDataSplines.root
  run4wDataSplines.root
  run5DataSplines.root
  run6DataSplines.root
  run7DataSplines.root
  run8aDataSplines.root
  run8wDataSplines.root
  run9DataSplines.root
)

# Spline directory - general location of MC / Sand production, specific location is handled by jobscript
SPLINE_DIR=/home/dlangrid/scratch/Splines/Prod7E/v11_MpiMSDialFix/Sand

SPLINE_FILES=(
  runFHCsand2aSplines.root
  runFHCsand2wSplines.root
  runFHCsand3Splines.root
  runFHCsand4aSplines.root
  runFHCsand4wSplines.root
  runRHCsand5Splines.root
  runRHCsand6Splines.root
  runRHCsand7Splines.root
  runFHCsand8aSplines.root
  runFHCsand8wSplines.root
  runRHCsand9Splines.root
)

# Output directory
OUTPUT_DIR=/home/dlangrid/scratch/Junk

OUTPUT_FILES=(
  JunkSandSpline_2a.root
  JunkSandSpline_2w.root
  JunkSandSpline_3.root
  JunkSandSpline_4a.root
  JunkSandSpline_4w.root
  JunkSandSpline_5.root
  JunkSandSpline_6.root
  JunkSandSpline_7.root
  JunkSandSpline_8a.root
  JunkSandSpline_8w.root
  JunkSandSpline_9.root
)

# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date

cd ${OAGenWeightsApps_DIR}
source setup_OAGenWeightsApps.sh

./app/ND280/GetPOTweight ${DATA_DIR}/${DATA_FILES[$SLURM_ARRAY_TASK_ID]} ${SPLINE_DIR}/${SPLINE_FILES[$SLURM_ARRAY_TASK_ID]} ${OUTPUT_DIR}/${OUTPUT_FILES[$SLURM_ARRAY_TASK_ID]}

}