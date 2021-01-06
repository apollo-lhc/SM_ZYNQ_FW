SRC_URI += "file://user_2019-05-30-15-53-00.cfg \
            file://user_2019-12-08-13-30-00.cfg \
            file://user_2020-02-09.cfg \
            file://user_2020-05-12-containers.cfg \
            file://user_2020-05-27-containers2.cfg \
            file://fsr-2level.patch"

#SRC_URI_append = "file://user_2019-05-30-15-53-00.cfg \
#                 file://user_2019-12-08-13-30-00.cfg \
#                 file://user_2020-02-09.cfg \
#                 file://user_2020-05-12-containers.cfg \
#                 file://user_2020-05-27-containers2.cfg \
#                 file://fsr-2level.patch"
#SRC_URI += "file://user_2019-05-30-15-53-00.cfg"
#SRC_URI += "file://user_2019-12-08-13-30-00.cfg"
#SRC_URI += "file://user_2020-02-09.cfg"
#SRC_URI += "file://user_2020-05-12-containers.cfg"
#SRC_URI += "file://user_2020-05-27-containers2.cfg"
#SRC_URI += "file://fsr-2level.patch"

KERNEL_FEATURES_append = " \
               user_2019-05-30-15-53-00.cfg \
	       user_2019-12-08-13-30-00.cfg \
	       user_2020-02-09.cfg \
	       user_2020-05-12-containers.cfg \
	       user_2020-05-27-containers2.cfg "



FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
