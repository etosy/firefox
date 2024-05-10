#! /bin/bash

source config.sh

echo
echo -n "Getting debloater latest release version..."
debloater_latest_release_version=$(curl -sL $debloater_release_page_url | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')
echo
debloater_download_url="github.com/arkenfox/user.js/archive/refs/tags/$debloater_latest_release_version.tar.gz"
debloater_tar_file_name=$(basename "$debloater_download_url")

echo -e "\nDownloading debloater tar file..."
curl -O -L $debloater_download_url

echo -e "\nExtracting debloater tar file..."
tar -xvf $debloater_tar_file_name