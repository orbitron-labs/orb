#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"
NODE_STORE=".orb/celestia-arabica"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/celestia" ]; then    
    echo "🚀 Celestia is already installed" 
    if [ ! -f "$HOME/.celestia-light-arabica-11/config.yml" ]; then
            # This should be handled in the InitializeConfig code
            mkdir -p $HOME/$NODE_DIR
            celestia light init --p2p.network arabica
        fi
        celestia light start --p2p.network arabica
    exit 0
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

# Download avail binary
FILE="celestia-$OS-$ARCH.tar.xz"
echo "💈 Downloading Celestia..."
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-v1.7.9/$FILE"
curl -sLO "$TGZ_URL" --progress-bar

tar -xf $FILE
chmod +x avail-light
sudo mv avail-light "$INTERNAL_DIR"/avail-light
rm $FILE

if [ ! -f "$HOME/.celestia-light-arabica-11/config.yml" ]; then
    # This should be handled in the InitializeConfig code
    celestia light --p2p.network arabica
fi

# Handle this in GetStartCmd
celestia light start --p2p.network arabica