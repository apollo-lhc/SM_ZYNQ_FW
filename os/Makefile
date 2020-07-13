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

USER_MOD_ROOTFS=$(ZYNQ_OS_PROJECT_PATH)_mods/configs/rootfs/rootfs_config
BUILD_ROOTFS=$(ZYNQ_OS_PROJECT_PATH)/project-spec/configs/rootfs_config
UPDATE_ROOTFS=UPDATE_ROOTFS

USER_MOD_BOOT=$(ZYNQ_OS_PROJECT_PATH)_mods/configs/boot_config/config
BUILD_BOOT=$(ZYNQ_OS_PROJECT_PATH)/project-spec/configs/config
UPDATE_BOOT=UPDATE_BOOT

YOCTO_MOD_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/
PACKAGE_LINUX_IMAGE=$(ZYNQ_OS_PROJECT_PATH)/images/linux/image.elf

KERNEL_USER_MODS_BASE=$(YOCTO_MOD_BASE)/recipes-kernel

.PHONY: list  clean $(BUILD_ROOTFS) $(BUILD_BOOT) REBUILD_BOOTBIN NOTIFY_DAN_GOOD NOTIFY_DAN_BAD tarball

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
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config -v --get-hw-description ../hw -c kernel

$(ZYNQ_OS_PROJECT) : $(HDF_FILE)
	@echo "Creating fresh OS project"
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw --oldconfig
	DTSI_PATH="./hw ./hw_user ./hw_remote" $(ZYNQ_OS)_mods/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER)
	make $(KERNEL_USER_MODS_BASE)
	make $(FSBL)



#################################################################################
## ROOT Filesystem and packages
#################################################################################


$(CONFIG_ROOTFS): $(ZYNQ_OS_PROJECT) 
#	copy an existing mod to start from
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 2>/dev/null || :
#	run the menuconfig 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config -c rootfs
	@cp $(BUILD_ROOTFS) $(USER_MOD_ROOTFS) 

$(KERNEL_USER_MODS_BASE):
	@echo "adding user kernel modifications"
	@mkdir -p $(KERNEL_USER_MODS_BASE)
	@cp -r ./zynq_os_mods/kernel/linux $(KERNEL_USER_MODS_BASE)


$(FSBL):
#	#Modify the FSBL to poll for SI chip config
	@echo "Modify FSBL"
	@mkdir -p $(FSBL_BASE)
	@cp -r $(FSBL_MOD)/* $(FSBL_BASE)


$(BUILD_ROOTFS): $(ZYNQ_OS_PROJECT) $(USER_MOD_ROOTFS) $(USER_MOD_BOOT)
	@echo "Copy user root fs config to build root fs config"
	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 
	@cp $(USER_MOD_BOOT)    $(BUILD_BOOT) 


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


clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt

make tarball:
	cd $(ZYNQ_OS_PROJECT_PATH)/images/linux/ && \
	tar -zcf ../../..//$(shell date +%F)-SD_p1.tar.gz BOOT.BIN image.ub
