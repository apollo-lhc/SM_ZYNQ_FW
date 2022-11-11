MONITORING_TAG=v1.1.4
MONITORING_TAG=2022-06-27_apollosm_fix
MONITORING_TAG=develop
MONITORING_URI=https://github.com/apollo-lhc/Grafana-Monitor.git
MONITORING_URI=https://gitlab.com/BU-EDF/shelf-tools.git

%xc7z035/opt/Graphite_Monitor : QEMU=qemu-arm-static
%xc7z045/opt/Graphite_Monitor : QEMU=qemu-arm-static
%xczu7ev/opt/Graphite_Monitor : QEMU=qemu-aarch64-static
%opt/Graphite_Monitor: TMP_PATH=$*/tmp/
%opt/Graphite_Monitor: INSTALL_PATH=$*/

%opt/Graphite_Monitor: %opt/BUTool | %tmp/
	cd ${TMP_PATH} && \
		git clone --branch ${MONITORING_TAG} ${MONITORING_URI} Graphite
	cp ${SCRIPTS_PATH}/build_Graphite.sh ${TMP_PATH}/Graphite/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/Graphite/build_Graphite.sh

