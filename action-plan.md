#  Optimistic Erigon Mainnet Bedrock Migration - Action Plan

## Init Instance

### Migration Instance

Boot up instance for migration.
- Name: `bedrock-migration`
- Instance Type: `x2idn.32xlarge`
- Instance storage: 200 GB io2 + 2 x 1900 GB NVMe SSD

Let migration instance's public ip `[migration-public-ip]`.

Run below commands.
```sh
cd
git clone https://github.com/testinprod-io/optimism-bedrock-db-migration
cd optimism-bedrock-db-migration
./init_fs.sh  # to mount 1900 GB NVMe SSD
./install.sh [arch] [optional:op-geth-database-download-endpoint] [optional:data-dir]
# ex) ./install.sh amd https://storage.googleapis.com/oplabs-goerli-data/goerli-bedrock.tar /data1
```

`./init_fs.sh` will mount available NVMe SSDs to directory `/data1` and `/data2`. It assumes that device names are `nvme1n1` and `nvme2n1`.

### Migration Monitor Instance

Boot up instance for migration monitoring.
- Name: `bedrock-migration-monitor`
- Instance Type: `m5.2xlarge`
- Instance storage: 200 GB gp2

Let migration monitor instance's public ip `[migration-monitor-public-ip]`.

Run below commands.
```sh
cd
git clone https://github.com/testinprod-io/optimism-bedrock-db-migration
cd optimism-bedrock-db-migration
# install docker and docker compose
./install_docker.sh
# fix volume permission
./install_monitor.sh
```

## Network Config

### Migration Instance

Add Inbound Rule for its security group.
- Type: Custom TCP
- Port Range: `55555`
- Source: `[migration-monitor-public-ip]`

This is for exposing erigon's metric interface only to prometheus.

### Migration Monitor Instance

Add Inbound Rule for its security group.
- Type: Custom TCP
- Port Range: `3000`
- Source: `0.0.0.0`

This is for exposing grafana dashboard.

## Migration

At `bedrock-migration` instance,

### DB import

```sh
cd
cd op-geth
./migrate.sh [bedrock_start_block_num] [geth_bedrock_archive_location] [optional:artifact_path] 2>&1 | tee migration.log
# ex) ./migrate.sh 4061224 /home/ubuntu/geth_db  2>&1 | tee migration.log
# ex) ./migrate.sh 4061224 /data1/geth_db /data1/migration-artifact 2>&1 | tee migration.log
```

### DB export

```sh
cd
cd op-erigon
./migrate.sh [chain_name] [bedrock_start_block_num] [optional:artifact_path] [optional:erigon_db_path] 2>&1 | tee migration.log
# ex) ./migrate.sh optimism-goerli 4061224 2>&1 | tee migration.log
# ex) ./migrate.sh optimism-goerli 4061224 /data1/migration-artifact /data2/erigon_db
```

## Migration Monitor

At `bedrock-migration-monitor` instance,

```sh
cd
cd optimism-bedrock-db-migration
# script will fail if metric interface is not up 
./update_prometheus.sh [migration-public-ip]:55555
cd 
cd op-erigon
# serve grafana at port 3000
docker compose up prometheus grafana
```

Go to `[migration-monitor-public-ip]:3000` for resource monitoring.

## Postprocessing and DB Upload

### Upload Bedrock Genesis DB

Upload to GCP:

```sh
cd /data1
tar cf op-erigon-goerli-bedrock-genesis.tar erigon_db/chaindata/
gsutil -m cp op-erigon-goerli-bedrock-genesis.tar gs://op-erigon-misc/op-erigon-mainnet-goerli-genesis.tar
# for mainnet:
#  tar cf op-erigon-mainnet-bedrock-genesis.tar erigon_db/chaindata/
#  gsutil -m cp op-erigon-mainnet-bedrock-genesis.tar gs://op-erigon-misc/op-erigon-mainnet-bedrock-genesis.tar
```

### Single Block State Transition

State transition:

```sh
cd https://github.com/testinprod-io/op-fast-sync
git clone https://github.com/testinprod-io/op-fast-sync
cd op-fast-sync
pip install -r requirements.txt
python3 main.py --l1=[L1_RPC_ENDPOINT] --l2=[L2_RPC_ENDPOINT] --rpc=[OP_ERIGON_RPC_ENDPOINT] --engine=[OP_ERIGON_ENGINE_ENDPOINT] --jwt-secret=[OP_ERIGON_JWT_SECRET_PATH]
```

Check next block hash for confirmation.

### Upload Bedrock Genesis DB with Single Block State Transition

Upload to GCP:

```sh
cd /data1
tar cf {block_number}.tar erigon_db/chaindata/
gsutil -m cp {block_number}.tar gs://op-erigon-backup/goerli
# for mainnet:
#  gsutil -m cp {block_number}.tar gs://op-erigon-backup/mainnet
```

### Gzip Bedrock Genesis DB with Single Block State Transition

Compression:

```sh
sudo apt install pigz -y
cd /data1
pigs -k {block_number}.tar
# pigs will create {block_number}.tar.gz
mv {block_number}.tar.gz op-erigon-goerli.tar.gz
# for mainnet:
#  mv {block_number}.tar.gz op-erigon-mainnet.tar.gz
```

Upload to CF:

```sh
# supply cred
aws configure
aws s3 cp --endpoint-url https://<accountid>.r2.cloudflarestorage.com op-erigon-goerli.tar.gz s3://op-erigon-data/op-erigon-goerli.tar.gz
# for mainnet:
# aws s3 cp --endpoint-url https://<accountid>.r2.cloudflarestorage.com op-erigon-mainnet.tar.gz s3://op-erigon-data/op-erigon-mainnet.tar.gz
```
