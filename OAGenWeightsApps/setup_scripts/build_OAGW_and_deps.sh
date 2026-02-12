#!/bin/bash

# Setup

export DL_SFT=/home/dlangrid/sft

export ROOT_ROOT=$ROOTSYS
export ROOT_DIR=$ROOTSYS

# build options

build_neut=true
build_niwgrw=true
build_highland=true
build_t2krw=true
build_oagw=true

build_clean=true

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

# NEUT
if [ $build_neut == "true" ]; then
  echo "========================================"
  echo "Building NEUT"
  echo "========================================"
  cd ${DL_SFT}/NEUT
  cd NEUT_${OAGWDEPS_NEUT_VERSION}
  mkdir build
  cd build
  ../src/configure --prefix=$(readlink -f Linux) --enable-builtin-cernlib
  if [ $build_clean == "true" ]; then
    make clean
  fi
  make -j8
  make install
fi

# If this fails, check the neut github for install steps and troubleshooting

source ${DL_SFT}/NEUT/NEUT_${OAGWDEPS_NEUT_VERSION}/build/Linux/setup.sh


# NIWGReWeight (NEUT dependency)

if [ $build_niwgrw == "true" ]; then
  echo "========================================"
  echo "Building NIWGReWeight"
  echo "========================================"
  cd ${DL_SFT}/NIWGReWeight
  cd NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}
  mkdir build_with_NEUT${OAGWDEPS_NEUT_VERSION}
  cd build_with_NEUT${OAGWDEPS_NEUT_VERSION}
  cmake ../
  if [ $build_clean == "true" ]; then
    make clean
  fi
  make -j8
  make install
fi

source ${DL_SFT}/NIWGReWeight/NIWGReWeight_${OAGWDEPS_NIWGReWeight_VERSION}/build/Linux/bin/setup.NIWG.sh


# HighLAND2

unset CMAKE_PREFIX_PATH

cd ${DL_SFT}/HighLAND2
cd HighLAND2_${OAGWDEPS_HIGHLAND_VERSION}

export ND280_ROOT=$(pwd)
export ND280_NJOBS=1

cd nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${ND280_ROOT}
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

if [ $build_highland == "true" ]; then
  echo "========================================"
  echo "Building HighLAND2"
  echo "========================================"
  highlandInstall="highland-install -R -j4 ${CStandard} ${OAGWDEPS_HIGHLAND_VERSION}"

  eval ${highlandInstall}
fi

cd ${ND280_ROOT}/nd280SoftwarePilot
./configure.sh
source nd280SoftwarePilot.profile

cd ${ND280_ROOT}/highland2SoftwarePilot
source highland2SoftwarePilot.profile

# Double check paths of the below files - name specifics may need a tweak

source ${ND280_ROOT}/psycheMaster_*/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${ND280_ROOT}/highland2Master_${OAGWDEPS_HIGHLAND_VERSION}/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh
source ${ND280_ROOT}/oaAnalysisReader_*/Linux-AlmaLinux_9.6-gcc_12-x86_64/setup.sh

export ND280PROD=prod7E


# T2KReWeight (NIWGReWeight [NEUT] & HighLAND2 dependency)

if [ $build_t2krw == "true" ]; then
  echo "========================================"
  echo "Building T2KReWeight"
  echo "========================================"
  cd ${DL_SFT}/T2KReWeight
  cd T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}
  mkdir build_with_NIWGRW${OAGWDEPS_NIWGReWeight_VERSION}_NEUT${OAGWDEPS_NEUT_VERSION}_HL${OAGWDEPS_HIGHLAND_VERSION}
  cd build_with_NIWGRW${OAGWDEPS_NIWGReWeight_VERSION}_NEUT${OAGWDEPS_NEUT_VERSION}_HL${OAGWDEPS_HIGHLAND_VERSION}
  cmake ../
  if [ $build_clean == "true" ]; then
    make clean
  fi
  make -j8
  make install
fi

source ${DL_SFT}/T2KReWeight/T2KReWeight_${OAGWDEPS_T2KReWeight_VERSION}/build/Linux/bin/setup.T2K.sh


# OAGenWeightsApps (T2KReWeight [NIWGReWeight {NEUT} & HighLAND2] dependency)

if [ $build_oagw == "true" ]; then
  echo "========================================"
  echo "Building OAGenWeightsApps"
  echo "========================================"
  cd ${DL_SFT}/OAGenWeightsApps/OAGenWeightsApps_${OAGW_BRANCH_NAME}
  mkdir build
  cd build
  cmake ../
  if [ $build_clean == "true" ]; then
    make clean
  fi
  make -j8
  make install
fi

source ${DL_SFT}/OAGenWeightsApps/OAGenWeightsApps_${OAGW_BRANCH_NAME}/build/Linux/bin/setup.OAGen.sh