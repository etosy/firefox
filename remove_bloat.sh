#!/bin/bash

# firefox profile bloatware removal

# this script path
BASEDIR=$(pwd)

# load user config
source config.sh

# exit if error occurs
set -e

# get profile name as arguement
profile=$1

# Check if profile name is provided as an argument and check if profile already exists
if [ ! -z "$profile" ]; then
    profile_path=$(find "$firefox_root_path" -maxdepth 1 -type d -name "*$profile")
    if [ -d "$profile_path" ]; then
        echo "$profile already exists. Choose another name."
        profile=""
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

    profile_path=$(find "$firefox_root_path" -maxdepth 1 -type d -name "*$profile")

    if [ -d "$profile_path" ]; then
        echo "$profile already exists. Choose another name."
        profile=""
    fi
done

bash check_internet.sh

bash download_debloater.sh

echo
echo -n "Creating firefox profile.."
firefox --CreateProfile $profile # >>/dev/null 2>&1
echo

echo
echo -n "Running firefox in headless mode..."
firefox -offline --headless -p $profile &>> /dev/null &
sleep 6
echo

echo
echo -n "Closing firefox..."
pkill firefox
sleep 1
echo

profile_dir=$(basename $(ls -d ~/.mozilla/firefox/*$profile))

cd $working_dir/$debloater_dir
cp -i prefsCleaner.sh updater.sh user.js ~/.mozilla/firefox/*$profile_dir
cd ~/.mozilla/firefox/*$profile_dir
cp -i $BASEDIR/user-overrides.js ./

echo
echo -n "Running debloater script..."
bash updater.sh -u -s >> /dev/null
echo

echo
echo -n "Running debloater cleanup script..."
bash prefsCleaner.sh -s >> /dev/null
echo

cd - >> /dev/null

echo
echo -n "Starting firefox..."
firefox -p $profile >>/dev/null 2>&1 &
echo

echo -e "\nAll done!\n"
