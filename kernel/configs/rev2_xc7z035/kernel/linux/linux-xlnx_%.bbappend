SRC_URI += "file://user_2019-05-30-15-53-00.cfg \
            file://user_2019-12-08-13-30-00.cfg \
            file://user_2020-02-09.cfg \
            file://user_2020-05-12-containers.cfg \
            file://user_2020-05-27-containers2.cfg \
	    "

#KERNEL_FEATURES_append = " \
#               user_2019-05-30-15-53-00.cfg \
#	       user_2019-12-08-13-30-00.cfg \
#	       user_2020-02-09.cfg \
#	       user_2020-05-12-containers.cfg \
#	       user_2020-05-27-containers2.cfg \
#	       user_2021-03-30-11-44-00.cfg "
#	       user_2021-04-05-13-07-00.cfg \
#	       plnx_kernel-user.cfg "



FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
