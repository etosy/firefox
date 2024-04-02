#!/bin/bash

extension_name="ublock-origin"
download_path="temp"

# Function to extract latest version of extension
get_latest_version() {
    # Fetching the latest version number from the Mozilla website
    version=$(curl -s "https://addons.mozilla.org/api/v4/addons/addon/$1/" | jq -r '.current_version.version')
    echo "$version"
}

# Function to download the extension
download_extension() {
    local extension_name=$1
    local download_path=$2
    
    # Fetching the download URL for the latest version
    download_url=$(curl -s "https://addons.mozilla.org/api/v4/addons/addon/$1/" | jq -r '.current_version.files[-1].url')
    
    # Extracting filename from the download URL
    filename=$(basename "$download_url")
    
    # Downloading the extension to the specified path
    wget "$download_url" -O "$download_path/$filename"
}

# Check if 'jq' command-line JSON processor is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required to run this script. Please install jq"
    exit 1
fi

# Get the latest version of the extension
latest_version=$(get_latest_version "$extension_name")

if [ -z "$latest_version" ]; then
    echo "Error: Extension '$extension_name' not found or unable to retrieve version information."
    exit 1
fi

echo "Latest version of '$extension_name' is $latest_version"

mkdir $download_path

# Download the extension
download_extension "$extension_name" "$download_path"

