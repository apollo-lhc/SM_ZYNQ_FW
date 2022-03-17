#Build BUTool from ApolloTool meta repo
APOLLO_TOOL_TAG=master
APOLLO_TOOL_URI=https://github.com/apollo-lhc/ApolloTool.git

#target level variables
%xc7z035/opt/BUTool/bin : QEMU=qemu-arm-static
%xc7z045/opt/BUTool/bin : QEMU=qemu-arm-static
%xczu7ev/opt/BUTool/bin : QEMU=qemu-aarch64-static
%opt/BUTool/bin: TMP_PATH=$*/tmp/
%opt/BUTool/bin: INSTALL_PATH=$*/

%opt/BUTool/bin: %opt/cactus | %tmp/
	cd ${TMP_PATH} && \
		git clone  ${APOLLO_TOOL_URI}
	cd ${TMP_PATH}/ApolloTool && \
		git checkout ${APOLLO_TOOL_TAG}
	cd ${TMP_PATH}/ApolloTool && \
		make init
	cd ${TMP_PATH}/ApolloTool && \
		make init
	cp ${SCRIPTS_PATH}/build_BUTool.sh ${TMP_PATH}/ApolloTool/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/ApolloTool/build_BUTool.sh
	#(find address_table/ -xtype f -exec sudo install -Dm 666 "{}" "${OPT_PATH}/{}" \;)
	sudo ln -s /fw/address_table /opt/address_table
#	sudo ln -s /opt/address_table ${OPT_PATH}/address_tables



