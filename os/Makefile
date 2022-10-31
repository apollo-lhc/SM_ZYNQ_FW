SHELL=bash
PWD=$(shell pwd)


SECURE_PATH=${PWD}/secure
SECURE_FILES="\
	secure/ssh/moduli \
	secure/ssh/ssh_config \
	secure/ssh/sshd_config \
	secure/ssh/ssh_host_ecdsa_key \
	secure/ssh/ssh_host_ecdsa_key.pub \
	secure/ssh/ssh_host_ed25519_key \
	secure/ssh/ssh_host_ed25519_key.pub \
	secure/ssh/ssh_host_rsa_key \
	secure/ssh/ssh_host_rsa_key.pub"

SECURE_CHECK=$(patsubst "secure",${SECURE_PATH},${SECURE_FILES})

%xc7z035.tar.gz : QEMU=qemu-arm-static
%xc7z045.tar.gz : QEMU=qemu-arm-static
%xczu7ev.tar.gz : QEMU=qemu-aarch64-static

%xc7z035.tar.gz : ZYNQ_ARCH=armv7hl
%xc7z045.tar.gz : ZYNQ_ARCH=armv7hl
%xczu7ev.tar.gz : ZYNQ_ARCH=aarch64

CONFIG_BASE_DIR=${PWD}/config
rev1_% : CONFIG_DIR=${CONFIG_BASE_DIR}/rev1
rev2_% : CONFIG_DIR=${CONFIG_BASE_DIR}/rev2
rev2a_% : CONFIG_DIR=${CONFIG_BASE_DIR}/rev2a


INSTALL_BASE_PATH?=${PWD}/image/
#INSTALL_PATH=${INSTALL_BASE_PATH}
rev1_xc7z035.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev1_xc7z035/
rev1_xc7z045.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev1_xc7z045/
rev2_xc7z035.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev2_xc7z035/
rev2_xc7z045.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev2_xc7z045/
rev2_xczu7ev.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev2_xczu7ev/
rev2a_xczu7ev.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev2a_xczu7ev/
rev2a_xc7z035.tar.gz : INSTALL_PATH=${INSTALL_BASE_PATH}rev2a_xc7z035/



SCRIPTS_PATH=${PWD}/scripts

CMS_UID=1000
CMS_GID=1000
ATLAS_UID=1001
ATLAS_GID=1001

ETC_PATH =${INSTALL_PATH}etc
HOME_PATH=${INSTALL_PATH}home
TMP_PATH =${INSTALL_PATH}tmp
OPT_PATH =${INSTALL_PATH}opt

all: rev1_xc7z035.tar.gz rev2_xc7z035.tar.gz rev2_xczu7ev.tar.gz

.PHONEY: clean finalize_image all shell


shell:
	sudo chroot ${INSTALL_PATH} /${QEMU_PATH}/${QEMU}  /bin/bash

clean:
	rm -f *.yaml
	sudo rm -rf ${INSTALL_BASE_PATH}

${INSTALL_BASE_PATH}/%/:
	#Build output path
	rm -rf $@
	mkdir -p $@

${OPT_PATH}: ${TMP_PATH}
	sudo mkdir -p ${OPT_PATH}


include mk/QEMU.mk

include mk/pip.mk
include mk/uHAL.mk
include mk/BUTool.mk
include mk/Monitoring.mk
include mk/CM_MCU.mk

include mk/overlay-tools.mk
include mk/netconfig-daemon.mk
include mk/apollo-updater.mk
include mk/users.mk

#${SECURE_CHECK}:
#	$(error Missing secure files)

%.tar.gz : centos-rootfs/extra_rpms.txt
	$(MAKE) ${INSTALL_PATH}${QEMU_PATH}/${QEMU} /${QEMU_PATH}/${QEMU} 
	cd centos-rootfs && \
		sudo python3 mkrootfs.py --root=${INSTALL_PATH} --arch=${ZYNQ_ARCH} --extra=extra_rpms.txt 
	# Add common filesystem mods
	sudo cp -r ${CONFIG_BASE_DIR}/common/file_system/* ${INSTALL_PATH} 
	# Add rev specific mods
	@echo ${CONFIG_DIR} 
	sudo cp -r ${CONFIG_DIR}/file_system/* ${INSTALL_PATH} 
	sudo chmod o+x ${ETC_PATH}/rc.local
	#Change ownership of the CM fw path
	sudo chmod a+rwX -R ${INSTALL_PATH}/fw/CM
	#Change ownership of the uio_daemon config file
	sudo chmod a+rw  ${INSTALL_PATH}/etc/uio_daemon	
	#Remove ipv6 from lighttpd
	sudo sed -i -e "s/server.use-ipv6 = \"enable\"/server.use-ipv6 = \"disable\"/g" ${ETC_PATH}/lighttpd/lighttpd.conf  
	#this service breaks things
	sudo rm -f ${ETC_PATH}/systemd/system/multi-user.target.wants/auditd.service 
	#Add all the password files and keys
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key       ${ETC_PATH}/ssh/ 
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ecdsa_key.pub   ${ETC_PATH}/ssh/ 
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key     ${ETC_PATH}/ssh/ 
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_ed25519_key.pub ${ETC_PATH}/ssh/ 
	sudo install -m 640 -g 997 -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key         ${ETC_PATH}/ssh/ 
	sudo install -m 644 -g 0   -o 0 ${SECURE_PATH}/ssh/ssh_host_rsa_key.pub     ${ETC_PATH}/ssh/ 
	#setup software and libraries
	${MAKE} pip_install_$*
	${MAKE} ${OPT_PATH}/BUTool/bin ${OPT_PATH}/cactus ${OPT_PATH}/mcu_tools ${OPT_PATH}/Graphite_Monitor ${OPT_PATH}/uio-daemon ${OPT_PATH}/netconfig-daemon ${OPT_PATH}/apollo-updater
	sudo cp ${SCRIPTS_PATH}/cleanup_locale.sh ${TMP_PATH} 
	sudo rm -rf ${TMP_PATH}/*
	#setup local user accounts
	${MAKE} users_$*

	cd ${INSTALL_PATH} && \
		sudo tar --numeric-owner -p -zcf ../$@ ./


#################################################################################
#docker builds 
#################################################################################
docker :
	docker pull centos:centos7
	docker run --rm --privileged -it -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${PWD}:/app:Z -v /etc/binfmt.d:/etc/binfmt.d:Z centos:centos7

docker_% :
	rm -f $*.tar.gz
	docker pull centos:centos7
	time docker run --rm --name os_build_$* --privileged -it -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${PWD}:/app:Z -v /etc/binfmt.d:/etc/binfmt.d:Z centos:centos7 /app/scripts/docker_build.sh $*


#################################################################################
# Help
#################################################################################
#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]/]' -e '^$@$$' | column

