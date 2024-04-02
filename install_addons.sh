#!/bin/bash

# Exit if error occurs
set -e

# load common functions
source common-functions.sh

# Directory containing add-on XPI files
temp_dir="temp"
firefox_root_path="$HOME/.mozilla/firefox"
profile="$1"

# Check if temp directory exists
if [ ! -d "$temp_dir" ]; then
  echo "Error: $temp_dir folder does not exist in current directory."
  echo "First download the extensions and put it in a folder called temp in current directory."
  exit 1
fi

# Check if there are any addon files
if [ ! -e "$temp_dir"/*.xpi ]; then
  echo "Error: No addon files found in the $temp_dir directory."
  exit 1
fi

# Addon files in the extensions directory
addon_files=("$temp_dir"/*.xpi)

# Check if there are any addon files
if [ ${#addon_files[@]} -eq 0 ]; then
  echo "Error: No addon files found in the $temp_dir directory."
  exit 1
fi


# Check if required packages are installed
required_packages=("curl" "unzip" "wget")
missing_packages=()
for pkg in "${required_packages[@]}"; do
  if ! command -v "$pkg" &> /dev/null; then
    missing_packages+=("$pkg")
  fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
  echo "Error: The following required packages are missing: ${missing_packages[*]}"
  exit 1
fi

# Exit if no profile name is given
while [ -z "$profile" ]; do 
  echo "Error: Profile name not provided."
  list_firefox_profiles
  exit 1
  read -p "Enter profile name: " profile
done

# Exit if Firefox root directory does not exist
if [ ! -d "$firefox_root_path" ]; then
  echo "Error: Firefox root folder not found."
  exit 1
fi

# Check if the specified profile exists
profile_dir=$(find "$firefox_root_path" -maxdepth 1 -type d -name "*$profile" -print -quit)
if [ -z "$profile_dir" ]; then
  echo "Error: Profile '$profile' not found."
  exit 1
fi

# This command should be after profile_dir check
addons_dir_path="$profile_dir/extensions"

mkdir -p "$addons_dir_path"

cd "$temp_dir"

# Install each addon from the extensions directory
for addon_file in "${addon_files[@]}"; do
  # Extract addon filename from file path
  addon_filename=$(basename "$addon_file")
  
  # unzip manifest.json from addon zip
  unzip -n -j -q "$addon_filename" manifest.json -d . 
  
  # extract addon id from manifest.json file
  addon_id=$(grep -oP '(?<="id": ").*(?=")' "manifest.json")
  
  # rename manifest.json file to avoid conflicts
  mv -n "manifest.json" "$addon_id-manifest.json"
  
  # rename addon to its id with extension 
  mv -n "$addon_filename" "$addon_id.xpi"
done

cd -

cp -i "$temp_dir/*.xpi" "$addons_dir_path"
