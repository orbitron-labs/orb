#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ -f "$INTERNAL_DIR/orb-avail-light" ]; then    
    echo "🚀 Avail is already installed" 
    data-avail --dev --rpc-port 9945 --port 30334
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
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-v1.7.9/avail-${OS}-${ARCH}.zip"
sudo mkdir -p "/tmp/orbavail"
echo "💈 Downloading Avail..."
sudo curl -o /tmp/orbavail/${OS}_${ARCH}.zip -L "$TGZ_URL" --progress-bar

sudo unzip -q /tmp/orbavail/${OS}_${ARCH}.zip -d /tmp/orb-avail-light/
sudo mv "/tmp/orb-avail-light/${OS}_${ARCH}"/* "$INTERNAL_DIR"
sudo chmod +x "$INTERNAL_DIR"
sudo rm -rf "/tmp/orbavail"

# Handle this in GetStartCmd
orb-avail-light --dev --rpc-port 9945 --port 30334