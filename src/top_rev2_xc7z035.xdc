set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Add overtemperature power down option
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# Set false path to temperature register synchronizer
# Paths coming from registers on AXI clock to synchronizers (first flop) on MIG DDR controller clock


# -------------------------------------------------------------------------------------------------
# PS 3V3  
# -------------------------------------------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[51]}]      #ZynqRevID0
set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[50]}]      #ZynqRevID1
set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[48]}]      #ZynqRevID2

# -------------------------------------------------------------------------------------------------
# PL 3V3  bank 12 & 13
# -------------------------------------------------------------------------------------------------
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W13}                [get_ports I2C_SCL]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y13}                [get_ports I2C_SDA]

set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {ZYNQ_BOOT_DONE}]

set_property -dict {PACKAGE_PIN Y18  IOSTANDARD LVCMOS33}               [get_ports {UART_RX_Zynq}] #alternate, not used by default
set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33}               [get_ports {UART_TX_Zynq}] #alternate, not used by default

set_property -dict {PACKAGE_PIN AD26 IOSTANDARD LVCMOS33}               [get_ports {IPMC_SDA}]
set_property -dict {PACKAGE_PIN AE18 IOSTANDARD LVCMOS33}               [get_ports {IPMC_SCL}]

set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33}               [get_ports {CM1_EN}]
set_property -dict {PACKAGE_PIN AE22 IOSTANDARD LVCMOS33}               [get_ports {CM1_PWR_EN}]
set_property -dict {PACKAGE_PIN  Y10 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_PWR_good}]
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_MON_RX}]
set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_TX}]
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_RX}]
set_property -dict {PACKAGE_PIN AC18 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[0]}]
set_property -dict {PACKAGE_PIN AC21 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[1]}]
set_property -dict {PACKAGE_PIN AC22 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[2]}]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33}               [get_ports {CM1_TCK}]
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33}               [get_ports {CM1_TMS}]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33}               [get_ports {CM1_TDO}]
set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS33}               [get_ports {CM1_TDI}]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM1_PS_RST}]

set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33}               [get_ports {CM2_EN}]
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33}               [get_ports {CM2_PWR_EN}]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM2_PWR_good}]
set_property -dict {PACKAGE_PIN AE23 IOSTANDARD LVCMOS33}               [get_ports {CM2_MON_RX}]
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_TX}]
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_RX}]
set_property -dict {PACKAGE_PIN AF23 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[0]}]
set_property -dict {PACKAGE_PIN AC23 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[1]}]
set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[2]}]
set_property -dict {PACKAGE_PIN Y20  IOSTANDARD LVCMOS33}               [get_ports {CM2_TCK}]
set_property -dict {PACKAGE_PIN V19  IOSTANDARD LVCMOS33}               [get_ports {CM2_TMS}]
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33}               [get_ports {CM2_TDO}]
set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33}               [get_ports {CM2_TDI}]
set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM2_PS_RST}]

								        
set_property -dict {PACKAGE_PIN AD20 IOSTANDARD LVCMOS33}               [get_ports {EEPROM_WE_N}]

set_property -dict {PACKAGE_PIN AF20 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_RST}] #CLK?
set_property -dict {PACKAGE_PIN AF19 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_CLK}] #RST?
set_property -dict {PACKAGE_PIN AD25 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_SDA}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33}               [get_ports {FP_BUTTON}]
							                							                
set_property -dict {PACKAGE_PIN AF18 IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_CLK}]
set_property -dict {PACKAGE_PIN AA24 IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_SDA}]
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_TX}]
set_property -dict {PACKAGE_PIN  W20 IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_RX}]
								        							        
set_property -dict {PACKAGE_PIN AE20 IOSTANDARD LVCMOS33}               [get_ports {LHC_SRC_SEL}]
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_BP_LOS}]
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_OSC_LOS}]
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33}               [get_ports {HQ_SRC_SEL}]
set_property -dict {PACKAGE_PIN AD18 IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_BP_LOS}]
set_property -dict {PACKAGE_PIN AD19 IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_OSC_LOS}]

set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[0]}]   #CPLD CLK pin
set_property -dict {PACKAGE_PIN AD21 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[1]}]
set_property -dict {PACKAGE_PIN AD23 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[2]}]
set_property -dict {PACKAGE_PIN AD24 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[3]}]

# -------------------------------------------------------------------------------------------------
# bank 33 & 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN L4  IOSTANDARD LVDS}                    [get_ports {onboard_CLK_N}]
set_property -dict {PACKAGE_PIN L5  IOSTANDARD LVDS}                    [get_ports {onboard_CLK_P}]
create_clock -period 5.000 -name onboard_CLK_P -add [get_ports onboard_CLK_P]

set_property -dict {PACKAGE_PIN J4   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_P}]
set_property -dict {PACKAGE_PIN J3   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_N}]

set_property -dict {PACKAGE_PIN C8   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_P}]
set_property -dict {PACKAGE_PIN C7   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_N}]

set_property -dict {PACKAGE_PIN G7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_P}]
set_property -dict {PACKAGE_PIN F7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_N}]
set_property -dict {PACKAGE_PIN F5   IOSTANDARD LVDS}                   [get_ports {TTC_P}]
set_property -dict {PACKAGE_PIN E5   IOSTANDARD LVDS}                   [get_ports {TTC_N}]
set_property -dict {PACKAGE_PIN E6   IOSTANDARD LVDS}                   [get_ports {TTS_P}]
set_property -dict {PACKAGE_PIN D5   IOSTANDARD LVDS}                   [get_ports {TTS_N}]

set_property -dict {PACKAGE_PIN B2   IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[0]}]
set_property -dict {PACKAGE_PIN A2   IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[1]}]

set_property -dict {PACKAGE_PIN E8   IOSTANDARD LVCMOS18}               [get_ports {SATA_DETECT_N}]

set_property -dict {PACKAGE_PIN D9   IOSTANDARD LVCMOS18}               [get_ports {CPLD_TCK}]
set_property -dict {PACKAGE_PIN D8   IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDI}]
set_property -dict {PACKAGE_PIN B10  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDO}]
set_property -dict {PACKAGE_PIN A10  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TMS}]

set_property -dict {PACKAGE_PIN B7   IOSTANDARD LVCMOS18}               [get_ports {SI_SDA}]
set_property -dict {PACKAGE_PIN A7   IOSTANDARD LVCMOS18}               [get_ports {SI_SCL}]
set_property -dict {PACKAGE_PIN C9   IOSTANDARD LVCMOS18}               [get_ports {SI_INT}]
set_property -dict {PACKAGE_PIN B9   IOSTANDARD LVCMOS18}               [get_ports {SI_OUT_DIS}]
set_property -dict {PACKAGE_PIN C4   IOSTANDARD LVCMOS18}               [get_ports {SI_ENABLE}]
set_property -dict {PACKAGE_PIN C3   IOSTANDARD LVCMOS18}               [get_ports {SI_LOL}]
set_property -dict {PACKAGE_PIN C2   IOSTANDARD LVCMOS18}               [get_ports {SI_LOS_XAXB}]

set_property -dict {PACKAGE_PIN A4   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[0]}]
set_property -dict {PACKAGE_PIN A3   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[1]}]
set_property -dict {PACKAGE_PIN B5   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[2]}]
set_property -dict {PACKAGE_PIN B4   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[3]}]
set_property -dict {PACKAGE_PIN B6   IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[4]}]
set_property -dict {PACKAGE_PIN A5   IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[5]}]

set_property -dict {PACKAGE_PIN E1   IOSTANDARD LVCMOS18}               [get_ports {GPIO[0]}]
set_property -dict {PACKAGE_PIN F4   IOSTANDARD LVCMOS18}               [get_ports {GPIO[1]}]
set_property -dict {PACKAGE_PIN E2   IOSTANDARD LVCMOS18}               [get_ports {GPIO[2]}]
set_property -dict {PACKAGE_PIN G4   IOSTANDARD LVCMOS18}               [get_ports {GPIO[3]}]
set_property -dict {PACKAGE_PIN E3   IOSTANDARD LVCMOS18}               [get_ports {GPIO[4]}]
set_property -dict {PACKAGE_PIN A8   IOSTANDARD LVCMOS18}               [get_ports {GPIO[5]}]
set_property -dict {PACKAGE_PIN F3   IOSTANDARD LVCMOS18}               [get_ports {GPIO[6]}]
set_property -dict {PACKAGE_PIN A9   IOSTANDARD LVCMOS18}               [get_ports {GPIO[7]}]

set_property -dict {PACKAGE_PIN G2   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[0]}]
set_property -dict {PACKAGE_PIN F2   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[1]}]
set_property -dict {PACKAGE_PIN D1   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[2]}]
set_property -dict {PACKAGE_PIN C1   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[3]}]
set_property -dict {PACKAGE_PIN D4   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[4]}]
set_property -dict {PACKAGE_PIN D3   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[5]}]











# -------------------------------------------------------------------------------------------------
# MGBT (refclks)
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN R6  }  [get_ports refclk_SSD_P]
set_property -dict {PACKAGE_PIN R5  }  [get_ports refclk_SSD_N]

set_property -dict {PACKAGE_PIN U6  }  [get_ports refclk_C2C1_P[0]]
set_property -dict {PACKAGE_PIN U5  }  [get_ports refclk_C2C1_N[0]]

set_property -dict {PACKAGE_PIN W6  }  [get_ports refclk_CMS_P]
set_property -dict {PACKAGE_PIN W5  }  [get_ports refclk_CMS_N]

set_property -dict {PACKAGE_PIN AA6 }  [get_ports refclk_C2C2_P[0]]
set_property -dict {PACKAGE_PIN AA5 }  [get_ports refclk_C2C2_N[0]]


# -------------------------------------------------------------------------------------------------
# MGBT 
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y4  }  [get_ports AXI_C2C_CM1_Rx_P[0]]
set_property -dict {PACKAGE_PIN Y3  }  [get_ports AXI_C2C_CM1_Rx_N[0]]
set_property -dict {PACKAGE_PIN W2  }  [get_ports AXI_C2C_CM1_Tx_P[0]]
set_property -dict {PACKAGE_PIN W1  }  [get_ports AXI_C2C_CM1_Tx_N[0]]
set_property -dict {PACKAGE_PIN AE6 }  [get_ports AXI_C2C_CM1_Rx_P[1]]
set_property -dict {PACKAGE_PIN AE5 }  [get_ports AXI_C2C_CM1_Rx_N[1]]
set_property -dict {PACKAGE_PIN AF4 }  [get_ports AXI_C2C_CM1_Tx_P[1]]
set_property -dict {PACKAGE_PIN AF3 }  [get_ports AXI_C2C_CM1_Tx_N[1]]


set_property -dict {PACKAGE_PIN AB4 }  [get_ports AXI_C2C_CM2_Rx_P[0] ]
set_property -dict {PACKAGE_PIN AB3 }  [get_ports AXI_C2C_CM2_Rx_N[0] ]
set_property -dict {PACKAGE_PIN AA2 }  [get_ports AXI_C2C_CM2_Tx_P[0] ]
set_property -dict {PACKAGE_PIN AA1 }  [get_ports AXI_C2C_CM2_Tx_N[0] ]
set_property -dict {PACKAGE_PIN AD8 }  [get_ports AXI_C2C_CM2_Rx_P[1]]
set_property -dict {PACKAGE_PIN AD7 }  [get_ports AXI_C2C_CM2_Rx_N[1]]
set_property -dict {PACKAGE_PIN AF8 }  [get_ports AXI_C2C_CM2_Tx_P[1]]
set_property -dict {PACKAGE_PIN AF7 }  [get_ports AXI_C2C_CM2_Tx_N[1]]

set_property -dict {PACKAGE_PIN V4  }  [get_ports SSD_Rx_P ]
set_property -dict {PACKAGE_PIN V3  }  [get_ports SSD_Rx_N ]
set_property -dict {PACKAGE_PIN U2  }  [get_ports SSD_Tx_P ]
set_property -dict {PACKAGE_PIN U1  }  [get_ports SSD_Tx_N ]

set_property -dict {PACKAGE_PIN T4  }  [get_ports CM1_TCDS_TTS_P ]
set_property -dict {PACKAGE_PIN T3  }  [get_ports CM1_TCDS_TTS_N ]
set_property -dict {PACKAGE_PIN AD4 }  [get_ports CM2_TCDS_TTS_P]
set_property -dict {PACKAGE_PIN AD3 }  [get_ports CM2_TCDS_TTS_N]
set_property -dict {PACKAGE_PIN R2  }  [get_ports TCDS_TTS_P ]
set_property -dict {PACKAGE_PIN R1  }  [get_ports TCDS_TTS_N ]

set_property -dict {PACKAGE_PIN AC6 }  [get_ports TCDS_TTC_P]
set_property -dict {PACKAGE_PIN AC5 }  [get_ports TCDS_TTC_N]
set_property -dict {PACKAGE_PIN AE2 }  [get_ports LOCAL_TCDS_TTC_P]
set_property -dict {PACKAGE_PIN AE1 }  [get_ports LOCAL_TCDS_TTC_N]















###### -------------------------------------------------------------------------------------------------
###### MIO
###### -------------------------------------------------------------------------------------------------
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[51]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[50]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[49]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[48]}]
#####
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[39]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[38]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[37]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[36]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[35]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[34]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[33]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[32]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[31]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[30]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[29]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[28]}]
#####
#####
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[15]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[14]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[13]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[12]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[11]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[10]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[9]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[8]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[7]}]
#####set_property IOSTANDARD LVCMOS33 [get_ports {FIXED_IO_mio[0]}]









##########set_clock_groups -asynchronous												                                    \
##########		 -group [get_clocks clk_fpga_0      -include_generated_clocks]						                                    \
##########		 		    		    													    \
##########	         -group [get_clocks onboard_CLK_P   -include_generated_clocks] 										    \
##########		 -group [get_clocks SGMII_INTF_1/U0/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i/TXOUTCLK -include_generated_clocks] \
##########		 -group [get_clocks SGMII_INTF_1/U0/transceiver_inst/gtwizard_inst/U0/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i/RXOUTCLK -include_generated_clocks] \
##########		 		    												 			    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt0_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
##########		 		    						     									    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt1_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
##########		 		    						     									    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/RXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/TXOUTCLKFABRIC -include_generated_clocks] 					    \
##########		 -group [get_clocks TCDS_2/LHC_2/U0/LHC_i/gt2_LHC_i/gtxe2_i/TXOUTCLK -include_generated_clocks] 					    \
##########		 		    												 			    \
##########		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK -include_generated_clocks] \
##########		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK -include_generated_clocks] \
##########		 		    																									   \
##########		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_core_i/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK -include_generated_clocks] \
##########		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_core_i/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK -include_generated_clocks] \
##########		 		    																									   \
##########		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/XVC_LOCAL/U0/bs_switch/inst/BSCAN_SWITCH.N_EXT_BSCAN.bscan_inst/SERIES7_BSCAN.bscan_inst/TCK -include_generated_clocks] 
########## 
