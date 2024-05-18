#!/usr/bin/env bash

# Check if sudo is available and set with_sudo accordingly
if command -v sudo &>/dev/null; then
    with_sudo="sudo "
else
    with_sudo=""
fi

# Function to install required dependencies
install_dependencies() {
    ${with_sudo}apt update && ${with_sudo}apt -y install pv cgpt tar unzip aria2
}

# Function to build Chrome OS image
build_chromeos() {
    # Verify chromeos-install.sh and chromeos.bin exist
    if [ ! -f chromeos-install.sh ] || [ ! -f chromeos.bin ]; then
        echo "chromeos-install.sh or chromeos.bin not found"
        exit 1
    fi

    # Check if bash is available
    command -v bash &>/dev/null || {
        echo "bash is not available. Please install bash"
        exit 1
    }

    ${with_sudo}bash chromeos-install.sh -src chromeos.bin -dst chromeos.img
}

# Function to download Chrome OS
download_chromeos() {
    local code_name=$1
    local url="https://cros.tech/device/${code_name}"
    local response=$(curl -s --progress-bar "$url")
    local link=$(echo "$response" | sed -n 's/.*<a[^>]*href="\([^"]*dl\.google\.com[^"]*\.zip\)"[^>]*>\([^<]*\)<\/a>.*/\1 \2/p' | awk '
    {
        if (match($2, /[0-9]+/)) {
            num = substr($2, RSTART, RLENGTH)
            if (num > max_num) {
                max_num = num
                max_link = $1
            }
        }
    }
    END { if (max_num != "") print max_link; else print "No valid links found"; }')

    if [ "$link" == "No valid links found" ]; then
        echo "No valid links found"
        exit 1
    fi

    echo "Downloading Chrome OS for $code_name"
    aria2c --console-log-level=warn --summary-interval=1 -x 16 -o chromeos.zip "$link"
    unzip -o chromeos.zip -d chromeos
    rm -f chromeos.zip
}

# Function to download the latest Brunch release
download_brunch() {
    local url="https://api.github.com/repos/sebanc/brunch/releases/latest"
    local response=$(curl -s "$url")
    local link=$(echo "$response" | sed -n 's/.*"browser_download_url": "\([^"]*\.tar\.gz\)".*/\1/p')

    if [ -z "$link" ]; then
        if [ "$D_BRUNCH_COUNT" -ge 2 ]; then
            echo "Failed to download Brunch"
            exit 1
        else
            local random_sec=$((1 + RANDOM % 5))
            echo "Failed to download Brunch. Retrying in $random_sec seconds"
            sleep $random_sec
            D_BRUNCH_COUNT=$((D_BRUNCH_COUNT + 1))
            download_brunch
            return
        fi
    fi

    echo "Downloading Brunch"
    aria2c --console-log-level=warn --summary-interval=1 -x 16 -o brunch.tar.gz "$link"
    mkdir -p brunch
    tar -xzvf brunch.tar.gz -C brunch
    rm -f brunch.tar.gz
}

# Function for post-download setup
post_download_setup() {
    # Check if brunch and chromeos directories exist
    [ ! -d brunch ] && {
        echo "brunch directory not found"
        exit 1
    }
    [ ! -d chromeos ] && {
        echo "chromeos directory not found"
        exit 1
    }

    # Copy all files from brunch to chromeos
    echo "Copying Brunch files to Chrome OS..."
    cp -r brunch/* chromeos/
    mv chromeos/chromeos*.bin chromeos/chromeos.bin
}

# Function to build the final Chrome OS image
build_chromos_img() {
    cd chromeos || {
        echo "Failed to change directory to chromeos"
        exit 1
    }

    # Check if chromeos.bin exists
    [ ! -f chromeos.bin ] && {
        echo "chromeos.bin not found"
        exit 1
    }
    # Check if chromeos-install.sh exists
    [ ! -f chromeos-install.sh ] && {
        echo "chromeos-install.sh not found"
        exit 1
    }

    # Remove existing chromeos.img if it exists
    [ -f chromeos.img ] && rm -f chromeos.img

    # Determine the image filename
    CHROMEOS_IMG_FILENAME=${CHROMEOS_IMG_FILENAME:-"chromeos.img"}
    [[ "$CHROMEOS_IMG_FILENAME" == *".img" ]] || {
        echo "CHROMEOS_IMG_FILENAME should contain .img"
        exit 1
    }

    ${with_sudo}bash chromeos-install.sh -src chromeos.bin -dst "$CHROMEOS_IMG_FILENAME"

    [ -f "$CHROMEOS_IMG_FILENAME" ] && echo "$CHROMEOS_IMG_FILENAME created successfully" || echo "Failed to create $CHROMEOS_IMG_FILENAME"
}

# Main script execution
install_dependencies
if [ $? -eq 0 ]; then
    if [ -z "$1" ]; then
        echo "Please provide Chrome OS code name"
        exit 1
    fi
    download_chromeos "$1" && download_brunch && post_download_setup && build_chromos_img
else
    echo "Failed to install dependencies"
    exit 1
fi
