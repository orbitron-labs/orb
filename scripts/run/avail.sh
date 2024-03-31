#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/avail-light" ]; then    
    echo "🚀 Avail is already installed" 
    avail-light --network goldberg
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
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-v1.7.9/avail-${OS}-${ARCH}.zip"
curl -sLO "$TGZ_URL" --progress-bar

unzip -q avail-${OS}-${ARCH}.zip 
chmod +x avail-light-linux-amd64
sudo mv avail-light-linux-amd64 "$INTERNAL_DIR"/avail-light
rm avail-${OS}-${ARCH}.zip

# Handle this in GetStartCmd
avail-light --network goldberg