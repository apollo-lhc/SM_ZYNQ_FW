CM_MCU_TAG=v0.5

%xc7z035/opt/mcu_tools : QEMU=qemu-arm-static
%xc7z045/opt/mcu_tools : QEMU=qemu-arm-static
%xczu7ev/opt/mcu_tools : QEMU=qemu-aarch64-static
%opt/mcu_tools: TMP_PATH=$*/tmp/
%opt/mcu_tools: INSTALL_PATH=$*/

%opt/mcu_tools: | %opt/ %tmp/
	cd ${OPT_PATH} && \
		git clone --branch ${CM_MCU_TAG} https://github.com/apollo-lhc/mcu_tools.git
	cp ${SCRIPTS_PATH}/build_mcu_tools.sh ${TMP_PATH}/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/build_mcu_tools.sh

