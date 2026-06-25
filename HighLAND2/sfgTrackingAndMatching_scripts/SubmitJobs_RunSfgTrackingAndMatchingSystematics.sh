#!/bin/bash

# This script will submit one or more instances of RunSfgTrackingAndMatchingSystematics.exe using LSF job manager

# Job config & setup

unset COSMICS_MODE
unset CLEAN_OUTPUTS
unset VERBOSE

# Script options

show_help() {
    echo "Usage: $0 [-h (help)] [-c (cosmics mode)] [-f (clean outputs for overwrite)] [-v (verbose)]"
}

while getopts "hcf" opt; do
  case $opt in
    h) show_help; exit 0
    ;;
    c) COSMICS_MODE=true
    ;;
    f) CLEAN_OUTPUTS=true
    ;;
    v) VERBOSE=true
    ;;
  esac
done

export CC_SYSTEMATICS=/home/t2k/dlangrid/CC_Systematics
export SYST_PROJECT=$CC_SYSTEMATICS/sfgTrackingAndMatchingSystematics

cd $CC_SYSTEMATICS
source DLsetup_sfgTrackingAndMatchingSystematics.sh

BASE_SCRIPT=$SYST_PROJECT/Jobscripts/RunExe_RunSfgTrackingAndMatchingSystematics.sh*

OUTPUT_BASENAME=$SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/split_lists/Output_SfgTrackingAndMatching_Highland${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}

if ! test -d "$SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}"; then
  echo "Making output directory $SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}"
  mkdir $SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}
fi
if ! test -d "$SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/split_lists"; then
  echo "Making output directory $SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/split_lists"
  mkdir "$SYST_PROJECT/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/split_lists"
fi

INPUT_LIST=(
  "$CC_SYSTEMATICS/FileLists/P${MC_PROD}_V${MC_VERS}/Cosmics/split_lists"
  "$CC_SYSTEMATICS/FileLists/P${MC_PROD}_V${MC_VERS}/Data/split_lists"
  "$CC_SYSTEMATICS/FileLists/P${MC_PROD}_V${MC_VERS}/MC/split_lists"
  "$CC_SYSTEMATICS/FileLists/P${MC_PROD}_V${MC_VERS}/Sand/split_lists"
)

if test -z "$COSMICS_MODE"; then
  COSMICS_MODE=false
else
  OUTPUT_BASENAME=${OUTPUT_BASENAME}_CosmicsMode
fi

if test -z "$CLEAN_OUTPUTS"; then
  CLEAN_OUTPUTS=false
fi

if test -z "$VERBOSE"; then
  VERBOSE=false
fi

# Run job submission script

echo ""
echo "Running job submission script:  $0" 
echo "Running in cosmic mode:         $COSMICS_MODE"
echo "Using base RunExe script:       $BASE_SCRIPT"
echo "Running with clean mode:        $CLEAN_OUTPUTS"
echo ""

# Loop over input lists

for (( i=0; i<${#INPUT_LIST[@]}; i++ )); do

  # Loop over split lists

  for input in ${INPUT_LIST[$i]}/*; do

    output=$OUTPUT_BASENAME"_"$(basename ${input})".root"

    if $COSMICS_MODE; then
      LOGFILE=$SYST_PROJECT/logs/RunSfgTrackingAndMatchingSystematics_CosmicsMode_$(basename ${input}).log
      TEMP_SCRIPT=$SYST_PROJECT/Jobscripts/Temp_Scripts/Temp_sfgTrackingAndMatchingSystematics_CosmicsMode_$(basename ${input}).sh
    else
      LOGFILE=$SYST_PROJECT/logs/RunSfgTrackingAndMatchingSystematics_$(basename ${input}).log
      TEMP_SCRIPT=$SYST_PROJECT/Jobscripts/Temp_Scripts/Temp_sfgTrackingAndMatchingSystematics_$(basename ${input}).sh
    fi

    echo "----- Creating job: $input -----"
    if $VERBOSE; then
      echo "  Temp script:      $TEMP_SCRIPT"
      echo "  Output name:      $output"
      echo "  Input file/list:  $input"
      echo ""
    fi

    # Check if output file already exists

    if test -f "$output"; then
      if $CLEAN_OUTPUTS; then
        echo "  > Removing pre-existing output file: $output"
        rm $output
      else
        echo "  >>>>> ERROR: $output already exists - skipping job"
        continue
      fi
    fi

    # Check if log file already exists

    if test -f "${LOGFILE}"; then
      if $CLEAN_OUTPUTS; then
        echo "  > Removing pre-existing log file: $LOGFILE"
        rm $LOGFILE
      else
        echo "  >>>>> WARNING: (${LOGFILE}) already exists - will append job output to this file"
      fi
    fi

    # Check if temp script already exists

    if test -f "${TEMP_SCRIPT}"; then
      if $CLEAN_OUTPUTS; then
        echo "  > Removing pre-existing temp script: $TEMP_SCRIPT"
        rm $TEMP_SCRIPT
      else
        echo "  >>>>> WARNING: (${TEMPSCRIPT}) already exists"
      fi
    fi

    cp $BASE_SCRIPT $TEMP_SCRIPT

    if $COSMICS_MODE; then
      eval "sed -i 's,RunInCosmicsMode=false,RunInCosmicsMode=true,' $TEMP_SCRIPT"
    fi
    eval "sed -i 's,RunAsMultiJob=false,RunAsMultiJob=true,' $TEMP_SCRIPT"
    eval "sed -i 's,output_blarb.root,$output,' $TEMP_SCRIPT"
    eval "sed -i 's,input_blarb.root,$input,' $TEMP_SCRIPT"

    # Submit jobs

    BSUB_COMMAND="bsub -q l -n 6 -o $LOGFILE -N $TEMP_SCRIPT"
    if $VERBOSE; then
      echo "  Submitting job: $input"
      echo "  ($BSUB_COMMAND)"
    fi

    eval $BSUB_COMMAND
    
  done
done

echo "Done"