UHAL_TAG=v2.7.4
UIO_UHAL_TAG=v1.0
${OPT_PATH}/cactus: | ${OPT_PATH} ${TMP_PATH}
	cd ${TMP_PATH} && \
		git clone --branch ${UHAL_TAG} https://github.com/ipbus/ipbus-software.git
	cp ${MODS_PATH}/build_ipbus.sh ${TMP_PATH}/ipbus-software/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ipbus-software/build_ipbus.sh
	cd ${TMP_PATH} && \
		git clone --branch ${UIO_UHAL_TAG} https://github.com/dgastler/UIOuHAL.git
	cp ${MODS_PATH}/build_uiouhal.sh ${TMP_PATH}/UIOuHAL
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/UIOuHAL/build_uiouhal.sh

clean_ipbus:
	sudo rm -rf ${TMP_PATH}/ipbus-software
	sudo rm -rf ${OPT_PATH}/cactus
