#
# This file is the bootscript recipe.
#

SUMMARY = "ARM monitor script"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://arm-monitor \
	"

S = "${WORKDIR}"
inherit update-rc.d

INITSCRIPT_NAME = "arm-monitor"
INITSCRIPT_PARAMS = "start 99 5 S . stop 99 6 ."
do_install() {
	     install -d ${D}/${sysconfdir}/init.d
	     install -m 0755 ${S}/arm-monitor ${D}/${sysconfdir}/init.d/arm-monitor
}
FILES_${PN} += "${sysconfdir}/*"