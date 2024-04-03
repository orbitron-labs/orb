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
FILE="avail-light-$OS-$ARCH.tar.xz"
echo "💈 Downloading Avail..."
TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-v1.7.9/$FILE"
curl -sLO "$TGZ_URL" --progress-bar

tar -xf $FILE
chmod +x avail-light
sudo mv avail-light "$INTERNAL_DIR"/avail-light
rm $FILE

# Handle this in GetStartCmd
avail-light --network goldberg