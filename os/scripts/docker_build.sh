#!/bin/bash

# exit when any command fails
SRC_PATH=/app/
BUILD_PATH=/tmp/build/

DUMP_FILE=${SRC_PATH}"make_log.txt"
DUMP_CMD="tee -a ${DUMP_FILE}"



if [ $# -gt 0 ]; then
    rm -f ${DUMP_FILE}
    
    #install the crap we need
    yum install selinux-policy-minimum.noarch -y                             | ${DUMP_CMD}
    setenforce 0                                                             | ${DUMP_CMD}
    set -e                                                                   | ${DUMP_CMD}
    yum install dnf -y                                                       | ${DUMP_CMD}
    yum clean all -y                                                         | ${DUMP_CMD}
    rm -f /var/lib/rpm/_db*			                             | ${DUMP_CMD}
    rpm --rebuilddb                                                          | ${DUMP_CMD}
						                               
    dnf update -y                                                            | ${DUMP_CMD}
    
    
    dnf install make wget sudo augeas dnf python3-pip git gcc -y             | ${DUMP_CMD}
    dnf install libffi-devel python3-devel -y                                | ${DUMP_CMD}
    
    
    pip3 install python-augeas                                               | ${DUMP_CMD}
    
    #create a directory to build in
    mkdir ${BUILD_PATH}                                                      | ${DUMP_CMD}
    #copy the needed files to it. Do not log the cd, otherwise does not work
    cp -r ${SRC_PATH}* ${BUILD_PATH}                                         | ${DUMP_CMD}
    cd ${BUILD_PATH}                                                       # | ${DUMP_CMD}
    #run the build
    make $1.tar.gz                                                           | ${DUMP_CMD}
    mv ${BUILD_PATH}/image/$1.tar.gz ${SRC_PATH}                             | ${DUMP_CMD}
    mv ${DUMP_FILE} ${SRC_PATH}/make_log_$1.txt
else
    echo "Missing build name.  ex. rev2a_xczu7ev"
fi
