PWD=$(shell pwd)

QEMU=qemu-arm-static
QEMU_PATH=/usr/local/bin
MODS_PATH=${PWD}/mods

INSTALL_PATH=${PWD}/image
ETC_PATH=${INSTALL_PATH}/etc/
HOME_PATH=${INSTALL_PATH}/home/
TMP_PATH=${INSTALL_PATH}/tmp/
OPT_PATH=${INSTALL_PATH}/opt/


CMS_UID=1000
CMS_GID=1000
ATLAS_UID=1001
ATLAS_GID=1001

.PHONEY: clean finalize_image all

all: finalize_image

${INSTALL_PATH}:  centos-rootfs/extra_rpms.txt
	rm -rf ${ISNTALL_PATH}
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

${HOME_PATH}/cms ${HOME_PATH}/atlas ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow: ${MODS_PATH}/group ${MODS_PATH}/gshadow ${MODS_PATH}/passwd ${MODS_PATH}/shadow | ${ETC_PATH} 
	sudo install -m 644 ${MODS_PATH}/group   ${ETC_PATH}/
	sudo install -m 644 ${MODS_PATH}/passwd  ${ETC_PATH}/
	sudo install -m 000 ${MODS_PATH}/gshadow ${ETC_PATH}/
	sudo install -m 000 ${MODS_PATH}/shadow  ${ETC_PATH}/
	sudo mkdir -p ${HOME_PATH}/cms
	sudo mkdir -p ${HOME_PATH}/atlas
	sudo cp ${MODS_PATH}/set_permissions.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/set_permissions.sh

${OPT_PATH}/cactus: | ${OPT_PATH} ${TMP_PATH}
	cd ${TMP_PATH} && \
	git clone https://github.com/dgastler/ipbus-software.git
	cd ${TMP_PATH}/ipbus-software && \
	git checkout feature-UIOuHAL
	cp ${MODS_PATH}/build_ipbus.sh ${TMP_PATH}/ipbus-software/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ipbus-software/build_ipbus.sh

${OPT_PATH}/BUTool: | ${OPT_PATH} ${TMP_PATH} ${OPT_PATH}/cactus
	cd ${TMP_PATH} && \
	git clone https://github.com/apollo-lhc/ApolloTool.git
	cd ${TMP_PATH}/ApolloTool && \
	make init
	cp ${MODS_PATH}/build_BUTool.sh ${TMP_PATH}/ApolloTool/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ApolloTool/build_BUTool.sh
	sudo install -d -m 755 ${OPT_PATH}/address_tables
	(cd mods && find address_tables/ -type f -exec sudo install -Dm 666 "{}" "${OPT_PATH}/{}" \;)
	sudo install -d -m 755 ${OPT_PATH}/BUTool/systemd
	sudo install    -m 664 ${MODS_PATH}/systemd/* ${OPT_PATH}/BUTool/systemd/
	sudo ln -s /opt/BUTool/systemd/smboot.service      ${ETC_PATH}/systemd/system/smboot.service
	sudo ln -s /opt/BUTool/systemd/heartbeat.service   ${ETC_PATH}/systemd/system/heartbeat.service
	sudo ln -s /opt/BUTool/systemd/arm_monitor.service ${ETC_PATH}/systemd/system/arm_monitor.service
	sudo ln -s /etc/systemd/system/smboot.service      ${ETC_PATH}/systemd/system/basic.target.wants/smboot.service
	sudo ln -s /etc/systemd/system/heartbeat.service   ${ETC_PATH}/systemd/system/basic.target.wants/heartbeat.service
	sudo ln -s /etc/systemd/system/arm_monitor.service ${ETC_PATH}/systemd/system/basic.target.wants/arm_monitor.service
	sudo install -m 777 ${MODS_PATH}/rc.local ${ETC_PATH}/rc.d/rc.local
	sudo rm ${ETC_PATH}/systemd/system/multi-user.target.wants/auditd.service

finalize_image: ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow | ${OPT_PATH}/BUTool ${HOME_PATH}/cms ${HOME_PATH}/atlas
	sudo rm -rf ${TMP_PATH}/*
	sudo ln -s /opt/BUTool/systemd/multi-user.target.wants/lighttpd.service ${INSTALL_PATH}/usr/lib/systemd/system/lighttpd.service
	sudo install -m 755 ${MODS_PATH}/uio.rules ${ETC_PATH}/udev/rules.d/
	sudo install                                 -m 774 ${MODS_PATH}/.bashrc       ${INSTALL_PATH}/root
	sudo install                                 -m 774 ${MODS_PATH}/.bash_profile ${INSTALL_PATH}/root
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/cms
	sudo install -g ${CMS_UID}   -o ${CMS_GID}   -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/cms
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bashrc       ${HOME_PATH}/atlas
	sudo install -g ${ATLAS_UID} -o ${ATLAS_GID} -m 774 ${MODS_PATH}/.bash_profile ${HOME_PATH}/atlas
clean:
	sudo rm -rf ${INSTALL_PATH}
