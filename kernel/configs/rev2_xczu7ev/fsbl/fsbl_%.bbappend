SRC_URI_append = " \
	       file://0001-mods.patch \
	       file://git/lib/sw_apps/zynqmp_fsbl/src/build_mods.c \
	       file://git/lib/sw_apps/zynqmp_fsbl/src/AXI_slave_addrs.h \
        "
 
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#Add debug for FSBL(optional)
XSCTH_BUILD_DEBUG = "1"


EXTERNALXSCTSRC = ""
EXTERNALXSCTSRC_BUILD = ""
