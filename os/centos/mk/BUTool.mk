
#Build BUTool from ApolloTool meta repo
APOLLO_TOOL_TAG=v1.2.1
${OPT_PATH}/BUTool: ${OPT_PATH}/cactus | ${OPT_PATH} ${TMP_PATH} 
	cd ${TMP_PATH} && \
		git clone --branch ${APOLLO_TOOL_TAG} https://github.com/apollo-lhc/ApolloTool.git
	cd ${TMP_PATH}/ApolloTool && \
		make init
	cp ${MODS_PATH}/build_BUTool.sh ${TMP_PATH}/ApolloTool/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ApolloTool/build_BUTool.sh
	sudo install -d -m 755 ${OPT_PATH}/address_tables
	(cd mods && find address_tables/ -type f -exec sudo install -Dm 666 "{}" "${OPT_PATH}/{}" \;)
	sudo install -d -m 755 ${OPT_PATH}/BUTool/systemd
	sudo install    -m 664 ${MODS_PATH}/systemd/BUTool/* ${OPT_PATH}/BUTool/systemd/
	sudo ln -s /opt/BUTool/systemd/smboot.service      ${ETC_PATH}/systemd/system/smboot.service
	sudo ln -s /opt/BUTool/systemd/heartbeat.service   ${ETC_PATH}/systemd/system/heartbeat.service
	sudo ln -s /opt/BUTool/systemd/ps_monitor.service  ${ETC_PATH}/systemd/system/ps_monitor.service
	sudo ln -s /opt/BUTool/systemd/htmlStatus.service  ${ETC_PATH}/systemd/system/htmlStatus.service
	sudo ln -s /opt/BUTool/systemd/xvc_cm1.service     ${ETC_PATH}/systemd/system/xvc_cm1.service
	sudo ln -s /opt/BUTool/systemd/xvc_cm2.service     ${ETC_PATH}/systemd/system/xvc_cm2.service
	sudo ln -s /opt/BUTool/systemd/xvc_local.service   ${ETC_PATH}/systemd/system/xvc_local.service
	sudo ln -s /etc/systemd/system/smboot.service      ${ETC_PATH}/systemd/system/basic.target.wants/smboot.service
	sudo ln -s /etc/systemd/system/heartbeat.service   ${ETC_PATH}/systemd/system/basic.target.wants/heartbeat.service
	sudo ln -s /etc/systemd/system/ps_monitor.service  ${ETC_PATH}/systemd/system/basic.target.wants/ps_monitor.service
	sudo ln -s /etc/systemd/system/htmlStatus.service  ${ETC_PATH}/systemd/system/basic.target.wants/htmlStatus.service
	sudo ln -s /etc/systemd/system/xvc_cm1.service     ${ETC_PATH}/systemd/system/basic.target.wants/xvc_cm1.service
	sudo ln -s /etc/systemd/system/xvc_cm2.service     ${ETC_PATH}/systemd/system/basic.target.wants/xvc_cm2.service
	sudo ln -s /etc/systemd/system/xvc_local.service   ${ETC_PATH}/systemd/system/basic.target.wants/xvc_local.service
	sudo install -m 777 ${MODS_PATH}/rc.local ${ETC_PATH}/rc.d/rc.local
	sudo rm ${ETC_PATH}/systemd/system/multi-user.target.wants/auditd.service
	sudo install -m 664 ${MODS_PATH}/htmlStatus ${ETC_PATH}/htmlStatus
	sudo install -m 664 ${MODS_PATH}/SM_boot ${ETC_PATH}/SM_boot

clean_BUTool:
	sudo rm -rf ${TMP_PATH}/ApolloTool
	sudo rm -rf ${OPT_PATH}/BUTool

