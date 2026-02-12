#!/bin/bash

# DL:
# This script sources all dependencies (NEUT, NIWGReWeight, ND280Software, T2KReWeight) from the same parent directory
#   To change parent directory, change the path in line 8 below
#   If all dependencies are in different locations, this script may need a little rewrite :)

SFT_DIR=/home/dlangrid/sft

OAGW_BRANCH_NAME="develop"
OAGWDEPS_NEUT_VERSION=5.8.0
OAGWDEPS_NIWGReWeight_VERSION=24.12
OAGWDEPS_HIGHLAND_VERSION=3.22.4
OAGWDEPS_T2KReWeight_VERSION=24.12

echo "-------------------------------------------------------------------------------------"
echo "Sourcing OAGenWeightsApps and dependencies"
echo "-------------------------------------------------------------------------------------"
echo "Version Control:"
echo "  OAGW:      $OAGW_BRANCH_NAME"
echo "  NEUT:      $OAGWDEPS_NEUT_VERSION"
echo "  NIWGRW:    $OAGWDEPS_NIWGReWeight_VERSION"
echo "  HighLAND2: $OAGWDEPS_HIGHLAND_VERSION"
echo "  T2KRW:     $OAGWDEPS_T2KReWeight_VERSION"
echo "-------------------------------------------------------------------------------------"

# build directories (named by dependency, except for OAGW)
BUILD_DIR_NEUT=build
BUILD_DIR_NIWGRW=build_with_NEUT${OAGWDEPS_NEUT_VERSION}
BUILD_DIR_T2KRW=build_with_NIWGRW${OAGWDEPS_NIWGReWeight_VERSION}_NEUT${OAGWDEPS_NEUT_VERSION}_HL${OAGWDEPS_HIGHLAND_VERSION}
BUILD_DIR_OAGW=build

cd ${SFT_DIR}
export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

source ${SFT_DIR}/NEUT/NEUT_${OAGWDEPS_NEUT_VERSION}/$BUILD_DIR_NEUT/Linux/setup.sh

source ${SFT_DIR}/NIWGReWeight/NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}/$BUILD_DIR_NIWGRW/Linux/bin/setup.NIWG.sh

cd ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/highland2SoftwarePilot
source highland2SoftwarePilot.profile

source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/psycheMaster_*/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/highland2Master_${OAGWDEPS_HIGHLAND_VERSION}/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/oaAnalysisReader_*/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh

export ND280PROD=prod7E

source ${SFT_DIR}/T2KReWeight/T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}/$BUILD_DIR_T2KRW/Linux/bin/setup.T2K.sh

# DL:
# You'll need to source all of the above before compiling OAGenWeightsApps
# Once compiled, update the below path to your OAGenWeightsApps directory and source
# OAGenWeightsApps should now be ready to use!

cd ${SFT_DIR}/OAGenWeightsApps/OAGenWeightsApps_$OAGW_BRANCH_NAME

export OAGENWEIGHTSAPPS_DIR=$PWD
source ${OAGENWEIGHTSAPPS_DIR}/$BUILD_DIR_OAGW/Linux/bin/setup.OAGen.sh
cd ${OAGENWEIGHTSAPPS_DIR}/$BUILD_DIR_OAGW

