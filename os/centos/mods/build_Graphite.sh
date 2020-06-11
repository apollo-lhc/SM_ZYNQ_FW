#!/bin/bash
cd /tmp/Graphite
export APOLLO_PATH=/opt/BUTool
export CACTUS_ROOT=/opt/cactus
#Build the ApolloMonitor library
make -j32 lib_ApolloMonitor
#build Graphite_Monitor with the 
make install INSTALL_PATH=/opt/Graphite
