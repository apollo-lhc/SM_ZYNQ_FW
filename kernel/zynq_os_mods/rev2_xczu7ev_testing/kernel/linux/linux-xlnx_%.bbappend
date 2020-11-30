SRC_URI += "file://user_containers.cfg"
SRC_URI += "file://user_rtc.cfg"  
SRC_URI += "file://user_uarts.cfg"  
SRC_URI += "file://user_uio.cfg"


FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

