#/bin/bash
#sudo pip install iResign


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


function create_temp {
    export TEMPDIR=$(mktemp -d -t iphoneipa-resign)
    mkdir "$TEMPDIR/app"
    mkdir "$TEMPDIR/provisioning"
}

function remove_temp {
  if [ -d "$TEMPDIR" ]; then
    rm -rf "$TEMPDIR"
  fi
}

function unpackage_ipa {
  ipa_path=$(realpath $1)
  export IPA_BASE=$(basename "$ipa_path")
  export IPA_DIR=$(dirname "$ipa_path")
  unzip "$ipa_path" -d "$TEMPDIR/app"
  

}

function copy_app_provision_profile {
  profile="$1"
  if [ -f "$profile" ]; then
    cp "$profile" "$TEMPDIR/provisioning"
  fi

}

function find_app_within_unpackaged_ipa {
  res=$(find "$TEMPDIR" -name "*.app" | head -1)
  echo $res

}

function get_provision_profile {
  res=$(find "$TEMPDIR/provisioning" -name "*.mobileprovision" | head -1)
  echo $res
}

function resign_app {
  #sign_identity="iPhone Developer"
  sign_identity="$1"
  app_path=$(find_app_within_unpackaged_ipa)
  if [ -d "$app_path" ]; then
    profile=$(get_provision_profile)
    if [ -f "$profile" ]; then
        pythonw2.7 "$BINARY_DIR/iresign.py" -v "$app_path" "$profile" "$sign_identity" 
    else
        echo "ERROR: could not find provisioning profile, aborting resign!"
        exit -2
    fi
  else
    echo "ERROR: aborting, could not find app folder within .ipa!"
    exit -1
  fi

}



function get_app_signature {
    app_path=$(find_app_within_unpackaged_ipa)
    if [ -d "$app_path" ]; then
        res=$(codesign -dv "$app_path" 2>&1)
        signtime=$(echo "$res" | awk -F "=" '/Signed\ Time/ {print $2}')
        teamid=$(echo "$res" | awk -F "=" '/TeamIdentifier/ {print $2}')
        echo "Team $teamid (signtime: $signtime)"
    else
        echo "Team none (signtime: none)"
    fi 
}

function repackage_app {
    newfilename="$IPA_DIR/resigned-$IPA_BASE"
    pushd "$TEMPDIR/app/" &>/dev/null
    zip -r -X "$newfilename" "Payload" &>/dev/null
    popd &>/dev/null
    echo $newfilename
}


function apphelp {
    printf "Usage: \n\t./resign.sh <ipafile> <mobileprovisionfile>\n"
    printf "Example: \n\t./resign.sh $HOME/Downloads/HelpDiabetes.ipa $HOME/Downloads/bjorningewildcard.mobileprovision\n\n"
    printf "Instructions for generating/downloading mobileprovisionfiles can be found online at the following location: https://calvium.com/how-to-make-a-mobileprovision-file/\n"
}

function guard_is_developer {
    devid=$1
    signing_id_count=$(security find-identity -v -p codesigning | grep $devid | wc -l)
    if [ "$signing_id_count" -eq "0" ]; then
        echo "ERROR: You don't appear to have $devid signing certificates installed, aborting!";
        exit -5;
    fi
    
}




if [ $1 = "--help" ]; then
   apphelp
   exit 0

fi

if [ $1 = "-h" ]; then
   apphelp
   exit 0

fi
RED='\033[0;31m'
NC='\033[0m' # No Color


developer_id="iPhone Developer"
guard_is_developer $developer_id

export BINARY_DIR="$(dirname $(realpath $0))"


##be gratious about parameter order, as long as it's the correct files present, swap them if necessary
if [[ $1 =~ .*\.ipa$ ]] && [[  $2 =~ .*\.mobileprovision$ ]]; then
    ipafile=$1
    provisionfile=$2
elif [[ $2 =~ .*\.ipa$ ]] && [[  $1 =~ .*\.mobileprovision$ ]]; then
    ipafile=$2
    provisionfile=$1
elif [[ $1 =~ .*\.ipa$ ]]; then
    ipafile=$1
    #no provisionfile specified, find one!
    adir=$(dirname $(realpath "$ipafile") )
    #mac specific command to fetch latest modified file, also matching extension .mobileprovision
    provisionfile=$(find "$adir" -type f -name "*.mobileprovision" -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -1 | cut -f2- -d" ")
    if [ ! -f "$provisionfile" ]; then
        printf "${RED}Error: Incorrect Usage, no .mobileprovision file found in either argument or in same dir as .ipa!${NC}\n"
        apphelp
        exit -11
    fi
else
    printf "${RED}Error: Incorrect Usage${NC}\n"
    apphelp
    exit -10
fi



create_temp
trap remove_temp EXIT

if [ ! -f "$provisionfile" ]; then
    echo ERROR: mobileprovisionfile not found
    exit -2
fi

if [ -f "$ipafile" ]; then
    unpackage_ipa "$ipafile"
    signature_before=$(get_app_signature)
    copy_app_provision_profile "$provisionfile"
    resign_app "$developer_id"
    signature_after=$(get_app_signature)
    
    newipa=$(repackage_app)
    if [ -f "$newipa" ]; then
        echo "Signature changed from $signature_before to $signature_after and newipa created: $newipa"
    else
        echo "ERROR: new ipa could not be created"
    fi 
    
    
else
    echo "ERROR:    Could not locate ipafile $ipafile, aborting!"
    exit -3
fi


