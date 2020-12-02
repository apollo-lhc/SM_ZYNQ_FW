#SRC_URI += "file://user_containers.cfg"
#SRC_URI += "file://user_rtc.cfg"  
#SRC_URI += "file://user_uarts.cfg"  
#SRC_URI += "file://user_uio.cfg"
SRC_URI += "file://user_containers.cfg \
file://user_rtc.cfg \
file://user_uarts.cfg \
file://user_uio.cfg"

#SRC_URI_append = " \
#	       file://user_containers.cfg \
#	       file://user_rtc.cfg \
#	       file://user_uarts.cfg \
#	       file://user_uio.cfg"

KERNEL_FEATURES_append = " \
	       user_containers.cfg \
	       user_rtc.cfg \
	       user_uarts.cfg \
	       user_uio.cfg"


#FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
