#!/bin/bash
set -e

scripts="$HOME/.orb/scripts"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi
ORB_RELEASE_TAG="v0.1.0"
GZ_URL="https://github.com/orbitron-labs/orb/releases/download/orb-${ORB_RELEASE_TAG}/orb-${OS}-${ARCH}.zip"

INTERNAL_DIR="/usr/local/bin/"
ORB_BIN_PATH="/usr/local/bin/orb"

if [ -f "$ORB_BIN_PATH" ]; then
    sudo rm -f "$ORB_BIN_PATH"
fi

# if [ -f "orb-${OS}-${ARCH}.tar.gz" ]; then
#     sudo rm -f "orb-${OS}-${ARCH}.tar.xz"
# fi

# if OS is linux then install unzip
if [[ "$OS" == "linux" ]]; then
    if which apt > /dev/null; then
        sudo apt-get update > /dev/null
        sudo apt-get install unzip > /dev/null
    elif which apk > /dev/null; then
        sudo apk update > /dev/null
        sudo apk add unzip > /dev/null
        ARCH="arm64_alpine"
    fi
fi


sudo mkdir -p "/tmp/orb_bins"
echo "💿 Downloading orb..."
curl -O -L $GZ_URL --progress-bar

sudo unzip orb-${OS}-${ARCH}.zip -d "/tmp/orb_bins" 2>/dev/null
# sudo tar -xzf orb-${OS}-${ARCH}.tar.xz -C "/tmp/orb_bins" 2>/dev/null

echo "🔨 Installing orb..."
sudo cp "/tmp/orb_bins/orb-${OS}-${ARCH}" "$INTERNAL_DIR/orb"
sudo chmod +x "$INTERNAL_DIR/orb"
sudo rm -rf "/tmp/orb_bins"
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/config.toml 2>/dev/null
mkdir -p ~/.orb && sudo cp config.toml ~/.orb/config.toml

# Get celestia script from repo
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/celestia.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv celestia.sh $scripts/run/celestia.sh

# Get avail script from repo
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/avail.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv avail.sh $scripts/run/avail.sh

sudo chmod +x $scripts/run/celestia.sh
sudo chmod +x $scripts/run/avail.sh

# sudo chmod +x /tmp/orb/celestia/celestia.sh
echo "✅ orb installed!"
