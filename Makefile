include mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################


VIVADO_FLAGS=-notrace -mode batch
BUILD_VIVADO_VERSION?=2020.2
BUILD_VIVADO_BASE?="/work/Xilinx/Vivado"
BUILD_VIVADO_SHELL=${BUILD_VIVADO_BASE}"/"$(BUILD_VIVADO_VERSION)"/settings64.sh"


#################################################################################
# TCL scripts
#################################################################################
SETUP_TCL=${MAKE_PATH}/scripts/Setup.tcl
BUILD_TCL=${MAKE_PATH}/scripts/Build.tcl
SETUP_BUILD_TCL=${MAKE_PATH}/scripts/SetupAndBuild.tcl
HW_TCL=${MAKE_PATH}/scripts/Run_hw.tcl



#################################################################################
# Source files
#################################################################################
PL_PATH=${MAKE_PATH}/src
BD_PATH=${MAKE_PATH}/bd
CORES_PATH=${MAKE_PATH}/cores
ADDRESS_TABLE = ${MAKE_PATH}/os/address_table/address_apollo.xml

################################################################################
# Configs
#################################################################################
#get a list of the subdirs in configs.  These are our FPGA builds
CONFIGS=$(filter-out configs/,$(patsubst configs/%/,%,$(dir $(wildcard configs/*/))))

define CONFIGS_template =
 $(1): clean_make_log clean
	time $(MAKE) $(BIT_BASE)$$@.bit || $(MAKE) NOTIFY_DAN_BAD
endef

#################################################################################
# Short build names
#################################################################################

BIT_BASE=${MAKE_PATH}/bit/top_


#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE_BASE=${MAKE_PATH}/configs/
ADDSLAVE_TCL_PATH=${MAKE_PATH}/src/ZynqPS/
ADDRESS_TABLE_CREATION_PATH=${MAKE_PATH}/os/
SLAVE_DTSI_PATH=${MAKE_PATH}/kernel/
MAP_TEMPLATE_FILE=${MAKE_PATH}/regmap_helper/templates/axi_generic/template_map.vhd

ifneq ("$(wildcard ${MAKE_PATH}/mk/preBuild.mk)","")
  include ${MAKE_PATH}/mk/preBuild.mk
endif

#################################################################################
# pull_cm
# fetch the CM files for building OS/Kernel
#################################################################################
ifneq ("$(wildcard ${MAKE_PATH}/mk/pull_CM.mk)","")
  include ${MAKE_PATH}/mk/pull_CM.mk
endif

#################################################################################
# address tables
#################################################################################
ifneq ("$(wildcard ${MAKE_PATH}/mk/addrTable.mk)","")
  include ${MAKE_PATH}/mk/addrTable.mk
endif



.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init  $(CONFIGS) $(PREBUILDS)


#################################################################################
# Clean
#################################################################################
clean_remote:
	@echo "Cleaning up remote files"
	@rm -f ${MAKE_PATH}/os/*_slaves.yaml
	@rm -f ${MAKE_PATH}/kernel/*_slaves.yaml
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ${MAKE_PATH}/cores -type f | { grep -v xci || true; } | awk '{print "rm " $$1}' | bash
#	@find ${MAKE_PATH}/cores -type f -name '*.dcp' -delete
clean_bd:
	@echo "Cleaning up bd generated files"
	@rm -rf ${MAKE_PATH}/bd/zynq_bd
	@rm -rf ${MAKE_PATH}/bd/c2cSlave
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf ${MAKE_PATH}/bit/*
clean_kernel:
	@echo "Clean hw files"
	@rm -f ${MAKE_PATH}/kernel/hw/*
clean: clean_bd clean_ip clean_bit clean_kernel
	@rm -rf ${MAKE_PATH}/proj/*
	@echo "Cleaning up"
clean_ip_%:
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado $(VIVADO_FLAGS) -source ../scripts/CleanIPs.tcl -tclargs ${MAKE_PATH} $(subst .bit,,$(subst clean_ip_,,$@))

clean_everything: clean clean_remote clean_CM clean_prebuild

#################################################################################
# Open vivado
#################################################################################

open_project : 
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado top.xpr
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

$(BIT_BASE)%.bit	: $(SLAVE_DTSI_PATH)/slaves_%.yaml $(ADDRESS_TABLE_CREATION_PATH)/slaves_%.yaml
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) -tclargs ${MAKE_PATH} $(subst .bit,,$(subst ${BIT_BASE},,$@)) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

full_%: BUILD_NAME=%
full_%: clean clean_bd clean_kernel clean_bit clean_remote clean_CM clean_prebuild
	cd os     && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	cd kernel && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	$(MAKE) init
	$(MAKE) ${BUILD_NAME}
	$(MAKE) ${ADDRESS_TABLE}
	cd kernel && $(MAKE) {BUILD_NAME} && cd ${MAKE_PATH}
	cd os     && $(MAKE) {BUILD_NAME}.tar.gz && cd ${MAKE_PATH}
#################################################################################         
# Sim     
#################################################################################         
ifneq ("$(wildcard ${MAKE_PATH}/sim/sim.mk)","") 
include ${MAKE_PATH}/sim/sim.mk
endif


init:
	git submodule update --init --recursive 
	$(git remote -v | grep push | sed 's/https:\/\//git@/g' | sed 's/.com\//.com:/g' | awk '{print "git remote set-url --push " $1 " " $2}')

