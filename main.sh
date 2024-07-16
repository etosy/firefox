#! bin/bash

bash remove_bloat.sh $1
bash download_extension.sh
bash install_addons.sh $1
