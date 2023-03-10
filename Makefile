-include build-scripts/mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_FLAGS=-notrace -mode batch
BUILD_VIVADO_VERSION?=2020.2
BUILD_VIVADO_BASE?="/opt/Xilinx/Vivado"
BUILD_VIVADO_SHELL=${BUILD_VIVADO_BASE}"/"$(BUILD_VIVADO_VERSION)"/settings64.sh"


#################################################################################
# TCL scripts
#################################################################################
BUILD_SCRIPTS_PATH=${MAKE_PATH}/build-scripts/
SETUP_TCL=${BUILD_SCRIPTS_PATH}/Setup.tcl
BUILD_TCL=${BUILD_SCRIPTS_PATH}/Build.tcl
SETUP_BUILD_TCL=${BUILD_SCRIPTS_PATH}/SetupAndBuild.tcl
HW_TCL=${BUILD_SCRIPTS_PATH}/Run_hw.tcl


################################################################################
# Configs
#################################################################################
CONFIGS_BASE_PATH=configs/
#get a list of the subdirs in configs.  These are our FPGA builds
CONFIGS=$(filter-out ${CONFIGS_BASE_PATH},$(patsubst ${CONFIGS_BASE_PATH}%/,%,$(dir $(wildcard ${CONFIGS_BASE_PATH}*/))))

define CONFIGS_template =
 $(1): clean_make_log clean
	time $(MAKE) $(BIT_BASE)$$@.bit || $(MAKE) NOTIFY_DAN_BAD
endef

#################################################################################
# Short build names
#################################################################################
BIT_BASE=${MAKE_PATH}/bit/top_

#################################################################################
# Paths
#################################################################################
SLAVE_DEF_FILE_BASE=${MAKE_PATH}/${CONFIGS_BASE_PATH}
OS_BUILD_PATH=${MAKE_PATH}/os/
KERNEL_BUILD_PATH=${MAKE_PATH}/kernel/
ADDRESS_TABLE_CREATION_PATH=${KERNEL_BUILD_PATH}

#################################################################################
# preBuild 
#################################################################################

MAP_TEMPLATE_FILE=${MAKE_PATH}/regmap_helper/templates/axi_generic/template_map.vhd
ifneq ("$(wildcard ${BUILD_SCRIPTS_PATH}/mk/preBuild.mk)","")
  include ${BUILD_SCRIPTS_PATH}/mk/preBuild.mk
endif


#################################################################################
# address tables
#################################################################################
$(BIT_BASE)%.bit $(BIT_BASE)%.svf       : ADDRESS_TABLE=${MAKE_PATH}/kernel/address_table_%/address_%.xml
ifneq ("$(wildcard ${BUILD_SCRIPTS_PATH}/mk/addrTable.mk)","")
  include ${BUILD_SCRIPTS_PATH}/mk/addrTable.mk
endif


#################################################################################
# Device tree overlays
#################################################################################
DTSI_PATH=${SLAVE_DTSI_PATH}/hw/
-include build-scripts/mk/deviceTreeOverlays.mk

.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init  $(CONFIGS) $(PREBUILDS)


#################################################################################
# Clean
#################################################################################
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ${MAKE_PATH}/cores -type f | { grep -v xci || true; } | awk '{print "rm " $$1}' | bash
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf ${MAKE_PATH}/bit/*
clean_kernel:
	@echo "Clean hw files"
	@rm -f ${MAKE_PATH}/kernel/hw/*
clean_ip_%:
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado $(VIVADO_FLAGS) -source ../scripts/CleanIPs.tcl -tclargs ${MAKE_PATH} $(subst .bit,,$(subst clean_ip_,,$@))
clean_autogen:
	rm -rf configs/*/autogen/*

clean: clean_ip clean_bit clean_kernel clean_address_tables
	@rm -rf ${MAKE_PATH}/proj/*
	@echo "Cleaning up"

clean_everything: clean clean_prebuild


#################################################################################
# Open vivado
#################################################################################

open_project : 
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado -source ../build-scripts/OpenProject.tcl top.xpr
open_synth : 
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_synth.dcp
open_impl : 
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_route.dcp
open_hw :
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado -source $(HW_TCL)


#################################################################################
# FPGA building
#################################################################################
#generate a build rule for each FPGA in the configs dir ($CONFIGS) 
$(foreach config,$(CONFIGS),$(eval $(call CONFIGS_template,$(config))))

interactive : 
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	cd proj &&\
	vivado -mode tcl

$(BIT_BASE)%.bit	: $(ADDRESS_TABLE_CREATION_PATH)config_%.yaml
	@ln -s config_$*.yaml $(ADDRESS_TABLE_CREATION_PATH)config.yaml
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) -tclargs ${MAKE_PATH} ${BUILD_SCRIPTS_PATH} $(subst .bit,,$(subst ${BIT_BASE},,$@)) $(OUTPUT_MARKUP)
	@echo   ${MAKE} $(ADDRESS_TABLE_CREATION_PATH)address_tables/address_table_$*/address_apollo.xml
	${MAKE} $(ADDRESS_TABLE_CREATION_PATH)address_tables/address_table_$*/address_apollo.xml
	$(MAKE) overlays  $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

full_%: BUILD_NAME=%
full_%: clean clean_bd clean_kernel clean_bit clean_remote clean_CM clean_prebuild
	cd os     && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	cd kernel && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	$(MAKE) init
	$(MAKE) ${BUILD_NAME}
	cd kernel && $(MAKE) {BUILD_NAME} && cd ${MAKE_PATH}

init:
	git submodule update --init --recursive 
	$(git remote -v | grep push | sed 's/https:\/\//git@/g' | sed 's/.com\//.com:/g' | awk '{print "git remote set-url --push " $1 " " $2}')

