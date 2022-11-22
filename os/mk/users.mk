users_%_xc7z035 : QEMU=qemu-arm-static
users_%_xc7z045 : QEMU=qemu-arm-static
users_%_xczu7ev : QEMU=qemu-aarch64-static

users_%: secure/user_info.txt
	cp $< ./image/$*/tmp
	cp scripts/add_users.sh ./image/$*/tmp
	chroot ./image/$*/ ${QEMU} /bin/bash /tmp/add_users.sh
	rm -f ./image/$*/tmp/$< /tmp/add_users.sh

