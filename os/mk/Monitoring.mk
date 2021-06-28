MONITORING_TAG=v1.1.4
${OPT_PATH}/Graphite_Monitor: ${OPT_PATH}/BUTool | ${OPT_PATH} ${TMP_PATH} 
	cd ${TMP_PATH} && \
		git clone --branch ${MONITORING_TAG} https://github.com/apollo-lhc/Grafana-Monitor.git Graphite
	cp ${MODS_PATH}/build_Graphite.sh ${TMP_PATH}/Graphite/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/Graphite/build_Graphite.sh

