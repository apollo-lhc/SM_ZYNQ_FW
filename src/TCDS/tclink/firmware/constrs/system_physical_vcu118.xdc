#######################################################
###            System clock - Common
#######################################################
# Local 125MHz oscillator
set_property PACKAGE_PIN AY24 [get_ports clk_sys_p_i]
set_property IOSTANDARD LVDS [get_ports clk_sys_p_i]
#-----------------------------------------------------

#######################################################
###            40MHz clock - Common
#######################################################
# User SMA clock
set_property PACKAGE_PIN R32 [get_ports clk40_p_i]
set_property IOSTANDARD LVDS [get_ports clk40_p_i]
#-----------------------------------------------------

#######################################################
###                  MASTER
#######################################################
# Common
#-----------------------------------------------------
### MGT Reference clocks
#-----------------------------------------------------
# FMC FSPC GBTCLK0 Connector
set_property PACKAGE_PIN AK38 [get_ports {master_trxrefclk_p_i[0]}]
#-----------------------------------------------------

# ----------------------------------------------------
# ------------------- Channel 0 ----------------------
#-----------------------------------------------------
### MGT Serial
#-----------------------------------------------------
# FMC HSPC DP0
set_property PACKAGE_PIN AR45 [get_ports {master_rx_p_i[0]}]
#-----------------------------------------------------
#-----------------------------------------------------
### SFP connectors
#-----------------------------------------------------
# FMC HSPC LA02-N
set_property PACKAGE_PIN AK32 [get_ports {master_sfp_tx_fault_i[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_tx_fault_i[0]}]
#-----------------------------------------------------
# FMC HSPC LA02-P
set_property PACKAGE_PIN AJ32 [get_ports {master_sfp_los_i[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_los_i[0]}]
#-----------------------------------------------------
# FMC HSPC LA03-N
set_property PACKAGE_PIN AT40 [get_ports {master_sfp_mod_abs_i[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_mod_abs_i[0]}]
#-----------------------------------------------------
# FMC HSPC LA03-P
set_property PACKAGE_PIN AT39 [get_ports {master_sfp_tx_dis_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_tx_dis_o[0]}]
#-----------------------------------------------------
# FMC HSPC LA11-N
set_property PACKAGE_PIN AJ31 [get_ports {master_sfp_rs0_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_rs0_o[0]}]
#-----------------------------------------------------
# FMC HSPC LA11-P
set_property PACKAGE_PIN AJ30 [get_ports {master_sfp_rs1_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_rs1_o[0]}]
#-----------------------------------------------------

# ----------------------------------------------------
# ------------------- Channel 1 ----------------------
#-----------------------------------------------------
### MGT Serial
#-----------------------------------------------------
# FMC HSPC DP0
set_property PACKAGE_PIN AN45 [get_ports {master_rx_p_i[1]}]
#-----------------------------------------------------
#-----------------------------------------------------
### SFP connectors
#-----------------------------------------------------
# FMC HSPC LA05-N
set_property PACKAGE_PIN AR38 [get_ports {master_sfp_tx_fault_i[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_tx_fault_i[1]}]
#-----------------------------------------------------
# FMC HSPC LA05-P
set_property PACKAGE_PIN AP38 [get_ports {master_sfp_los_i[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_los_i[1]}]
#-----------------------------------------------------
# FMC HSPC LA06-N
set_property PACKAGE_PIN AT36 [get_ports {master_sfp_mod_abs_i[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_mod_abs_i[1]}]
#-----------------------------------------------------
# FMC HSPC LA06-P
set_property PACKAGE_PIN AT35 [get_ports {master_sfp_tx_dis_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_tx_dis_o[1]}]
#-----------------------------------------------------
# FMC HSPC LA12-N
set_property PACKAGE_PIN AH34 [get_ports {master_sfp_rs0_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_rs0_o[1]}]
#-----------------------------------------------------
# FMC HSPC LA12-P
set_property PACKAGE_PIN AH33 [get_ports {master_sfp_rs1_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {master_sfp_rs1_o[1]}]
#-----------------------------------------------------

#######################################################
###                  SLAVE
#######################################################

#-----------------------------------------------------
### MGT Reference clocks
#-----------------------------------------------------
# SMA Connector
set_property PACKAGE_PIN J9 [get_ports slave_txrefclk_p_i]
#-----------------------------------------------------
# Local programmable oscillator SI570 (MGT_SI570_CLOCK3)
set_property PACKAGE_PIN L9 [get_ports slave_rxrefclk_p_i]
#-----------------------------------------------------

#-----------------------------------------------------
### MGT Serial
#-----------------------------------------------------
# FIREFLY_1
set_property PACKAGE_PIN K2 [get_ports slave_rx_p_i]
#-----------------------------------------------------

#-----------------------------------------------------
### Recovered clock
#-----------------------------------------------------
# User SMA clock
set_property IOSTANDARD LVDS [get_ports slave_clk40_p_o]
set_property PACKAGE_PIN AL35 [get_ports slave_clk40_p_o]
#-----------------------------------------------------

#-----------------------------------------------------
### Firefly connectors
#-----------------------------------------------------
# MODPRS_B
set_property PACKAGE_PIN BD22 [get_ports slave_firefly_modprs_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports slave_firefly_modprs_b_i]
#-----------------------------------------------------
# INT_B
set_property PACKAGE_PIN BF24 [get_ports slave_firefly_int_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports slave_firefly_int_b_i]
#-----------------------------------------------------
# MODSEL_B
set_property PACKAGE_PIN BC23 [get_ports slave_firefly_modsel_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports slave_firefly_modsel_b_o]
#-----------------------------------------------------
# RESET_B
set_property PACKAGE_PIN BE24 [get_ports slave_firefly_reset_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports slave_firefly_reset_b_o]
#-----------------------------------------------------

######################################################
###                  ILA
######################################################

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk40_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {prbschk_master_error[0]} {prbschk_master_error[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {prbschk_master_locked[0]} {prbschk_master_locked[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {prbschk_master_reset[0]} {prbschk_master_reset[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {prbsgen_master_data_valid[0]} {prbsgen_master_data_valid[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list prbschk_slave_error]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list prbschk_slave_locked]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list prbschk_slave_reset]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list prbsgen_slave_data_valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys_BUFG]
