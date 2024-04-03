#!/bin/sh
set -e

INTERNAL_DIR="/usr/local/bin"

# check if the binary is already installed
if [ ! -f "$INTERNAL_DIR/cel-gmd" ]; then    
echo "💈 Downloading cel-gmd..."
    # OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    # ARCH=$(uname -m)

    # if [[ "$ARCH" == "x86_64" ]]; then
    #     ARCH="amd64"
    # elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    #     ARCH="arm64"
    # fi

   FILE="rollkit-cel-gmd-linux-amd64.tar.xz"

  # Download avail binary
  TGZ_URL="https://github.com/orbitron-labs/orb/releases/download/rollkit-gmd/$FILE"
  curl -sLO "$TGZ_URL" --progress-bar

  tar -xf $FILE
  chmod +x cel-gmd
  sudo mv cel-gmd "$INTERNAL_DIR"/cel-gmd
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
# an RPC endpoint provided by Celestia Labs. The RPC endpoint is
# to allow users to interact with Celestia's core network by querying
# the node's state and broadcasting transactions on the Celestia
# network. This is for Arabica, if using another network, change the RPC.
DA_BLOCK_HEIGHT=$(curl https://rpc.celestia-arabica-11.com/block | jq -r '.result.block.header.height')
echo -e "\n Your DA_BLOCK_HEIGHT is $DA_BLOCK_HEIGHT \n"

AUTH_TOKEN=$(celestia light auth write --p2p.network arabica)
echo -e "\n Your DA AUTH_TOKEN is $AUTH_TOKEN \n"

# reset any existing genesis/chain data
cel-gmd tendermint unsafe-reset-all

# initialize the validator with the chain ID you set
cel-gmd init $VALIDATOR_NAME --chain-id $CHAIN_ID

# add keys for key 1 and key 2 to keyring-backend test
cel-gmd keys add $KEY_NAME --keyring-backend test
cel-gmd keys add $KEY_2_NAME --keyring-backend test

# add these as genesis accounts
cel-gmd genesis add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
cel-gmd genesis add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test

# set the staking amounts in the genesis transaction
cel-gmd genesis gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test

# collect genesis transactions
cel-gmd genesis collect-gentxs

# copy centralized sequencer address into genesis.json
# Note: validator and sequencer are used interchangeably here
ADDRESS=$(jq -r '.address' ~/.gm/config/priv_validator_key.json)
PUB_KEY=$(jq -r '.pub_key' ~/.gm/config/priv_validator_key.json)
jq --argjson pubKey "$PUB_KEY" '.consensus["validators"]=[{"address": "'$ADDRESS'", "pub_key": $pubKey, "power": "1000", "name": "Rollkit Sequencer"}]' ~/.gm/config/genesis.json > temp.json && mv temp.json ~/.gm/config/genesis.json

# create a restart-testnet.sh file to restart the chain later
[ -f restart-testnet.sh ] && rm restart-testnet.sh
echo "DA_BLOCK_HEIGHT=$DA_BLOCK_HEIGHT" >> restart-testnet.sh
echo "AUTH_TOKEN=$AUTH_TOKEN" >> restart-testnet.sh

echo "cel-gmd start --rollkit.aggregator --rollkit.da_auth_token=\$AUTH_TOKEN --rollkit.da_namespace 00000000000000000000000000000000000000000008e5f679bf7116cb --rollkit.da_start_height \$DA_BLOCK_HEIGHT --rpc.laddr tcp://127.0.0.1:36657 --grpc.address 127.0.0.1:9290 --p2p.laddr \"0.0.0.0:36656\" --minimum-gas-prices="0.025stake"" >> restart-testnet.sh

# start the chain
cel-gmd start --rollkit.aggregator --rollkit.da_auth_token=$AUTH_TOKEN --rollkit.da_namespace 00000000000000000000000000000000000000000008e5f679bf7116cb --rollkit.da_start_height $DA_BLOCK_HEIGHT --rpc.laddr tcp://127.0.0.1:36657 --grpc.address 127.0.0.1:9290 --p2p.laddr "0.0.0.0:36656" --minimum-gas-prices="0.025stake"