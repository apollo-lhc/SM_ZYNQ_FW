# Patch for FSBL
# Note: do_configure_prepend task section is required only for 2017.1 release
# Refer https://github.com/Xilinx/meta-xilinx-tools/blob/rel-v2017.2/classes/xsctbase.bbclass#L29-L35
 
#do_configure() {
#    if [ -d "${S}/patches" ]; then
#       rm -rf ${S}/patches
#    fi
# 
#    if [ -d "${S}/.pc" ]; then
#       rm -rf ${S}/.pc
#    fi
#}
 
#SRC_URI_append = " \
#        file://0001-fsbl.patch \
#        "

SRC_URI_append = " \
	       file://2018.3-mods.patch \
	       "

 
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#Add debug for FSBL(optional)
XSCTH_BUILD_DEBUG = "1"


EXTERNALXSCTSRC = ""
EXTERNALXSCTSRC_BUILD = ""
