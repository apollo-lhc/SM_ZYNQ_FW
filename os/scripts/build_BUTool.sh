#!/bin/bash
cd /tmp/ApolloTool
export CACTUS_ROOT=/opt/cactus
make local UHAL_VER_MAJOR=2 UHAL_VER_MINOR=8 -j32 RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/
make install UHAL_VER_MAJOR=2 UHAL_VER_MINOR=8 RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/ INSTALL_PATH=/opt/BUTool
