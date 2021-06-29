DTBO_TAG=main
DTBO_URI=https://gitlab.com/BU-EDF/devicetreeoverlay-scripts.git
NAME=overlay-tools

${INSTALL_BASE_PATH}/%/opt/${NAME}: INSTALL_PATH=${INSTALL_BASE_PATH}/%/

${INSTALL_BASE_PATH}/%/opt/${NAME}: ${INSTALL_BASE_PATH}/%/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${DTBO_TAG} ${DTBO_URI} ${NAME}

clean_${NAME}:
	sudo rm -rf ${OPT_PATH}/${NAME}
