#build and install mmc-utils
BRANCH_PATH=mmc-utils

%xc7z035/usr/local/bin/mmc : QEMU=qemu-arm-static
%xc7z045/usr/local/bin/mmc : QEMU=qemu-arm-static
%xczu7ev/usr/local/bin/mmc : QEMU=qemu-aarch64-static
%usr/local/bin/mmc : TMP_PATH=$*/tmp/
%usr/local/bin/mmc : INSTALL_PATH=$*/

%usr/local/bin/mmc : | %tmp/
	cd ${TMP_PATH} && \
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git ${BRANCH_PATH}
	cp ${SCRIPTS_PATH}/build_mmc-utils.sh ${TMP_PATH}/${BRANCH_PATH}/
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/${BRANCH_PATH}/build_mmc-utils.sh
