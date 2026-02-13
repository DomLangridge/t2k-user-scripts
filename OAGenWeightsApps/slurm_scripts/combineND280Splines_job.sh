#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! combineND280Splines_multi_job script !
# ! Step 3 of input generation pipeline !
# ! Updated to use outputs of makeXSecAndNDSystSplines_job.sh !

# --- JOB CONFIG ---

echo Job started at $HOSTNAME
eval date
echo

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps/OAGenWeightsApps
INPUT_LOC=/home/dlangrid/scratch/Outputs_OAGenWeightsApps/Prod7E/v13Test_HadronicW_2a_5/NDS_and_Xsec_Weighted/
OUTPUT_LOC=/home/dlangrid/scratch/Outputs_OAGenWeightsApps/Prod7E/v13Test_HadronicW_2a_5/CombinedSplines/

SPLINE_TYPE=(
  MC
  # Data
  # Sand
)

# --- RUN JOB ---

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh

for (( i=0; i<${#SPLINE_TYPE[@]}; i++ )); do

  for SUBRUN_DIR in ${INPUT_LOC}/${SPLINE_TYPE[$i]}/*; do

    subrun=$(basename ${SUBRUN_DIR})
    OUTPUT_FILE="${SPLINE_TYPE[$i]}_${subrun}_WithoutPOTWeights.root"

    COMMAND="combineND280Splines -f -o ${OUTPUT_LOC}/${SPLINE_TYPE[$i]}/${OUTPUT_FILE}"
    
    for file in ${SUBRUN_DIR}/*; do

      COMMAND=${COMMAND}" "${file}
      echo "$file added to arg list"

    done

    echo "Combining $subrun splines..."
    echo "Running: $COMMAND"
    eval $COMMAND

  done

done