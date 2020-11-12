include ../mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
BUILD_VIVADO_VERSION=2019.1
BUILD_VIVADO_PETALINUX="/work/Xilinx/petalinux/"$(BUILD_VIVADO_VERSION)"/settings.sh"

ifeq ($(BUILD_VIVADO_VERSION),2018.2)
	PETALINUX_OLD_CONFIG_OPTION=--oldconfig
else 
ifeq ($(BUILD_VIVADO_VERSION),2018.3)
	PETALINUX_OLD_CONFIG_OPTION=--oldconfig
else
	PETALINUX_OLD_CONFIG_OPTION=--silentconfig
endif
endif

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


YOCTO_MOD_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/
PACKAGE_LINUX_IMAGE=$(ZYNQ_OS_PROJECT_PATH)/images/linux/image.elf

KERNEL_USER_MODS_BASE=$(YOCTO_MOD_BASE)/recipes-kernel

.PHONY: list  clean $(BUILD_ROOTFS) $(BUILD_BOOT) REBUILD_BOOTBIN NOTIFY_DAN_GOOD NOTIFY_DAN_BAD tarball

all: 
	$(MAKE) $(BOOT_FILES) || $(MAKE) NOTIFIFY_DAN_BAD


clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt


ZYNQ_OS_MODS_BASE=zynq_os_mods/
define copy_configs =
	@echo "adding rootfs mods" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(BUILD_ROOTFS)) $(OUTPUT_MARKUP)
	@cp $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS)
	@cp $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_ROOTFS_PATH)  $(BUILD_ROOTFS).old 
	@echo "adding boot mods" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(BUILD_BOOT)) $(OUTPUT_MARKUP)
	@cp $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_BOOT_PATH)  $(BUILD_BOOT)
	@cp $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_BOOT_PATH)  $(BUILD_BOOT).old
	@echo "adding u-boot files" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(BUILD_UBOOT)) $(OUTPUT_MARKUP)
	@cp -r $(ZYNQ_OS_MODS_BASE)/$@/$(USER_MOD_UBOOT_PATH)/*  $(BUILD_UBOOT) || :
	@echo "adding user kernel modifications" $(OUTPUT_MARKUP)
	@mkdir -p $(dir $(KERNEL_USER_MODS_BASE)) $(OUTPUT_MARKUP)
	@cp -r ./zynq_os_mods/$@/kernel/linux $(KERNEL_USER_MODS_BASE) $(OUTPUT_MARKUP)
	DTSI_PATH="./hw ./hw_*" $(ZYNQ_OS_MODS_BASE)/$@/device-tree/build_user_dtsi.sh > $(DEVICE_TREE_USER) $(OUTPUT_MARKUP)
	@echo "Modify FSBL" $(OUTPUT_MARKUP)
	@mkdir -p $(FSBL_BASE)
	@cp -r $(ZYNQ_OS_MODS_BASE)/$@/fsbl/* $(FSBL_BASE)
endef





rev2_xczu7ev : ../bit/top_rev2_xczu7ev.bit
	@echo "Creating fresh OS project"
	@rm -f make_log.txt
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynqMP --force $(OUTPUT_MARKUP)
	@echo "foo"  $(OUTPUT_MARKUP)
	$(copy_configs)
	@echo "foo2"  $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw $(PETALINUX_OLD_CONFIG_OPTION) $(OUTPUT_MARKUP)
	$(copy_configs) 
	@echo "foo3"  $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"  $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --fpga ../$<  --uboot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --atf images/linux/bl31.elf  --force $(OUTPUT_MARKUP)
#	petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)

rev2_xc7z035 : ../bit/top_rev2_xc7z035.bit
	@echo "Creating fresh OS project"
	@rm -f make_log.txt
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force $(OUTPUT_MARKUP)
	$(copy_configs) 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw $(PETALINUX_OLD_CONFIG_OPTION) $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)


rev2_xc7z045 : ../bit/top_rev2_xc7z045.bit
	@echo "Creating fresh OS project"
	@rm -f make_log.txt
	@rm -rf $(ZYNQ_OS_PROJECT_PATH)	
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-create --type project --name $(ZYNQ_OS) --template zynq --force $(OUTPUT_MARKUP)
	$(copy_configs) 
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-config --get-hw-description ../hw $(PETALINUX_OLD_CONFIG_OPTION) $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build $(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-build -x package $(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
	source $(BUILD_VIVADO_PETALINUX) && \
	petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga ../$<  --uboot --force $(OUTPUT_MARKUP)
