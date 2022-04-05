#!/bin/bash

pwd
#../build-scripts/fsbl_Si.py --outfile=zynq_os/project-spec/meta-user//recipes-bsp/fsbl//files/git/lib/sw_apps/zynqmp_fsbl/src/build_mods.c 
scripts/fsbl_Si.py --outfile=zynq_os/project-spec/meta-user//recipes-bsp/fsbl//files/git/lib/sw_apps/zynqmp_fsbl/src/build_mods.c \
             -f ../src/services/si5344-SM_BASE/Si5344-RevD-SM_BASE-Registers.txt  -i 0xD0 -s 0x0 \
             -f ../src/TCDS/si5344-TCDS/Si5344-RevD-TCDS2-Registers.txt           -i 0xD4 -s 0x5
