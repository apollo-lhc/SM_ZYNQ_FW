#!/bin/bash

KERNEL_BUILD_PATH=/app/kernel

if [ $# -gt 2 ]; then
    BUILD_NAME=$1
    #add the packages we need
    yum -y install iproute gcc gcc-c++ net-tools ncurses-devel zlib-devel openssl-devel flex bison libselinux xterm autoconf libtool texinfo SDL-devel glibc-devel glibc glib2-devel automake screen pax libstdc++ gawk python3 python3-pip python3-GitPython python3-jinja2 perl patch diffutils cpp perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue xz which make rsync file sudo

    #petalinux won't build as root(the defaul docker user) so make a test user
    adduser test

    cd ${KERNEL_BUILD_PATH}

        
    sudo -u test make clean
    sudo -u test BUILD_PETALINUX_VERSION=$2 BUILD_PETALINUX_ROOT=$3 make ${BUILD_NAME} | tee  /app/kernel/docker_build.txt
else
    echo "Missing build name.  ex. rev2a_xczu7ev"
fi
