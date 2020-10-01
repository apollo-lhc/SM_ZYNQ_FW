#################################################################################
# make stuff
#################################################################################
SHELL=/bin/bash -o pipefail
OUTPUT_MARKUP= 2>&1 | tee ../make_log.txt | ccze -A
SLACK_MESG ?= echo
#add path so build can be more generic
MAKE_PATH := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL?="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"


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
ADDRESS_TABLE = os/address_table/address_apollo.xml


#################################################################################
# Short build names
#################################################################################

BIT=${MAKE_PATH}/bit/top.bit

.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init

all:
	$(MAKE) bit || $(MAKE) NOTIFY_DAN_BAD

#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE=${MAKE_PATH}/src/slaves.yaml
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
# Slack notifications
#################################################################################
NOTIFY_DAN_GOOD:
	${SLACK_MESG} "FINISHED building FW!"
NOTIFY_DAN_BAD:
	${SLACK_MESG} "FAILED to build FW!"



#################################################################################
# FPGA building
#################################################################################
bit	:
	time $(MAKE) $(BIT) || $(MAKE) NOTIFY_DAN_BAD

interactive : 
	source $(VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	cd proj &&\
	vivado -mode tcl
$(BIT)	:
	source $(VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

all-the-things: clean clean_ip clean_bd clean_kernel clean_bit clean_remote clean_CM clean_prebuild
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



################################################################################# 
# Generate MAP and PKG files from address table 
################################################################################# 
#XML2VHD_PATH=regmap_helper
#ifneq ("$(wildcard $(XML2VHD_PATH)/xml_regmap.mk)","") 
#	include $(XML2VHD_PATH)/xml_regmap.mk
#endif

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column

init:
	git submodule update --init --recursive 
