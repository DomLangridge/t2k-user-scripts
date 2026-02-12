#!/bin/bash

# Setup

export DL_SFT=/home/dlangrid/sft # DL_SFT just means 'the place where I keep my various software'. Btw hi, it's me, DL :) Feel free to rename it I guess

export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

# Version Control

OAGW_BRANCH=develop
OAGWDEPS_NEUT_VERSION=5.8.0
OAGWDEPS_NIWGReWeight_VERSION=24.12
OAGWDEPS_T2KReWeight_VERSION=24.12
OAGWDEPS_HIGHLAND_VERSION=3.22.4
OAGW_BRANCH_NAME="develop"

echo "-------------------------------------------------------------------------------------"
echo "Cloning OAGenWeights and dependencies into: OAGenWeightsApps_$OAGW_BRANCH_NAME"
echo "-------------------------------------------------------------------------------------"
echo "Version Control:"
echo "  OAGW:      $OAGW_BRANCH"
echo "  NEUT:      $OAGWDEPS_NEUT_VERSION"
echo "  NIWGRW:    $OAGWDEPS_NIWGReWeight_VERSION"
echo "  HighLAND2: $OAGWDEPS_HIGHLAND_VERSION"
echo "  T2KRW:     $OAGWDEPS_T2KReWeight_VERSION"
echo "-------------------------------------------------------------------------------------"


# OAGenWeightsApps
if [ ! -d "$DL_SFT/OAGenWeightsApps" ]; then
  mkdir ${DL_SFT}/OAGenWeightsApps
fi
cd ${DL_SFT}/OAGenWeightsApps

if [ -d "$DL_SFT/OAGenWeightsApps/OAGenWeightsApps_${OAGW_BRANCH_NAME}" ]; then
  echo "NOTE: OAGenWeightsApps directory 'OAGenWeightsApps_${OAGenWeightsApps_${OAGW_BRANCH_NAME}}' already exists - will not clone"
else
  git clone --branch ${OAGW_BRANCH} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/OAGenWeightsApps.git OAGenWeightsApps_${OAGW_BRANCH_NAME}
fi


# NEUT

if [ ! -d "$DL_SFT/NEUT" ]; then
  mkdir ${DL_SFT}/NEUT
fi
cd ${DL_SFT}/NEUT

if [ -d "$DL_SFT/NEUT/NEUT_${OAGWDEPS_NEUT_VERSION}" ]; then
  echo "NOTE: NEUT directory 'NEUT_${OAGWDEPS_NEUT_VERSION}' already exists - will not clone"
else
  git clone --branch ${OAGWDEPS_NEUT_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/neut-devel/neut NEUT_${OAGWDEPS_NEUT_VERSION}
fi


# NIWGReWeight

if [ ! -d "$DL_SFT/NIWGReWeight" ]; then
  mkdir ${DL_SFT}/NIWGReWeight
fi
cd ${DL_SFT}/NIWGReWeight

if [ -d "$DL_SFT/NIWGReWeight/NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}" ]; then
  echo "NOTE: NIWGReWeight directory 'NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}' already exists - will not clone"
else
  git clone --branch ${OAGWDEPS_NIWGReWeight_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/NIWGReWeight.git NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}
fi


# HighLAND2

unset CMAKE_PREFIX_PATH

if [ ! -d "$DL_SFT/HighLAND2" ]; then
  mkdir ${DL_SFT}/HighLAND2
fi
cd ${DL_SFT}/HighLAND2

if [ -d "$DL_SFT/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}" ]; then
  echo "NOTE: HighLAND2 directory 'HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}' already exists"
else
  mkdir HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}
fi
cd HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}

export ND280_ROOT=$(pwd)
export ND280_NJOBS=1

if [ -d "$DL_SFT/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/nd280SoftwarePilot" ]; then
  echo "NOTE: HighLAND2 directory 'HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}' already contains package 'nd280SoftwarePilot' - will not clone"
else
  git clone https://oauth2:${GITLAB_TOKEN}@git.t2k.org/nd280/pilot/nd280SoftwarePilot.git
fi;
cd nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${ND280_ROOT}
if [ -d "$DL_SFT/HighLAND2/HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}/highland2SoftwarePilot" ]; then
  echo "NOTE: HighLAND2 directory 'HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}' already contains package 'highland2SoftwarePilot' - will not clone"
else
  git clone https://oauth2:${GITLAB_TOKEN}@git.t2k.org/nd280/highland2Software/highland2SoftwarePilot.git
fi
cd highland2SoftwarePilot
source highland2SoftwarePilot.profile

cd ${ND280_ROOT}

#KS You need to set the same C++ standard as used for ROOT. Highland is not smart enough to adjust it 
FlagsName=$(root-config --cflags)
CStandard="-DND280_PROJECT_CXX_STANDARD=11"
if [[ "$FlagsName" == *"-std=c++11"* ]]; then
  echo "Found root with -std=c++11"
  CStandard="-DND280_PROJECT_CXX_STANDARD=11"
elif [[ "$FlagsName" == *"-std=c++1x"* ]]; then
  echo "Found root with -std=c++11"
  CStandard="-DND280_PROJECT_CXX_STANDARD=11"
elif [[ "$FlagsName" == *"-std=c++1y"* ]]; then
  echo "Found root with -std=c++14"
  CStandard="-DND280_PROJECT_CXX_STANDARD=14"
elif [[ "$FlagsName" == *"-std=c++14"* ]]; then
  echo "Found root with -std=c++14"
  CStandard="-DND280_PROJECT_CXX_STANDARD=14"
elif [[ "$FlagsName" == *"-std=c++1z"* ]]; then
  echo "Found root with -std=c++17"
  CStandard="-DND280_PROJECT_CXX_STANDARD=17"
elif [[ "$FlagsName" == *"-std=c++17"* ]]; then
  echo "Found root with -std=c++17"
  CStandard="-DND280_PROJECT_CXX_STANDARD=17"
fi

highlandClone="highland-install -R -c ${CStandard} ${OAGWDEPS_HIGHLAND_VERSION}"

eval ${highlandClone}


# T2KReWeight

if [ ! -d "$DL_SFT/T2KReWeight" ]; then
  mkdir ${DL_SFT}/T2KReWeight
fi
cd ${DL_SFT}/T2KReWeight

if [ -d "$DL_SFT/T2KReWeight/T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}" ]; then
  echo "NOTE: T2KReWeight directory 'T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}' already exists - will not clone"
else
  git clone --branch ${OAGWDEPS_T2KReWeight_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/T2KReWeight.git T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}
fi


# Return to software directory

cd ${DL_SFT}
