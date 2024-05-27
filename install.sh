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

FILE="orb-$OS-$ARCH.tar.xz"
GZ_URL="https://github.com/orbitron-labs/orb/releases/download/orb-v0.1.0/$FILE"

INTERNAL_DIR="/usr/local/bin/"
ORB_BIN_PATH="/usr/local/bin/orb"

if [ -f "$ORB_BIN_PATH" ]; then
    sudo rm -f "$ORB_BIN_PATH"
fi


sudo mkdir -p "/tmp/orb_bins"
echo "💿 Downloading orb..."
curl -O -L $GZ_URL --progress-bar

# sudo unzip orb-${OS}-${ARCH}.zip -d "/tmp/orb_bins" 2>/dev/null
tar -xf $FILE
chmod +x orb
sudo mv orb "$INTERNAL_DIR"/orb
sudo rm -rf $FILE
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/config.toml 2>/dev/null

CONFIG_PATH="$HOME/.orb/config.toml"
mkdir -p ~/.orb && sudo mv config.toml $CONFIG_PATH

# Get celestia script from repo
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/celestia.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv celestia.sh $scripts/run/celestia.sh

# Get avail script from repo
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/avail.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv avail.sh $scripts/run/avail.sh

# Get avail script from repo
curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/avail-full.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv avail-full.sh $scripts/run/avail-full.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_avail.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_avail.sh $scripts/run/rollkit_avail.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_gmd.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_gmd.sh $scripts/run/rollkit_gmd.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_celestia.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_celestia.sh $scripts/run/rollkit_celestia.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_gmd_celestia.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_gmd_celestia.sh.sh $scripts/run/rollkit_gmd_celestia.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_celestia_mainnet.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_celestia_mainnet.sh $scripts/run/rollkit_celestia_mainnet.sh

curl -O https://raw.githubusercontent.com/orbitron-labs/orb/main/scripts/run/rollkit_gmd_celestia_mainnet.sh 2>/dev/null
mkdir -p $scripts/run && sudo mv rollkit_gmd_celestia_mainnet.sh.sh $scripts/run/rollkit_gmd_celestia_mainnet.sh

curl -X POST http://57.151.52.101:8080/save-orb-install > /dev/null 2>&1
sudo chmod +x $scripts/run/celestia.sh
sudo chmod +x $scripts/run/avail.sh
sudo chmod +x $scripts/run/avail-full.sh
sudo chmod +x $scripts/run/rollkit_avail.sh
sudo chmod +x $scripts/run/rollkit_gmd.sh
sudo chmod +x $scripts/run/rollkit_celestia.sh
sudo chmod +x $scripts/run/rollkit_gmd_celestia.sh
sudo chmod +x $scripts/run/rollkit_celestia_mainnet.sh
sudo chmod +x $scripts/run/rollkit_gmd_celestia_mainnet.sh

# sudo chmod +x /tmp/orb/celestia/celestia.sh
echo "✅ orb installed!"
