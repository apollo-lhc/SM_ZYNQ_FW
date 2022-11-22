SRC_URI += "file://user_containers.cfg \
file://user_rtc.cfg \
file://user_uarts.cfg \
file://user_uio.cfg \
file://user_pinctrl.cfg \
file://user_ethernet.cfg"

#SRC_URI_append = " file://0001-net-macb-Add-MDIO-driver-for-accessing-multiple-PHY-.patch"


#HACK for 2018.3
#https://forums.xilinx.com/t5/Embedded-Linux/Petalinux-2018-3-kernel-configuration-builtin-configuration-for/td-p/1073484
KERNEL_FEATURES_append = " \
	       user_containers.cfg \
	       user_rtc.cfg \
	       user_uarts.cfg \
	       user_uio.cfg \
	       user_pinctrl.cfg \
	       user_ethernet.cfg"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

