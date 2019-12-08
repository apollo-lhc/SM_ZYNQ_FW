#!/bin/bash

export ROOTFS_PATH=/home/dan/work/Apollo/centos/image
cd centos-rootfs
sudo python mkrootfs.py --root=$ROOTFS_PATH --arch=armv7hl --extra=extra_rpms.txt

