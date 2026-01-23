#!/bin/bash -l
#SBATCH --account=def-blairt2k
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=80G
#SBATCH --time=23:59:59
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --output=logs/%x/%x_%a.out
#SBATCH --array=0-11
#SBATCH --mail-user=dominic.langridge.2023@live.rhul.ac.uk
#SBATCH --mail-type=END


# DL:
# ND280_PriorPosteriorPredictive job script

##### CONFIG #####

export MACH3_DIR=/home/dlangrid/MaCh3_T2K/MaCh3_OAR11B

BASECONFIGFILE=(
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_AsimovFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
  "p7_2024a_ND_DataFit_Predictives.yaml"
)

CREATE_PRIOR=(
  "false"
  "true"
  "false"
  "true"
  "false"
  "true"
  "false"
  "true"
  "false"
  "true"
  "false"
  "true"
)

SYSTEMATICS_ENABLED=(
  "xsec"
  "xsec"
  "flux"
  "flux"
  "det"
  "det"
  "xsec"
  "xsec"
  "flux"
  "flux"
  "det"
  "det"
)

# Output

# CHAIN_FILE=(
#   "OAR11B_P7E_v12_Asimov_MCMC.root"
#   "OAR11B_P7E_v12_Asimov_MCMC.root"
#   "OAR11B_P7E_v12_Data_MCMC.root"
#   "OAR11B_P7E_v12_Data_MCMC.root"
# )

##### RUN JOB #####

time -p {

echo Job started at $HOSTNAME
eval date

source ${MACH3_DIR}/DLsetup.sh
cd ${MACH3_DIR}/build

JOB_CONFIG=tempConfig_PriorPosteriorPredictive_${SLURM_ARRAY_TASK_ID}.yaml
cp ${MACH3_DIR}/build/configs/${BASECONFIGFILE[$SLURM_ARRAY_TASK_ID]} $JOB_CONFIG

# Fixed Systematics

FIX_XSEC="false"
FIX_FLUX="false"
FIX_DET="false"

if [ ${SYSTEMATICS_ENABLED[$SLURM_ARRAY_TASK_ID]} == "xsec" ]; then
  FIX_FLUX="true"
  FIX_DET="true"
else if [ ${SYSTEMATICS_ENABLED[$SLURM_ARRAY_TASK_ID]} == "flux" ]; then
  FIX_XSEC="true"
  FIX_DET="true"
else if [ ${SYSTEMATICS_ENABLED[$SLURM_ARRAY_TASK_ID]} == "det" ]; then
  FIX_XSEC="true"
  FIX_FLUX="true"
fi

COMMAND="sed -i 's/<FIX_XSEC>/"${FIX_XSEC}"/' $JOB_CONFIG"
eval $COMMAND
COMMAND="sed -i 's/<FIX_FLUX>/"${FIX_FLUX}"/' $JOB_CONFIG"
eval $COMMAND
COMMAND="sed -i 's/<FIX_DET>/"${FIX_DET}"/' $JOB_CONFIG"
eval $COMMAND

# Set prior if enabled

RUN_COMMAND="./bin/ND280_PriorPosteriorPredictive "${JOB_CONFIG}

if [ ${CREATE_PRIOR[$SLURM_ARRAY_TASK_ID]} == "true" ]; then
  RUN_COMMAND=${RUN_COMMAND}" CreatePrior"
fi

# Print settings and run job

echo ""
echo "Running command: "$RUN_COMMAND
echo "  Base config:  "${BASECONFIGFILE[$SLURM_ARRAY_TASK_ID]}
echo "  Create prior: "${CREATE_PRIOR[$SLURM_ARRAY_TASK_ID]}
echo "  Systematics:  "${SYSTEMATICS_ENABLED[$SLURM_ARRAY_TASK_ID]}
echo ""

eval ${RUN_COMMAND}

}
