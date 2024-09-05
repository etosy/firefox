#! /bin/bash

set -e

source config.sh

bash check_internet.sh

###if [ ! -z $curl ]; then
echo "Getting debloater latest release version..."
debloater_latest_release_version=$(curl -sL $debloater_release_page_url | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')
echo "latest release version: $debloater_latest_release_version"

debloater_download_url="github.com/arkenfox/user.js/archive/refs/tags/$debloater_latest_release_version.tar.gz"
echo "download url: $debloater_download_url"

debloater_tar_file_name=$(basename "$debloater_download_url")

if [ ! -d "$working_dir" ]; then
    mkdir $working_dir
fi

cd $working_dir

echo "Downloading $debloater_download_url"
curl -O -L $debloater_download_url

echo "Extracting debloater tar file..."
tar -xvf $debloater_tar_file_name
