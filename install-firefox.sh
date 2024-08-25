set -e

url="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"

# Check if running with root privilage
if [ "$(id -u)" != "0" ]; then
    if ! sudo -n true 2>/dev/null; then
        echo "This script requires root privileges to execute."
    fi
    
    sudo sh "$0" "$@"
    exit $?
fi

wget -O /tmp/firefox.tar.bz $url

sudo tar -xjf /tmp/firefox.tar.bz -C /opt

sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

sudo wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications

# Verify installation
echo "Verifying installation..."
if command -v firefox --version >/dev/null 2>&1; then
    echo "firefox is installed successfully."
else
    echo "firefox installation failed."
fi
