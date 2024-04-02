#! bin/bash

bash remove-bloat.sh $1
bash download-extension.sh
bash install-addons.sh $1
