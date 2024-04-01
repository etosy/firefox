#! bin/bash

remove-bloat.sh $1
download-extension.sh
install-addons.sh $1
