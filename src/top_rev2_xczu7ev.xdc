#set_property CFGBVS VCCO [current_design]
#set_property CONFIG_VOLTAGE 3.3 [current_design]

# Add overtemperature power down option
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# Set false path to temperature register synchronizer
# Paths coming from registers on AXI clock to synchronizers (first flop) on MIG DDR controller clock


set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]



# -------------------------------------------------------------------------------------------------
# PS 3V3  
# -------------------------------------------------------------------------------------------------
#set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[45]}]      #ZynqRevID0
#set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[44]}]      #ZynqRevID1
#set_property -dict {IOSTANDARD LVCMOS33 PULLUP TRUE}                    [get_ports {FIXED_IO_mio[42]}]      #ZynqRevID2

# -------------------------------------------------------------------------------------------------
# PL 3V3  bank 12 & 13
# -------------------------------------------------------------------------------------------------
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB13}                [get_ports I2C_SCL] #mio
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AH13}                [get_ports I2C_SDA] #mio

set_property -dict {PACKAGE_PIN B15  IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {ZYNQ_BOOT_DONE}]

set_property -dict {PACKAGE_PIN F16  IOSTANDARD LVCMOS33}               [get_ports {UART_RX_Zynq}] #alternate, not used by default
set_property -dict {PACKAGE_PIN F15  IOSTANDARD LVCMOS33}               [get_ports {UART_TX_Zynq}] #alternate, not used by default

set_property -dict {PACKAGE_PIN C12  IOSTANDARD LVCMOS33}               [get_ports {IPMC_SDA}]
set_property -dict {PACKAGE_PIN D12  IOSTANDARD LVCMOS33}               [get_ports {IPMC_SCL}]

set_property -dict {PACKAGE_PIN E13  IOSTANDARD LVCMOS33}               [get_ports {CM1_EN}]
set_property -dict {PACKAGE_PIN J16  IOSTANDARD LVCMOS33}               [get_ports {CM1_PWR_EN}]
#LVCMOS12, but has level shifters on SoM for conn-A VCCIO)
set_property -dict {PACKAGE_PIN AF17 IOSTANDARD LVCMOS12 PULLDOWN TRUE} [get_ports {CM1_PWR_good}]
set_property -dict {PACKAGE_PIN H16  IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_MON_RX}]
set_property -dict {PACKAGE_PIN C14  IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_TX}]
set_property -dict {PACKAGE_PIN B14  IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_RX}]
set_property -dict {PACKAGE_PIN J15  IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[0]}]
set_property -dict {PACKAGE_PIN G13  IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[1]}]
set_property -dict {PACKAGE_PIN F13  IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[2]}]
set_property -dict {PACKAGE_PIN K15  IOSTANDARD LVCMOS33}               [get_ports {CM1_TCK}]
set_property -dict {PACKAGE_PIN K14  IOSTANDARD LVCMOS33}               [get_ports {CM1_TMS}]
set_property -dict {PACKAGE_PIN K12  IOSTANDARD LVCMOS33}               [get_ports {CM1_TDO}]
set_property -dict {PACKAGE_PIN K11  IOSTANDARD LVCMOS33}               [get_ports {CM1_TDI}]
set_property -dict {PACKAGE_PIN L15  IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM1_PS_RST}]

set_property -dict {PACKAGE_PIN E14  IOSTANDARD LVCMOS33}               [get_ports {CM2_EN}]
set_property -dict {PACKAGE_PIN J14  IOSTANDARD LVCMOS33}               [get_ports {CM2_PWR_EN}]
#LVCMOS12, but has level shifters on SoM for conn-A VCCIO)
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS12 PULLDOWN TRUE} [get_ports {CM2_PWR_good}]
set_property -dict {PACKAGE_PIN D16  IOSTANDARD LVCMOS33}               [get_ports {CM2_MON_RX}]
set_property -dict {PACKAGE_PIN K13  IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_TX}]
set_property -dict {PACKAGE_PIN J12  IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_RX}]
set_property -dict {PACKAGE_PIN C16  IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[0]}]
set_property -dict {PACKAGE_PIN E17  IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[1]}]
set_property -dict {PACKAGE_PIN D17  IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[2]}]
set_property -dict {PACKAGE_PIN D15  IOSTANDARD LVCMOS33}               [get_ports {CM2_TCK}]
set_property -dict {PACKAGE_PIN A17  IOSTANDARD LVCMOS33}               [get_ports {CM2_TMS}]
set_property -dict {PACKAGE_PIN A16  IOSTANDARD LVCMOS33}               [get_ports {CM2_TDO}]
#LVCMOS12, but has level shifters on SoM for conn-A VCCIO)
set_property -dict {PACKAGE_PIN AG19 IOSTANDARD LVCMOS12}               [get_ports {CM2_TDI}]
set_property -dict {PACKAGE_PIN B16  IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM2_PS_RST}]

								        
set_property -dict {PACKAGE_PIN D14  IOSTANDARD LVCMOS33}               [get_ports {EEPROM_WE_N}]

set_property -dict {PACKAGE_PIN H12  IOSTANDARD LVCMOS33}               [get_ports {FP_LED_RST}] #CLK?
set_property -dict {PACKAGE_PIN H13  IOSTANDARD LVCMOS33}               [get_ports {FP_LED_CLK}] #RST?
set_property -dict {PACKAGE_PIN H14  IOSTANDARD LVCMOS33}               [get_ports {FP_LED_SDA}]
set_property -dict {PACKAGE_PIN L14  IOSTANDARD LVCMOS33}               [get_ports {FP_BUTTON}]
							                							                
set_property -dict {PACKAGE_PIN C12  IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_CLK}]
set_property -dict {PACKAGE_PIN C17  IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_SDA}]
set_property -dict {PACKAGE_PIN A15  IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_TX}]
set_property -dict {PACKAGE_PIN E15  IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_RX}]
								        							        
set_property -dict {PACKAGE_PIN A14  IOSTANDARD LVCMOS33}               [get_ports {LHC_SRC_SEL}]
set_property -dict {PACKAGE_PIN A13  IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_BP_LOS}]
set_property -dict {PACKAGE_PIN F12  IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_OSC_LOS}]
set_property -dict {PACKAGE_PIN E12  IOSTANDARD LVCMOS33}               [get_ports {HQ_SRC_SEL}]
set_property -dict {PACKAGE_PIN B12  IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_BP_LOS}]
set_property -dict {PACKAGE_PIN A12  IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_OSC_LOS}]

#LVCMOS12, but has level shifters on SoM for conn-A VCCIO)
set_property -dict {PACKAGE_PIN AH16 IOSTANDARD LVCMOS12}               [get_ports {ZYNQ_CPLD_GPIO[0]}]   #CPLD CLK pin
set_property -dict {PACKAGE_PIN C13  IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[1]}]
set_property -dict {PACKAGE_PIN G16  IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[2]}]
set_property -dict {PACKAGE_PIN G15  IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[3]}]

# -------------------------------------------------------------------------------------------------
# bank 33 & 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AH6  IOSTANDARD LVDS}                   [get_ports {onboard_CLK_N}]
set_property -dict {PACKAGE_PIN AJ6  IOSTANDARD LVDS}                   [get_ports {onboard_CLK_P}]
create_clock -period 10.000 -name onboard_CLK_P -add [get_ports onboard_CLK_P]

set_property -dict {PACKAGE_PIN AD7  IOSTANDARD LVDS}                   [get_ports {CLK_LHC_P}]
set_property -dict {PACKAGE_PIN AE7  IOSTANDARD LVDS}                   [get_ports {CLK_LHC_N}]

set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVDS}                   [get_ports {CLK_HQ_P}]
set_property -dict {PACKAGE_PIN AB8  IOSTANDARD LVDS}                   [get_ports {CLK_HQ_N}]

set_property -dict {PACKAGE_PIN AC8  IOSTANDARD LVDS}                   [get_ports {CLK_TTC_P}]
set_property -dict {PACKAGE_PIN AC7  IOSTANDARD LVDS}                   [get_ports {CLK_TTC_N}]
set_property -dict {PACKAGE_PIN AA2  IOSTANDARD LVDS}                   [get_ports {TTC_P}]
set_property -dict {PACKAGE_PIN AA1  IOSTANDARD LVDS}                   [get_ports {TTC_N}]
set_property -dict {PACKAGE_PIN AD2  IOSTANDARD LVDS}                   [get_ports {TTS_P}]
set_property -dict {PACKAGE_PIN AE2  IOSTANDARD LVDS}                   [get_ports {TTS_N}]

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[0]}]
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[1]}]

set_property -dict {PACKAGE_PIN AE1  IOSTANDARD LVCMOS18}               [get_ports {SATA_DETECT_N}]

set_property -dict {PACKAGE_PIN AA3  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TCK}]
set_property -dict {PACKAGE_PIN AB3  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDI}]
set_property -dict {PACKAGE_PIN AC3  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDO}]
set_property -dict {PACKAGE_PIN AC2  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TMS}]

set_property -dict {PACKAGE_PIN AB4  IOSTANDARD LVCMOS18}               [get_ports {SI_SDA}]
set_property -dict {PACKAGE_PIN AC4  IOSTANDARD LVCMOS18}               [get_ports {SI_SCL}]
set_property -dict {PACKAGE_PIN AD5  IOSTANDARD LVCMOS18}               [get_ports {SI_INT}]
set_property -dict {PACKAGE_PIN AE5  IOSTANDARD LVCMOS18}               [get_ports {SI_OUT_DIS}]
set_property -dict {PACKAGE_PIN AA6  IOSTANDARD LVCMOS18}               [get_ports {SI_ENABLE}]
set_property -dict {PACKAGE_PIN AA5  IOSTANDARD LVCMOS18}               [get_ports {SI_LOL}]
set_property -dict {PACKAGE_PIN AC6  IOSTANDARD LVCMOS18}               [get_ports {SI_LOS_XAXB}]

set_property -dict {PACKAGE_PIN Y7   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[0]}]
set_property -dict {PACKAGE_PIN AA7  IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[1]}]
set_property -dict {PACKAGE_PIN W8   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[2]}]
set_property -dict {PACKAGE_PIN Y8   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[3]}]
set_property -dict {PACKAGE_PIN AC9  IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[0]}]
set_property -dict {PACKAGE_PIN AD9  IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[1]}]

set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS18}               [get_ports {GPIO[0]}]
set_property -dict {PACKAGE_PIN Y1   IOSTANDARD LVCMOS18}               [get_ports {GPIO[1]}]
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS18}               [get_ports {GPIO[2]}]
set_property -dict {PACKAGE_PIN AE3  IOSTANDARD LVCMOS18}               [get_ports {GPIO[3]}]
set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVCMOS18}               [get_ports {GPIO[4]}]
set_property -dict {PACKAGE_PIN AE4  IOSTANDARD LVCMOS18}               [get_ports {GPIO[5]}]
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVCMOS18}               [get_ports {GPIO[6]}]
set_property -dict {PACKAGE_PIN AD4  IOSTANDARD LVCMOS18}               [get_ports {GPIO[7]}]

set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[0]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[1]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[2]}]
set_property -dict {PACKAGE_PIN AC11 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[3]}]
set_property -dict {PACKAGE_PIN AC12 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[4]}]
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[5]}]











# -------------------------------------------------------------------------------------------------
# MGBT (refclks)
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN M23 }  [get_ports refclk_SSD_P]
set_property -dict {PACKAGE_PIN M24 }  [get_ports refclk_SSD_N]

set_property -dict {PACKAGE_PIN D10 }  [get_ports refclk_C2C1_P[0]]
set_property -dict {PACKAGE_PIN D9  }  [get_ports refclk_C2C1_N[0]]

set_property -dict {PACKAGE_PIN B10 }  [get_ports refclk_CMS_P[0]]
set_property -dict {PACKAGE_PIN B9  }  [get_ports refclk_CMS_N[0]]

set_property -dict {PACKAGE_PIN L25 }  [get_ports refclk_C2C2_P[0]]
set_property -dict {PACKAGE_PIN L26 }  [get_ports refclk_C2C2_N[0]]

set_property -dict {PACKAGE_PIN H10 }  [get_ports refclk_C2C1_P[1]]
set_property -dict {PACKAGE_PIN H9  }  [get_ports refclk_C2C1_N[1]]

set_property -dict {PACKAGE_PIN F10 }  [get_ports refclk_C2C2_P[1]]
set_property -dict {PACKAGE_PIN F9  }  [get_ports refclk_C2C2_N[1]]

set_property -dict {PACKAGE_PIN J8  }  [get_ports refclk_CMS_P[1]]
set_property -dict {PACKAGE_PIN J7  }  [get_ports refclk_CMS_N[1]]


# -------------------------------------------------------------------------------------------------
# MGBT 
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN G4  }  [get_ports AXI_C2C_CM1_Rx_P[0]]
set_property -dict {PACKAGE_PIN G3  }  [get_ports AXI_C2C_CM1_Rx_N[0]]
set_property -dict {PACKAGE_PIN G8  }  [get_ports AXI_C2C_CM1_Tx_P[0]]
set_property -dict {PACKAGE_PIN G7  }  [get_ports AXI_C2C_CM1_Tx_N[0]]
set_property -dict {PACKAGE_PIN C4  }  [get_ports AXI_C2C_CM1_Rx_P[1]]
set_property -dict {PACKAGE_PIN C3  }  [get_ports AXI_C2C_CM1_Rx_N[1]]
set_property -dict {PACKAGE_PIN C8  }  [get_ports AXI_C2C_CM1_Tx_P[1]]
set_property -dict {PACKAGE_PIN C7  }  [get_ports AXI_C2C_CM1_Tx_N[1]]


set_property -dict {PACKAGE_PIN H2  }  [get_ports AXI_C2C_CM2_Rx_P[0] ]
set_property -dict {PACKAGE_PIN H1  }  [get_ports AXI_C2C_CM2_Rx_N[0] ]
set_property -dict {PACKAGE_PIN H6  }  [get_ports AXI_C2C_CM2_Tx_P[0] ]
set_property -dict {PACKAGE_PIN H5  }  [get_ports AXI_C2C_CM2_Tx_N[0] ]
set_property -dict {PACKAGE_PIN D2  }  [get_ports AXI_C2C_CM2_Rx_P[1]]
set_property -dict {PACKAGE_PIN D1  }  [get_ports AXI_C2C_CM2_Rx_N[1]]
set_property -dict {PACKAGE_PIN D6  }  [get_ports AXI_C2C_CM2_Tx_P[1]]
set_property -dict {PACKAGE_PIN D5  }  [get_ports AXI_C2C_CM2_Tx_N[1]]

set_property -dict {PACKAGE_PIN H27 }  [get_ports SSD_Rx_P ]
set_property -dict {PACKAGE_PIN H18 }  [get_ports SSD_Rx_N ]
set_property -dict {PACKAGE_PIN J25 }  [get_ports SSD_Tx_P ]
set_property -dict {PACKAGE_PIN J26 }  [get_ports SSD_Tx_N ]

set_property -dict {PACKAGE_PIN E4  }  [get_ports CM1_TCDS_TTS_P ]
set_property -dict {PACKAGE_PIN E3  }  [get_ports CM1_TCDS_TTS_N ]
set_property -dict {PACKAGE_PIN A4  }  [get_ports CM2_TCDS_TTS_P]
set_property -dict {PACKAGE_PIN A3  }  [get_ports CM2_TCDS_TTS_N]
set_property -dict {PACKAGE_PIN E8  }  [get_ports TCDS_TTS_P ]
set_property -dict {PACKAGE_PIN E7  }  [get_ports TCDS_TTS_N ]

set_property -dict {PACKAGE_PIN B2  }  [get_ports TCDS_TTC_P]
set_property -dict {PACKAGE_PIN B1  }  [get_ports TCDS_TTC_N]
set_property -dict {PACKAGE_PIN B6  }  [get_ports LOCAL_TCDS_TTC_P]
set_property -dict {PACKAGE_PIN B5  }  [get_ports LOCAL_TCDS_TTC_N]

set_property -dict {PACKAGE_PIN N4  }  [get_ports LDAQ_Rx_P ]
set_property -dict {PACKAGE_PIN N3  }  [get_ports LDAQ_Rx_N ]
set_property -dict {PACKAGE_PIN P6  }  [get_ports LDAQ_Tx_P ]
set_property -dict {PACKAGE_PIN P5  }  [get_ports LDAQ_Tx_N ]






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
