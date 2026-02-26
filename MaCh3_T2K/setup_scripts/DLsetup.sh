#!/bin/bash -l

# Set ND spline paths - MAKE SURE THESE PATHS ARE CORRECT
export MACH3_DATA=/home/dlangrid/scratch/Splines/Prod7E/v12_Highland_3.22.4/Data/
export MACH3_MC=/home/dlangrid/scratch/Splines/Prod7E/v12_Highland_3.22.4/MC/
export MACH3_SAND=/home/dlangrid/scratch/Splines/Prod7E/v12_Highland_3.22.4/Sand/

# Set MaCh3 paths - MAKE SURE THESE PATHS ARE CORRECT
export MACH3_T2K=/home/dlangrid/MaCh3_T2K/MaCh3_OAR11B
export MACH3_CORE=/home/dlangrid/MaCh3_Core/v1.5.0_patches


# Reset important variables (required when sourcing script)
unset T2K_BUILD_DIR
unset CORE_BUILD_DIR
unset OMP_NUM_THREADS
unset INBUILT_CORE
OPTIND=1

# Script help function
show_help() {
    echo "Usage: $0 [-h] [-t <MaCh3_T2K_build_dir>] ([-c <MaCh3_Core_build_dir>] or [-b] to use in-built core) [-n <OMP_num_threads>]"
}

# Use argument options
#   -h to view help output (see above)
#   -t to set MaCh3 T2K build directory
#   -c to set MaCh3 Core build directory
#   -n to set number of OMP threads (use '-n 1' when running debug | use '-n unset' to unset variable)
while getopts "ht:bc:n:" opt; do
  case $opt in
    h) show_help; return 0
    ;;
    t) export T2K_BUILD_DIR=$OPTARG
    ;;
    b) export INBUILT_CORE=true
    ;;
    c) export CORE_BUILD_DIR=$OPTARG
    ;;
    n)
      if [ $OPTARG == "unset" ]; then
        unset OMP_NUM_THREADS; echo "- Unsetting OMP_NUM_THREADS"
      elif [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
        echo "  ERROR: Selected OMP_NUM_THREADS option is not an integer"; return 2
      else
        export OMP_NUM_THREADS=$OPTARG; echo "- Setting OMP_NUM_THREADS="$OPTARG
      fi
    ;;
    \?) show_help; return 1
    ;;
  esac
done

# Set INBUILT_CORE to false if not set
if test -z "$INBUILT_CORE"; then
  export INBUILT_CORE=false
fi

# Use default number of threads if none set
if test -z "$OMP_NUM_THREADS"; then
  export OMP_NUM_THREADS=8
  echo "- No thread number chosen: using default "$OMP_NUM_THREADS" threads"
fi

# Use default t2k build directory if none set
if test -z "$T2K_BUILD_DIR"; then
  # Edit below line to change default build directory
  export T2K_BUILD_DIR=build_gpu
  echo "- No MaCh3 T2K build directory chosen: using default "$T2K_BUILD_DIR
else
  echo "- Using MaCh3 T2K build directory "$T2K_BUILD_DIR
fi

# Check if chosen t2k build directory exists
if [ ! -d "${MACH3_T2K}/$T2K_BUILD_DIR" ]; then
  echo "  ERROR: "${MACH3_T2K}"/"$T2K_BUILD_DIR" does not exist"
  unset T2K_BUILD_DIR

  if test -z "$1"; then
    echo "           Please update default MaCh3 T2K build directory" 
  fi
  echo ""
  CHECK_BUILD_DIRS="ls "$MACH3_T2K" | grep build"
  echo "Available builds in "$MACH3_T2K":"
  eval $CHECK_BUILD_DIRS
  echo ""

  return 2
fi

# Use default core build directory if none set and not using inbuilt
if ! $INBUILT_CORE; then
  if test -z "$CORE_BUILD_DIR"; then
    # Edit below line to change default build directory
    export CORE_BUILD_DIR=$T2K_BUILD_DIR
    echo "- No MaCh3 Core build directory chosen: using same type as MaCh3 T2K ("$MACH3_CORE/$CORE_BUILD_DIR")"
  else
    echo "- Using MaCh3 Core build directory "$MACH3_CORE/$CORE_BUILD_DIR
  fi

  # Check if chosen core build directory exists
  if [ ! -d "${MACH3_CORE}/$CORE_BUILD_DIR" ]; then
    echo "  ERROR: "${MACH3_CORE}"/"$CORE_BUILD_DIR" does not exist"
    unset CORE_BUILD_DIR

    if test -z "$1"; then
      echo "           Please update default MaCh3 Core build directory" 
    fi
    echo ""
    CHECK_BUILD_DIRS="ls "$MACH3_CORE" | grep build"
    echo "Available builds in "$MACH3_CORE":"
    eval $CHECK_BUILD_DIRS
    echo ""

    return 2
  fi

else
  echo "- Sourcing in-built MaCh3 Core"
  if ! test -z "$CORE_BUILD_DIR"; then
    echo "  WARNING: You've asked to use in-built MaCh3 Core, but also set a core build directory"
    echo "           Will ignore build dir and just use in-built Core"
  fi
fi

# Source psyche (optional)
# cd ${MACH3_T2K}
# cd psychestuff/nd280SoftwarePilot/
# ./configure.sh
# source nd280SoftwarePilot.profile
# cd ../highland2SoftwarePilot
# source highland2SoftwarePilot.profile
# cd ../
# source psycheMaster_*/Linux*/setup.sh

# Source MaCh3 and required dependencies
if $INBUILT_CORE; then
  source ${MACH3_T2K}/${T2K_BUILD_DIR}/bin/setup.MaCh3.sh
else
  source ${MACH3_CORE}/${CORE_BUILD_DIR}/bin/setup.MaCh3.sh
fi
source ${MACH3_T2K}/${T2K_BUILD_DIR}/bin/setup.NIWG.sh
source ${MACH3_T2K}/${T2K_BUILD_DIR}/bin/setup.MaCh3T2K.sh

# Enter build directory - ready to run MaCh3!
cd ${MACH3_T2K}/$T2K_BUILD_DIR
