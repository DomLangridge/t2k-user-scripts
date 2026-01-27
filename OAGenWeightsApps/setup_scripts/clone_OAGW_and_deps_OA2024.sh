#!/bin/bash

# Setup

export DL_SFT=$(pwd)

export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

# Version Control

if test -z "$1"; then
  OAGW_BRANCH=develop
else
  OAGW_BRANCH=$1
fi

if test -z "$2"; then
  OAGWDEPS_NEUT_VERSION=5.8.0
else
  OAGWDEPS_NEUT_VERSION=$2
fi

if test -z "$3"; then
  OAGWDEPS_NIWGReWeight_VERSION=24.12
else
  OAGWDEPS_NIWGReWeight_VERSION=$3
fi

if test -z "$4"; then
  OAGWDEPS_HIGHLAND_VERSION=3.22.4
else
  OAGWDEPS_HIGHLAND_VERSION=$4
fi

if test -z "$5"; then
  OAGWDEPS_T2KReWeight_VERSION=$OAGWDEPS_NIWGReWeight_VERSION
else
  OAGWDEPS_T2KReWeight_VERSION=$5
fi

if test -z "$6"; then
  OAGW_BRANCH_NAME=$OAGW_BRANCH
else
  OAGW_BRANCH_NAME=$6
fi

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

git clone --branch ${OAGW_BRANCH} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/OAGenWeightsApps.git OAGenWeightsApps_${OAGW_BRANCH_NAME}

cd OAGenWeightsApps_${OAGW_BRANCH_NAME}
mkdir _deps


# NEUT

cd ${DL_SFT}/OAGenWeightsApps_${OAGW_BRANCH_NAME}/_deps
git clone --branch ${OAGWDEPS_NEUT_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/neut-devel/neut NEUT_${OAGWDEPS_NEUT_VERSION}


# NIWGReWeight

cd ${DL_SFT}/OAGenWeightsApps_${OAGW_BRANCH_NAME}/_deps
git clone --branch ${OAGWDEPS_NIWGReWeight_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/NIWGReWeight.git NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}

# HighLAND2

unset CMAKE_PREFIX_PATH

cd ${DL_SFT}/OAGenWeightsApps_${OAGW_BRANCH_NAME}/_deps
mkdir nd280_${OAGWDEPS_HIGHLAND_VERSION}
cd nd280_${OAGWDEPS_HIGHLAND_VERSION}

export ND280_ROOT=$(pwd)
export ND280_NJOBS=1

git clone https://oauth2:${GITLAB_TOKEN}@git.t2k.org/nd280/pilot/nd280SoftwarePilot.git
cd nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${ND280_ROOT}
git clone https://oauth2:${GITLAB_TOKEN}@git.t2k.org/nd280/highland2Software/highland2SoftwarePilot.git
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

cd ${DL_SFT}/OAGenWeightsApps_${OAGW_BRANCH_NAME}/_deps
git clone --branch ${OAGWDEPS_T2KReWeight_VERSION} --single-branch https://${GITHUB_TOKEN}@github.com:/t2k-software/T2KReWeight.git T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}

cd ${DL_SFT}/OAGenWeightsApps_${OAGW_BRANCH_NAME}
