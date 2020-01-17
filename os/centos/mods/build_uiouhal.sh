#!/bin/bash
export CACTUS_ROOT=/opt/cactus
#export IPBUS_PATH=/tmp/ipbus
cd /tmp/UIOuHAL/
make
mkdir -p /opt/UIOuHAL/
cp -r lib /opt/UIOuHAL/
cp -r include /opt/UIOuHAL/
