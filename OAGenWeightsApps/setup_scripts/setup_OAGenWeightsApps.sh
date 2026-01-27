#!/bin/bash

# DL:
# This script sources all dependencies (NEUT, NIWGReWeight, ND280Software, T2KReWeight) from the same parent directory
#   To change parent directory, change the path in line 8 below
#   If all dependencies are in different locations, this script may need a little rewrite :)

SFT_DIR=/home/dlangrid/sft

OAGW_BRANCH_NAME=develop
OAGWDEPS_NEUT_VERSION=5.8.0
OAGWDEPS_NIWGReWeight_VERSION=24.12
OAGWDEPS_HIGHLAND_VERSION=3.22.4
OAGWDEPS_T2KReWeight_VERSION=24.08

cd ${SFT_DIR}
export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/NEUT_${OAGWDEPS_NEUT_VERSION}/build/Linux/setup.sh

source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}/build/Linux/bin/setup.NIWG.sh

cd ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/nd280_${OAGWDEPS_HIGHLAND_VERSION}/nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/nd280_${OAGWDEPS_HIGHLAND_VERSION}/highland2SoftwarePilot
source highland2SoftwarePilot.profile

source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/nd280_${OAGWDEPS_HIGHLAND_VERSION}/psycheMaster_4.21.3/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/nd280_${OAGWDEPS_HIGHLAND_VERSION}/highland2Master_3.22.4/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/nd280_${OAGWDEPS_HIGHLAND_VERSION}/oaAnalysisReader_3.4/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh

export ND280PROD=prod7E

source ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME/_deps/T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}/build/Linux/bin/setup.T2K.sh

# DL:
# You'll need to source all of the above before compiling OAGenWeightsApps
# Once compiled, update the below path to your OAGenWeightsApps directory and source
# OAGenWeightsApps should now be ready to use!

cd ${SFT_DIR}/OAGenWeightsApps_$OAGW_BRANCH_NAME

export OAGENWEIGHTSAPPS_DIR=$PWD
source ${OAGENWEIGHTSAPPS_DIR}/build/Linux/bin/setup.OAGen.sh
cd ${OAGENWEIGHTSAPPS_DIR}/build