#build and install mmc-utils
BRANCH_PATH=mmc-utils

${INSTALL_BASE_PATH}/%/usr/local/bin/mmc: TMP_PATH=${INSTALL_BASE_PATH}/%/tmp/
${INSTALL_BASE_PATH}/%/usr/local/bin/mmc: INSTALL_PATH=${INSTALL_BASE_PATH}/%/

${INSTALL_BASE_PATH}/%/usr/local/bin/mmc : | ${INSTALL_BASE_PATH}/%/tmp/
	cd ${TMP_PATH} && \
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git ${BRANCH_PATH}
	cp ${SCRIPTS_PATH}/build_mmc-utils.sh ${TMP_PATH}/${BRANCH_PATH}/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/${BRANCH_PATH}/build_mmc-utils.sh
