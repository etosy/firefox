source config.sh

list_firefox_profiles() {
    echo "Existing profiles:-"
    find $firefox_root_path -maxdepth 1 -type d -name '*.*' | grep -v '^.$' | awk -F '.' '{print $NF}'
}