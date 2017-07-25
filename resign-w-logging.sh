#/bin/bash
function realpath() {
  OURPWD=$PWD
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
}

ipafile=$1
if [[ $2 =~ .*\.ipa$ ]]; then
    ipafile=$2
fi

if [ -f "$ipafile" ]; then
    logdir=$(dirname $(realpath "$ipafile"))
else
    logdir="$HOME"
fi
./resign.sh "$@" &> "$logdir/resignlog.txt"