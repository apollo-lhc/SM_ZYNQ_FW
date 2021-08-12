DTBO_TAG=main
DTBO_URI=https://gitlab.com/BU-EDF/devicetreeoverlay-scripts.git
NAME=overlay-tools

%/opt/${NAME}: OPT_PATH=$*/opt/

%/opt/${NAME}: %/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${DTBO_TAG} ${DTBO_URI} ${NAME}
