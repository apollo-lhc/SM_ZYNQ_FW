#UHAL_TAG=v2.7.4
UHAL_TAG=v2.8.0
UIO_UHAL_URI=https://github.com/ammitra/UIOuHAL.git
#UIO_UHAL_TAG=feature-kernelPatch
UIO_UHAL_TAG=feature-uhal_280
DT_OVERLAY_URI=https://gitlab.com/BU-EDF/devicetreeoverlay-scripts.git
DT_OVERLAY_TAG=main
${OPT_PATH}/cactus: | ${OPT_PATH} ${TMP_PATH}
	cd ${TMP_PATH} && \
		git clone --branch ${UHAL_TAG} https://github.com/ipbus/ipbus-software.git
	cp ${SCRIPTS_PATH}/build_ipbus.sh ${TMP_PATH}/ipbus-software/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ipbus-software/build_ipbus.sh
	cd ${TMP_PATH} && \
		git clone --branch ${UIO_UHAL_TAG} ${UIO_UHAL_URI}
	cp ${SCRIPTS_PATH}/build_uiouhal.sh ${TMP_PATH}/UIOuHAL
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/UIOuHAL/build_uiouhal.sh
	cd ${TMP_PATH} && \
		git clone --branch ${DT_OVERLAY_TAG} ${DT_OVERLAY_URI}

clean_ipbus:
	sudo rm -rf ${TMP_PATH}/ipbus-software
	sudo rm -rf ${OPT_PATH}/cactus
