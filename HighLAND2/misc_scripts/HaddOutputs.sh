#!/bin/bash

export SYST_DIR=/home/t2k/dlangrid/CC_Systematics/sfgTrackingAndMatchingSystematics

cd $SYST_DIR/output/HL${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}/split_lists

OUTPUT_BASENAME=Output_SfgTrackingAndMatching_Highland${HIGHLAND_VERSION}_P${MC_PROD}V${MC_VERS}

hadd ../${OUTPUT_BASENAME}_Cosmics.root ${OUTPUT_BASENAME}_Cosmics_*.root
hadd ../${OUTPUT_BASENAME}_Data.root ${OUTPUT_BASENAME}_Data_*.root
hadd ../${OUTPUT_BASENAME}_MC.root ${OUTPUT_BASENAME}_MC_*.root
hadd ../${OUTPUT_BASENAME}_Sand.root ${OUTPUT_BASENAME}_Sand_*.root

hadd ../${OUTPUT_BASENAME}_CosmicsMode_Cosmics.root ${OUTPUT_BASENAME}_CosmicsMode_Cosmics_*.root
hadd ../${OUTPUT_BASENAME}_CosmicsMode_Data.root ${OUTPUT_BASENAME}_CosmicsMode_Data_*.root
hadd ../${OUTPUT_BASENAME}_CosmicsMode_MC.root ${OUTPUT_BASENAME}_CosmicsMode_MC_*.root
hadd ../${OUTPUT_BASENAME}_CosmicsMode_Sand.root ${OUTPUT_BASENAME}_CosmicsMode_Sand_*.root

cd ..

hadd ${OUTPUT_BASENAME}_MC_wSand.root ${OUTPUT_BASENAME}_MC.root ${OUTPUT_BASENAME}_Sand.root

cd $SYST_DIR