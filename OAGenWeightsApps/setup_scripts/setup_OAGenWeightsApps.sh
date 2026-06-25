#!/bin/bash

# DL:
# This script sources all dependencies (NEUT, NIWGReWeight, ND280Software, T2KReWeight) from the same parent directory
#   To change parent directory, change the path in line 8 below
#   If all dependencies are in different locations, this script may need a little rewrite :)

# unset OAGWDEPS_NEUT_VERSION
# unset OAGWDEPS_NIWGReWeight_VERSION
# unset OAGWDEPS_T2KReWeight_VERSION
# unset OAGWDEPS_HIGHLAND_VERSION
# unset OAGW_DIR_NAME
unset OAGENWEIGHTSAPPS_DIR

# ----- ARG PARSER -----

# Script help function
show_help() {
    echo "Usage: $0 [-h] [-n <NEUT_VERSION>] [-t <NIWGReWeight/T2KReWeight_VERSION>] [-v <HIGHLAND_VERSION>] [-o <OAGW_DIRECTORY>]"
}

# Use argument options
while getopts "hn:t:v:o:" opt; do
  case $opt in
    h) show_help; return 0
    ;;
    n) OAGWDEPS_NEUT_VERSION=$OPTARG
    ;;
    t) OAGWDEPS_NIWGReWeight_VERSION=$OPTARG
       OAGWDEPS_T2KReWeight_VERSION=$OPTARG
    ;;
    v) OAGWDEPS_HIGHLAND_VERSION=$OPTARG
    ;;
    o) OAGW_DIR_NAME=$OPTARG
    ;;
    \?) show_help; return 1
    ;;
  esac
done

# ----- DEFAULT VERSIONS -----

SFT_DIR=/home/dlangrid/sft

if test -z "$OAGW_DIR_NAME"; then
  OAGW_DIR_NAME=OAGenWeightsApps_UpgradeDev
fi
if test -z "$OAGWDEPS_HIGHLAND_VERSION"; then
  OAGWDEPS_HIGHLAND_VERSION=5.20
fi
if test -z "$OAGWDEPS_NEUT_VERSION"; then
  OAGWDEPS_NEUT_VERSION=5.8.0
fi
if test -z "$OAGWDEPS_NIWGReWeight_VERSION"; then
  OAGWDEPS_NIWGReWeight_VERSION=24.12
fi
if test -z "$OAGWDEPS_T2KReWeight_VERSION"; then
  OAGWDEPS_T2KReWeight_VERSION=24.12
fi

# ----------------------------

echo "-------------------------------------------------------------------------------------"
echo "Sourcing OAGenWeightsApps and dependencies"
echo "-------------------------------------------------------------------------------------"
echo "Version Control:"
echo "  OAGW:      $OAGW_DIR_NAME"
echo "  HighLAND2: $OAGWDEPS_HIGHLAND_VERSION"
echo "  NEUT:      $OAGWDEPS_NEUT_VERSION"
echo "  NIWGRW:    $OAGWDEPS_NIWGReWeight_VERSION"
echo "  T2KRW:     $OAGWDEPS_T2KReWeight_VERSION"
echo "-------------------------------------------------------------------------------------"

# build directories (named by dependency, except for OAGW)
BUILD_DIR_NEUT=build
BUILD_DIR_NIWGRW=build_with_NEUT${OAGWDEPS_NEUT_VERSION}
BUILD_DIR_T2KRW=build_with_NIWGRW${OAGWDEPS_NIWGReWeight_VERSION}_NEUT${OAGWDEPS_NEUT_VERSION}_HL${OAGWDEPS_HIGHLAND_VERSION}
BUILD_DIR_OAGW=build_HL${OAGWDEPS_HIGHLAND_VERSION}

cd ${SFT_DIR}
export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

cd ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/highland2SoftwarePilot
source highland2SoftwarePilot.profile

source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/psycheMaster_*/$(nd280-system)/setup.sh
source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/highland2Master_${OAGWDEPS_HIGHLAND_VERSION}/$(nd280-system)/setup.sh
source ${SFT_DIR}/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/oaAnalysisReader_*/$(nd280-system)/setup.sh

source ${SFT_DIR}/NEUT/NEUT_${OAGWDEPS_NEUT_VERSION}/$BUILD_DIR_NEUT/Linux/setup.sh

source ${SFT_DIR}/NIWGReWeight/NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}/$BUILD_DIR_NIWGRW/Linux/bin/setup.NIWG.sh

source ${SFT_DIR}/T2KReWeight/T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}/$BUILD_DIR_T2KRW/Linux/bin/setup.T2K.sh

# DL:
# You'll need to source all of the above before compiling OAGenWeightsApps
# Once compiled, update the below path to your OAGenWeightsApps directory and source
# OAGenWeightsApps should now be ready to use!

cd ${SFT_DIR}/OAGenWeightsApps/$OAGW_DIR_NAME

export OAGENWEIGHTSAPPS_DIR=$PWD
source ${OAGENWEIGHTSAPPS_DIR}/$BUILD_DIR_OAGW/Linux/bin/setup.OAGen.sh
cd ${OAGENWEIGHTSAPPS_DIR}/$BUILD_DIR_OAGW