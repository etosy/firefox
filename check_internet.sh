#!/bin/bash

source config.sh

MAX_ATTEMPTS=3
attempts=0
ping_address="1.1.1.1"

print_color() {
    color="$1"
    message="$2"
    case "$color" in
        "green") echo -e "\e[32m$message\e[0m";;  # Green color
        "red") echo -e "\e[31m$message\e[0m";;    # Red color
        *) echo -n "$message";;
    esac
}

echo "Checking internet connection..."

while (( attempts < MAX_ATTEMPTS )); do
    # > $log_file_path 2>&1

    curl -s --connect-timeout 5 $ping_address > /dev/null
    
    #if ping -c 1 $ping_address; then
    if [ $? -eq 0 ]; then
        print_color "green" "Internet connection is available. Continuing..."
        exit 0
    else
        (( attempts++ ))
        if (( attempts < MAX_ATTEMPTS )); then
            print_color "red" "No internet connection detected. Please connect to the internet and press Enter to retry."
            read -p "Press Enter to retry..."
        else
            print_color "red" "No internet connection after $MAX_ATTEMPTS attempts. Exiting."
            exit 1
        fi
    fi
done
