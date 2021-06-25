${HOME_PATH}/cms ${HOME_PATH}/atlas ${ETC_PATH}/group ${ETC_PATH}/gshadow ${ETC_PATH}/passwd ${ETC_PATH}/shadow: ${PWD}/secure ${SECURE_PATH}/group ${SECURE_PATH}/gshadow ${SECURE_PATH}/passwd ${SECURE_PATH}/shadow | ${ETC_PATH} 
	sudo install -m 644 ${SECURE_PATH}/group   ${ETC_PATH}/
	sudo install -m 644 ${SECURE_PATH}/passwd  ${ETC_PATH}/
	sudo install -m 000 ${SECURE_PATH}/gshadow ${ETC_PATH}/
	sudo install -m 000 ${SECURE_PATH}/shadow  ${ETC_PATH}/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key       ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key.pub   ${ETC_PATH}/ssh/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key     ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key.pub ${ETC_PATH}/ssh/
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key         ${ETC_PATH}/ssh/
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key.pub     ${ETC_PATH}/ssh/
	sudo mkdir -p ${HOME_PATH}/cms
	sudo mkdir -p ${HOME_PATH}/atlas
	sudo cp ${MODS_PATH}/scripts/set_permissions.sh ${TMP_PATH}
	sudo chroot ${INSTALL_PATH} ${QEMU_PATH}/${QEMU} /bin/bash /tmp/set_permissions.sh
