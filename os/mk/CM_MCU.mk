CM_MCU_TAG=v0.5

${INSTALL_BASE_PATH}/%/opt/mcu_tools: TMP_PATH=${INSTALL_BASE_PATH}/%/tmp/
${INSTALL_BASE_PATH}/%/opt/mcu_tools: INSTALL_PATH=${INSTALL_BASE_PATH}/%/

${INSTALL_BASE_PATH}/%/opt/mcu_tools: | ${INSTALL_BASE_PATH}/%/opt/ ${INSTALL_BASE_PATH}/%/tmp/
	cd ${OPT_PATH} && \
		git clone --branch ${CM_MCU_TAG} https://github.com/apollo-lhc/mcu_tools.git
	cp ${SCRIPTS_PATH}/build_mcu_tools.sh ${TMP_PATH}/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/build_mcu_tools.sh

