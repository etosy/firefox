#!/bin/bash
# firefox profile bloatware removal

set -e

sudo test || true

CUR_DIR="$(pwd)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BASE_DIR=$SCRIPT_DIR

source $BASE_DIR/config.sh

get_profile_name() {

  return $(head /dev/urandom | tr -dc 'A-Za-z' | head -c 8)

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

######################## Start Here ##################################

if [ ! -d "$working_dir" ]; then
    mkdir $working_dir
    touch $log_file_path
fi



profile=get_profile_name
echo "Profile name: $profile"
create_profile

./download_debloater.sh

profile_dir=$(basename $(ls -d ~/.mozilla/firefox/*$profile))

cd $working_dir/$debloater_dir
cp -i prefsCleaner.sh  ~/.mozilla/firefox/*$profile_dir
cp -i updater.sh ~/.mozilla/firefox/*$profile_dir
cp -i user.js ~/.mozilla/firefox/*$profile_dir
#cp -i $BASEDIR/user-overrides.js ~/.mozilla/firefox/*$profile_dir

cd ~/.mozilla/firefox/*$profile_dir
./updater.sh -u -s # >> $log_file_path
./prefsCleaner.sh -s # >> $log_file_path

echo "Starting firefox..."
firefox -p $profile >> $log_file_path 2>&1 &

cd $CUR_DIR