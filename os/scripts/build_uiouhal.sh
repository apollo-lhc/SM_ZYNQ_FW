#!/bin/bash
export CACTUS_ROOT=/opt/cactus
#export IPBUS_PATH=/tmp/ipbus
cd /tmp/UIOuHAL/
make UHAL_VER_MAJOR=2 UHAL_VER_MINOR=8
mkdir -p /opt/UIOuHAL/
cp -r lib /opt/UIOuHAL/
cp -r include /opt/UIOuHAL/
