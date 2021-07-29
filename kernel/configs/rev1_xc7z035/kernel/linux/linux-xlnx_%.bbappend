SRC_URI += "file://user_working.cfg \
            file://user_uarts.cfg \
            file://user_containers.cfg \
	    "
#	    file://0001-Added-debugging-output-for-external-abort-on-non-lin.patch \
#	    "
#	    file://fsr-2level.patch \
#	    "



FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
