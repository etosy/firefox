#!/bin/bash

# exit if error occurs
set -e

# uncomment to enable debug output
#set -x

# get profile name as arguement
profile=$1

# if profile name is not given as arguent get from the user
if [ -z "$profile" ]; then
    # Prompt the user for the profile name
    read -p "Enter the profile name: " profile

    # Check again if the user provided a profile name
    if [ -z "$profile" ]; then
        echo "Profile name not given! Exiting."
        exit 1
    fi
fi

# exit if given profile already exists
if [ -d ~/.mozilla/firefox/*$profile ]; then
    echo "There is already a profile titled as $profile exists. Exiting."
    exit 1
fi

# exit if not internet
print_color() {
    color="$1"
    message="$2"
    case "$color" in
        "green") echo -e "\e[32m$message\e[0m";;  # Green color
        "red") echo -e "\e[31m$message\e[0m";;    # Red color
        *) echo "$message";;
    esac
}

if ping -c 1 google.com > /dev/null 2>&1; then
    print_color "green" "Internet connection is available."
else
    print_color "red" "No internet! Exiting."
    exit 1
fi


latest_release_ver=$(curl -sL https://github.com/arkenfox/user.js/releases/latest | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')

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
