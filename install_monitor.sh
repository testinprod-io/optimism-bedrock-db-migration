#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

XDG_DATA_HOME="~/.local/share/"
if [[ -n "$1" ]]; then
    XDG_DATA_HOME=$1
fi

# setup permissions for prometheus and grafana
mkdir -p $XDG_DATA_HOME/erigon-prometheus
chmod 777 $XDG_DATA_HOME/erigon-prometheus
mkdir -p $XDG_DATA_HOME/erigon-grafana
chmod 777 $XDG_DATA_HOME/erigon-grafana

# setup monitoring
cd 
git clone https://github.com/testinprod-io/op-erigon
cd op-erigon
git switch pcw109550/bedrock-db-migration
