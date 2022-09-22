BRANCH=main
URI=https://gitlab.com/apollo-lhc/soc-tools/netconfig-daemon.git
NAME=netconfig-daemon

%/opt/${NAME}: OPT_PATH=$*/opt/

%/opt/${NAME}: %/opt/
	cd ${OPT_PATH} && \
		git clone --branch ${BRANCH} ${URI} ${NAME}
	ln -s /opt/${NAME}/netconfig_daemon.service $*/etc/systemd/system/netconfig_daemon.service
	ln -s /opt/${NAME}/netconfig_daemon.service $*/etc/systemd/system/multi-user.target.wants/netconfig_daemon.service
	
