SRC_URI += "file://user_containers.cfg \
file://user_rtc.cfg \
file://user_uarts.cfg \
file://user_uio.cfg \
file://user_pinctrl.cfg \
file://user_ethernet.cfg"



FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
