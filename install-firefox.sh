#!/bin/bash

# use this if creating firefox.desktop fails
firefox_desktop_download_link=https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop

# Download the latest version of Firefox
wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"

# Extract the downloaded archive
tar xjf firefox.tar.bz2

# Move the extracted folder to /opt
sudo mv firefox /opt/

# Create a symlink to the Firefox executable
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

# Create a desktop shortcut for Firefox
cat > ~/.local/share/applications/firefox.desktop <<EOL
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOL

# Make the desktop shortcut executable
chmod +x ~/.local/share/applications/firefox.desktop
