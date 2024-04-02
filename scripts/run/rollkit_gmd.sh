#!/bin/sh
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ ! -f "$INTERNAL_DIR/gmd" ]; then    
echo "💈 Downloading gmd..."
    # OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    # ARCH=$(uname -m)

    # if [[ "$ARCH" == "x86_64" ]]; then
    #     ARCH="amd64"
    # elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    #     ARCH="arm64"
    # fi

   FILE="rollkit-gmd-linux-amd64.tar.xz"

  # Download avail binary
  TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/rollkit-gmd/$FILE"
  curl -sLO "$TGZ_URL" --progress-bar

  tar -xf $FILE
  chmod +x gmd
  sudo mv gmd "$INTERNAL_DIR"/gmd
  rm $FILE

fi

# set variables for the chain
VALIDATOR_NAME=validator1
CHAIN_ID=gm
KEY_NAME=gm-key
KEY_2_NAME=gm-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000stake"
STAKING_AMOUNT="1000000000stake"

# query the DA Layer start height, in this case we are querying
# our local devnet at port 26657, the RPC. The RPC endpoint is
# to allow users to interact with Celestia's nodes by querying
# the node's state and broadcasting transactions on the Celestia
# network. The default port is 26657.
DA_BLOCK_HEIGHT=$(curl http://localhost:7000/v1/latest_block | jq -r '.latest_block')

# echo variables for the chain
echo -e "\n Your DA_BLOCK_HEIGHT is $DA_BLOCK_HEIGHT \n"

# reset any existing genesis/chain data
gmd tendermint unsafe-reset-all

# initialize the validator with the chain ID you set
gmd init $VALIDATOR_NAME --chain-id $CHAIN_ID

# add keys for key 1 and key 2 to keyring-backend test
gmd keys add $KEY_NAME --keyring-backend test
# gmd keys add $KEY_2_NAME --keyring-backend test

# add these as genesis accounts
gmd genesis add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
# gmd genesis add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test

# set the staking amounts in the genesis transaction
gmd genesis gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test

# collect genesis transactions
gmd genesis collect-gentxs

# copy centralized sequencer address into genesis.json
# Note: validator and sequencer are used interchangeably here
ADDRESS=$(jq -r '.address' ~/.gm/config/priv_validator_key.json)
PUB_KEY=$(jq -r '.pub_key' ~/.gm/config/priv_validator_key.json)
jq --argjson pubKey "$PUB_KEY" '.consensus["validators"]=[{"address": "'$ADDRESS'", "pub_key": $pubKey, "power": "1000", "name": "Rollkit Sequencer"}]' ~/.gm/config/genesis.json > temp.json && mv temp.json ~/.gm/config/genesis.json

# create a restart-local.sh file to restart the chain later
[ -f restart-local.sh ] && rm restart-local.sh
echo "DA_BLOCK_HEIGHT=$DA_BLOCK_HEIGHT" >> restart-local.sh

echo "gmd start --rollkit.aggregator true --rollkit.da_address=":26650" --rollkit.da_start_height \$DA_BLOCK_HEIGHT --rpc.laddr tcp://127.0.0.1:36657 --p2p.laddr \"0.0.0.0:36656\"" >> restart-local.sh

# start the chain
gmd start --rollkit.aggregator true --rollkit.da_address="127.0.0.1:3000" --rollkit.da_start_height $DA_BLOCK_HEIGHT --minimum-gas-prices="0.025stake"

# uncomment the next command if you are using lazy aggregation
# gmd start --rollkit.aggregator true --rollkit.da_address=":26650" --rollkit.da_start_height $DA_BLOCK_HEIGHT --rollkit.lazy_aggregator