#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/celestia" ]; then    
    echo "🚀 Celestia is already installed" 
    if [ ! -f "$HOME/.celestia-light/config.yml" ]; then
            # This should be handled in the InitializeConfig code
            celestia light init 
        fi
        celestia light start --core.ip rpc.celestia.pops.one --p2p.network celestia
    exit 0
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

# Download celestia binary
FILE="celestia-$OS-$ARCH.tar.xz"
echo "💈 Downloading Celestia..."
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/celestia-v0.13.2/$FILE"
curl -sLO "$TGZ_URL" --progress-bar

tar -xf $FILE
chmod +x celestia
sudo mv celestia "$INTERNAL_DIR"/celestia
rm $FILE

if [ ! -f "$HOME/.celestia-light/config.yml" ]; then
    # This should be handled in the InitializeConfig code
    celestia light init
fi

# Handle this in GetStartCmd
celestia light start --p2p.network celestia --core.ip rpc.celestia.pops.one