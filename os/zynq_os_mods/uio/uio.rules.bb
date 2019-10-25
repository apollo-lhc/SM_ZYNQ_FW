#
# This file is the uio udev rules recipe.
#

SUMMARY = "udev rules for uio"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://uio.rules \
	file://mount.blacklist \
	"

S = "${WORKDIR}"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
do_install() {
	     install -d ${D}/${sysconfdir}/udev/mount.blacklist.d
	     install -m 0755 ${S}/mount.blacklist ${D}/${sysconfdir}/udev/mount.blacklist.d

	     install -d ${D}/${sysconfdir}/udev/rules.d
	     install -m 0755 ${S}/uio.rules ${D}/${sysconfdir}/udev/rules.d

}
FILES_${PN} += "${sysconfdir}/*"