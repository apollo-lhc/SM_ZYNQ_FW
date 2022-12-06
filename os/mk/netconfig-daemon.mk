NETCONFIG_BRANCH=v0.1.2
NETCONFIG_URI=https://gitlab.com/apollo-lhc/soc-tools/netconfig-daemon.git
NETCONFIG_NAME=netconfig-daemon

%/opt/${NETCONFIG_NAME}: OPT_PATH=$*/opt/

%/opt/${NETCONFIG_NAME}: %/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${NETCONFIG_BRANCH} ${NETCONFIG_URI} ${NETCONFIG_NAME}
#	ln -s /opt/${NETCONFIG_NAME}/netconfig_daemon.service $*/etc/systemd/system/netconfig_daemon.service
#	ln -s /opt/${NETCONFIG_NAME}/netconfig_daemon.service $*/etc/systemd/system/multi-user.target.wants/netconfig_daemon.service

