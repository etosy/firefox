#! /bin/bash

latest_release_ver=$(curl -sL $arkenfox_release_url | grep -oE '[0-9]+\.[0-9]+' | sed -n '1p')

url="github.com/arkenfox/user.js/archive/refs/tags/$latest_release_ver.tar.gz"

tar_file=$(basename "$url")

curl -O -s -L $url

tar -xf $tar_file