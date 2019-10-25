#################################################################################
# make stuff
#################################################################################
OUTPUT_MARKUP= 2>&1 | tee -a make_log.txt | ccze -A
SLACK_MESG ?= echo 

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_PETALINUX="/opt/Xilinx/petalinux/"$(VIVADO_VERSION)"/settings.sh"

HDF_FILE=hw/top.hdf
ZYNQ_OS=zynq_os
ZYNQ_OS_PROJECT_PATH=$(ZYNQ_OS)
ZYNQ_OS_PROJECT=$(ZYNQ_OS_PROJECT_PATH)/config.project
BOOT_FILES=$(ZYNQ_OS_PROJECT)/images/linux/BOOT.BIN

#CONFIG_BOOTLOADER=CONFIG_BOOTLOADER
CONFIG_ROOTFS=CONFIG_ROOTFS
DEVICE_TREE_USER=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

FSBL_BASE=$(YOCTO_MOD_BASE)/recipes-bsp/fsbl/
FSBL=$(FSBL_BASE)/fsbl_%.bbappend
FSBL_MOD=$(ZYNQ_OS_PROJECT_PATH)_mods/fsbl

USER_MOD_ROOTFS=$(ZYNQ_OS_PROJECT_PATH)_mods/configs/rootfs/config
BUILD_ROOTFS=$(ZYNQ_OS_PROJECT_PATH)/project-spec/configs/rootfs_config
UPDATE_ROOTFS=UPDATE_ROOTFS

YOCTO_MOD_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/
PACKAGE_LINUX_IMAGE=$(ZYNQ_OS_PROJECT_PATH)/images/linux/image.elf

KERNEL_USER_MODS_BASE=$(YOCTO_MOD_BASE)/recipes-kernel

FSTAB=$(YOCTO_MOD_BASE)/recipes-core/base-files/base-files_%.bbappend
DROPBEAR=$(YOCTO_MOD_BASE)/recipes-core/dropbear/dropbear_%.bbappend
USERS=$(YOCTO_MOD_BASE)/recipes-core/images/petalinux-user-image.bbappend
BOOTSCRIPT=$(YOCTO_MOD_BASE)/recipes-apps/bootscript/files/bootscript/bootscript
SMBOOTSCRIPT=$(YOCTO_MOD_BASE)/recipes-apps/smboot/files/smboot/smboot
HEARTBEATSCRIPT=$(YOCTO_MOD_BASE)/recipes-apps/heartbeat/files/heartbeat/heartbeat
STARTUP-SCRIPT=$(YOCTO_MOD_BASE)/recipes-apps/startupscript/files/startupscript/startupscript
UIO-UDEV=$(YOCTO_MOD_BASE)/recipes-apps/startupscript/files/uio/uio.rules.bb


.PHONY: list  clean $(BUILD_ROOTFS) REBUILD_BOOTBIN NOTIFY_DAN_GOOD NOTIFY_DAN_BAD

all: 
	$(MAKE) $(BOOT_FILES) || $(MAKE) NOTIFIFY_DAN_BAD

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column



NOTIFY_DAN_GOOD: 
	${SLACK_MESG} "FINISHED building image!"
NOTIFY_DAN_BAD:
	${SLACK_MESG} "FAILED to build image!"



RECONFIG_ZYNQ : $(HDF_FILE)
#	@echo "Creating fresh OS project"
#	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
#	source $(VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config -v --get-hw-description ../hw -c kernel
#	petalinux-config --get-hw-description ../hw


$(ZYNQ_OS_PROJECT) : $(HDF_FILE)
	@echo "Creating fresh OS project"
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw --oldconfig
	DTSI_PATH=./hw $(ZYNQ_OS)_mods/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER)
	make $(KERNEL_USER_MODS_BASE)
	make $(FSBL)



#################################################################################
## ROOT Filesystem and packages
#################################################################################

#os/zynq_os_mods/configs/rootfs/config : $(CONFIG_ROOTFS)

$(CONFIG_ROOTFS): $(ZYNQ_OS_PROJECT) 
#	copy an existing mod to start from
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 2>/dev/null || :
#	run the menuconfig 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config -c rootfs
	@cp $(BUILD_ROOTFS) $(USER_MOD_ROOTFS) 



#$(USER_MOD_ROOTFS):
#	@echo USER_MOD_ROOTFS $(USER_MOD_ROOTFS)
#	make $(CONFIG_ROOTFS)
#	@echo "Copying new root fs config to user mod storage"
#	@cp $(BUILD_ROOTFS) $(USER_MOD_ROOTFS) 

$(FSTAB):
#	#Add modifications to the fstab to automount sdcard
	@echo "Setup auto-mount in /etc/fstab"
	@mkdir -p $(YOCTO_MOD_BASE)/recipes-core/base-files
	@cp ./zynq_os_mods/mounts/base-files_%.bbappend	         $(YOCTO_MOD_BASE)/recipes-core/base-files

$(KERNEL_USER_MODS_BASE):
	@echo "adding user kernel modifications"
	@mkdir -p $(KERNEL_USER_MODS_BASE)
	@cp -r ./zynq_os_mods/kernel/linux $(KERNEL_USER_MODS_BASE)

$(DROPBEAR):
#	#unlock dropbear so we can override its hostkey file with a symbolic link
	@echo "Adding link to /fw for dropbear hostkey"
	@echo "SIGGEN_UNLOCKED_RECIPES += \"dropbear\"" >>       $(YOCTO_MOD_BASE)/conf/petalinuxbsp.conf
#	#Modify dropbear so that it uses a symbolic link for the hostkey that is saved on the sdcard and mounted at /fw
	@mkdir -p $(YOCTO_MOD_BASE)/recipes-core/dropbear
	@cp ./zynq_os_mods/dropbear/dropbear_%.bbappend	         $(YOCTO_MOD_BASE)/recipes-core/dropbear
$(USERS): ./zynq_os_mods/users/users.dat
#	#Update users
	@echo "Updating users"
	@mkdir -p $(YOCTO_MOD_BASE)/recipes-core/images
	@cd ./zynq_os_mods/users/; ./setup_users
	@cp ./zynq_os_mods/users/petalinux-user-image.bbappend	 $(YOCTO_MOD_BASE)/recipes-core/images/

$(BOOTSCRIPT):
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-create -t apps --template install --name bootscript --enable
	@cp ./zynq_os_mods/bootscript/bootscript.bb              $(YOCTO_MOD_BASE)/recipes-apps/bootscript/bootscript.bb
	@cp ./zynq_os_mods/bootscript/bootscript                 $(YOCTO_MOD_BASE)/recipes-apps/bootscript/files/bootscript

$(SMBOOTSCRIPT):
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-create -t apps --template install --name smboot --enable
	@cp ./zynq_os_mods/smboot/smboot.bb              $(YOCTO_MOD_BASE)/recipes-apps/smboot/smboot.bb
	@cp ./zynq_os_mods/smboot/smboot                 $(YOCTO_MOD_BASE)/recipes-apps/smboot/files/smboot

$(HEARTBEATSCRIPT):
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-create -t apps --template install --name heartbeat --enable
	@cp ./zynq_os_mods/heartbeat/heartbeat.bb              $(YOCTO_MOD_BASE)/recipes-apps/heartbeat/heartbeat.bb
	@cp ./zynq_os_mods/heartbeat/heartbeat                 $(YOCTO_MOD_BASE)/recipes-apps/heartbeat/files/heartbeat

$(STARTUP-SCRIPT):
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-create -t apps --template install --name startup-script --enable
	@cp ./zynq_os_mods/startup-script/startup-script.bb              $(YOCTO_MOD_BASE)/recipes-apps/startup-script/startup-script.bb
	@cp ./zynq_os_mods/startup-script/startup-script                 $(YOCTO_MOD_BASE)/recipes-apps/startup-script/files/startup-script

$(UIO-UDEV):
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-create -t apps --template install --name uio.rules --enable
	@cp ./zynq_os_mods/uio/uio.rules.bb              $(YOCTO_MOD_BASE)/recipes-apps/uio.rules/uio.rules.bb
	@cp ./zynq_os_mods/uio/uio.rules                 $(YOCTO_MOD_BASE)/recipes-apps/uio.rules/files/uio.rules
	@cp ./zynq_os_mods/uio/mount.blacklist           $(YOCTO_MOD_BASE)/recipes-apps/uio.rules/files/mount.blacklist

$(FSBL):
#	#Modify the FSBL to poll for SI chip config
	@echo "Modify FSBL"
	@mkdir -p $(FSBL_BASE)
	@cp -r $(FSBL_MOD)/* $(FSBL_BASE)


$(BUILD_ROOTFS): $(ZYNQ_OS_PROJECT) $(USER_MOD_ROOTFS)
	@echo "Copy user root fs config to build root fs config"
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS).test
#	@chmod a-w $(BUILD_ROOTFS)
	@echo "Copy user mods to mounting"
	make $(FSTAB)
	make $(DROPBEAR)
	make $(USERS)
	make $(BOOTSCRIPT)
	make $(SMBOOTSCRIPT)
	make $(HEARTBEATSCRIPT)
	make $(STARTUP-SCRIPT)
	make $(UIO-UDEV)

#$(BUILD_UBOOT): $(ZYNQ_OS_PROJECT)
#	@echo "Building u-boot"
#	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
#	source $(VIVADO_PETALINUX) && \

$(PACKAGE_LINUX_IMAGE) : $(ZYNQ_OS_PROJECT) $(BUILD_ROOTFS)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-build -x mrproper $(OUTPUT_MARKUP)
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)

$(BOOT_FILES): $(PACKAGE_LINUX_IMAGE)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../../bit/top.bit  --uboot --force $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

REBUILD_BOOTBIN: 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../../bit/top.bit  --uboot --force $(OUTPUT_MARKUP)


#REBUILD_FSBL:
#	rm -rf $(ZYNQ_OS_PROJECT_PATH)/components/plnx_workspace/fsbl
#	rm -f $(FSBL)
#	make $(FSBL)
#	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
#	source $(VIVADO_PETALINUX) && \
#	petalinux-build -c bootloader -x distclean $(OUTPUT_MARKUP) && \
#	petalinux-build -c bootloader $(OUTPUT_MARKUP) && \
#	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../../bit/top.bit  --uboot --force $(OUTPUT_MARKUP)


clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt
	@rm -f ./zynq_os_mods/users/petalinux-user-image.bbappend
