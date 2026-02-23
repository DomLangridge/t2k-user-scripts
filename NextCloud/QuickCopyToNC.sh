User=
Password=

ToPath=https://nextcloud.nms.kcl.ac.uk/remote.php/dav/files/${User}/ASG/OA2024/MaCh3/ND_Fit/v12_Highland_3.22.4/

for file in "$@"
do
  FileName="$(basename $file)"

  echo "Uploading $FileName to $ToPath..."
  curl -u ${User}:${Password} -T $file ${ToPath}/$FileName
  echo "  Done"
done

echo "Finished uploading files"