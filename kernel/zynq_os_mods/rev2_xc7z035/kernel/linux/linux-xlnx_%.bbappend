SRC_URI += "file://user_2019-05-30-15-53-00.cfg"
SRC_URI += "file://user_2019-12-08-13-30-00.cfg"
SRC_URI += "file://user_2020-02-09.cfg"
SRC_URI += "file://sgmii.patch"
SRC_URI += "file://macb_main.c.patch"
SRC_URI += "file://user_2020-05-12-containers.cfg"
SRC_URI += "file://user_2020-05-27-containers2.cfg"
SRC_URI += "file://fsr-2level.patch"


FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

