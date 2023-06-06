#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

XDG_DATA_HOME="$HOME/.local/share/"
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

GRAFANA_INI_FILE_LOCATION="./cmd/prometheus/grafana.ini"
ADMIN_PASSWD=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1)
sed -i "/^\[security\]$/a admin_password = $ADMIN_PASSWD" "$GRAFANA_INI_FILE_LOCATION"

echo "grafana password: $ADMIN_PASSWD"
echo "$ADMIN_PASSWD" > "$HOME/grafana_passwd.txt"
