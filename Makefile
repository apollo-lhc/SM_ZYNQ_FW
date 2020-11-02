include mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################


VIVADO_FLAGS=-notrace -mode batch
#VIVADO_SHELL?="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"
#VIVADO_VERSION=2019.2
#VIVADO_SHELL="~/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"
VIVADO_SHELL="/home/dan/Xilinx/Vivado/2019.2/settings64.sh"


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


#################################################################################
# Short build names
#################################################################################

BIT_BASE=${MAKE_PATH}/bit/top_

.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init

all:
	$(MAKE) xc7z035 || $(MAKE) NOTIFY_DAN_BAD

#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE_BASE=${MAKE_PATH}/src/slaves_
ADDSLAVE_TCL_PATH=${MAKE_PATH}/src/ZynqPS/
ADDRESS_TABLE_CREATION_PATH=${MAKE_PATH}/os/
SLAVE_DTSI_PATH=${MAKE_PATH}/kernel/

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

#################################################################################
# Clean
#################################################################################
clean_remote:
	@echo "Cleaning up remote files"
	@rm -f ${MAKE_PATH}/os/*_slaves.yaml
	@rm -f ${MAKE_PATH}/kernel/*_slaves.yaml
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ${MAKE_PATH}/cores -type f -name '*.dcp' -delete
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

clean_everything: clean clean_remote clean_CM clean_prebuild

#################################################################################
# Open vivado
#################################################################################

open_project : 
	source $(VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado top.xpr
open_synth : 
	source $(VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_synth.dcp
open_impl : 
	source $(VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_route.dcp
open_hw :
	source $(VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado -source ../$(HW_TCL)


#################################################################################
# FPGA building
#################################################################################
rev1_xc7z035	: 
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

rev2_xc7z035	: 
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

rev1_xc7z045	:
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

rev2_xc7z045	:
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

rev2_xczu7ev	:
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

interactive : 
	source $(VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	cd proj &&\
	vivado -mode tcl

#$(BIT_BASE)%.bit	: 
#$(BIT_BASE)%.bit	: $(ADDSLAVE_TCL_PATH)/AddSlaves_%.tcl $(ADDRESS_TABLE_CREATION_PATH)/slaves_%.yaml $(SLAVE_DTSI_PATH)/slaves_%.yaml
$(BIT_BASE)%.bit	: $(ADDSLAVE_TCL_PATH)/AddSlaves_%.tcl 
	source $(VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) -tclargs ${MAKE_PATH} $(subst .bit,,$(subst ${BIT_BASE},,$@)) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

all-the-things: clean clean_bd clean_kernel clean_bit clean_remote clean_CM clean_prebuild
	cd os     && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	cd kernel && $(MAKE) -f Makefile clean && cd ${MAKE_PATH}
	$(MAKE) init
	$(MAKE) prebuild
	$(MAKE) all
	$(MAKE) pull_cm
	$(MAKE) ${ADDRESS_TABLE}
	cd kernel && $(MAKE) -f Makefile all  && cd ${MAKE_PATH}
	cd os     && $(MAKE) -f Makefile all  && cd ${MAKE_PATH}
#################################################################################         
# Sim     
#################################################################################         
ifneq ("$(wildcard ${MAKE_PATH}/sim/sim.mk)","") 
include ${MAKE_PATH}/sim/sim.mk
endif


init:
	git submodule update --init --recursive 
