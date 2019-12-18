#!/bin/bash

PWD=$(pwd)

export BUILD_PATH=${PWD}/build
export SYSROOT=${PWD}/image
export INSTALL_PATH=${BUILD_PATH}/install
#INSTALL_PATH=${SYSROOT}/usr/local/

mkdir -p ${BUILD_PATH}
mkdir -p ${INSTALL_PATH}

#source /opt/Xilinx/petalinux/2018.2/settings.sh




GCC_VERSION=4.8.5
cd ${BUILD_PATH}
mkdir gcc
cd gcc
#cp ../../mods/patch-gcc_cp_cfns.h ./
wget ftp://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar xf gcc-${GCC_VERSION}.tar.gz
mkdir build && cd build
#patch -u -b ../gcc-${GCC_VERSION}/gcc/cp/cfns.h -i ../patch-gcc_cp_cfns.h
../gcc-${GCC_VERSION}/configure \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib \
    --with-gmp=${INSTALL_PATH} \
    --with-mpfr=${INSTALL_PATH} \
    --with-mpc=${INSTALL_PATH} \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=${INSTALL_PATH} \
    --with-arch=armv7 \
    --with-fpu=vfp \
    --with-float=hard \
    --enable-languages="c,c++" \
    --with-no-thumb-interwork \
    --disable-multilib \
    --with-mode=thumb   
make all-gcc   
make install-gcc  

