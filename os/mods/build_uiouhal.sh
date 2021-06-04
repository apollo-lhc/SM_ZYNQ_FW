#!/bin/bash
export CACTUS_ROOT=/opt/cactus
#export IPBUS_PATH=/tmp/ipbus
cd /tmp/UIOuHAL/
make MAP_TYPE=-DSTD_UNORDERED_MAP 
mkdir -p /opt/UIOuHAL/
cp -r lib /opt/UIOuHAL/
cp -r include /opt/UIOuHAL/
