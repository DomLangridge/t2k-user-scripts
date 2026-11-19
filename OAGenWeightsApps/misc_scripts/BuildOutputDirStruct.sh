#!/bin/bash -l

### CONFIG ¢¢¢

DIR_LIST=(
  ND280GenWeights
  ND280GenWeights/neut
  ND280GenWeights/neut/NoMirroring
  ND280GenWeights/neut/Mirroring
  ND280GenWeights/sand
  ND280GenWeights/data
  makeND280SystSplines
  makeND280SystSplines/neut
  makeND280SystSplines/neut/NoMirroring
  makeND280SystSplines/neut/Mirroring
  makeND280SystSplines/sand
  throwPsycheSplineToys
  throwPsycheSplineToys/neut
  throwPsycheSplineToys/neut/NoMirroring
  throwPsycheSplineToys/neut/Mirroring
  throwPsycheSplineToys/sand
  combineND280Splines
  GetPOTweight
  plotMultiInd
  RunSystBinCorr
  RunSystBinCorr/neut
  RunSystBinCorr/sand
  genWeightFromPsyche
  genWeightFromPsyche/neut
  genWeightFromPsyche/sand
  MakeND280Cov
  MergeND280CovBins
  optimiseBinning
)

### RUN SCRIPT ###

if [ -z "$1" ]; then
  echo "Come on buddy you need to tell me where to build the structures"
  echo "-> run as ./BuildOutputDirStruct.sh <OAGWoutput_root_dir>"
  exit 1
fi

CurrentDir=$PWD

cd $1
StructRootDir=$PWD

echo "making output directory struct for OAGW stuff in this directory: $StructRootDir"

for path in ${DIR_LIST[@]}; do
  echo "Making $StructRootDir/$path"
  mkdir $path
done

cd $CurrentDir
