#!/bin/bash

# exit if error occurs
set -e

# exit if dependecy packages are not installed
if ! which wget >> /dev/null; then echo "wget not installed. Exiting."; exit; fi
if ! which curl >> /dev/null; then echo "curl not installed. Exiting."; exit; fi
if ! which unzip >> /dev/null; then echo "unzip not installed. Exiting."; exit; fi

profile=$1

# exit if no arguement is given
if [ -z $profile ];then echo "Profile name not given! Exiting."; exit 1; fi

# exit if firefox not installed
if ! command -v firefox >> /dev/null; then echo "Firefox is not installed. Exiting."; exit 1; fi

# exit if default profile exists
if [ -d ~/.mozilla/firefox/*default* ] || [ -d ~/.cache/mozilla/firefox/*default* ]; then echo "Default Firefox profile found. Exiting."; exit 1; fi

# exit if there is already a profile titled as given argument exists
if [ -d ~/.mozilla/firefox/*$profile ]; then echo "There is already a profile titled as $profile exists. Exiting."; exit 1; fi

# exit if no internet
if ! ping -c 1 example.com >> /dev/null; then echo "No internet! Exiting."; exit 1; fi


zip_ver=$(curl -sL https://github.com/arkenfox/user.js/releases/latest | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')
url=github.com/arkenfox/user.js/archive/refs/tags/$zip_ver.zip
zip=$(basename $url)

wget -nc -q -L $url
unzip -n -q $zip

firefox --CreateProfile $profile
firefox -offline --headless -p $profile &>> /dev/null &
sleep 6
pkill firefox
sleep 1

profile_dir=$(basename $(ls -d ~/.mozilla/firefox/*$profile))

cd user.js-$zip_ver/
cp -i prefsCleaner.sh updater.sh user.js ~/.mozilla/firefox/*$profile_dir
cd ~/.mozilla/firefox/*$profile_dir
echo 'user_pref("keyword.enabled", true);
user_pref("media.peerconnection.enabled", false);
user_pref("privacy.resistFingerprinting.letterboxing", false);' >> user-overrides.js
./updater.sh -u -s >> /dev/null
./prefsCleaner.sh -s >> /dev/null
cd - >> /dev/null
