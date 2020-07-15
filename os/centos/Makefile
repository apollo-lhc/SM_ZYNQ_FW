PWD=$(shell pwd)

QEMU=qemu-arm-static
QEMU_PATH=/usr/local/bin
MODS_PATH=${PWD}/mods
SECURE_PATH=${PWD}/secure

INSTALL_PATH=${PWD}/image
ETC_PATH=${INSTALL_PATH}/etc/
HOME_PATH=${INSTALL_PATH}/home/
TMP_PATH=${INSTALL_PATH}/tmp/
OPT_PATH=${INSTALL_PATH}/opt/


CMS_UID=1000
CMS_GID=1000
ATLAS_UID=1001
ATLAS_GID=1001

.PHONEY: clean finalize_image all shell

all: finalize_image

${INSTALL_PATH}:  centos-rootfs/extra_rpms.txt
	rm -rf ${INSTALL_PATH}
	mkdir -p ${INSTALL_PATH}

${QEMU_PATH}/${QEMU} ${INSTALL_PATH}/${QEMU_PATH}/${QEMU}: | ${INSTALL_PATH}
	wget https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0/${QEMU}
	chmod +x ${QEMU}
	sudo mkdir -p ${INSTALL_PATH}/${QEMU_PATH}
	sudo mkdir -p ${QEMU_PATH}
	sudo cp -a ${QEMU} ${INSTALL_PATH}/${QEMU_PATH}
	sudo cp -a ${QEMU} ${QEMU_PATH}
	rm ${QEMU}

${ETC_PATH} ${TMP_PATH}: ${QEMU_PATH}/${QEMU} ${INSTALL_PATH}/${QEMU_PATH}/${QEMU} centos-rootfs/extra_rpms.txt
	cd centos-rootfs && \
		sudo python mkrootfs.py --root=${INSTALL_PATH} --arch=armv7hl --extra=extra_rpms.txt

${OPT_PATH}: ${TMP_PATH}
	sudo mkdir -p ${OPT_PATH}

${HOME_PATH}/cms ${HOME_PATH}/atlas ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow: ${PWD}/secure ${SECURE_PATH}/group ${SECURE_PATH}/gshadow ${SECURE_PATH}/passwd ${SECURE_PATH}/shadow | ${ETC_PATH} 
	sudo install -m 644 ${SECURE_PATH}/group   ${ETC_PATH}/
	sudo install -m 644 ${SECURE_PATH}/passwd  ${ETC_PATH}/
	sudo install -m 000 ${SECURE_PATH}/gshadow ${ETC_PATH}/
	sudo install -m 000 ${SECURE_PATH}/shadow  ${ETC_PATH}/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key       ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key.pub   ${ETC_PATH}/ssh/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key     ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key.pub ${ETC_PATH}/ssh/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key         ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key.pub     ${ETC_PATH}/ssh/
	sudo mkdir -p ${HOME_PATH}/cms
	sudo mkdir -p ${HOME_PATH}/atlas
	sudo cp ${MODS_PATH}/set_permissions.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/set_permissions.sh

include mk/uHAL.mk

include mk/BUTool.mk

include mk/Monitoring.mk

include mk/CM_MCU.mk


finalize_image: ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow  ${OPT_PATH}/BUTool ${HOME_PATH}/cms ${HOME_PATH}/atlas ${OPT_PATH}/mcu_tools ${OPT_PATH}/Graphite_Monitor
#	sudo rm -rf ${INSTALL_PATH}/usr/share/doc
	sudo cp ${MODS_PATH}/cleanup_locale.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/cleanup_locale.sh
	sudo rm -rf ${TMP_PATH}/*
	sudo ln -s /usr/lib/systemd/system/lighttpd.service ${ETC_PATH}/systemd/system/multi-user.target.wants/lighttpd.service
	sudo install -m 755 ${MODS_PATH}/uio.rules ${ETC_PATH}/udev/rules.d/
	sudo install                                 -m 774 ${MODS_PATH}/.bashrc       ${INSTALL_PATH}/root
	sudo install                                 -m 774 ${MODS_PATH}/.bash_profile ${INSTALL_PATH}/root
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/cms
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/cms
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 700 -d ${HOME_PATH}/cms/.screen
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/atlas
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/atlas
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 700 -d ${HOME_PATH}/cms/.screen
	sudo sed -i -e "s/server.use-ipv6 = \"enable\"/server.use-ipv6 = \"disable\"/g" ${ETC_PATH}/lighttpd/lighttpd.conf 


shell:
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash
clean:
	sudo rm -rf ${INSTALL_PATH}


#################################################################################
# Help
#################################################################################
#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]/]' -e '^$@$$' | column

tarball:
	cd ${INSTALL_PATH} && \
	sudo tar --numeric-owner -p -zcf ../$(shell date +%F)-SD_p2.tar.gz ./

