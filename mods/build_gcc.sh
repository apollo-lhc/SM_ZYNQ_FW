#!/bin/bash

PWD=$(pwd)

export BUILD_PATH=${PWD}/build
export SYSROOT=${PWD}/image
export INSTALL_PATH=${BUILD_PATH}/install

mkdir -p ${BUILD_PATH}
mkdir -p ${INSTALL_PATH}

source /opt/Xilinx/petalinux/2018.2/settings.sh


#####cd ${BUILD_PATH}
#####mkdir binutils
#####cd binutils
#####wget http://ftpmirror.gnu.org/binutils/binutils-2.27.tar.gz
#####tar xf binutils-2.27.tar.gz
#####mkdir build && cd build
#####../binutils-2.27/configure \
#####    CC=arm-linux-gnueabihf-gcc \
#####    CXX=arm-linux-gnueabihf-g++ \
#####    AR=arm-linux-gnueabihf-ar \
#####    RANLIB=arm-linux-gnueabihf-ranlib \
#####    LD=arm-linux-gnueabihf-ld \
#####    NM=arm-linux-gnueabihf-gcc-nm \
#####    --host=arm-linux-gnueabihf \
#####    --build=x86_64-linux-gnu \
#####    --prefix=${INSTALL_PATH} \
#####    --with-arch=armv7 \
#####    --with-fpu=vfp \
#####    --with-float=hard \
#####    --disable-ultilib \
#####    --with-no-thumb-interwork \
#####    --with-mode=thumb
#####make -j8 all install
#####export PATH="$PATH:$INSTALL_PATH/arm-none-eabi/bin"
#####
#####cd ${BUILD_PATH}
#####mkdir gmp
#####cd gmp
#####wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2
#####tar xf gmp-6.1.0.tar.bz2
#####mkdir build && cd build
#####../gmp-6.1.0/configure \
#####    CC=arm-linux-gnueabihf-gcc \
#####    CXX=arm-linux-gnueabihf-g++ \
#####    AR=arm-linux-gnueabihf-ar \
#####    RANLIB=arm-linux-gnueabihf-ranlib \
#####    LD=arm-linux-gnueabihf-ld \
#####    NM=arm-linux-gnueabihf-gcc-nm \
#####    CFLAGS="-I. -I./Include -IInclude -I${INSTALL_PATH}/include -I${SYSROOT}/usr/include" \
#####    LDFLAGS="--sysroot=${SYSROOT} -L${PWD}/image/lib -L${INSTALL_PATH}/lib -L${SYSROOT}/usr/lib" \
#####    --host=arm-linux-gnueabihf \
#####    --build=x86_64-linux-gnu \
#####    --prefix=${INSTALL_PATH} \
#####    --with-arch=armv7 \
#####    --with-fpu=vfp \
#####    --with-float=hard \
#####    --disable-ultilib \
#####    --with-no-thumb-interwork \
#####    --with-mode=thumb
#####make -j8 all 
#####make install
#####
#####
#####cd ${BUILD_PATH}
#####mkdir mpfr
#####cd mpfr
#####wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-3.1.4.tar.bz2
#####tar xf mpfr-3.1.4.tar.bz2
#####mkdir build && cd build
#####../mpfr-3.1.4/configure \
#####    CC=arm-linux-gnueabihf-gcc \
#####    CXX=arm-linux-gnueabihf-g++ \
#####    AR=arm-linux-gnueabihf-ar \
#####    RANLIB=arm-linux-gnueabihf-ranlib \
#####    LD=arm-linux-gnueabihf-ld \
#####    NM=arm-linux-gnueabihf-gcc-nm \
#####    CFLAGS="-I. -I./Include -IInclude -I${INSTALL_PATH}/include -I${SYSROOT}/usr/include" \
#####    LDFLAGS="--sysroot=${SYSROOT} -L${PWD}/image/lib -L${INSTALL_PATH}/lib -L${SYSROOT}/usr/lib" \
#####    --host=arm-linux-gnueabihf \
#####    --build=x86_64-linux-gnu \
#####    --prefix=${INSTALL_PATH} \
#####    --with-arch=armv7 \
#####    --with-fpu=vfp \
#####    --with-float=hard \
#####    --disable-ultilib \
#####    --with-no-thumb-interwork \
#####    --with-mode=thumb
#####make -j8 all 
#####make install
#####
#####cd ${BUILD_PATH}
#####mkdir mpc
#####cd mpc
#####wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz
#####tar xf mpc-1.0.3.tar.gz
#####mkdir build && cd build
#####../mpc-1.0.3/configure \
#####    CC=arm-linux-gnueabihf-gcc \
#####    CXX=arm-linux-gnueabihf-g++ \
#####    AR=arm-linux-gnueabihf-ar \
#####    RANLIB=arm-linux-gnueabihf-ranlib \
#####    LD=arm-linux-gnueabihf-ld \
#####    NM=arm-linux-gnueabihf-gcc-nm \
#####    CFLAGS="-I. -I./Include -IInclude -I${INSTALL_PATH}/include -I${SYSROOT}/usr/include" \
#####    LDFLAGS="--sysroot=${SYSROOT} -L${PWD}/image/lib -L${INSTALL_PATH}/lib -L${SYSROOT}/usr/lib" \
#####    --host=arm-linux-gnueabihf \
#####    --build=x86_64-linux-gnu \
#####    --prefix=${INSTALL_PATH} \
#####    --with-arch=armv7 \
#####    --with-fpu=vfp \
#####    --with-float=hard \
#####    --disable-ultilib \
#####    --with-no-thumb-interwork \
#####    --with-mode=thumb
#####make -j8 all 
#####make install



cd ${BUILD_PATH}
mkdir gcc-4.7.1
cd gcc-4.7.1
wget ftp://ftp.gnu.org/gnu/gcc/gcc-4.7.1/gcc-4.7.1.tar.bz2
tar xf gcc-4.7.1.tar.bz2
mkdir build && cd build
../gcc-4.7.1/configure \
    CC=arm-linux-gnueabihf-gcc \
    CXX=arm-linux-gnueabihf-g++ \
    AR=arm-linux-gnueabihf-ar \
    RANLIB=arm-linux-gnueabihf-ranlib \
    LD=arm-linux-gnueabihf-ld \
    NM=arm-linux-gnueabihf-gcc-nm \
    CFLAGS="-I. -I./Include -IInclude -I${INSTALL_PATH}/include -I${SYSROOT}/usr/include" \
    LDFLAGS="--sysroot=${SYSROOT} -L${PWD}/image/lib -L${INSTALL_PATH}/lib -L${SYSROOT}/usr/lib -L${SYSROOT}/lib -L/opt/Xilinx/petalinux/2018.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/libc/lib/" \
    --with-sysroot=${SYSROOT} \
    --with-lib-path=${INSTALL_PATH}/lib:${INSTALL_PATH}/usr/lib:${SYSROOT}/lib:${SYSROOT}/usr/lib:/opt/Xilinx/petalinux/2018.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/libc/lib/ \
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

#    --with-sysroot=${PWD}/build/install \
#    CFLAGS="-I. -I./Include -IInclude -I${PWD}/image/usr/include" \
#    LDFLAGS="--sysroot=${PWD}/image -L${PWD}/image/lib -L${PWD}/image/usr/lib" \
    
