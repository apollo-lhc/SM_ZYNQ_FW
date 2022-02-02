SRC_URI_append = " \
	       file://0001-code-for-apollo-si-programming.patch \
	       file://0002-SI-programming-in-the-way-wrong-locatoin.patch \
	       file://0003-updated-printing.patch \
	       file://0004-Added-updates-for-7series-zynq.patch \
	       file://0005-Added-axi-addr-printing-in-7s-fsbl.patch \
	       file://0006-Moved-which-7s-fsbl-hooks-we-use.patch \
	       file://0007-Fix-for-SSD.patch \
	       file://0008-another-fsbl-change-for-SSD.patch \
	       file://0009-Another-fsbl-change-for-SSD.patch \
	       file://0010-Commenting-out-serdes_illcalib-for-test.patch \
	       file://git/lib/sw_apps/zynqmp_fsbl/src/AXI_slave_addrs.h \
        "
 
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#Add debug for FSBL(optional)
XSCTH_BUILD_DEBUG = "1"


EXTERNALXSCTSRC = ""
EXTERNALXSCTSRC_BUILD = ""
