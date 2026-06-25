#!/bin/bash

export CC_SYSTEMATICS=/home/t2k/dlangrid/CC_Systematics
export SYST_PROJECT=$CC_SYSTEMATICS/sfgTrackingAndMatchingSystematics

cd $CC_SYSTEMATICS
source DLsetup_sfgTrackingAndMatchingSystematics.sh

OUTPUT_BASENAME=/home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics/output/HL5.6_P8V17/Plots/Plots_SfgTrackingAndMatching_Highland5.6_P8V17

TITLE_LIST=(
  MC
)

FILE_LIST=(
  /home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics/output/HL5.6_P8V17/Output_SfgTrackingAndMatching_Highland5.6_P8V17_MC_wSand.root
)

PLOT_PULL_STUDY="python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}"

for (( i=0; i<${#TITLE_LIST[@]}; i++ )); do
  echo "python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}_${TITLE_LIST[$i]} ${TITLE_LIST[$i]}:${FILE_LIST[$i]}"
  python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}_${TITLE_LIST[$i]} ${TITLE_LIST[$i]}:${FILE_LIST[$i]}
done