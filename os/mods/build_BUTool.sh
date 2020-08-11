#!/bin/bash
cd /tmp/ApolloTool
export CACTUS_ROOT=/opt/cactus
make local -j32 RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/
make install RUNTIME_LDPATH=/opt/BUTool COMPILETIME_ROOT=--sysroot=/ INSTALL_PATH=/opt/BUTool
