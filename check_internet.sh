MAX_ATTEMPTS=3
attempts=0
ping_site="google.com"

print_color() {
    color="$1"
    message="$2"
    case "$color" in
        "green") echo -e "\e[32m$message\e[0m";;  # Green color
        "red") echo -e "\e[31m$message\e[0m";;    # Red color
        *) echo -n "$message";;
    esac
}

echo -n "Checking internet connection..."

while (( attempts < MAX_ATTEMPTS )); do
    if ping -c 1 $ping_site > /dev/null 2>&1; then
        echo
        print_color "green" "Internet connection is available. Continuing..."
        # Your script continues here...
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
