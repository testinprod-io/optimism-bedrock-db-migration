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

# setup import
cd 
git clone https://github.com/testinprod-io/op-erigon
cd op-erigon
git switch pcw109550/bedrock-db-migration
make erigon

# op-geth db download
cd 
wget https://storage.googleapis.com/oplabs-goerli-data/goerli-bedrock.tar
tar xvf goerli-bedrock.tar
mkdir geth_db
mv geth geth_db/
