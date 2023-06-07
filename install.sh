#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

sudo apt install -y gcc g++ tmux jq make

# determine architecture
if [[ -n "$1" ]]; then
    if [[ "$1" == "arm" || "$1" == "amd" ]]; then
        ARCH=$1
    else
        echo "invalid arch."
        exit 1
    fi
else
    echo "Arch not set"
    exit 1
fi

# install go
wget https://go.dev/dl/go1.19.6.linux-"$ARCH"64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.6.linux-"$ARCH"64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
export PATH=$PATH:/usr/local/go/bin

# setup export
cd 
git clone https://github.com/testinprod-io/op-geth
cd op-geth
git switch pcw109550/bedrock-db-migration
make geth
cp ../optimism-bedrock-db-migration/slack_report.sh .

# setup import
cd 
git clone https://github.com/testinprod-io/op-erigon
cd op-erigon
git switch pcw109550/bedrock-db-migration
make erigon
cp ../optimism-bedrock-db-migration/slack_report.sh .

# op-geth db download
# determine endpoint
OP_GETH_DB_ENDPOINT="https://storage.googleapis.com/oplabs-goerli-data/goerli-bedrock.tar"
if [[ -n "$2" ]]; then
    OP_GETH_DB_ENDPOINT=$2
fi
echo "op-geth db endpoint set to $OP_GETH_DB_ENDPOINT"

# determine data location
DATA_DIR=$HOME
if [[ -n "$3" ]]; then
    DATA_DIR=$3
    mkdir -p "$DATA_DIR"
fi
echo "data directory set to $DATA_DIR"

cd "$DATA_DIR"
wget "$OP_GETH_DB_ENDPOINT" -O bedrock.tar
tar xvf bedrock.tar
mkdir geth_db
mv geth geth_db/
