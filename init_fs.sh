#!/bin/bash
set -e

init_filesystem() {
    DEVICE=$1
    MOUNT_DIR=$2

    sudo mkdir -p "$MOUNT_DIR"
    sudo chown -R $(whoami):$(whoami) "$MOUNT_DIR"

    if ! lsblk -f "$DEVICE" | grep -q "$DEVICE"; then
        echo "device $DEVICE does not exist"
        exit 1
    fi

    if ! sudo file -s "$DEVICE" | grep -q "data"; then 
        echo "device $DEVICE has fs initialized"
        exit 1
    fi

    # make file system
    # warning: volume data will be wiped
    sudo mkfs -t xfs "$DEVICE"

    # mount
    sudo mount "$DEVICE" "$MOUNT_DIR"
}

init_filesystem "/dev/nvme1n1" "/data1"
init_filesystem "/dev/nvme2n1" "/data2"
