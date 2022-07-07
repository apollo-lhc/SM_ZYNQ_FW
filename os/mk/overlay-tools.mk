DTBO_TAG=feature/rev2a
DTBO_URI=https://gitlab.com/apollo-lhc/soc-tools/bootup-daemon.git
NAME=uio-daemon

%/opt/${NAME}: OPT_PATH=$*/opt/

%/opt/${NAME}: %/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${DTBO_TAG} ${DTBO_URI} ${NAME}
	cd ${OPT_PATH} && \
		git submodule update --init --recursive
	ln -s /opt/${NAME}/uio_daemon.service $*/etc/systemd/system/uio_daemon.service
	ln -s /opt/${NAME}/uio_daemon.service $*/etc/systemd/system/multi-user.target.wants/uio_daemon.service
