#!/bin/bash

# Script to run sfgTrackingAndMatchingSystematics project
# This script can be called directly, or through SubmitJobs_RunSfgTrackingAndMatchingSystematicsmulti.sh,
# the latter of which will make temporary job scripts to submit through bsub.

# Source HighLAND2 & required packages

export CC_SYSTEMATICS=/home/t2k/dlangrid/CC_Systematics
export SYST_PROJECT=$CC_SYSTEMATICS/sfgTrackingAndMatchingSystematics
cd $CC_SYSTEMATICS
source DLsetup_sfgTrackingAndMatchingSystematics.sh

# Job config

# The multi_job temp scripts will find and replace this to be true, while replacing output_blarb.root and input_blarb.root in the below if statement with relevant arguments
RunAsMultiJob=false
RunInCosmicsMode=false

# If just running / submitting this script as standalone, you should set the output/input here
OUTPUT=$SYST_PROJECT/output/output_blarb.root
INPUT=$CC_SYSTEMATICS/FileLists/P${MC_PROD}_V${MC_VERS}/MC/Test_MC.list

if $RunAsMultiJob; then
  OUTPUT=output_blarb.root
  INPUT=input_blarb.root
fi

# Run job
if $RunInCosmicsMode; then
  RunSfgTrackingAndMatchingSystematics.exe -c -o $OUTPUT $INPUT
else
  RunSfgTrackingAndMatchingSystematics.exe -o $OUTPUT $INPUT
fi