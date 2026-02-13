#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END

# ! GetPOTweight_multi_job script !
# ! Step 4 of input generation pipeline !

# ! Should only need to be run once !
# ! Runs separate job for each run !
# ! MAKE SURE NUMBER OF JOBS IN JOB ARRAY MATCHES NUMBER OF ENTRIES IN CONFIG ARRAYS !

# --- JOB CONFIG ---

RUN=(
  "2a"
  # "2w"
  # "3"
  # "4a"
  # "4w"
  "5"
  # "6"
  # "7"
  # "8a"
  # "8w"
  # "9"
)

WEIGHT_MC=true
WEIGHT_SAND=false

OAGW_DIR=/home/dlangrid/sft/OAGenWeightsApps/OAGenWeightsApps

SPLINE_DIR=/home/dlangrid/scratch/Outputs_OAGenWeightsApps/Prod7E/v13Test_HadronicW_2a_5/

INPUT_LOC=$SPLINE_DIR/CombinedSplines/
OUTPUT_LOC=$SPLINE_DIR/WithPOTweights/

DATA_DIR=/home/dlangrid/scratch/Splines/Prod7E/v12_Highland_3.22.4/Data/



# --- RUN JOB ---

time -p {

echo Job started at $HOSTNAME
eval date
echo
echo Weight MC $WEIGHT_MC
echo Weight Sand $WEIGHT_SAND
echo

cd ${OAGW_DIR}
source ${OAGW_DIR}/setup_OAGenWeightsApps.sh

for (( i=0; i<${#RUN[@]}; i++ )); do

  # Data setup

  DATA_FILE=run${RUN[i]}DataSplines.root

  # ----- MC weighting -----
  if [ $WEIGHT_MC == "true" ]; then
    echo "-- Running MC POT weight --"
    echo "    run: "${RUN[$i]}
    echo "    MC input: "$INPUT_LOC/MC/$MC_FILE
    echo "    MC output: "$OUTPUT_LOC/MC/$MC_OUT_FILE
    echo "    Data file: "${DATA_DIR}/${DATA_FILE}


  # MC setup

    MC_OUT_FILE=run${RUN[$i]}MCsplines.root

    if [ ${RUN[$i]} == "2a" ]; then
      MC_FILE=MC_run2_air_p7_mcp_fhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "2w" ]; then
      MC_FILE=MC_run2_water_p7_mcp_fhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "3" ]; then
      MC_FILE=MC_run3_air_p7_mcp_fhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "4a" ]; then
      MC_FILE=MC_run4_air_p7_mcp_fhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "4w" ]; then
      MC_FILE=MC_run4_water_p7_mcp_fhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "5" ]; then
      MC_FILE=MC_run5_water_p7_mcp_rhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "6" ]; then
      MC_FILE=MC_run6_air_p7_mcp_rhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "7" ]; then
      MC_FILE=MC_run7_water_p7_mcp_rhc_WithoutPOTWeights.root

    elif [ ${RUN[$i]} == "8a" ]; then
      MC_FILE=MC_run8_air_p7_mcp_fhc_WithoutPOTWeights.root
      
    elif [ ${RUN[$i]} == "8w" ]; then
      MC_FILE=MC_run8_water_p7_mcp_fhc_WithoutPOTWeights.root
      
    elif [ ${RUN[$i]} == "9" ]; then
      MC_FILE=MC_run9_water_p7_mcp_rhc_WithoutPOTWeights.root

    fi

    ./app/ND280/GetPOTweight ${DATA_DIR}/${DATA_FILE} $INPUT_LOC/MC/$MC_FILE $OUTPUT_LOC/MC/$MC_OUT_FILE

    echo "-- MC weighting done --"
    echo
  fi

  # ----- Sand weighting -----

  if [ $WEIGHT_SAND == "true" ]; then
    echo "-- Running Sand POT weight --"
    echo "    run: "${RUN[$i]}
    echo "    Sand input: "$INPUT_LOC/Sand/$SAND_FILE
    echo "    Sand output: "$OUTPUT_LOC/Sand/$SAND_OUT_FILE
    echo "    Data file: "${DATA_DIR}/${DATA_FILE}

  # Sand setup

    if [[ ${RUN[$i]} == *"2"* ]] || [[ ${RUN[$i]} == *"3"* ]] || [[ ${RUN[$i]} == *"4"* ]]; then
      SAND_OUT_FILE=runFHCsand${RUN[$i]}Splines.root
      SAND_FILE=Sand_fhc_run4_WithoutPOTWeights.root

    elif [[ ${RUN[$i]} == *"8"* ]]; then
      SAND_OUT_FILE=runFHCsand${RUN[$i]}Splines.root
      SAND_FILE=Sand_fhc_run8_WithoutPOTWeights.root
      
    elif [[ ${RUN[$i]} == *"5"* ]] || [[ ${RUN[$i]} == *"6"* ]] || [[ ${RUN[$i]} == *"7"* ]] || [[ ${RUN[$i]} == *"9"* ]]; then
      SAND_OUT_FILE=runRHCsand${RUN[$i]}Splines.root
      SAND_FILE=Sand_rhc_WithoutPOTWeights.root

    fi


    ./app/ND280/GetPOTweight ${DATA_DIR}/${DATA_FILE} $INPUT_LOC/Sand/$SAND_FILE $OUTPUT_LOC/Sand/$SAND_OUT_FILE

    echo "-- Sand weighting done --"
    echo
  fi

done

}