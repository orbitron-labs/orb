#!/bin/bash
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ ! -f "$INTERNAL_DIR/avail-da" ]; then    
   echo "💈 Downloading Avail..."

    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    if [[ "$ARCH" == "x86_64" ]]; then
        ARCH="amd64"
    elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
        ARCH="arm64"
    fi

    FILE=rollkit-avail-$OS-$ARCH.tar.xz

    # Download avail binary
    TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/avail-v1.7.9/$FILE"
    curl -sLO "$TGZ_URL" --progress-bar

    tar -xf $FILE
    chmod +x rollkit-avail-linux-amd64/*
    sudo mv rollkit-avail-linux-amd64/* "$INTERNAL_DIR"/
    rm $FILE
fi


DA_LOGS="tmp/data-avail.log"
mkdir -p "tmp"
if [ ! -f "$DA_LOGS" ]; then
    touch "$DA_LOGS"
fi
data-avail --dev > "$DA_LOGS" 2>&1 &

LOGS="tmp/avail-light-bootstrap.log"
if [ ! -f "$LOGS" ]; then
    touch "$LOGS"
fi
avail-light-bootstrap > "$LOGS" 2>&1 &


sleep 5

LOGS="tmp/avail-light.log"
if [ ! -f "$LOGS" ]; then
    touch "$LOGS"
fi
# avail-light --network local -c $HOME/.orb/scripts/configs/avail-config.yaml --clean > "$LOGS" 2>&1 &
avail-light --network local > "$LOGS" 2>&1 &



# Navigate to the root directory
LOGS="tmp/avail-da.log"
if [ ! -f "$LOGS" ]; then
    touch "$LOGS"
fi
# Run the server
avail-da > "$LOGS" 2>&1 &

# # Wait for the processes to initialize
# sleep 10
# Display the contents of tmp/data-avail.log
tail -f $DA_LOGS