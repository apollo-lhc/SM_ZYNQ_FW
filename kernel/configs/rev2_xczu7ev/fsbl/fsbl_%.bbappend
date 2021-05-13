SRC_URI_append = " \
	       file://1001-fsbl.patch \
	       file://0001-Addes-SI-programming.patch \
	       file://0002-fixes.patch \
	       file://0003-adding-missed-includes.patch \
	       file://0004-fixed-printf.patch \
	       file://0005-fixed-address.patch \
	       file://0006-forgot-this-needs-the-SERV-and-the-SI_I2C-AXI-addres.patch \
	       file://0007-preprint.patch \
	       file://AXI_slave_addrs.h \
        "
 
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#Add debug for FSBL(optional)
#XSCTH_BUILD_DEBUG = "1"


EXTERNALXSCTSRC = ""
EXTERNALXSCTSRC_BUILD = ""
