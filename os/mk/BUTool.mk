#Build BUTool from ApolloTool meta repo
APOLLO_TOOL_TAG=master
APOLLO_TOOL_URI=https://github.com/apollo-lhc/ApolloTool.git
${OPT_PATH}/BUTool: ${OPT_PATH}/cactus | ${OPT_PATH} ${TMP_PATH} 
	cd ${TMP_PATH} && \
		git clone --branch ${APOLLO_TOOL_TAG} ${APOLLO_TOOL_URI}
	cd ${TMP_PATH}/ApolloTool && \
		make init
	cp ${SCRIPTS_PATH}/build_BUTool.sh ${TMP_PATH}/ApolloTool/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ApolloTool/build_BUTool.sh
	(find address_table/ -xtype f -exec sudo install -Dm 666 "{}" "${OPT_PATH}/{}" \;)
	sudo ln -s /opt/address_table ${OPT_PATH}/address_tables


clean_BUTool:
	sudo rm -rf ${TMP_PATH}/ApolloTool
	sudo rm -rf ${OPT_PATH}/BUTool

