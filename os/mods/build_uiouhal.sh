#!/bin/bash
export CACTUS_ROOT=/opt/cactus
#export IPBUS_PATH=/tmp/ipbus
cd /tmp/UIOuHAL/
UHAL_VER_MAJOR=2 UHAL_VER_MINOR=8 make MAP_TYPE=-DSTD_UNORDERED_MAP 
#make MAP_TYPE=-DSTD_UNORDERED_MAP 
mkdir -p /opt/UIOuHAL/
cp -r lib /opt/UIOuHAL/
cp -r include /opt/UIOuHAL/
