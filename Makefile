#################################################################################
# make stuff
#################################################################################
OUTPUT_MARKUP= 2>&1 | tee ../make_log.txt | ccze -A

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"


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

.PHONY: clean list bit

all: bit 


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
clean_os:
	@echo "Clean OS hw files"
	@rm os/hw/*
clean: clean_bd clean_ip clean_bit clean_os
	@rm -rf ./proj/*
	@echo "Cleaning up"
sim_clean :
	@cd sim && rm -rf xsim.dir vhdl webtalk* xelab* xvhdl* *.log *.jou
	@echo cleaning up sim directory


#################################################################################
# Open vivado
#################################################################################

open_project : 
	@source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado top.xpr
open_synth : 
	@source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado post_synth.dcp
open_impl : 
	@source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado post_route.dcp
open_hw :
	@source $(VIVADO_SHELL) &&\
	cd proj &&\
	vivado -source ../$(HW_TCL)


#################################################################################
# FPGA building
#################################################################################
bit	: $(BIT)

interactive : 
	@source $(VIVADO_SHELL) &&\
	mkdir -p proj &&\
	cd proj &&\
	vivado -mode tcl
$(BIT)	:
	@source $(VIVADO_SHELL) &&\
	mkdir -p os/hw &&\
	mkdir -p proj &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source ../$(SETUP_BUILD_TCL) $(OUTPUT_MARKUP)

#################################################################################         
# Sim     
#################################################################################         
build_vdb_list = $(patsubst %.vhd,%.vdb,$(subst src/,sim/vhdl/,$(1)))                                                                                                     
define TB_RULE =    
	set -o pipefail &&\
	source $(VIVADO_SHELL) && \
	cd sim &&\
	xvhdl $@/$@.vhd $(OUTPUT_MARKUP)
	@mkdir -p sim/ && \
	source $(VIVADO_SHELL) &&\
	cd sim &&\
	xelab -debug typical $@ -s $@ $(OUTPUT_MARKUP)      
	source $(VIVADO_SHELL) &&\
	cd sim &&\
	xsim $@ -gui -t $@/setup.tcl    
endef     

#build the vdb file from a vhd file     
sim/vhdl/%.vdb : src/%.vhd    
	@echo "Building $@ from $<"     
	@rm -rf $@
	@mkdir -p sim/vhdl && \
	source $(VIVADO_SHELL) && \
	cd sim &&\
	xvhdl ../$< $(OUTPUT_MARKUP)    
	@cd sim && mkdir -p $(subst src,vhdl,$(dir $<))     
	@cd sim && ln -f -s $(PWD)/sim/xsim.dir/work/$(notdir $@) $(subst src,vhdl,$(dir $<))     

TB_MISC_VDBS=$(call build_vdb_list, src/misc/types.vhd )

TB_CM_PWR_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/CM_interface/CM_pwr.vhd)    
tb_CM_pwr : $(TB_CM_PWR_VDBS)  
	$(TB_RULE)     

TB_IPMC_I2C_SLAVE_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/misc/I2C_reg_master.vhd src/axiReg/axiRegPkg.vhd src/axiReg/axiReg.vhd src/IPMC_i2c_slave/i2c_slave.vhd src/misc/asym_dualport_ram.vhd src/IPMC_i2c_slave/IPMC_i2c_slave.vhd)
tb_IPMC_i2c_slave : $(TB_IPMC_I2C_SLAVE_VDBS)  
	$(TB_RULE)     

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column

