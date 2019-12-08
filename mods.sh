#!/bin/bash

cp mods/group   image/etc
chmod 644 image/etc/group

cp mods/gshadow	image/etc
chmod 004 image/etc/gshadow

cp mods/passwd	image/etc
chmod 644 image/etc/passwd

cp mods/shadow  image/etc
chmod 000 image/etc/passwd

mkdir -p image/home/cms
mkdir -p image/home/atlas

