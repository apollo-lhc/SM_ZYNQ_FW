#!/bin/bash
cd /tmp/Graphite
export APOLLO_PATH=/opt/BUTool
export CACTUS_ROOT=/opt/cactus
#Build the ApolloMonitor library
make -j32 lib_ApolloMonitor
#Build shelf scan tools (crappy as is, but still might be useful)
make -j32 lib_ATCA
make shelf_scan
#build Graphite_Monitor with the 
make install INSTALL_PATH=/opt/Graphite
