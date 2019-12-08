#!/bin/bash

export ROOTFS_PATH=/home/dan/work/Apollo/centos/image

#armv7hl
rm qemu-arm-static
wget https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0/qemu-arm-static
chmod +x qemu-arm-static
sudo mkdir -p $ROOTFS_PATH/usr/local/bin
sudo cp -a qemu-arm-static $ROOTFS_PATH/usr/local/bin
sudo cp -a qemu-arm-static /usr/local/bin
