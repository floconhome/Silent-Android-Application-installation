#!/system/bin/sh

#todo
#- pm / cmd
#- data local tmp
#- split apk
#- doc
#- versioning: 1.0.0
#- busybox or toybox ?
#- aapt 64 et 33 ?
#- app already install: up to date ? no ?
#- coucou

bb=/system/bin/busybox
awk="$bb awk"
cat="$bb cat"
chmod="$bb chmod"
cp="$bb cp"
cut="$bb cut"
date="$bb date"
find="$bb find"
grep="$bb grep"
mkdir="$bb mkdir"
rev="$bb rev"
rm="$bb rm"
rmdir="$bb rmdir"
sed="$bb sed"
sort="$bb sort"
wc="$bb wc"

function try {
  for i in 1 2 3
  do
    "$@" &>/dev/null
    rc=$?
    [ "$rc" = "0" ] && break
  done
  echo "$rc:$i"
}

# load lang resource
locale=$(getprop persist.sys.locale)
lang=${locale:0:2}
[ ! "$lang" = "fr" -a ! "$lang" = "en" ] && lang=en
source ./$lang.txt
# end

# verify prerequities
if [ ! -d /data/local/tmp ]
then
  echo "$STR_NO_DATA_LOCAL_TMP"
  exit
fi
tmpDir="/data/local/tmp/$(date +%s)"
mkdir $tmpDir
cp -f aapt $tmpDir/aapt &>/dev/null
chmod a+x $tmpDir/aapt &>/dev/null
aapt=$tmpDir/aapt
if [ -z "$($bb)" ]
then
  echo "$STR_NO_BUSYBOX"
  exit
fi
# end

cd apk
countTotalAPK=$($find . -iname "*.apk" | $wc -l)
echo "$STR_COUNT_TOTAL_APK $countTotalAPK"
count=1
for apk in *.apk
do
  tmp=$($aapt d badging "$apk")
  # extract info
  label=$(echo "$tmp" | $grep -i "application-label-$locale:")
  [ -z "$label" ] && label=$(echo "$tmp" | $grep -i "application-label-$lang:")
  [ -z "$label" ] && label=$(echo "$tmp" | $grep -i "application-label:")
  label=$(echo $label | $cut -d: -f2 | $sed "s/'//g")
  versionName=$(echo $tmp | $grep -i versionname | $cut -d= -f4 | $cut -d\' -f2)
  versionCodeFromApk=$(echo $tmp | $grep -i versioncode | $cut -d= -f3 | $cut -d\' -f2)
  packageName=$(echo $tmp | $grep -i "package: name" | $cut -d= -f2 | $cut -d\' -f2)
  versionCodeFromSystem=$(pm list package --show-versioncode $packageName | $cut -d: -f3)
  echo -n "- [$count/$countTotalAPK] $label v$versionName: "
  # app already installed and up to date ?
  if [ ! -z "$versionCodeFromSystem" ]
  then
    if [ "$versionCodeFromApk" -lt "$versionCodeFromSystem" ]
    then
      echo "$STR_APP_ALREADY_INSTALLED"
       (( count = count + 1 ))
       continue
    fi
  fi
  # install process
  cpRes=$(try $cp -f "$apk" $tmpDir/app.apk)
  if [ ! "$cpRes" = "0:1" ]; then
    echo "$STR_ERROR_DURING_COPY (E$cpRes)"
    (( count = count + 1 ))
    continue
  fi
  pmRes=$(try pm install "$tmpDir/app.apk")
  if [ ! "$pmRes" = "0:1" ]; then
    echo "$STR_ERROR_DURING_INSTALLATION (E$pmRes)"
    (( count = count + 1 ))
    continue
  fi
  echo "OK"
  (( count = count + 1 ))
done

# remove stuff
rmRes=$(try $rm -rf $tmpDir)
if [ ! "$rmRes" = "0:1" ]
then
  echo "$STR_ERROR_DURING_CLEANING (E$rmRes), $STR_ERROR_DURING_CLEANING_WHAT_TO_DO $tmpDir"
fi
echo "$STR_GOODBYE"
