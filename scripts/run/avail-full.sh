#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/avail-node" ]; then    
    echo "🚀 Avail is already installed" 
    avail-node --dev
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
echo "💈 Downloading Avail..."
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-full-v2.0.0/avail-node.tar.xz"
curl -sLO "$TGZ_URL" --progress-bar

tar -xf avail-node.tar.xz
chmod +x avail-node
sudo mv avail-node "$INTERNAL_DIR"/avail-node
rm avail-node.tar.xz

# Handle this in GetStartCmd
avail-node --dev