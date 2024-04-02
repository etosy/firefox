#!/bin/bash

# install firefox locally

# load user config
source config.sh

# Download the latest version of Firefox
wget -O "$working_dir/firefox.tar.bz2" $firefox_download_link 

# Extract the downloaded archive
tar xjf "$working_dir/firefox.tar.bz2"

# Move the extracted folder to /opt
sudo mv "$working_dir/firefox" /opt/

# Create a symlink to the Firefox executable
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

# Create a desktop shortcut for Firefox
sudo cp -i firefox.desktop $icon_path

# Make the desktop shortcut executable
chmod +x $icon_path
