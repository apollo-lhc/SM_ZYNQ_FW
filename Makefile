#################################################################################
# make stuff
#################################################################################
SHELL=/bin/bash -o pipefail
OUTPUT_MARKUP= 2>&1 | tee ../make_log.txt | ccze -A
SLACK_MESG ?= echo

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL?="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"



#################################################################################
# TCL scripts
#################################################################################
SETUP_TCL=scripts/Setup.tcl
BUILD_TCL=scripts/Build.tcl
SETUP_BUILD_TCL=scripts/SetupAndBuild.tcl
HW_TCL=scripts/Run_hw.tcl



#################################################################################
# Source files
#################################################################################
PL_PATH=../src
BD_PATH=../bd
CORES_PATH=../cores


#################################################################################
# Short build names
#################################################################################

BIT=./bit/top.bit

.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init

all:
	$(MAKE) bit || $(MAKE) NOTIFY_DAN_BAD

#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE=src/slaves.yaml
ADDSLAVE_TCL_PATH=src/c2cSlave/
ADDRESS_TABLE_CREATION_PATH=os/
SLAVE_DTSI_PATH=kernel/

ifneq ("$(wildcard mk/preBuild.mk)","")
  include mk/preBuild.mk
endif

#################################################################################
# Clean
#################################################################################
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ./cores -type f -name '*.dcp' -delete
clean_bd:
	@echo "Cleaning up bd generated files"
	@rm -rf ./bd/zynq_bd
	@rm -rf ./bd/c2cSlave
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf $(BIT)
clean_kernel:
	@echo "Clean hw files"
	@rm -f kernel/hw/*
clean: clean_bd clean_ip clean_bit clean_kernel
	@rm -rf ./proj/*
	@echo "Cleaning up"


#################################################################################
# Open vivado
#################################################################################

open_project : 
	source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado top.xpr
open_synth : 
	source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado post_synth.dcp
open_impl : 
	source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado post_route.dcp
open_hw :
	source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado -source ../$(HW_TCL)

#################################################################################
# Slack notifications
#################################################################################
NOTIFY_DAN_GOOD:
	${SLACK_MESG} "FINISHED building FW!"
NOTIFY_DAN_BAD:
	${SLACK_MESG} "FAILED to build FW!"

#################################################################################
# prebuild 
#################################################################################
prebuild: $(SLAVE_DEF_FILE)
	./scripts/preBuild.py   -s $(SLAVE_DEF_FILE) \
				-t $(ADDSLAVE_TCL_PATH) \
				-a $(ADDRESS_TABLE_CREATION_PATH) \
				-d $(SLAVE_DTSI_PATH)

$(ADDSLAVE_TCL_PATH)/AddSlaves.tcl $(ADDRESS_TABLE_CREATION_PATH)/slaves.yaml $(SLAVE_DTSI_PATH)/slaves.yaml: prebuild


#################################################################################
# FPGA building
#################################################################################
bit	:
	time $(MAKE) $(BIT) || $(MAKE) NOTIFY_DAN_BAD

interactive : 
	source $(VIVADO_SHELL) &&\
	mkdir -p proj &&\
	cd proj &&\
	vivado -mode tcl
$(BIT)	:
	source $(VIVADO_SHELL) &&\
	mkdir -p kernel/hw &&\
	mkdir -p proj &&\
	mkdir -p bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source ../$(SETUP_BUILD_TCL) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD

#################################################################################         
# Sim     
#################################################################################         
ifneq ("$(wildcard sim/sim.mk)","") 
include sim/sim.mk
endif



################################################################################# 
# Generate MAP and PKG files from address table 
################################################################################# 
XML2VHD_PATH=regmap_helper
ifneq ("$(wildcard $(XML2VHD_PATH)/xml_regmap.mk)","") 
	include $(XML2VHD_PATH)/xml_regmap.mk
endif

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column

init:
	git submodule update --init --recursive 
