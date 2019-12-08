#!/bin/bash

PWD=$(shell pwd)

export PREFIX=${PWD}/build
export SYSROOT=${PWD}/image
export INSTALL_DIR=${PREFIX}/cross
export WRKDIR=${PWD}

source /opt/Xilinx/petalinux/2018.2/settings.sh


cd $WRKDIR
wget http://ftpmirror.gnu.org/binutils/binutils-2.24.tar.gz
tar xf binutils-2.27.tar.gz
mkdir build-binutils && cd build-binutils
../binutils-2.27/configure --prefix=$INSTALL_DIR --target=arm-linux-gnueabihf --with-arch=armv7 --with-fpu=vfp --with-float=hard --disable-multilib
make -j 8
make install


cd $WRKDIR
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz
tar xvf mpc-1.0.3.tar.gz 
mkdir build-mpc && cd build-mpc
../mpc-1.0.3/configure --prefix=$INSTALL_DIR --target=arm-linux-gnueabihf
make -j 8 && make install


cd $WRKDIR
wget http://ftpmirror.gnu.org/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz
tar xf gcc-8.2.0.tar.gz 
mkdir -p build-gcc && cd build-gcc/
../gcc-8.2.0/configure --prefix=$INSTALL_DIR --target=arm-linux-gnueabihf --with-arch=armv7 --with-fpu=vfp --with-float=hard --enable-languages=c,c++ --disable-multilib --with-gmp=/usr --with-mpc=$INSTALL_DIR --with-sysroot=$SYSROOT
make -j 8 && make install
