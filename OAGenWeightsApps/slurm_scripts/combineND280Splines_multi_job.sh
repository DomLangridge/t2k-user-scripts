#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=32G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=3,7
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! combineND280Splines_multi_job script !
# ! Step 3 of input generation pipeline !
# ! Updated to use outputs of makeXSecAndNDSystSplines_job.sh !

# ! Should only need to be run once !
# ! Script will run a separate job for each folder of XSec_ND files !
# ! MAKE SURE NUMBER OF JOBS IN JOB ARRAY MATCHES NUMBER OF ENTRIES IN CONFIG ARRAYS !

# --- JOB CONFIG ---

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps
INPUT_LOC=/home/dlangrid/scratch/Splines/Prod7E/OAGenWeightsAppsOutputs/v12_Highland_3.22.4_mirrored/XSec_ND/
OUTPUT_LOC=/home/dlangrid/scratch/Splines/Prod7E/OAGenWeightsAppsOutputs/v12_Highland_3.22.4_mirrored/CombinedSplines/

MODE_PATH_LIST=($(< /home/dlangrid/scratch/Splines/Prod7E/OAGenWeightsAppsOutputs/v12_Highland_3.22.4_mirrored/subdirstruct.txt))

# --- RUN JOB ---

MODE_PATH=${MODE_PATH_LIST[${SLURM_ARRAY_TASK_ID}]}

MC_TYPE=${MODE_PATH%/*}
MC_TYPE=${MC_TYPE##*/}

OUTPUT_FILE=${MC_TYPE}_${MODE_PATH##*/}_WithoutPOTweight.root

INPUT_FILES=($INPUT_LOC$MODE_PATH/*)

echo Info: running with input directory
echo $INPUT_LOC$MODE_PATH
echo 
echo Info: will output to
echo $OUTPUT_LOC"/"$MC_TYPE"/"$OUTPUT_FILE

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh

COMMAND="combineND280Splines -f -o "$OUTPUT_LOC"/"$MC_TYPE"/"$OUTPUT_FILE
for file in ${INPUT_FILES[@]}
do
  COMMAND=${COMMAND}" "${file}
  echo "$file added to arg list"
done

echo $COMMAND

eval $COMMAND