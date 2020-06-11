set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Add overtemperature power down option
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# Set false path to temperature register synchronizer
# Paths coming from registers on AXI clock to synchronizers (first flop) on MIG DDR controller clock


#VHDL version
#set_false_path -from [get_pins {i_system/xadc_wiz_0/U0/AXI_XADC_CORE_I/temperature_update_inst/temp_out_reg[*]/C}] -to [get_pins {i_system/SDRAM/u_MercuryZX1_SDRAM_0_mig/temp_mon_enabled.u_tempmon/device_temp_sync_r1_reg[*]/D}]

# -------------------------------------------------------------------------------------------------
# MIO
# -------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[51]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[50]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[49]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[48]}]

set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[39]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[38]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[37]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[36]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[35]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[34]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[33]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[32]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[28]}]


set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[0]}]


set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W13} [get_ports I2C_SCL]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y13} [get_ports I2C_SDA]

# -------------------------------------------------------------------------------------------------
# bank 12 & 13
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33} [get_ports {CM1_enable}]
set_property -dict {PACKAGE_PIN AE22 IOSTANDARD LVCMOS33} [get_ports {CM1_PWR_enable}]
set_property -dict {PACKAGE_PIN  Y10 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_PWR_good}]
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_GPIO[0]}]
set_property -dict {PACKAGE_PIN AC18 IOSTANDARD LVCMOS33} [get_ports {CM1_GPIO[1]}]
set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVCMOS33} [get_ports {CM1_UART_TX}]
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33} [get_ports {CM1_UART_RX}]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports {CM1_tck}]
set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS33} [get_ports {CM1_tdi}]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports {CM1_tdo}]
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports {CM1_tms}]

set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33} [get_ports {CM2_enable}]
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33} [get_ports {CM2_PWR_enable}]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM2_PWR_good}]
set_property -dict {PACKAGE_PIN AE23 IOSTANDARD LVCMOS33} [get_ports {CM2_GPIO[0]}]
set_property -dict {PACKAGE_PIN AF23 IOSTANDARD LVCMOS33} [get_ports {CM2_GPIO[1]}]
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33} [get_ports {CM2_UART_TX}]
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS33} [get_ports {CM2_UART_RX}]
set_property -dict {PACKAGE_PIN Y20  IOSTANDARD LVCMOS33} [get_ports {CM2_tck}]
set_property -dict {PACKAGE_PIN W18  IOSTANDARD LVCMOS33} [get_ports {CM2_tdi}]
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33} [get_ports {CM2_tdo}]
set_property -dict {PACKAGE_PIN V19  IOSTANDARD LVCMOS33} [get_ports {CM2_tms}]

set_property -dict {PACKAGE_PIN AD26 IOSTANDARD LVCMOS33} [get_ports {IPMC_SDA}]
set_property -dict {PACKAGE_PIN AE18 IOSTANDARD LVCMOS33} [get_ports {IPMC_SCL}]



set_property -dict {PACKAGE_PIN AE21  IOSTANDARD LVCMOS33} [get_ports {LHC_CLK_CMS_LOS   }]
set_property -dict {PACKAGE_PIN AB26  IOSTANDARD LVCMOS33} [get_ports {LHC_CLK_OSC_LOS   }]
set_property -dict {PACKAGE_PIN AE20  IOSTANDARD LVCMOS33} [get_ports {LHC_SRC_SEL       }]
set_property -dict {PACKAGE_PIN AD18  IOSTANDARD LVCMOS33} [get_ports {HQ_CLK_CMS_LOS    }]
set_property -dict {PACKAGE_PIN AD19  IOSTANDARD LVCMOS33} [get_ports {HQ_CLK_OSC_LOS    }]
set_property -dict {PACKAGE_PIN AC26  IOSTANDARD LVCMOS33} [get_ports {HQ_SRC_SEL        }]
#set_property -dict {PACKAGE_PIN AF19  IOSTANDARD LVCMOS33} [get_ports {FP_LED_RST        }]
#set_property -dict {PACKAGE_PIN AF20  IOSTANDARD LVCMOS33} [get_ports {FP_LED_CLK        }]
set_property -dict {PACKAGE_PIN AF20  IOSTANDARD LVCMOS33} [get_ports {FP_LED_RST        }]
set_property -dict {PACKAGE_PIN AF19  IOSTANDARD LVCMOS33} [get_ports {FP_LED_CLK        }]
set_property -dict {PACKAGE_PIN AD25  IOSTANDARD LVCMOS33} [get_ports {FP_LED_SDA        }]
set_property -dict {PACKAGE_PIN AB20  IOSTANDARD LVCMOS33} [get_ports {FP_switch         }]

set_property -dict {PACKAGE_PIN AF18  IOSTANDARD LVCMOS33} [get_ports {ESM_LED_CLK       }]
set_property -dict {PACKAGE_PIN AA24  IOSTANDARD LVCMOS33} [get_ports {ESM_LED_SDA       }]
set_property -dict {PACKAGE_PIN AA23  IOSTANDARD LVCMOS33} [get_ports {ESM_UART_TX       }]
set_property -dict {PACKAGE_PIN  W20  IOSTANDARD LVCMOS33} [get_ports {ESM_UART_RX       }]


# -------------------------------------------------------------------------------------------------
# bank 33
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN L4  IOSTANDARD LVDS}     [get_ports {onboard_CLK_N}]
set_property -dict {PACKAGE_PIN L5  IOSTANDARD LVDS}     [get_ports {onboard_CLK_P}]
create_clock -period 5.000 -name onboard_CLK_P -add [get_ports onboard_CLK_P]

# -------------------------------------------------------------------------------------------------
# bank 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN F9  IOSTANDARD LVCMOS18} [get_ports {TTC_SRC_SEL       }]

set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS18} [get_ports {SI_sda}]
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS18} [get_ports {SI_scl}]
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS18} [get_ports {SI_INT    }]
set_property -dict {PACKAGE_PIN C3  IOSTANDARD LVCMOS18} [get_ports {SI_LOL    }]
set_property -dict {PACKAGE_PIN C2  IOSTANDARD LVCMOS18} [get_ports {SI_LOS    }]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS18} [get_ports {SI_OUT_DIS}]
set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS18} [get_ports {SI_ENABLE }]


# -------------------------------------------------------------------------------------------------
# fast ethernet
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN W6 }  [get_ports refclk_125Mhz_P]
set_property -dict {PACKAGE_PIN W5 }  [get_ports refclk_125Mhz_N]
set_property -dict {PACKAGE_PIN AA6}  [get_ports refclk_TCDS_P]
set_property -dict {PACKAGE_PIN AA5}  [get_ports refclk_TCDS_N]
#				   
set_property -dict {PACKAGE_PIN AF8}  [get_ports sgmii_tx_P]
set_property -dict {PACKAGE_PIN AF7}  [get_ports sgmii_tx_N]
set_property -dict {PACKAGE_PIN AD8}  [get_ports sgmii_rx_P]
set_property -dict {PACKAGE_PIN AD7}  [get_ports sgmii_rx_N]
#				   
set_property -dict {PACKAGE_PIN AF4}  [get_ports tts_P]
set_property -dict {PACKAGE_PIN AF3}  [get_ports tts_N]
set_property -dict {PACKAGE_PIN AE6}  [get_ports ttc_P]
set_property -dict {PACKAGE_PIN AE5}  [get_ports ttc_N]
				   
set_property -dict {PACKAGE_PIN AE2}  [get_ports fake_ttc_P]
set_property -dict {PACKAGE_PIN AE1}  [get_ports fake_ttc_N]
set_property -dict {PACKAGE_PIN AC6}  [get_ports m1_tts_P]
set_property -dict {PACKAGE_PIN AC5}  [get_ports m1_tts_N]
				   
set_property -dict {PACKAGE_PIN AD4}  [get_ports m2_tts_P]
set_property -dict {PACKAGE_PIN AD3}  [get_ports m2_tts_N]



# -------------------------------------------------------------------------------------------------
# axi c2c
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN  R6}  [get_ports refclk_C2C_P[0] ]
set_property -dict {PACKAGE_PIN  R5}  [get_ports refclk_C2C_N[0] ]
#set_property -dict {PACKAGE_PIN  U6}  [get_ports refclk_C2C_P[0] ]
#set_property -dict {PACKAGE_PIN  U5}  [get_ports refclk_C2C_N[0] ]

set_property -dict {PACKAGE_PIN U2}  [get_ports AXI_C2C_CM1_Tx_P[0] ]
set_property -dict {PACKAGE_PIN U1}  [get_ports AXI_C2C_CM1_Tx_N[0] ]
set_property -dict {PACKAGE_PIN V4}  [get_ports AXI_C2C_CM1_Rx_P[0] ]
set_property -dict {PACKAGE_PIN V3}  [get_ports AXI_C2C_CM1_Rx_N[0] ]

set_property -dict {PACKAGE_PIN R2}  [get_ports AXI_C2C_CM1_Tx_P[1] ]
set_property -dict {PACKAGE_PIN R1}  [get_ports AXI_C2C_CM1_Tx_N[1] ]
set_property -dict {PACKAGE_PIN T4}  [get_ports AXI_C2C_CM1_Rx_P[1] ]
set_property -dict {PACKAGE_PIN T3}  [get_ports AXI_C2C_CM1_Rx_N[1] ]

set_property -dict {PACKAGE_PIN AA2}  [get_ports AXI_C2C_CM2_Tx_P[0] ]
set_property -dict {PACKAGE_PIN AA1}  [get_ports AXI_C2C_CM2_Tx_N[0] ]
set_property -dict {PACKAGE_PIN AB4}  [get_ports AXI_C2C_CM2_Rx_P[0] ]
set_property -dict {PACKAGE_PIN AB3}  [get_ports AXI_C2C_CM2_Rx_N[0] ]

set_property -dict {PACKAGE_PIN W2}  [get_ports AXI_C2C_CM2_Tx_P[1] ]
set_property -dict {PACKAGE_PIN W1}  [get_ports AXI_C2C_CM2_Tx_N[1] ]
set_property -dict {PACKAGE_PIN Y4}  [get_ports AXI_C2C_CM2_Rx_P[1] ]
set_property -dict {PACKAGE_PIN Y3}  [get_ports AXI_C2C_CM2_Rx_N[1] ]





set_clock_groups -asynchronous												                                    \
		 -group [get_clocks clk_fpga_0      -include_generated_clocks]						                                    \
		 		    		    													    \
	         -group [get_clocks onboard_CLK_P   -include_generated_clocks] 										    \
		 -group [get_clocks SGMII_INTF_1/U0/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i/TXOUTCLK -include_generated_clocks] \
		 -group [get_clocks SGMII_INTF_1/U0/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i/RXOUTCLK -include_generated_clocks] \
		 		    												 			    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
		 		    						     									    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
		 		    						     									    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
		 		    												 			    \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK -include_generated_clocks] \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK -include_generated_clocks] \
		 		    																									   \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_core_i/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK -include_generated_clocks] \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_core_i/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK -include_generated_clocks] \
		 		    																									   \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/XVC_LOCAL/U0/bs_switch/inst/BSCAN_SWITCH.N_EXT_BSCAN.bscan_inst/SERIES7_BSCAN.bscan_inst/TCK -include_generated_clocks] 
 
