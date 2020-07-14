MONITORING_TAG=v1.0
${OPT_PATH}/Graphite_Monitor: ${OPT_PATH}/BUTool | ${OPT_PATH} ${TMP_PATH} 
	cd ${TMP_PATH} && \
		git clone --branch ${MONITORING_TAG} https://github.com/apollo-lhc/Grafana-Monitor.git Graphite
	cp ${MODS_PATH}/build_Graphite.sh ${TMP_PATH}/Graphite/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/Graphite/build_Graphite.sh
	sudo install -d -m 755 ${OPT_PATH}/Graphite/systemd
	sudo install    -m 664 ${MODS_PATH}/systemd/Graphite/*       ${OPT_PATH}/Graphite/systemd/
	sudo ln -s /opt/Graphite/systemd/graphite_monitor.service    ${ETC_PATH}/systemd/system/graphite_monitor.service
	sudo ln -s /etc/systemd/system/graphite_monitor.service      ${ETC_PATH}/systemd/system/basic.target.wants/graphite_monitor.service

