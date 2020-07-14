CM_MCU_TAG=v0.2

${OPT_PATH}/mcu_tools: | ${OPT_PATH} ${TEMP_PATH}
	cd ${OPT_PATH} && \
		git clone --branch ${CM_MCU_TAG} https://github.com/apollo-lhc/mcu_tools.git
	cp ${MODS_PATH}/build_mcu_tools.sh ${TMP_PATH}/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/build_mcu_tools.sh

