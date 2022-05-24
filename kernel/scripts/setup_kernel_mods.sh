#!/bin/bash


DIRS=$(ls -1 ${KMODULE_SRC_PATH})
START_PATH=$(pwd)
for kmod in ${DIRS}; do
    echo "Adding module $kmod";		
    cd ${ZYNQ_OS_PROJECT_PATH} && \
	source ${SOURCE_PETALINUX_ENV} &&  \
	petalinux-create -t modules --enable --name $kmod
    echo $PWD
    cd ${START_PATH}
    echo $PWD
    cp -r  ${KMODULE_SRC_PATH}/$kmod/* ${KMODULE_DST_PATH}/$kmod
done
