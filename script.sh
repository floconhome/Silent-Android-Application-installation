#!/system/bin/sh

# error output redirection to /dev/null for whole script
exec 2>/dev/null

# verify prerequities
tmpDir=/data/local/tmp/floconhome.asi.$(date +%s)
mkdir -p $tmpDir
cp -f bin/aapt-arm-32 $tmpDir/aapt
chmod 777 $tmpDir/aapt
aapt=$tmpDir/aapt
echo
if [ -z "$($aapt version)" ]
then
  echo "- error while verifying prerequities: exit script"
  rm -rf $tmpDir
  exit
fi

# core
start=$(date +%s)
countAllAppsToInstall=$(find apps -mindepth 1 -type d | wc -l)
if [ $countAllAppsToInstall -eq 0 ]
then
  echo "- no subfolder found in the apps folder: exit script"
  exit
fi
echo "found $countAllAppsToInstall app(s) to install"
echo
count=1
find apps -mindepth 1 -type d -print0 | while read -r -d '' appFolder
do
  # get application label and version
  find "$appFolder" \( -iname "*.apk" -a ! -iname "split_*.apk" \) -print0 | while read -r -d '' apk
  do
    tmp=$($aapt d badging "$apk")
    label=$(echo "$tmp" | grep -i "application-label-$locale:")
    [ -z "$label" ] && label=$(echo "$tmp" | grep -i "application-label-$lang:")
    [ -z "$label" ] && label=$(echo "$tmp" | grep -i "application-label:")
    label=$(echo $label | cut -d: -f2 | sed "s/'//g")
    versionName=$(echo $tmp | grep -i versionname | cut -d= -f4 | cut -d\' -f2)
    echo "$label v$versionName ($count/$countAllAppsToInstall)"
    break
  done
  # install application
  echo "  > in progress"
  session_id=$(cmd package install-create -R | grep -Eo "[0-9]+")
  if [ -z "$session_id" ]
  then
    echo "KO: go on with next app"
   (( count += 1 ))
    continue
  fi
 find "$appFolder" -iname "*.apk" -print0 | while read -r -d '' apk
  do
    target=$tmpDir/$(basename "$apk" | sha256sum -b).apk
    cp -f "$apk" $target
    cmd package install-write $session_id $(basename $target) $target >/dev/null
    rm -f $target
  done
  rcs=$(cmd package install-commit $session_id)
  rc=$?
  if [ $rc -eq 0 ]
  then
    echo "  > SUCCESS"
  else
    if [ -z "$rcs" ]
    then
      echo "  > FAILURE with error code $rc: go on with next app"
    else
      echo "  > $rcs"
      echo "  > go on with next app"
    fi
  fi
  (( count += 1 ))
  echo
done
rm -rf $tmpDir
duration=$(( $(date +%s) - start ))

# end
echo duration: ${duration}s
echo
