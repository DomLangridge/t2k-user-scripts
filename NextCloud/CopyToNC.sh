User=
Password=

FromPath=/home/dlangrid/AltBinning_Outputs/v6_GaussRes
ToPath=https://nextcloud.nms.kcl.ac.uk/remote.php/dav/files/${User}/ASG/OA2024/ND280/Inputs/Binning/Polybinning_Tests/v6_GaussRes

NCScriptsDir=$(pwd)

cd ${FromPath}

FileList=(
  4PiMultiPiPhotonProton_PolyBins_v6_GaussRes_ThetaOpt_ResFix.root
)

for file in ${FileList[@]}
do
  echo "Uploading $file to $ToPath..."
  curl -u ${User}:${Password} -T ${FromPath}/$file ${ToPath}/$file
  echo "  Done"
done

echo "All files uploaded"

cd $NCScriptsDir
