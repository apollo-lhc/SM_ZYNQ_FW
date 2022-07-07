PIP_PACKAGE_FILE=${SCRIPTS_PATH}/../centos-rootfs/pip-packages.txt

pip_install_%_xc7z035 : QEMU=qemu-arm-static
pip_install_%_xc7z045 : QEMU=qemu-arm-static
pip_install_%_xczu7ev : QEMU=qemu-aarch64-static

ENV_SET=LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

pip_install_%:
	cp /etc/resolv.conf ./image/$*/etc/
	cp ${PIP_PACKAGE_FILE} ./image/$*/tmp/pip-packages.txt
	mount --bind /dev/ ./image/$*/dev/
	${ENV_SET} chroot ./image/$*/ ${QEMU} /usr/bin/python3 -m pip install --upgrade pip
	${ENV_SET} chroot ./image/$*/ ${QEMU} /usr/bin/python3 -m pip install setuptools_rust wheel
	${ENV_SET} chroot ./image/$*/ ${QEMU} /usr/bin/python3 -m pip install --force-reinstall importlib_metadata packaging click==7.1.2 click_didyoumean pytest==4.6.9
	${ENV_SET} chroot ./image/$*/ ${QEMU} /usr/bin/python3 -m pip install -r /tmp/pip-packages.txt
	rm ./image/$*/etc/resolv.conf
	umount ./image/$*/dev/


