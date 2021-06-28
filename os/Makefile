SHELL=bash
PWD=$(shell pwd)

SCRIPTS_PATH=${PWD}/scripts
SECURE_PATH=${PWD}/secure

%xc7z035.tar.gz : QEMU=qemu-arm-static
%xc7z045.tar.gz : QEMU=qemu-arm-static
%xczu7ev.tar.gz : QEMU=qemu-aarch64-static

%xc7z035.tar.gz : ZYNQ_ARCH=armv7hl
%xc7z045.tar.gz : ZYNQ_ARCH=armv7hl
%xczu7ev.tar.gz : ZYNQ_ARCH=aarch64

CONFIG_BASE_DIR=${PWD}/config
rev1_% : CONFIG_DIR = ${CONFIG_BASE_DIR}/rev1
rev2_% : CONFIG_DIR = ${CONFIG_BASE_DIR}/rev2

INSTALL_BASE_PATH=${PWD}/image/
rev1_xc7z035.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}/rev1_xc7z035/
rev1_xc7z045.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}/rev1_xc7z035/
rev2_xc7z035.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}/rev2_xc7z035/
rev2_xc7z045.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}/rev2_xc7z045/
rev2_xczu7ev.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}/rev2_xczu7ev/



#INSTALL_PATH=${PWD}/image
ETC_PATH =${INSTALL_PATH}/etc/
HOME_PATH=${INSTALL_PATH}/home/
TMP_PATH =${INSTALL_PATH}/tmp/
OPT_PATH =${INSTALL_PATH}/opt/


.PHONEY: clean finalize_image all shell


#paths for build output
${INSTALL_PATH}:  centos-rootfs/extra_rpms.txt
	rm -rf $@
	mkdir -p $@

#rules for building QEMU emulators
include mk/QEMU.mk

${ETC_PATH} ${TMP_PATH}: ${QEMU_PATH}/${QEMU} ${INSTALL_PATH}/${QEMU_PATH}/${QEMU} centos-rootfs/extra_rpms.txt
	cd centos-rootfs && \
		sudo python mkrootfs.py --root=${INSTALL_PATH} --arch=${ZYNQ_ARCH} --extra=extra_rpms.txt

${OPT_PATH}: ${TMP_PATH}
	sudo mkdir -p ${OPT_PATH}

#system components
include mk/secrets.mk
include mk/fs_mods.mk
include mk/users.mk
include mk/services.mk

#software/libraries
include mk/uHAL.mk
include mk/BUTool.mk
include mk/Monitoring.mk
include mk/CM_MCU.mk
include mk/mmc-utils.mk
include mk/overlay-tools.mk

SOFTWARE_AND_LIBS=${OPT_PATH}/BUTool ${OPT_PATH}/mcu_tools ${OPT_PATH}/Graphite_Monitor ${INSTALL_PATH}/usr/local/bin/mmc ${OPT_PATH}/overlay-tools


shell:
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash
clean:
	sudo rm -rf ${INSTALL_BASE_PATH}



%.tar.gz : ${INSTALL_PATH} ${ETC_PATH} ${SECURE_FILES} ${USERS_FILES} ${SOFTWARE_AND_LIBS}
	#modifications made via configs dir (common and rev specific)
	$(MAKE) fs_mods
	$(MAKE) users
	$(MAKE) services
	sudo cp ${SCRIPTS_PATH}/cleanup_locale.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/cleanup_locale.sh
	sudo rm -rf ${TMP_PATH}/*
	cd ${INSTALL_PATH} && \
		sudo tar --numeric-owner -p -zcf ../$@ ./


#################################################################################
# Help
#################################################################################
#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]/]' -e '^$@$$' | column

