UHAL_TAG=v2.8.1
UHAL_URI=https://github.com/ipbus/ipbus-software.git

UIO_UHAL_URI=https://github.com/BU-Tools/UIOuHAL.git
UIO_UHAL_TAG=develop

DT_OVERLAY_URI=https://gitlab.com/BU-EDF/devicetreeoverlay-scripts.git
DT_OVERLAY_TAG=main

#Makefile target-specific variables
%xc7z035/opt/cactus : QEMU=qemu-arm-static
%xc7z045/opt/cactus : QEMU=qemu-arm-static
%xczu7ev/opt/cactus : QEMU=qemu-aarch64-static

%opt/cactus: TMP_PATH=$*/tmp/

%opt/cactus: INSTALL_PATH=$*/

%opt/cactus:
	echo ${TMP_PATH}
	cd ${TMP_PATH} && \
		git clone --branch ${UHAL_TAG} ${UHAL_URI}
	cp ${SCRIPTS_PATH}/build_ipbus.sh ${TMP_PATH}/ipbus-software/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ipbus-software/build_ipbus.sh
	cd ${TMP_PATH} && \
		git clone ${UIO_UHAL_URI}
	cd ${TMP_PATH}/UIOuHAL && \
		git checkout ${UIO_UHAL_TAG}
	cp ${SCRIPTS_PATH}/build_uiouhal.sh ${TMP_PATH}/UIOuHAL
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/UIOuHAL/build_uiouhal.sh
	cd ${TMP_PATH} && \
		git clone --branch ${DT_OVERLAY_TAG} ${DT_OVERLAY_URI}

#clean_ipbus:
#	sudo rm -rf ${TMP_PATH}/ipbus-software
#	sudo rm -rf ${OPT_PATH}/cactus
#${INSTALL_BASE_PATH}/%/opt/cactus: | ${INSTALL_BASE_PATH}/%/opt/ ${INSTALL_BASE_PATH}/%/tmp/
