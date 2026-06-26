#!/bin/bash

export CC_SYSTEMATICS=/home/t2k/dlangrid/CC_Systematics
export SYST_PROJECT=$CC_SYSTEMATICS/sfgTrackingAndMatchingSystematics

cd $CC_SYSTEMATICS
source DLsetup_sfgTrackingAndMatchingSystematics.sh

OUTPUT_BASENAME=/home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/Plots/Plots_sfgTM_HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}

TITLE_LIST=(
  MC
  # Data
)

FILE_LIST=(
  /home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/Output_SfgTrackingAndMatching_Highland${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}_MC_wSand.root
  # /home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/Output_SfgTrackingAndMatching_Highland${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}_Data.root
)

PLOT_PULL_STUDY="python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}"

for (( i=0; i<${#TITLE_LIST[@]}; i++ )); do
  echo "python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}_${TITLE_LIST[$i]} ${TITLE_LIST[$i]}:${FILE_LIST[$i]}"
  python ${SYST_PROJECT}/macros/sfgTrackingAndMatchingPullStudies.py -o ${OUTPUT_BASENAME}_${TITLE_LIST[$i]} ${TITLE_LIST[$i]}:${FILE_LIST[$i]}
done