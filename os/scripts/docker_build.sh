#!/bin/bash

# exit when any command fails

DUMP_FILE="/app/make_log.txt"
DUMP_CMD= | tee -a ${DUMP_FILE}


if [ $# -gt 0 ]; then
    rm -f ${DUMP_FILE}
    
    #install the crap we need
    yum install selinux-policy-minimum.noarch -y                               ${DUMP_CMD}
    setenforce 0                                                               ${DUMP_CMD}
    set -e                                                                     ${DUMP_CMD}
    yum install dnf -y                                                         ${DUMP_CMD}
    yum clean all -y                                                           ${DUMP_CMD}
    rm -f /var/lib/rpm/_db*			                               ${DUMP_CMD}
    rpm --rebuilddb                                                            ${DUMP_CMD}
						                               
    dnf update -y                                                              ${DUMP_CMD}
    
    
    dnf install make wget sudo augeas dnf python3-pip git gcc python3-devel -y ${DUMP_CMD}
    dnf install libffi-devel -y                                                ${DUMP_CMD}
    
    
    pip3 install python-augeas                                                 ${DUMP_CMD}
    
    #create a directory to build in
    mkdir /tmp/build                                                           ${DUMP_CMD}
    #copy the needed files to it
    cp -r /app/* /tmp/build                                                    ${DUMP_CMD}
    cd /tmp/build                                                              ${DUMP_CMD}
    #run the build
    make $1.tar.gz                                                             ${DUMP_CMD}
    mv /tmp/build/image/$1.tar.gz /app                                         ${DUMP_CMD}
else
    echo "Missing build name.  ex. rev2a_xczu7ev"
fi
