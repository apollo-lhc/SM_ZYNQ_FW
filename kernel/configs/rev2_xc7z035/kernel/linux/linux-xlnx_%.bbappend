SRC_URI += "file://user_working.cfg \
            file://user_uarts.cfg \
            file://user_containers.cfg \
	    file://fsr-2level.patch \
	    "



FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
