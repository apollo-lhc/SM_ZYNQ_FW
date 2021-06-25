SHELL=bash
PWD=$(shell pwd)

ZYNQ_ARCH=aarch64
#ZYNQ_ARCH=armv7hl
MODS_PATH=${PWD}/mods
SECURE_PATH=${PWD}/secure

INSTALL_PATH=${PWD}/image
ETC_PATH=${INSTALL_PATH}/etc/
HOME_PATH=${INSTALL_PATH}/home/
TMP_PATH=${INSTALL_PATH}/tmp/
OPT_PATH=${INSTALL_PATH}/opt/



TARBALL_NAME=SD_p2.tar.gz

.PHONEY: clean finalize_image all shell

all: finalize_image


#paths for build output
${INSTALL_PATH}:  centos-rootfs/extra_rpms.txt
	rm -rf ${INSTALL_PATH}
	mkdir -p ${INSTALL_PATH}

#rules for building QEMU emulators
include mk/QEMU.mk

${ETC_PATH} ${TMP_PATH}: ${QEMU_PATH}/${QEMU} ${INSTALL_PATH}/${QEMU_PATH}/${QEMU} centos-rootfs/extra_rpms.txt
	cd centos-rootfs && \
		sudo python mkrootfs.py --root=${INSTALL_PATH} --arch=${ZYNQ_ARCH} --extra=extra_rpms.txt

${OPT_PATH}: ${TMP_PATH}
	sudo mkdir -p ${OPT_PATH}

#system components
include mk/secrets.mk
include mk/users.mk
include mk/services.mk

#software/libraries
include mk/uHAL.mk
include mk/BUTool.mk
include mk/Monitoring.mk
include mk/CM_MCU.mk
include mk/mmc-utils.mk
include mk/overlay-tools.mk



finalize_image: ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow  ${OPT_PATH}/BUTool ${HOME_PATH}/cms ${HOME_PATH}/atlas ${OPT_PATH}/mcu_tools ${OPT_PATH}/Graphite_Monitor ${INSTALL_PATH}/usr/local/bin/mmc ${OPT_PATH}/overlay-tools
	$(MAKE) users
	$(MAKE) services
	sudo cp ${MODS_PATH}/scripts/cleanup_locale.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/cleanup_locale.sh
	sudo rm -rf ${TMP_PATH}/*


shell:
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash
clean:
	sudo rm -rf ${INSTALL_PATH}
	rm -f ${TARBALL_NAME}



rev1_armv7hl.tar.gz : 

#################################################################################
# Help
#################################################################################
#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]/]' -e '^$@$$' | column

tarball:
	cd ${INSTALL_PATH} && \
	sudo tar --numeric-owner -p -zcf ../${TARBALL_NAME} ./

