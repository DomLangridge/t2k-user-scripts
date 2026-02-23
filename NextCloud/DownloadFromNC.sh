User=
Password=

LocalPath=/home/dlangrid/scratch/Chains/Prod7E/v12_Highland_3.22.4/Asimov/

NCPath=https://nextcloud.nms.kcl.ac.uk/remote.php/dav/files/${User}/ASG/OA2024/MaCh3/ND_Fit/v12_Highland_3.22.4/Asimov/

NCScriptsDir=$(pwd)

FileList=(
  OAR11B_P7E_v12_Asimov_MCMC_drawCorr.root
)

for file in ${FileList[@]}
do
  echo "Downloading $file from $NCPath to $LocalPath ..."
  curl -u ${User}:${Password} ${NCPath}/$file --output ${LocalPath}/$file
done

echo "All files downloaded"

cd $NCScriptsDir
