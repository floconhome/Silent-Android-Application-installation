#!/system/bin/sh

aapt=/data/local/tmp/asi/aapt-arm-32

# todo
# copier aapt32
# verifier /data/local/tmp
# stocker la sortie texte du commit + code erreur
# OK | si le write esr KO, alors supprioer la session ouis oasser a l'app suivante: non, la gestion du commit s'en occupera
# OK | si la sessionid est vide alors passer à l'app suivabte

function try {
  for i in 1 2 3
  do
    "$@" #&>/dev/null
    rc=$?
    [ "$rc" = "0" ] && break
  done
  echo "$rc:$i"
}

# load lang resource
locale=$(getprop persist.sys.locale)
lang=${locale:0:2}
[ ! "$lang" = "fr" -a ! "$lang" = "en" ] && lang=en
source res/$lang.txt

INSTALL_SUCCESS=0
INSTALL_FAILED_VERSION_DOWNGRADE=4
INSTALL_FAILED_ALREADY_EXISTS=5
INSTALL_FAILED_BAD_WRITE=255

start=$(date +%s)

countAllApps=$(find apps -mindepth 1 -type d | wc -l)
echo "$STR_COUNT_TOTAL_APK $countAllApps"
count=1

find apps -mindepth 1 -type d -print0 | while read -r -d '' appFolder
do
  # get application label
  find "$appFolder" \( -iname "*.apk" -a ! -iname "split_*.apk" \) -print0 | while read -r -d '' apk
  do
    tmp=$($aapt d badging "$apk")
    label=$(echo "$tmp" | grep -i "application-label-$locale:")
    [ -z "$label" ] && label=$(echo "$tmp" | grep -i "application-label-$lang:")
    [ -z "$label" ] && label=$(echo "$tmp" | grep -i "application-label:")
    label=$(echo $label | cut -d: -f2 | sed "s/'//g")
    versionName=$(echo $tmp | grep -i versionname | cut -d= -f4 | cut -d\' -f2)
    echo "$count/$countAllApps: $label v$versionName"
    break
  done
  # install apps
  echo "preparing... "
  session_id=$(cmd package install-create -R | grep -Eo "[0-9]+")
  if [ -z "$session_id" ]
  then
    echo session id void: next app
   (( count += 1 ))
    continue
  fi
 find "$appFolder" -iname "*.apk" -print0 | while read -r -d '' apk
  do
    target=/data/local/tmp/asi/$(basename "$apk" | sha256sum -b).apk
    #echo $target
    try cp -f "$apk" $target
    cmd package install-write $session_id $(basename $target) $target #>/dev/null
    #cmd package install-write $session_id poil /poul >/dev/null
    rm -f $target
  done
  echo "committing... "
  cmd package install-commit $session_id #>/dev/null
  rc=$?
  echo rc commit=$rc
  if [ $rc -eq $INSTALL_SUCCESS ]
  then
    echo "OK"
  elif [ $rc -eq $INSTALL_FAILED_VERSION_DOWNGRADE ]
  then
    echo "downgrade or invalide apk no pkg staged !!"
  elif [ $rc -eq $INSTALL_FAILED_ALREADY_EXISTS ]
  then
    echo "exists ;)"
  else
    echo unknown
  fi
  #cmd package install-abandon $session_id
  (( count += 1 ))
  echo
done

duration=$(( $(date +%s) - start ))
echo duration: ${duration}s