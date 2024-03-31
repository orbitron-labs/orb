#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"
CELESTIA_VER="0.12.3"
NODE_DIR=.orb/celestia
NODE_STORE="~/.orb/celestia"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/celestia" ]; then
    # Capture the version output
    VERSION_OUTPUT=$("$INTERNAL_DIR/celestia" version)
    
    # Check if the version matches "v0.11.0-rc15-dev"
    if [[ $VERSION_OUTPUT == *$CELESTIA_VER* ]]; then
        echo "🚀 Celestia is already installed with the correct version." $VERSION_OUTPUT
        # celestia light init --p2p.network mocha
        if [ ! -f "$HOME/$NODE_STORE/config.yml" ]; then
            # This should be handled in the InitializeConfig code
            mkdir -p $HOME/$NODE_DIR
            celestia light init --node.store $NODE_STORE
        fi
        celestia light start --node.store $NODE_STORE
        exit 0
    else
        echo "🚀 Celestia is installed but with a different version."
    fi
fi

echo "🔍 Determining OS and architecture..."

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

echo "💻  OS: $OS"
echo "🏗️  ARCH: $ARCH"

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

# Download celestia binary

TGZ_URL="https://github.com/orbitronlabs/orb/releases/download/celestia-v0.12.3/celestia-${OS}-${ARCH}.zip"
sudo mkdir -p "/tmp/orbcelestia"
echo "💈 Downloading Celestia..."
sudo curl -o /tmp/orbcelestia/${OS}_${ARCH}.zip -L "$TGZ_URL" --progress-bar

sudo unzip -q /tmp/orbcelestia/${OS}_${ARCH}.zip -d /tmp/orbcelestia/
sudo mv "/tmp/orbcelestia/${OS}_${ARCH}"/* "$INTERNAL_DIR"
sudo chmod +x "$INTERNAL_DIR"
sudo rm -rf "/tmp/orbcelestia"

if [ ! -f "$HOME/$NODE_STORE/config.yml" ]; then
    # This should be handled in the InitializeConfig code
    mkdir -p $HOME/$NODE_DIR
    celestia light --node.store $NODE_STORE
fi

# Handle this in GetStartCmd
celestia light start --node.store $NODE_STORE