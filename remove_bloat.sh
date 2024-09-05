#!/bin/bash

# firefox profile bloatware removal

source config.sh

# exit if error occurs
set -e



# this case handled
# if [ ! -f "$log_file_path" ]; then
#     touch $log_file_path
# fi

get_profile_name() {
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

      if [ -z "$profile" ]; then
        echo "Profile name is not provided. Please provide one."
        continue
      fi

      if [ ! -d  "$firefox_root_path" ]; then
        break
      fi
      profile_path=$(find "$firefox_root_path" -maxdepth 1 -type d -name "*$profile")
      
      if [ -d "$profile_path" ]; then
          echo "$profile already exists. Choose another name."
          profile=""
      fi
  done
}

create_profile() {
  echo "Creating firefox profile.."
  firefox --CreateProfile $profile # >> $log_file_path 2>&1

  echo "Running firefox in headless mode..."
  firefox -offline --headless -p $profile &>> $log_file_path &
  sleep 6

  echo "Closing firefox..."
  pkill firefox
  sleep 1
}

if [ ! -d "$working_dir" ]; then
    mkdir $working_dir
    touch $log_file_path
fi

get_profile_name
create_profile
bash download_debloater.sh

profile_dir=$(basename $(ls -d ~/.mozilla/firefox/*$profile))

cp -i $working_dir/$debloater_dir/prefsCleaner.sh  ~/.mozilla/firefox/*$profile_dir
cp -i $working_dir/$debloater_dir/updater.sh ~/.mozilla/firefox/*$profile_dir
cp -i $working_dir/$debloater_dir/user.js ~/.mozilla/firefox/*$profile_dir
cp -i $BASEDIR/user-overrides.js ~/.mozilla/firefox/*$profile_dir

echo "Running debloater script..."
bash ~/.mozilla/firefox/*$profile_dir/updater.sh -u -s # >> $log_file_path

echo "Running debloater cleanup script..."
bash ~/.mozilla/firefox/*$profile_dir/prefsCleaner.sh -s # >> $log_file_path

echo "Starting firefox..."
firefox -p $profile >> $log_file_path 2>&1 &