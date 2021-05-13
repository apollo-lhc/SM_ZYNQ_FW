#add path so build can be more generic
include ../mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
BUILD_VIVADO_VERSION=2020.2
BUILD_VIVADO_PETALINUX="/work/Xilinx/PetaLinux/"$(BUILD_VIVADO_VERSION)"/tool/settings.sh"

ifeq ($(BUILD_VIVADO_VERSION),2018.2)
	PETALINUX_OLD_CONFIG_OPTION=--oldconfig
else 
ifeq ($(BUILD_VIVADO_VERSION),2018.3)
	PETALINUX_OLD_CONFIG_OPTION=--oldconfig
else
	PETALINUX_OLD_CONFIG_OPTION=--silentconfig
endif
endif

################################################################################
# Configs
#################################################################################
#get a list of the subdirs in configs.  These are our FPGA builds
CONFIGS_7s=$(filter-out configs/,$(patsubst configs/%/,%,$(dir $(wildcard configs/*xc7z*/))))
CONFIGS_USp=$(filter-out configs/,$(patsubst configs/%/,%,$(dir $(wildcard configs/*xczu*/))))

define CONFIGS_7s_template =
 $(1): ../bit/top_$(1).bit
	$(build_7s)
endef
define CONFIGS_USp_template =
 $(1): ../bit/top_$(1).bit
	$(build_USp)
endef

################################################################################
# Kernel build variables
#################################################################################

BUILD_TIME=$(shell date +%s)

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

USER_MOD_BOOT_PATH=configs/boot_config/config
BUILD_BOOT=$(ZYNQ_OS_PROJECT_PATH)/project-spec/configs/config
UPDATE_BOOT=UPDATE_BOOT

USER_MOD_UBOOT_PATH=u-boot/
BUILD_UBOOT=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/recipes-bsp/u-boot/

USER_MOD_ATF_PATH=ATF/
BUILD_ATF=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/recipes-bsp/arm-trusted-firmware/

YOCTO_MOD_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/
PACKAGE_LINUX_IMAGE=$(ZYNQ_OS_PROJECT_PATH)/images/linux/image.elf

KERNEL_USER_MODS_BASE=$(YOCTO_MOD_BASE)/recipes-kernel

.PHONY: list  clean $(BUILD_ROOTFS) $(BUILD_BOOT) REBUILD_BOOTBIN NOTIFY_DAN_GOOD NOTIFY_DAN_BAD tarball



clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt


CONFIGS_BASE=configs/

#################################################################################
# Helper calls to simplify build rules
#################################################################################

define copy_configs =
	@echo "adding rootfs mods" $(OUTPUT_MARKUP)
#	@mkdir -p $(dir $(BUILD_ROOTFS)) $(OUTPUT_MARKUP)
	@echo $(CONFIGS_BASE)/$$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS)
	@cp $(CONFIGS_BASE)/$$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS)
	@cp $(CONFIGS_BASE)/$$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS).old 
	@echo "adding boot mods" $(OUTPUT_MARKUP)
#	@mkdir -p $(dir $(BUILD_BOOT)) $(OUTPUT_MARKUP)
	@echo $(CONFIGS_BASE)/$$@/$(USER_MOD_BOOT_PATH)  $(BUILD_BOOT)
	@cp $(CONFIGS_BASE)/$$@/$(USER_MOD_BOOT_PATH)  $(BUILD_BOOT) || :
	@cp $(CONFIGS_BASE)/$$@/$(USER_MOD_BOOT_PATH)  $(BUILD_BOOT).old || :
	@echo "adding u-boot files" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(BUILD_UBOOT)) $(OUTPUT_MARKUP)
	@cp -r $(CONFIGS_BASE)/$$@/$(USER_MOD_UBOOT_PATH)/*  $(BUILD_UBOOT) || :
	@echo "adding ATF files" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(BUILD_ATF)) $(OUTPUT_MARKUP) 
	@cp -r $(CONFIGS_BASE)/$$@/$(USER_MOD_ATF_PATH)/*    $(BUILD_ATF) || :
	@echo "adding user kernel modifications" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(KERNEL_USER_MODS_BASE)) $(OUTPUT_MARKUP)
#	@cp -r ./configs/$$@/kernel/linux $(KERNEL_USER_MODS_BASE) $(OUTPUT_MARKUP)
	@cp -r ./configs/$$@/kernel/ $(KERNEL_USER_MODS_BASE) $(OUTPUT_MARKUP)
	DTSI_PATH="./hw ./hw_* ./$(CONFIGS_BASE)/$$@/hw_user" $(CONFIGS_BASE)/$$@/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER) $(OUTPUT_MARKUP)
	@echo "Modify FSBL" $(OUTPUT_MARKUP)
	@mkdir -p $(FSBL_BASE)
	@cp -r $(CONFIGS_BASE)/$$@/fsbl/* $(FSBL_BASE)
	@cp    ../$(CONFIGS_BASE)/$$@/AXI_slave_addrs.h $(FSBL_BASE)/files
	@echo "layer config (if needed)"
	@cp ./configs/$$@/configs/layer.conf $(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/conf/ || :
	@echo "End of mods"
endef

define setup_path =
	@echo "Creating fresh OS project"
	@rm -f make_log.txt
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
endef

define build_project =
	@echo "Config the project with info from the HW"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	pwd && \
	petalinux-config --get-hw-description ../hw/ $(PETALINUX_OLD_CONFIG_OPTION) $(OUTPUT_MARKUP)
	@echo "Apply all mods"
	$(copy_configs) 
	@echo "Reset the project build"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build -x mrproper $(OUTPUT_MARKUP)
	@echo "Build the project"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)
endef

#################################################################################
# Calls for building 7 vs US+ configs
#################################################################################

define build_7s =
	@echo "clean out old things"
	$(setup_path)
	@echo "Create petalinux project"
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force $(OUTPUT_MARKUP)
	@echo "build"
	$(build_project)
	@echo "package"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../$$<  --uboot --force $(OUTPUT_MARKUP)
	@echo "Build ended:"
	@date
endef

define build_USp =
	@echo "clean out old things"
	$(setup_path)
	@echo "Create petalinux project"
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynqMP --force $(OUTPUT_MARKUP)
	@echo "build"
	$(build_project)
	@echo "package"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --fpga ../$$<  --uboot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --atf images/linux/bl31.elf  --force $(OUTPUT_MARKUP)
	@echo "Build ended:"
	@date
endef


#################################################################################
# Real builds
#################################################################################
#generate a build rule for each config in the configs dir ($CONFIGS) 
$(foreach config,$(CONFIGS_7s), $(eval $(call CONFIGS_7s_template,$(config))))
$(foreach config,$(CONFIGS_USp),$(eval $(call CONFIGS_USp_template,$(config))))


get_built_dts : ${ZYNQ_OS_PROJECT_PATH}/images/linux/system.dtb
	dtc -I dtb -O dts -o dump_${BUILD_TIME}.dts ${ZYNQ_OS_PROJECT_PATH}/images/linux/system.dtb


reconfig_kernel:
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-config -c kernel

reconfig:
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-config
