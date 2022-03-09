#!/bin/bash

if [ $# -gt 0 ]; then
    #install the crap we need
    yum install make wget sudo  python-augeas dnf python3-pip git -y

    #create a directory to build in
    mkdir /tmp/build
    #copy the needed files to it
    cp -r /app/* /tmp/build
    cd /tmp/build
    #run the build
    make $1.tar.gz
    mv /tmp/build/image/$1.tar.gz /app
else
    echo "Missing build name.  ex. rev2a_xczu7ev"
fi
