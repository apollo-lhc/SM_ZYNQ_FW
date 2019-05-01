set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Add overtemperature power down option
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# Set false path to temperature register synchronizer
# Paths coming from registers on AXI clock to synchronizers (first flop) on MIG DDR controller clock


#VHDL version
set_false_path -from [get_pins {i_system/xadc_wiz_0/U0/AXI_XADC_CORE_I/temperature_update_inst/temp_out_reg[*]/C}] -to [get_pins {i_system/SDRAM/u_MercuryZX1_SDRAM_0_mig/temp_mon_enabled.u_tempmon/device_temp_sync_r1_reg[*]/D}]


# -------------------------------------------------------------------------------------------------
# bank 12
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# bank 33
# -------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN L5 [get_ports CLK200_P]
#set_property PACKAGE_PIN L4 [get_ports CLK200_N]
#set_property IOSTANDARD LVDS [get_ports CLK200_N]
#set_property IOSTANDARD LVDS [get_ports CLK200_P]

# -------------------------------------------------------------------------------------------------
# bank 34
# -------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN G9 [get_ports DDR3_reset_n]
#set_property IOSTANDARD LVCMOS18 [get_ports DDR3_reset_n]
#
#set_property PACKAGE_PIN K11 [get_ports ETH0_INT_N_PL]
#set_property IOSTANDARD LVCMOS18 [get_ports ETH0_INT_N_PL]


# -------------------------------------------------------------------------------------------------
# fast ethernet
# -------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN W6   [get_ports refclk_125Mhz_P]
set_property PACKAGE_PIN W5   [get_ports refclk_125Mhz_N]
set_property PACKAGE_PIN AA6  [get_ports refclk_TCDS_P]
set_property PACKAGE_PIN AA5  [get_ports refclk_TCDS_N]

set_property PACKAGE_PIN AF8  [get_ports sgmii_tx_P]
set_property PACKAGE_PIN AF7  [get_ports sgmii_tx_N]
set_property PACKAGE_PIN AD8  [get_ports sgmii_rx_P]
set_property PACKAGE_PIN AD7  [get_ports sgmii_rx_N]

set_property PACKAGE_PIN AF4  [get_ports tts_P]
set_property PACKAGE_PIN AF3  [get_ports tts_N]
set_property PACKAGE_PIN AE6  [get_ports ttc_P]
set_property PACKAGE_PIN AE5  [get_ports ttc_N]

set_property PACKAGE_PIN AE2  [get_ports fake_ttc_P]
set_property PACKAGE_PIN AE1  [get_ports fake_ttc_N]
set_property PACKAGE_PIN AC6  [get_ports m1_tts_P]
set_property PACKAGE_PIN AC5  [get_ports m1_tts_N]

set_property PACKAGE_PIN AD4  [get_ports m2_tts_P]
set_property PACKAGE_PIN AD3  [get_ports m2_tts_N]


# -------------------------------------------------------------------------------------------------
# fast ethernet
# -------------------------------------------------------------------------------------------------

# set_property PACKAGE_PIN W14 [get_ports ETH1_CLK]
# set_property PACKAGE_PIN W17 [get_ports ETH1_INT_PWDN_N]
# set_property PACKAGE_PIN AD14 [get_ports ETH1_MDC]
# set_property PACKAGE_PIN AD11 [get_ports ETH1_MDIO]
# set_property PACKAGE_PIN AF14 [get_ports ETH1_RESET_N]
# set_property PACKAGE_PIN J11 [get_ports ETH1A_COL_PL]
# set_property PACKAGE_PIN G6 [get_ports ETH1A_CRS_PL]
#set_property PACKAGE_PIN J10 [get_ports ETH1A_LED_N_PL]
# set_property PACKAGE_PIN AC13 [get_ports ETH1A_RXCLK]
# set_property PACKAGE_PIN AE12 [get_ports {ETH1A_RXD[0]}]
# set_property PACKAGE_PIN AF12 [get_ports {ETH1A_RXD[1]}]
# set_property PACKAGE_PIN AE11 [get_ports {ETH1A_RXD[2]}]
# set_property PACKAGE_PIN AF10 [get_ports {ETH1A_RXD[3]}]
# set_property PACKAGE_PIN AE13 [get_ports ETH1A_RXDV]
# set_property PACKAGE_PIN AF13 [get_ports ETH1A_RXER]
# set_property PACKAGE_PIN AC12 [get_ports ETH1A_TXCLK]
# set_property PACKAGE_PIN AB12 [get_ports {ETH1A_TXD[0]}]
# set_property PACKAGE_PIN AC11 [get_ports {ETH1A_TXD[1]}]
# set_property PACKAGE_PIN AB11 [get_ports {ETH1A_TXD[2]}]
# set_property PACKAGE_PIN AB10 [get_ports {ETH1A_TXD[3]}]
# set_property PACKAGE_PIN AE10 [get_ports ETH1A_TXEN]
# set_property PACKAGE_PIN H11 [get_ports ETH1B_COL_PL]
# set_property PACKAGE_PIN G5 [get_ports ETH1B_CRS_PL]
#set_property PACKAGE_PIN J9 [get_ports ETH1B_LED_N_PL]
# set_property PACKAGE_PIN AC14 [get_ports ETH1B_RXCLK]
# set_property PACKAGE_PIN AF15 [get_ports {ETH1B_RXD[0]}]
# set_property PACKAGE_PIN AE15 [get_ports {ETH1B_RXD[1]}]
# set_property PACKAGE_PIN AD15 [get_ports {ETH1B_RXD[2]}]
# set_property PACKAGE_PIN AE16 [get_ports {ETH1B_RXD[3]}]
# set_property PACKAGE_PIN AD13 [get_ports ETH1B_RXDV]
# set_property PACKAGE_PIN AB14 [get_ports ETH1B_RXER]
# set_property PACKAGE_PIN AB15 [get_ports ETH1B_TXCLK]
# set_property PACKAGE_PIN AD16 [get_ports {ETH1B_TXD[0]}]
# set_property PACKAGE_PIN AE17 [get_ports {ETH1B_TXD[1]}]
# set_property PACKAGE_PIN AA17 [get_ports {ETH1B_TXD[2]}]
# set_property PACKAGE_PIN Y17 [get_ports {ETH1B_TXD[3]}]
# set_property PACKAGE_PIN AF17 [get_ports ETH1B_TXEN]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1_CLK]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1_INT_PWDN_N]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1_MDC]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1_MDIO]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1_RESET_N]
# set_property IOSTANDARD LVCMOS18 [get_ports ETH1A_COL_PL]
# set_property IOSTANDARD LVCMOS18 [get_ports ETH1A_CRS_PL]
#set_property IOSTANDARD LVCMOS18 [get_ports ETH1A_LED_N_PL]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1A_RXCLK]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_RXD[0]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_RXD[1]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_RXD[2]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_RXD[3]}]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1A_RXDV]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1A_RXER]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1A_TXCLK]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_TXD[0]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_TXD[1]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_TXD[2]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1A_TXD[3]}]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1A_TXEN]
# set_property IOSTANDARD LVCMOS18 [get_ports ETH1B_COL_PL]
# set_property IOSTANDARD LVCMOS18 [get_ports ETH1B_CRS_PL]
#set_property IOSTANDARD LVCMOS18 [get_ports ETH1B_LED_N_PL]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1B_RXCLK]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_RXD[0]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_RXD[1]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_RXD[2]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_RXD[3]}]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1B_RXDV]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1B_RXER]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1B_TXCLK]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_TXD[0]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_TXD[1]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_TXD[2]}]
# set_property IOSTANDARD LVCMOS25 [get_ports {ETH1B_TXD[3]}]
# set_property IOSTANDARD LVCMOS25 [get_ports ETH1B_TXEN]


# -------------------------------------------------------------------------------------------------
# module internal
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# timing constraints
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# eof
# -------------------------------------------------------------------------------------------------
