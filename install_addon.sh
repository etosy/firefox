#!/bin/bash

# exit if error occurs
set -e

# Install curl and unzip
if ! which curl >> /dev/null; then echo "curl not installed. Exiting."; exit; fi
if ! which unzip >> /dev/null; then echo "unzip not installed. Exiting."; exit; fi
if ! which wget >> /dev/null; then echo "wget not installed. Exiting."; exit; fi


this_script=$(basename $0)
working_dir=~/Firefox_Addons
firefox_root_path=~/.mozilla/firefox
profile=$1

# exit if no arguement is given
if [ -z $1 ]; then echo "Profile name not given. Exiting."; exit; fi

# exit if firefox root dir does not found
if ! [ -d $firefox_root_path ]; then echo "Firefox root folder not found. Exiting."; exit 1; fi

profile_dir=$(ls -1 ~/.mozilla/firefox/ | grep $profile) || true

# exit if given profile donot exist
if [[ -z $profile_dir ]]; then echo "Profile $profile not found. Exiting."; exit; fi

addons_dir_path=$firefox_root_path/$profile_dir/extensions

mkdir -p $addons_dir_path

xpi_files=$(find "$addons_dir_path" -type f -name "*.xpi")

#addon=$(ls -1 $addons_dir_path | grep ".xpi") || true

# exit if any addons already exist
#if [[ -n "$xpi_files" ]]; then echo "Addon already exist. Exiting."; exit; fi

# exit if there is no internet
if ! ping -c 1 example.com >> /dev/null; then echo "Error: No internet!"; exit 1; fi


addons_urls=(
  "https://addons.mozilla.org/firefox/downloads/file/4095037/darkreader-4.9.63.xpi"
  "https://addons.mozilla.org/firefox/downloads/file/4121906/ublock_origin-1.50.0.xpi"
  "https://addons.mozilla.org/firefox/downloads/file/4111078/noscript-11.4.22.xpi"
  "https://addons.mozilla.org/firefox/downloads/file/4101836/i_dont_care_about_cookies-3.4.7.xpi"
)

mkdir -p $working_dir

# download addon one by one
for url in "${addons_urls[@]}"; do

  # download addon
  wget -q -nc --show-progress -P $working_dir $url

  # extract addon name from url
  addon=$(basename $url)

  # unzip manifest.json form addon zip
  unzip -n -j -q "$working_dir/$addon" manifest.json -d "$working_dir"

  # extract addon id from manifest.json file
  addon_id=$(grep -oP '(?<="id": ").*(?=")' "$working_dir/manifest.json")

  # copy addon to addons_dir and rename to its id
  cp -n "$working_dir/$addon" "$addons_dir_path/$addon_id.xpi"

  # rename manifest.json file to include its id
  mv -n "$working_dir/manifest.json" "$working_dir/$addon_id-manifest.json"

done
