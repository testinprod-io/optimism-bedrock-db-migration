#!/bin/bash
set e

sudo apt update && sudo apt upgrade -y

sudo apt install -y uidmap

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo systemctl disable --now docker.service docker.socket

dockerd-rootless-setuptool.sh install
docker version

# install docker compose
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
docker compose version
