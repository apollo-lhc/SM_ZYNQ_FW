
#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL?="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"

sim_clean :
	@cd sim && rm -rf xsim.dir vhdl webtalk* xelab* xvhdl* *.log *.jou
	@echo cleaning up sim directory

#################################################################################         
# Sim     
#################################################################################         
build_vdb_list = $(patsubst %.vhd,%.vdb,$(subst src/,sim/vhdl/,$(1)))
USE_GUI=-gui

define TB_RULE =    
	@rm -f tb_out.txt
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
	xsim $@ -t $@/setup.tcl $(USE_GUI)
	@md5sum -c sim/$@/golden_md5sum.txt
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

IPCORES=$(foreach  file,$(shell find ./cores | grep "netlist.vhdl"),../$(file))

TB_IPCORES :
	@echo "Building sim files for IPCores"
	source $(VIVADO_SHELL) && \
	cd sim && \
	xvhdl $(IPCORES)


TB_MISC_VDBS=$(call build_vdb_list, src/misc/types.vhd src/misc/pacd.vhd src/misc/DC_data_CDC.vhd src/misc/data_CDC.vhd src/misc/counter.vhd src/misc/capture_CDC.vhd)

TB_CM_PWR_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/CM_interface/CM_pwr.vhd)    
tb_CM_pwr : $(TB_CM_PWR_VDBS)  
	$(TB_RULE)     
test_CM_pwr : $(TB_CM_PWR_VDBS)
	$(MAKE) tb_CM_pwr USE_GUI="-onfinish quit -t ./quit.tcl"


TB_IPMC_I2C_SLAVE_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/misc/I2C_reg_master.vhd src/axiReg/axiRegPkg.vhd src/axiReg/axiReg.vhd src/IPMC_i2c_slave/i2c_slave.vhd src/misc/asym_dualport_ram.vhd src/misc/counter.vhd src/IPMC_i2c_slave/IPMC_i2c_slave.vhd)
tb_IPMC_i2c_slave : $(TB_IPMC_I2C_SLAVE_VDBS)  
	$(TB_RULE)     
test_IPMC_i2c_slave : $(TB_IPMC_I2C_SLAVE_VDBS)
	$(MAKE) tb_IPMC_i2c_slave USE_GUI="-onfinish quit -t ./quit.tcl"


TB_AXI_HELPERS_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/axiReg/axiRegPkg.vhd src/axiReg/axiRegMaster.vhd src/axiReg/axiReg.vhd)    
tb_axi_helpers : $(TB_AXI_HELPERS_VDBS)
	$(TB_RULE)     
test_axi_helpers : $(TB_AXI_HELPERS_VDBS)
	$(MAKE) tb_axi_helpers USE_GUI="-onfinish quit -t ./quit.tcl"


TB_CM_MONITOR_VDBS=$(TB_MISC_VDBS) $(TB_IPMC_I2C_SLAVE_VDBS) $(call build_vdb_list, src/axiReg/axiRegPkg.vhd src/axiReg/axiRegMaster.vhd src/axiReg/axiReg.vhd src/misc/uart_rx6.vhd src/misc/uart_tx6.vhd src/CM_interface/CM_Monitoring.vhd)    
tb_cm_monitor : $(TB_CM_MONITOR_VDBS)
	$(TB_RULE)     
test_cm_monitor : $(TB_CM_MONITOR_VDBS)
	$(MAKE) tb_cm_monitor USE_GUI="-onfinish quit -t ./quit.tcl"

TB_TCDS_MONITOR_VDBS=$(TB_MISC_VDBS) $(call build_vdb_list, src/TCDS/TCDS_Monitor.vhd)    
tb_TCDS_Monitor : $(TB_TCDS_MONITOR_VDBS)
	$(TB_RULE)     
test_TCDS_Monitor : $(TB_TCDS_MONITOR_VDBS)
	$(MAKE) tb_TCDS_Monitor USE_GUI="-onfinish quit -t ./quit.tcl"

TB_AXIREG_VDBS=$(call build_vdb_list, src/axiReg/axiRegPkg.vhd src/axiReg/axiReg.vhd src/axiReg/axiRegMaster.vhd)    

TB_TCDS_VDBS=TB_IPCORES $(TB_TCDS_MONITOR_VDBS) $(TB_AXIREG_VDBS) $(call build_vdb_list, src/misc/types.vhd src/TCDS/TCDS_PKG.vhd src/TCDS/TCDS_map.vhd src/TCDS/TCDS_Control.vhd src/TCDS/lhc_clock_module.vhd src/TCDS/lhc_gt_usrclk_source.vhd src/TCDS/lhc_support.vhd src/TCDS/MGBT2_common_reset.vhd src/TCDS/MGBT2_common.vhd src/TCDS/TCDS.vhd)    
tb_TCDS : $(TB_TCDS_VDBS)
	$(TB_RULE)     
test_TCDS : $(TB_TCDS_VDBS)
	$(MAKE) tb_TCDS USE_GUI="-onfinish quit -t ./quit.tcl"

TB_PHY_LANE_CONTROL_VDBS=$(call build_vdb_list, src/misc/types.vhd src/misc/counter.vhd src/CM_interface/CM_phy_lane_control.vhd)
tb_phy_lane_control : $(TB_PHY_LANE_CONTROL_VDBS)
	$(TB_RULE)
test_phy_lane_control : $(TB_PHY_LANE_CONTROL_VDBS)
	$(MAKE) tb_phy_lane_control USE_GUI="-onfinish quit -t ./quit.tcl"

