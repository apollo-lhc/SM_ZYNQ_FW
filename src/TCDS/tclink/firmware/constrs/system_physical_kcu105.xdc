#######################################################
###            System clock - Common
#######################################################
# Local 125MHz oscillator
set_property PACKAGE_PIN G10 [get_ports clk_sys_p_i]
set_property IOSTANDARD LVDS [get_ports clk_sys_p_i]
#-----------------------------------------------------

#######################################################
###            40MHz clock - Common
#######################################################
# User SMA clock
set_property PACKAGE_PIN D23 [get_ports clk40_p_i]
set_property IOSTANDARD LVDS [get_ports clk40_p_i]
#-----------------------------------------------------

#######################################################
###                  MASTER
#######################################################
# Common
#-----------------------------------------------------
### MGT Reference clocks
#-----------------------------------------------------
# USER SMA MGT CLOCK
set_property PACKAGE_PIN V6 [get_ports {master_trxrefclk_p_i[0]}]
#-----------------------------------------------------

# ----------------------------------------------------
# ------------------- High-speed ----------------------
#-----------------------------------------------------
### MGT Serial
#-----------------------------------------------------
# FMC HPC CHANNEL 0
set_property PACKAGE_PIN E4 [get_ports {master_rx_p_i[0]}]
# FMC HPC CHANNEL 1
set_property PACKAGE_PIN D2 [get_ports {master_rx_p_i[1]}]
# FMC HPC CHANNEL 2
set_property PACKAGE_PIN B2 [get_ports {master_rx_p_i[2]}]
# FMC HPC CHANNEL 3
set_property PACKAGE_PIN A4 [get_ports {master_rx_p_i[3]}]
# FMC HPC CHANNEL 4
set_property PACKAGE_PIN M2 [get_ports {master_rx_p_i[4]}]
# FMC HPC CHANNEL 5
set_property PACKAGE_PIN H2 [get_ports {master_rx_p_i[5]}]
# FMC HPC CHANNEL 6
set_property PACKAGE_PIN K2 [get_ports {master_rx_p_i[6]}]
# FMC HPC CHANNEL 7
set_property PACKAGE_PIN F2 [get_ports {master_rx_p_i[7]}]

#-----------------------------------------------------
#-----------------------------------------------------
### SAMTEC FMC CONNECTORS
#-----------------------------------------------------
# MODPRS_B
set_property PACKAGE_PIN A13 [get_ports master_firefly_tx_modprs_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_tx_modprs_b_i]
#-----------------------------------------------------
# INT_B
set_property PACKAGE_PIN L12 [get_ports master_firefly_tx_int_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_tx_int_b_i]
#-----------------------------------------------------
# MODSEL_B
set_property PACKAGE_PIN A12 [get_ports master_firefly_tx_modsel_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_tx_modsel_b_o]
#-----------------------------------------------------
# RESET_B
set_property PACKAGE_PIN K12 [get_ports master_firefly_tx_reset_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_tx_reset_b_o]
#-----------------------------------------------------
# MODPRS_B
set_property PACKAGE_PIN K10 [get_ports master_firefly_rx_modprs_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_rx_modprs_b_i]
#-----------------------------------------------------
# INT_B
set_property PACKAGE_PIN H11 [get_ports master_firefly_rx_int_b_i]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_rx_int_b_i]
#-----------------------------------------------------
# MODSEL_B
set_property PACKAGE_PIN G11 [get_ports master_firefly_rx_modsel_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_rx_modsel_b_o]
#-----------------------------------------------------
# RESET_B
set_property PACKAGE_PIN G9 [get_ports master_firefly_rx_reset_b_o]
set_property IOSTANDARD LVCMOS18 [get_ports master_firefly_rx_reset_b_o]
#-----------------------------------------------------
