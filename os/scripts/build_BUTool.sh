#!/bin/bash
cd /tmp/ApolloTool
export CACTUS_ROOT=/opt/cactus
make local MAP_TYPE=-DSTD_UNORDERED_MAP -j32 RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/
make install RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/ INSTALL_PATH=/opt/BUTool
