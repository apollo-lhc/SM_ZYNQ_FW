#!/bin/bash

sudo cp mods/group   image/etc
sudo chmod 644 image/etc/group

sudo cp mods/gshadow	image/etc
sudo chmod 004 image/etc/gshadow

sudo cp mods/passwd	image/etc
sudo chmod 644 image/etc/passwd

sudo cp mods/shadow  image/etc
sudo chmod 000 image/etc/passwd

sudo mkdir -p image/home/cms
sudo mkdir -p image/home/atlas

cd image/lib
sudo sudo ln -s libstdc++.so.6 libstdc++.so
cd ..

cd tmp
git clone https://github.com/dgastler/ipbus-software.git
cd ipbus-software
git checkout feature-UIOuHAL
cd ../../../
cp mods/build_ipbus.sh ./image/tmp/ipbus-software
sudo chroot ./image/ /usr/local/bin/qemu-arm-static /bin/bash /tmp/ipbus-software/build_ipbus.sh

cd image/tmp
git clone https://github.com/apollo-lhc/ApolloTool.git
cd ApolloTool
make init
cd ../../../
cp mods/build_BUTool.sh ./image/tmp/ApolloTool
sudo chroot ./image/ /usr/local/bin/qemu-arm-static /bin/bash /tmp/ApolloTool/build_BUTool.sh

sudo rm -rf ./image/tmp/*
