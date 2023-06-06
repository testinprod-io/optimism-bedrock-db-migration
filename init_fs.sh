#!/bin/bash
set -e

init_filesystem() {
    DEVICE=$1
    MOUNT_DIR=$2

    DEVICE_DIR="/dev/$DEVICE"

    sudo mkdir -p "$MOUNT_DIR"
    sudo chown -R $(whoami):$(whoami) "$MOUNT_DIR"

    if ! lsblk -f "$DEVICE_DIR" | grep -q "$DEVICE"; then
        echo "device $DEVICE does not exist"
        exit 1
    fi

    if sudo file -s "$DEVICE_DIR" | grep -q "XFS"; then 
        echo "device $DEVICE has fs initialized"
        exit 1
    fi

    # make file system
    # warning: volume data will be wiped
    sudo mkfs -t xfs "$DEVICE_DIR"

    # mount
    sudo mount "$DEVICE_DIR" "$MOUNT_DIR"
}

init_filesystem "nvme1n1" "/data1"
init_filesystem "nvme2n1" "/data2"
