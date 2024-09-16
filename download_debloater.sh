#!/bin/bash

set -e

sudo test || true

CUR_DIR="$(pwd)"
BASE_DIR=
source config.sh

bash check_internet.sh

sudo apt install curl -y

debloater_latest_release_version=$(curl -sL $debloater_release_page_url | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')
echo "latest release version: $debloater_latest_release_version"

debloater_download_url="github.com/arkenfox/user.js/archive/refs/tags/$debloater_latest_release_version.tar.gz"
echo "download url: $debloater_download_url"

debloater_tar_file_name=$(basename "$debloater_download_url")

if [ ! -d "$working_dir" ]; then
    mkdir $working_dir
fi

cd $working_dir

# download debloater if latest not already exist
if [ ! -f "$debloater_tar_file_name" ]; then
    echo "Downloading $debloater_download_url"
    curl -O -L $debloater_download_url
else
    echo "latest debloater already exist. Skipping download."
fi

folder_name=$(find . -maxdepth 1 -type d -name "*${debloater_latest_release_version}*")

# extract debloater if latest not already extracted
if [ ! -d "$folder_name" ]; then
    echo "Extracting debloater tar file..."
    tar -xvf $debloater_tar_file_name
else
    echo "latest debloater already extracted. Skipping extract."
fi

cd $CUR_DIR
