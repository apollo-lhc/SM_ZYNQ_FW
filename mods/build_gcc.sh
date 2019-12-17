#!/bin/bash

PWD=$(pwd)

export BUILD_PATH=${PWD}/build
export SYSROOT=${PWD}/image
#export INSTALL_PATH=${BUILD_PATH}/install
INSTALL_PATH=${SYSROOT}/usr/local/

mkdir -p ${BUILD_PATH}
mkdir -p ${INSTALL_PATH}

source /opt/Xilinx/petalinux/2018.2/settings.sh


cd ${BUILD_PATH}
mkdir binutils
cd binutils
wget http://ftpmirror.gnu.org/binutils/binutils-2.27.tar.gz
tar xf binutils-2.27.tar.gz
mkdir build && cd build
../binutils-2.27/configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=${INSTALL_PATH} \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib \
    --with-arch=armv7 \
    --with-fpu=vfp \
    --with-float=hard \
    --disable-ultilib \
    --with-no-thumb-interwork \
    --with-mode=thumb  
make -j32 all   
make install   
export PATH="$PATH:$INSTALL_PATH/arm-none-eabi/bin"

cd ${BUILD_PATH}
mkdir gmp
cd gmp
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2
tar xf gmp-6.1.0.tar.bz2
mkdir build && cd build
../gmp-6.1.0/configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib \
    --prefix=${INSTALL_PATH} \
    --with-arch=armv7 \
    --with-fpu=vfp \
    --with-float=hard \
    --disable-ultilib \
    --with-no-thumb-interwork \
    --with-mode=thumb  
make -j32 all   
make install  


cd ${BUILD_PATH}
mkdir mpfr
cd mpfr
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-3.1.4.tar.bz2
tar xf mpfr-3.1.4.tar.bz2
mkdir build && cd build
../mpfr-3.1.4/configure \
    --with-gmp=${INSTALL_PATH} \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib \
    --prefix=${INSTALL_PATH} \
    --with-arch=armv7 \
    --with-fpu=vfp \
    --with-float=hard \
    --disable-ultilib \
    --with-no-thumb-interwork \
    --with-mode=thumb  
make -j32 all   
make install  

cd ${BUILD_PATH}
mkdir mpc
cd mpc
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz
tar xf mpc-1.0.3.tar.gz
mkdir build && cd build
../mpc-1.0.3/configure \
    --host=arm-linux-gnueabihf \
    --build=x86_64-linux-gnu \
    --prefix=${INSTALL_PATH} \
    LDFLAGS="--sysroot=${SYSROOT} -L${PWD}/image/lib -L${INSTALL_PATH}/lib -L${SYSROOT}/usr/lib" \
    --with-mpfr=${INSTALL_PATH} \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib \
    --with-arch=armv7 \
    --with-fpu=vfp \
    --with-float=hard \
    --disable-ultilib \
    --with-no-thumb-interwork \
    --with-mode=thumb  
make -j32 all   
make install  



GCC_VERSION=8.3.0
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


GLIBC_VERSION=2.26
cd ${BUILD_PATH}
mkdir glibc
cd glibc
wget ftp://ftp.gnu.org/gnu/glibc/glibc-${GLIBC_VERSION}.tar.gz
tar xf glibc-${GLIBC_VERSION}.tar.gz
mkdir build && cd build
#patch -u -b ../gcc-${GCC_VERSION}/gcc/cp/cfns.h -i ../patch-gcc_cp_cfns.h
../glibc-${GLIBC_VERSION}/configure \
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
make -j32 all  
make install  
