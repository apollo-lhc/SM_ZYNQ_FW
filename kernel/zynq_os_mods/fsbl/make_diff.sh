#!/bin/bash
XILINX_PATH=/opt/Xilinx/
PETALINUX_PATH=$XILINX_PATH/petalinux/2018.2/
FSBL_SRC=$PETALINUX_PATH/tools/hsm/data/embeddedsw/lib/sw_apps/zynq_fsbl/src/fsbl_hooks.c

DIFF_FILE=./files/0001-fsbl.patch

#diff -Naur $FSBL_SRC fsbl_hooks_patch.c
diff -Naur $FSBL_SRC fsbl_hooks_patch.c --label a/lib/sw_apps/zynq_fsbl/src/fsbl_hooks.c --label b/lib/sw_apps/zynq_fsbl/src/fsbl_hooks.c  > $DIFF_FILE
