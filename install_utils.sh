#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

sudo apt install -y curl unzip

# install aws client
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
# aws configure
# https://developers.cloudflare.com/r2/api/s3/tokens/

# install google cloud cli for gsutil
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-433.0.1-linux-x86_64.tar.gz
tar -xf google-cloud-cli-433.0.1-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
# gcloud init --no-browser --console-only 
# https://cloud.google.com/sdk/gcloud/reference/init
