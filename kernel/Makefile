include ../mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2019.2 #2018.2
VIVADO_PETALINUX="/home/dan/Xilinx/petalinux/settings.sh" #"/opt/Xilinx/petalinux/"$(VIVADO_VERSION)"/settings.sh"

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

USER_MOD_ROOTFS_PATH=configs/rootfs/rootfs_config
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


####
####RECONFIG_ZYNQ : $(HDF_FILE)
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-config -v --get-hw-description ../hw -c kernel
####
####$(ZYNQ_OS_PROJECT) : $(HDF_FILE)
####	@echo "Creating fresh OS project"
####	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
####	source $(VIVADO_PETALINUX) && \
####	petalinux-create --type project --name $(ZYNQ_OS) --template zynqMP --force
####	#	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-config --get-hw-description ../hw
#####	petalinux-config --get-hw-description ../hw --silentconfig
#####	petalinux-config --get-hw-description ../hw --oldconfig
#####	petalinux-config --get-hw-description ../hw
####	DTSI_PATH="./hw ./hw_*" $(ZYNQ_OS)_mods/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER)
####	make $(KERNEL_USER_MODS_BASE)
####	make $(FSBL)
####


#################################################################################
## ROOT Filesystem and packages
#################################################################################

####
####$(CONFIG_ROOTFS): $(ZYNQ_OS_PROJECT) 
#####	copy an existing mod to start from
####	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 2>/dev/null || :
#####	run the menuconfig 
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-config -c rootfs
####	@cp $(BUILD_ROOTFS) $(USER_MOD_ROOTFS) 

#$(KERNEL_USER_MODS_BASE):
#	@echo "adding user kernel modifications"
#	@mkdir -p $(KERNEL_USER_MODS_BASE)
#	@cp -r ./zynq_os_mods/kernel/linux $(KERNEL_USER_MODS_BASE)


#$(FSBL):
##	#Modify the FSBL to poll for SI chip config
#	@echo "Modify FSBL"
#	@mkdir -p $(FSBL_BASE)
#	@cp -r $(FSBL_MOD)/* $(FSBL_BASE)


#$(BUILD_ROOTFS): $(ZYNQ_OS_PROJECT) $(USER_MOD_ROOTFS) $(USER_MOD_BOOT)
#	@echo "Copy user root fs config to build root fs config"
#	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 
#	@cp $(USER_MOD_BOOT)    $(BUILD_BOOT) 

####
####$(PACKAGE_LINUX_IMAGE) : $(ZYNQ_OS_PROJECT) $(BUILD_ROOTFS)
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-build -x mrproper $(OUTPUT_MARKUP)
####	@cp $(USER_MOD_ROOTFS)  $(BUILD_ROOTFS) 
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-build $(OUTPUT_MARKUP)
####	@echo "Packaging images"
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-build -x package $(OUTPUT_MARKUP)
####
####$(BOOT_FILES).% : ../bit/top_%.bit $(PACKAGE_LINUX_IMAGE) 
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)
####	$(MAKE) NOTIFY_DAN_GOOD
####
####REBUILD_BOOTBIN_%: ../bit/top_%.bit 
####	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
####	source $(VIVADO_PETALINUX) && \
####	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)
####
####rev2_xc7z035 : $(BOOT_FILES).rev2_xc7z035 images/linux/zynq_fsbl.elf
####
####rev2_xc7z045 : $(BOOT_FILES).rev2_xc7z045 images/linux/zynq_fsbl.elf
####
#rev2_xczu7ev : $(BOOT_FILES).rev2_xczu7ev images/linux/zynqmp_fsbl.elf

clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt


ZYNQ_OS_MODS_BASE=zynq_os_mods/
define copy_configs =
	@echo "adding rootfs mods"
	@cp $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS) 2>/dev/null || :
	@echo "adding user kernel modifications"
	@mkdir -p $(KERNEL_USER_MODS_BASE)
	@cp -r ./zynq_os_mods/kernel/linux $(KERNEL_USER_MODS_BASE)
	DTSI_PATH="./hw ./hw_*" $(ZYNQ_OS_MODS_BASE)/$@/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER)
	@echo "Modify FSBL"
	@mkdir -p $(FSBL_BASE)
	@cp -r $(FSBL_MOD)/* $(FSBL_BASE)
endef





rev2_xczu7ev : ../bit/top_rev2_xczu7ev.bit
	@echo "Creating fresh OS project"
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynqMP --force
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw --silentconfig
	$(TB_RULE)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)
