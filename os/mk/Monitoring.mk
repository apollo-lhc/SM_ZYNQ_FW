MONITORING_TAG=v1.1.4

${INSTALL_BASE_PATH}/%/opt/BUTool: TMP_PATH=${INSTALL_BASE_PATH}/%/tmp/
${INSTALL_BASE_PATH}/%/opt/BUTool: INSTALL_PATH=${INSTALL_BASE_PATH}/%/

${INSTALL_BASE_PATH}/%/Graphite_Monitor: ${INSTALL_BASE_PATH}/%/BUTool | ${INSTALL_BASE_PATH}/%/opt/ ${INSTALL_BASE_PATH}/%/tmp/
	cd ${TMP_PATH} && \
		git clone --branch ${MONITORING_TAG} https://github.com/apollo-lhc/Grafana-Monitor.git Graphite
	cp ${SCRIPTS_PATH}/build_Graphite.sh ${TMP_PATH}/Graphite/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/Graphite/build_Graphite.sh

