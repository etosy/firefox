#!/bin/bash

# firefox profile bloatware removal

# load user config
source config.sh

# exit if error occurs
set -e

# get profile name as arguement
profile=$1

# Check if profile name is provided as an argument
if [ ! -z "$profile" ]; then
    profile_path=$(find "$firefox_root_path" -name "*$profile")
    if [ -d "$profile_path" ]; then
        echo "$profile already exists. Choose another name."
        profile=
    fi
fi

# If profile is still empty, prompt the user for the profile name
count=0
while [ -z "$profile" ]; do
    

    if ((count == 3 )); then
        echo "Error: too many attempts. Exiting."
        exit 1
    fi  
    count=$((count + 1))
    read -p "$count Enter the profile name: " profile

    profile_path=$(find "$firefox_root_path" -name "*$profile")

    if [ -d "$profile_path" ]; then
        echo "$profile already exists. Choose another name."
        profile=
        count=0
    fi
done

bash check_internet.sh

echo "debug exit"; exit

latest_release_ver=$(curl -sL $arkenfox_release_url | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')

url="github.com/arkenfox/user.js/archive/refs/tags/$latest_release_ver.tar.gz"

tar_file=$(basename "$url")

curl -O -s -L $url

tar -xf $tar_file

firefox --CreateProfile $profile >>/dev/null 2>&1
firefox -offline --headless -p $profile &>> /dev/null &
sleep 6
pkill firefox
sleep 1

profile_dir=$(basename $(ls -d ~/.mozilla/firefox/*$profile))

cd user.js-$latest_release_ver/
cp -i prefsCleaner.sh updater.sh user.js ~/.mozilla/firefox/*$profile_dir
cd ~/.mozilla/firefox/*$profile_dir
echo 'user_pref("keyword.enabled", true);
user_pref("media.peerconnection.enabled", false);
user_pref("privacy.resistFingerprinting.letterboxing", false);' >> user-overrides.js
./updater.sh -u -s >> /dev/null
./prefsCleaner.sh -s >> /dev/null
cd - >> /dev/null

firefox -p $profile >>/dev/null 2>&1 &
