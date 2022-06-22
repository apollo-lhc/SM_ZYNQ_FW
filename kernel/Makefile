#add path so build can be more generic
include ../build-scripts/mk/helpers.mk
OUTPUT_MARKUP= 2>&1 | tee -a make_log.txt ${CCZE_CMD}

#################################################################################
# VIVADO stuff
#################################################################################
BUILD_PETALINUX_VERSION?=2020.2
BUILD_PETALINUX_ROOT?="/opt/Xilinx/petalinux/"
#BUILD_VIVADO_PETALINUX="/work/Xilinx/PetaLinux/"$(BUILD_VIVADO_VERSION)"/tool/settings.sh"
#BUILD_VIVADO_PETALINUX="/work/Xilinx/petalinux/"$(BUILD_VIVADO_VERSION)"/settings.sh"
SOURCE_PETALINUX_ENV=${BUILD_PETALINUX_ROOT}$(BUILD_PETALINUX_VERSION)/settings.sh

ifeq ($(BUILD_PETALINUX_VERSION),2018.2)
	PETALINUX_OLD_CONFIG_OPTION=--oldconfig
else 
ifeq ($(BUILD_PETALINUX_VERSION),2018.3)
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

#$$@ escapes $@, which is used in the makefile functions to specify the specific build
CONFIGS_BASE=configs/
CONFIG_BASE=configs/$$@/

#YOCTO_MOD_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/
YOCTO_BASE=$(ZYNQ_OS_PROJECT_PATH)/project-spec/

YOCTO_CONFIG_BASE=$(YOCTO_BASE)/configs/

YOCTO_USER_BASE        =$(YOCTO_BASE)/meta-user/
YOCTO_USER_BSP_BASE    =$(YOCTO_USER_BASE)/recipes-bsp/
YOCTO_USER_KERNEL_BASE =$(YOCTO_USER_BASE)/recipes-kernel/
YOCTO_USER_MODULES_BASE=$(YOCTO_USER_BASE)/recipes-modules/


#CONFIG_BOOTLOADER=CONFIG_BOOTLOADER
CONFIG_ROOTFS=CONFIG_ROOTFS

ROOTFS_CONFIG_SRC_PATH=$(CONFIG_BASE)/configs/rootfs/
ROOTFS_CONFIG_DST_PATH=$(YOCTO_CONFIG_BASE)/

BOOT_CONFIG_SRC_PATH=$(CONFIG_BASE)/configs/boot_config/
BOOT_CONFIG_DST_PATH=$(YOCTO_CONFIG_BASE)/

UBOOT_MOD_SRC_PATH=$(CONFIG_BASE)/u-boot/
UBOOT_MOD_DST_PATH=$(YOCTO_USER_BSP_BASE)/u-boot/

ATF_MOD_SRC_PATH=$(CONFIG_BASE)/ATF/
ATF_MOD_DST_PATH=$(YOCTO_USER_BSP_BASE)/arm-trusted-firmware/

KERNEL_MODS_SRC_PATH=$(CONFIG_BASE)/kernel/
KERNEL_MODS_DST_PATH=$(YOCTO_USER_KERNEL_BASE)/

DEVTREE_MODS_SRC_PATHS="./hw ./hw_* $(CONFIG_BASE)/hw_user"
DEVTREE_MODS_SCRIPT=$(CONFIG_BASE)/device-tree/build_user_dtsi.sh
DEVTREE_MODS_DST_FILE=$(YOCTO_USER_BSP_BASE)/device-tree/files/system-user.dtsi

KMODULE_SRC_PATH=$(CONFIG_BASE)/kmodules/
KMODULE_DST_PATH=$(YOCTO_USER_MODULES_BASE)
KMODULE_SCRIPT=scripts/setup_kernel_mods.sh

FSBL_MOD_SRC_PATH=$(CONFIG_BASE)/fsbl/
FSBL_MOD_DST_PATH=$(YOCTO_USER_BSP_BASE)/fsbl/
FSBL_MOD_ADDR_SRC_PATH=../$(CONFIG_BASE)/autogen/
FSBL_MOD_ADDR_DST_PATH=$(FSBL_MOD_DST_PATH)/files/git/lib/sw_apps/








PACKAGE_LINUX_IMAGE=$(ZYNQ_OS_PROJECT_PATH)/images/linux/image.elf



KERNEL_MODULES_BASE=$(YOCTO_MOD_BASE)/recipes-modules

.PHONY: list  clean $(ROOTFS_CONFIG_DST_PATH) $(BOOT_CONFIG_DST_PATH) REBUILD_BOOTBIN NOTIFY_DAN_GOOD NOTIFY_DAN_BAD tarball



clean:
	@rm -rf zynq_os
	@rm -f  make_log.txt




#################################################################################
# Helper calls to simplify build rules
#################################################################################
# " || : " allows for a config to not fail if it doesn't have this kind of mod
define copy_configs =
	@echo $(CONFIGS_BASE)
	@echo $(CONFIG_BASE)
	@pwd
#	ROOTFS_MODS =============================================================
	@echo "adding rootfs mods" 					$(OUTPUT_MARKUP)
	@cp   	$(ROOTFS_CONFIG_SRC_PATH)/rootfs_config  \
		$(ROOTFS_CONFIG_DST_PATH)/rootfs_config || :
	@cp   	$(ROOTFS_CONFIG_SRC_PATH)/rootfs_config  \
		$(ROOTFS_CONFIG_DST_PATH)/rootfs_config.old || :	$(OUTPUT_MARKUP)

#	BOOT MODS ===============================================================
	@echo "adding boot mods" 					$(OUTPUT_MARKUP)
	@cp 	$(BOOT_CONFIG_SRC_PATH)/config  \
		$(BOOT_CONFIG_DST_PATH)/config 	 || :
	@cp 	$(BOOT_CONFIG_SRC_PATH)/config  \
		$(BOOT_CONFIG_DST_PATH)/config.old || :			$(OUTPUT_MARKUP)

#       UBOOT Mods ==============================================================
	@echo "adding u-boot files" 					$(OUTPUT_MARKUP)
	@mkdir -p $(dir $(UBOOT_MOD_DST_PATH)) 				$(OUTPUT_MARKUP)
	@cp -r 	$(UBOOT_MOD_SRC_PATH)/*  \
		$(UBOOT_MOD_DST_PATH) || :				$(OUTPUT_MARKUP)

#       ATF mods ================================================================
	@echo "adding ATF files" 					$(OUTPUT_MARKUP)
	@mkdir -p $(dir $(ATF_MOD_DST_PATH)) 				$(OUTPUT_MARKUP) 
	@cp -r 	$(ATF_MOD_SRC_PATH)/*    \
		$(ATF_MOD_DST_PATH) || :				$(OUTPUT_MARKUP)

#       Kernel mods =============================================================
	@echo "adding user kernel modifications" 			$(OUTPUT_MARKUP)
	@mkdir -p $(dir $(KERNEL_MODS_DST_PATH)) 			$(OUTPUT_MARKUP)
	@cp -r 	$(KERNEL_MODS_SRC_PATH) \
		$(KERNEL_MODS_DST_PATH) || : 				$(OUTPUT_MARKUP)

#	Device Tree mods ========================================================
	DTSI_PATH= $(DEVTREE_MODS_SCRIPT) \
		 	$(DEVTREE_MODS_SRC_PATHS) > \
			$(DEVTREE_MODS_DST_FILE) || : 			$(OUTPUT_MARKUP)

#	Kernel modules ==========================================================
	@echo "adding kernel modules to be built"			$(OUTPUT_MARKUP)
	KMODULE_SRC_PATH=$(KMODULE_SRC_PATH) \
		ZYNQ_OS_PROJECT_PATH=$(ZYNQ_OS_PROJECT_PATH) \
		SOURCE_PETALINUX_ENV=${SOURCE_PETALINUX_ENV} \
		KMODULE_DST_PATH=${KMODULE_DST_PATH} \
		${KMODULE_SCRIPT}					$(OUTPUT_MARKUP)

#       FSBL mods ===============================================================
#	Make dir, copy base files, address files, run fsbl mod script
	@echo "Modify FSBL" 						$(OUTPUT_MARKUP)
	@mkdir -p $(FSBL_MOD_DST_PATH)					$(OUTPUT_MARKUP)
	@cp -r 	$(FSBL_MOD_SRC_PATH)/* \
		$(FSBL_MOD_DST_PATH) || :				$(OUTPUT_MARKUP)
	@mkdir -p $(FSBL_MOD_ADDR_DST_PATH)/zynqmp_fsbl/src/		$(OUTPUT_MARKUP)
	@cp    	$(FSBL_MOD_ADDR_SRC_PATH)/AXI_slave_addrs.h \
		$(FSBL_MOD_ADDR_DST_PATH)/zynqmp_fsbl/src/		$(OUTPUT_MARKUP)
	@mkdir -p $(FSBL_MOD_ADDR_DST_PATH)/zynq_fsbl/src/		$(OUTPUT_MARKUP)
	@cp    	$(FSBL_MOD_ADDR_SRC_PATH)/AXI_slave_addrs.h \
		$(FSBL_MOD_ADDR_DST_PATH)/zynq_fsbl/src/		$(OUTPUT_MARKUP)
	@echo foo							$(OUTPUT_MARKUP)
	@$(FSBL_MOD_SRC_PATH)/build_mods.sh || :			

#	Layer config mod ========================================================
#	@echo "layer config (if needed)"
#	@cp ./configs/$$@/configs/layer.conf $(ZYNQ_OS_PROJECT_PATH)/project-spec/meta-user/conf/ || :

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
		source $(SOURCE_PETALINUX_ENV) && \
		pwd && \
		petalinux-config --get-hw-description \
			../hw/ $(PETALINUX_OLD_CONFIG_OPTION) 		$(OUTPUT_MARKUP)
	@echo "Apply all mods" 						$(OUTPUT_MARKUP)
	$(copy_configs) 
	@echo "Reset the project build"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-build -x mrproper 				$(OUTPUT_MARKUP)
	@echo "Build the project"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-build 					$(OUTPUT_MARKUP)
	@echo "Packaging images"
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-build -x package 				$(OUTPUT_MARKUP)
endef

#################################################################################
# Calls for building 7 vs US+ configs
#################################################################################

define build_7s =
	@echo "clean out old things"					$(OUTPUT_MARKUP)
	$(setup_path)
	@echo "Create petalinux project"				$(OUTPUT_MARKUP)
	source $(SOURCE_PETALINUX_ENV) && \
		petalinux-create --type project --name $(ZYNQ_OS) \
			--template zynq --force 			$(OUTPUT_MARKUP)
	@echo "build"							$(OUTPUT_MARKUP)
	$(build_project)
	@echo "package"							$(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-package --boot --format BIN \
			--fsbl images/linux/zynq_fsbl.elf \
			--fpga ../$$<  --uboot --force 			$(OUTPUT_MARKUP)
	tar -h -zcf $$@.tar.gz -C output BOOT.BIN boot.scr image.ub \
		-C ../address_tables/ address_table 			$(OUTPUT_MARKUP)
	@echo "Build ended:"
	@date
endef

define build_USp =
	@echo "clean out old things"					$(OUTPUT_MARKUP)
	$(setup_path)
	@echo "Create petalinux project"				$(OUTPUT_MARKUP)
	source $(SOURCE_PETALINUX_ENV) && \
		petalinux-create --type project --name $(ZYNQ_OS) \
			--template zynqMP --force 			$(OUTPUT_MARKUP)
	@echo "build"							$(OUTPUT_MARKUP)
	$(build_project)
	@echo "package"							$(OUTPUT_MARKUP)
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf \
			--fpga ../$$<  --uboot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf \
			--atf images/linux/bl31.elf  --force 		$(OUTPUT_MARKUP)
#	build a tarball of the firmware files and the address table files
#	for -C, remember that the have state, so ../ infront of address talbes because of the output dir change
	tar -h -zcf $$@.tar.gz -C output BOOT.BIN boot.scr image.ub \
		-C ../address_tables/ address_table 			$(OUTPUT_MARKUP)
	@echo "Build ended:"						$(OUTPUT_MARKUP)
	@date								$(OUTPUT_MARKUP)
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
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-config -c kernel

reconfig:
	@cd $(ZYNQ_OS_PROJECT_PATH) &&\
		source $(SOURCE_PETALINUX_ENV) && \
		petalinux-config

docker :
	docker pull centos:centos7
	time docker run --rm -it --env="DISPLAY" --volume="${HOME}/.Xauthority:/root/.Xauthority:rw" -v ${MAKE_PATH}/../:/app:Z -v /opt/Xilinx/petalinux:/opt/Xilinx/petalinux:Z,ro centos:centos7 bash

docker_% :
	docker pull centos:centos7
	time docker run --rm -it -v ${MAKE_PATH}/../:/app:Z -v /opt/Xilinx/petalinux:/opt/Xilinx/petalinux:Z,ro centos:centos7 /app/kernel/scripts/build_container.sh $* ${BUILD_PETALINUX_VERSION} ${BUILD_PETALINUX_ROOT}
