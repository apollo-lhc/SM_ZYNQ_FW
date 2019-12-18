PWD=$(shell pwd)

QEMU=qemu-arm-static
QEMU_PATH=/usr/local/bin
MODS_PATH=${PWD}/mods

INSTALL_PATH=${PWD}/image
ETC_PATH=${INSTALL_PATH}/etc/
HOME_PATH=${INSTALL_PATH}/home/
TMP_PATH=${INSTALL_PATH}/tmp/
OPT_PATH=${INSTALL_PATH}/opt/


.PHONEY: clean finalize_image all

all: finalize_image

${INSTALL_PATH}:  centos-rootfs/extra_rpms.txt
	rm -rf ${ISNTALL_PATH}
	mkdir -p ${INSTALL_PATH}

${QEMU_PATH}/${QEMU} ${INSTALL_PATH}/${QEMU_PATH}/${QEMU}: ${INSTALL_PATH}
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

${HOME_PATH}/cms ${HOME_PATH}/atlas ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow: ${ETC_PATH} ${MODS_PATH}/group ${MODS_PATH}/gshadow ${MODS_PATH}/passwd ${MODS_PATH}/shadow
	sudo cp ${MODS_PATH}/group   ${ETC_PATH}/
	sudo chmod 644 ${ETC_PATH}//group
	sudo cp ${MODS_PATH}/gshadow	${ETC_PATH}/
	sudo chmod 004 ${ETC_PATH}//gshadow
	sudo cp ${MODS_PATH}/passwd	${ETC_PATH}/
	sudo chmod 644 ${ETC_PATH}//passwd
	sudo cp ${MODS_PATH}/shadow  ${ETC_PATH}/
	sudo chmod 000 ${ETC_PATH}//passwd
	sudo mkdir -p ${HOME_PATH}/cms
	sudo mkdir -p ${HOME_PATH}/atlas

${OPT_PATH}/cactus: ${OPT_PATH} ${TMP_PATH}
	cd ${TMP_PATH} && \
	git clone https://github.com/dgastler/ipbus-software.git
	cd ${TMP_PATH}/ipbus-software && \
	git checkout feature-UIOuHAL
	cp ${MODS_PATH}/build_ipbus.sh ${TMP_PATH}/ipbus-software/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ipbus-software/build_ipbus.sh

${OPT_PATH}/BUTool: ${OPT_PATH} ${TMP_PATH} ${OPT_PATH}/cactus
	cd ${TMP_PATH} && \
	git clone https://github.com/apollo-lhc/ApolloTool.git
	cd ${TMP_PATH}/ApolloTool && \
	make init
	cp ${MODS_PATH}/build_BUTool.sh ${TMP_PATH}/ApolloTool/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ApolloTool/build_BUTool.sh

finalize_image: ${HOME_PATH}/cms ${HOME_PATH}/atlas ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow ${OPT_PATH}/BUTool
	sudo rm -rf ${TMP_PATH}/*

clean:
	sudo rm -rf ${INSTALL_PATH}
