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



# PL_Fast_Ethernet_1
set_property -dict {PACKAGE_PIN W14   IOSTANDARD LVCMOS33  } [get_ports {ETH1_CLK}]
set_property -dict {PACKAGE_PIN AD14  IOSTANDARD LVCMOS33  } [get_ports {ETH1_MDC}]
set_property -dict {PACKAGE_PIN AD11  IOSTANDARD LVCMOS33  } [get_ports {ETH1_MDIO}]
set_property -dict {PACKAGE_PIN AF14  IOSTANDARD LVCMOS33  } [get_ports {ETH1_RESET_N}]
set_property -dict {PACKAGE_PIN W17   IOSTANDARD LVCMOS33  } [get_ports {ETH1_INT_N_PWDN_N}]

# PL_Fast_Ethernet_1A
set_property -dict {PACKAGE_PIN J11   IOSTANDARD LVCMOS18  } [get_ports {ETH1A_COL_PL}]
set_property -dict {PACKAGE_PIN AE12  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXD[0]}]
set_property -dict {PACKAGE_PIN AF12  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXD[1]}]
set_property -dict {PACKAGE_PIN AE11  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXD[2]}]
set_property -dict {PACKAGE_PIN AF10  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXD[3]}]
set_property -dict {PACKAGE_PIN AB12  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXD[0]}]
set_property -dict {PACKAGE_PIN AC11  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXD[1]}]
set_property -dict {PACKAGE_PIN AB11  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXD[2]}]
set_property -dict {PACKAGE_PIN AB10  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXD[3]}]
set_property -dict {PACKAGE_PIN AE13  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXDV}]
set_property -dict {PACKAGE_PIN AF13  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXER}]
set_property -dict {PACKAGE_PIN AE10  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXEN}]
set_property -dict {PACKAGE_PIN AC13  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_RXCLK}]
set_property -dict {PACKAGE_PIN AC12  IOSTANDARD LVCMOS33  } [get_ports {ETH1A_TXCLK}]
set_property -dict {PACKAGE_PIN G6    IOSTANDARD LVCMOS18  } [get_ports {ETH1A_CRS_PL}]
set_property -dict {PACKAGE_PIN J10   IOSTANDARD LVCMOS18  } [get_ports {ETH1A_LED_PL_N}]


set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN W13} [get_ports I2C_SCL]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y13} [get_ports I2C_SDA]


# -------------------------------------------------------------------------------------------------
# PL 3V3  bank 12 & 13
# -------------------------------------------------------------------------------------------------


set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {ZYNQ_BOOT_DONE}];       #A.73  XU8:  B15, ZX1: AA22

#alternate, not used by default
set_property -dict {PACKAGE_PIN Y18  IOSTANDARD LVCMOS33}               [get_ports {UART_RX_ZYNQ}];         #A.52  XU8:  F16, ZX1: Y18
set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33}               [get_ports {UART_TX_ZYNQ}];         #A.54  XU8:  F15, ZX1: AA18

set_property -dict {PACKAGE_PIN AD26 IOSTANDARD LVCMOS33}               [get_ports {IPMC_SDA}];             #A.27  XU8:  G14, ZX1: AD26
set_property -dict {PACKAGE_PIN AE18 IOSTANDARD LVCMOS33}               [get_ports {IPMC_SCL}];             #A.28  XU8:  D12, ZX1: AE18

set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33}               [get_ports {CM1_EN}];               #A.45  XU8:  E13, ZX1: AB25
set_property -dict {PACKAGE_PIN AE22 IOSTANDARD LVCMOS33}               [get_ports {CM1_PWR_EN}];           #A.61  XU8:  J16, ZX1: AE22        
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS33 DRIVE 8 PULLDOWN TRUE} [get_ports {CM1_PWR_GOOD}]; #A.88  XU8: AF17, ZX1: Y10
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {CM1_MON_RX}];           #A.63  XU8:  H16, ZX1: AF22
set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_TX}];          #A.15  XU8:  C14, ZX1: AE25
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33}               [get_ports {CM1_UART_RX}];          #A.17  XU8:  B14, ZX1: AE26
set_property -dict {PACKAGE_PIN AC18 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[0]}];          #A.64  XU8:  J15, ZX1: AC18
set_property -dict {PACKAGE_PIN AC21 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[1]}];          #A.16  XU8:  G13, ZX1: AC21
set_property -dict {PACKAGE_PIN AC22 IOSTANDARD LVCMOS33}               [get_ports {CM1_GPIO[2]}];          #A.18  XU8:  F13, ZX1: AC22
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33}               [get_ports {CM1_TCK}];              #A.55  XU8:  K15, ZX1: AB21
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33}               [get_ports {CM1_TMS}];              #A.57  XU8:  K14, ZX1: AB22

set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS33}               [get_ports {CM1_TDO}];              #A.60  XU8:  K11, ZX1: AB19
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33}               [get_ports {CM1_TDI}];              #A.58  XU8:  K12, ZX1: AA19
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM1_PS_RST}];           #A.70  XU8:  L15, ZX1: AA20

set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33}               [get_ports {CM2_EN}];               #A.43  XU8:  E14, ZX1: AA25
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33}               [get_ports {CM2_PWR_EN}];           #A.66  XU8:  J14, ZX1: AC19
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33 DRIVE 8 PULLDOWN TRUE} [get_ports {CM2_PWR_GOOD}]; #A.90  XU8: AC19, ZX1: AA10
set_property -dict {PACKAGE_PIN AE23 IOSTANDARD LVCMOS33}               [get_ports {CM2_MON_RX}];           #A.67  XU8:  D16, ZX1: AE23
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_TX}];          #A.19  XU8:  K13, ZX1: AF24
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS33}               [get_ports {CM2_UART_RX}];          #A.21  XU8:  J12, ZX1: AF25
set_property -dict {PACKAGE_PIN AF23 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[0]}];          #A.69  XU8:  C16, ZX1: AF23
set_property -dict {PACKAGE_PIN AC23 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[1]}];          #A.85  XU8:  E17, ZX1: AC23
set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVCMOS33}               [get_ports {CM2_GPIO[2]}];          #A.87  XU8:  D17, ZX1: AC24
set_property -dict {PACKAGE_PIN Y20  IOSTANDARD LVCMOS33}               [get_ports {CM2_TCK}];              #A.78  XU8:  D15, ZX1:  Y20
set_property -dict {PACKAGE_PIN V19  IOSTANDARD LVCMOS33}               [get_ports {CM2_TMS}];              #A.79  XU8:  A17, ZX1:  V19
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33}               [get_ports {CM2_TDO}];              #A.81  XU8:  A16, ZX1:  V18

set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33 DRIVE 8 }      [get_ports {CM2_TDI}];              #A.94  XU8: AG19, ZX1:  Y11
set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVCMOS33 PULLUP TRUE}   [get_ports {CM2_PS_RST}];           #A.33  XU8:  B16, ZX1: AB24

								        
set_property -dict {PACKAGE_PIN AD20 IOSTANDARD LVCMOS33}               [get_ports {EEPROM_WE_N}];          #A.46  XU8:  D14, ZX1: AD20

set_property -dict {PACKAGE_PIN AF20 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_RST}];           #A.24  XU8:  H12, ZX1: AF20
set_property -dict {PACKAGE_PIN AF19 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_CLK}];           #A.22  XU8:  H13, ZX1: AF19
set_property -dict {PACKAGE_PIN AD25 IOSTANDARD LVCMOS33}               [get_ports {FP_LED_SDA}];           #A.25  XU8:  H14, ZX1: AD25
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33}               [get_ports {FP_BUTTON}];            #A.72  XU8:  L14, ZX1: AB20
							                							                
set_property -dict {PACKAGE_PIN AF18 IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_CLK}];          #A.30  XU8:  C12, ZX1: AF18
set_property -dict {PACKAGE_PIN AA24 IOSTANDARD LVCMOS33}               [get_ports {ESM_LED_SDA}];          #A.31  XU8:  C17, ZX1: AA24
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_TX}];          #A.75  XU8:  A15, ZX1: AA23
set_property -dict {PACKAGE_PIN W20  IOSTANDARD LVCMOS33}               [get_ports {ESM_UART_RX}];          #A.76  XU8:  E15, ZX1:  W20
								        							        
set_property -dict {PACKAGE_PIN AE20 IOSTANDARD LVCMOS33}               [get_ports {LHC_SRC_SEL}];          #A.34  XU8:  A14, ZX1: AE20
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_BP_LOS}];       #A.36  XU8:  A13, ZX1: AE21
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33}               [get_ports {LHC_CLK_OSC_LOS}];      #A.37  XU8:  F12, ZX1: AB26
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33}               [get_ports {HQ_SRC_SEL}];           #A.39  XU8:  E12, ZX1: AC26
set_property -dict {PACKAGE_PIN AD18 IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_BP_LOS}];        #A.40  XU8:  B12, ZX1: AD18
set_property -dict {PACKAGE_PIN AD19 IOSTANDARD LVCMOS33}               [get_ports {HQ_CLK_OSC_LOS}];       #A.42  XU8:  A12, ZX1: AD19

#CPLD CLK pin
set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS33  DRIVE 8 }     [get_ports {ZYNQ_CPLD_GPIO[0]}];    #A.92  XU8: AH16, ZX1:  Y12
set_property -dict {PACKAGE_PIN AD21 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[1]}];    #A.48  XU8:  C13, ZX1: AD21
set_property -dict {PACKAGE_PIN AD23 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[2]}];    #A.49  XU8:  G16, ZX1: AD23
set_property -dict {PACKAGE_PIN AD24 IOSTANDARD LVCMOS33}               [get_ports {ZYNQ_CPLD_GPIO[3]}];    #A.51  XU8:  G15, ZX1: AD24

# -------------------------------------------------------------------------------------------------
# bank 33 & 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN J4   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_P}];            #B.133 XU8:  AD7, ZX1:   J4
set_property -dict {PACKAGE_PIN J3   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_N}];            #B.153 XU8:  AE7, ZX1:   J3

set_property -dict {PACKAGE_PIN C8   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_P}];             #B.154 XU8:  AA8, ZX1:   C8
set_property -dict {PACKAGE_PIN C7   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_N}];             #B.156 XU8:  AB8, ZX1:   C7

set_property -dict {PACKAGE_PIN G7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_P}];            #B.78  XU8:  AC8, ZX1:   G7
set_property -dict {PACKAGE_PIN F7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_N}];            #B.80  XU8:  AC7, ZX1:   F7
set_property -dict {PACKAGE_PIN F5   IOSTANDARD LVDS}                   [get_ports {TTC_P}];                #B.90  XU8:  AA2, ZX1:   F5
set_property -dict {PACKAGE_PIN E5   IOSTANDARD LVDS}                   [get_ports {TTC_N}];                #B.92  XU8:  AA1, ZX1:   E5
set_property -dict {PACKAGE_PIN E6   IOSTANDARD LVDS}                   [get_ports {TTS_P}];                #B.94  XU8:  AD2, ZX1:   E6
set_property -dict {PACKAGE_PIN D5   IOSTANDARD LVDS}                   [get_ports {TTS_N}];                #B.96  XU8:  AE2, ZX1:   D5

set_property -dict {PACKAGE_PIN B2   IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[0]}];        #B.164 XU8: AB10, ZX1:   B2
set_property -dict {PACKAGE_PIN A2   IOSTANDARD LVCMOS18}               [get_ports {CM_TTC_SEL[1]}];        #B.166 XU8:  AB9, ZX1:   A2

set_property -dict {PACKAGE_PIN E8   IOSTANDARD LVCMOS18}               [get_ports {SATA_DETECT_N}];        #B.86  XU8:  AE1, ZX1:   E8

set_property -dict {PACKAGE_PIN D9   IOSTANDARD LVCMOS18}               [get_ports {CPLD_TCK}];             #B.100 XU8:  AA3, ZX1:   D9
set_property -dict {PACKAGE_PIN D8   IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDI}];             #B.102 XU8:  AB3, ZX1:   D8
set_property -dict {PACKAGE_PIN B10  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TDO}];             #B.104 XU8:  AC3, ZX1:  B10
set_property -dict {PACKAGE_PIN A10  IOSTANDARD LVCMOS18}               [get_ports {CPLD_TMS}];             #B.106 XU8:  AC2, ZX1:  A10

set_property -dict {PACKAGE_PIN A7   IOSTANDARD LVCMOS18}               [get_ports {SI_SDA}];               #B.116 XU8:  AC4, ZX1:   A7
set_property -dict {PACKAGE_PIN B7   IOSTANDARD LVCMOS18}               [get_ports {SI_SCL}];               #B.114 XU8:  AB4, ZX1:   B7
set_property -dict {PACKAGE_PIN C9   IOSTANDARD LVCMOS18}               [get_ports {SI_INT}];               #B.120 XU8:  AD5, ZX1:   C9
set_property -dict {PACKAGE_PIN B9   IOSTANDARD LVCMOS18}               [get_ports {SI_OUT_DIS}];           #B.122 XU8:  AE5, ZX1:   B9
set_property -dict {PACKAGE_PIN C4   IOSTANDARD LVCMOS18}               [get_ports {SI_ENABLE}];            #B.124 XU8:  AA6, ZX1:   C4
set_property -dict {PACKAGE_PIN C3   IOSTANDARD LVCMOS18}               [get_ports {SI_LOL}];               #B.126 XU8:  AA5, ZX1:   C3
set_property -dict {PACKAGE_PIN C2   IOSTANDARD LVCMOS18}               [get_ports {SI_LOS_XAXB}];          #B.136 XU8:  AC6, ZX1:   C2

set_property -dict {PACKAGE_PIN  E7  IOSTANDARD LVCMOS18}               [get_ports {SI_TCDS_INT}];          #B.74  XU8:  AC1, ZX1:   E7
set_property -dict {PACKAGE_PIN  D6  IOSTANDARD LVCMOS18}               [get_ports {SI_TCDS_OUT_DIS}];      #B.130 XU8:  AB6, ZX1:   D6
set_property -dict {PACKAGE_PIN  C6  IOSTANDARD LVCMOS18}               [get_ports {SI_TCDS_ENABLE}];       #B.132 XU8:  AB5, ZX1:   C6
set_property -dict {PACKAGE_PIN  F9  IOSTANDARD LVCMOS18}               [get_ports {SI_TCDS_LOL}];          #B.84  XU8:  AD1, ZX1:   F9
set_property -dict {PACKAGE_PIN  F8  IOSTANDARD LVCMOS18}               [get_ports {SI_TCDS_LOS_XAXB}];     #B.72  XU8:  AB1, ZX1:   F8

set_property -dict {PACKAGE_PIN A4   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[0]}];           #B.143 XU8:   Y7, ZX1:   A4
set_property -dict {PACKAGE_PIN A3   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[1]}];           #B.144 XU8:  AA7, ZX1:   A3
set_property -dict {PACKAGE_PIN B5   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[2]}];           #B.148 XU8:   W8, ZX1:   B5
set_property -dict {PACKAGE_PIN B4   IOSTANDARD LVCMOS18}               [get_ports {IPMC_IN[3]}];           #B.150 XU8:   Y8, ZX1:   B4
set_property -dict {PACKAGE_PIN B6   IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[0]}];          #B.160 XU8:  AC9, ZX1:   B6
set_property -dict {PACKAGE_PIN A5   IOSTANDARD LVCMOS18}               [get_ports {IPMC_OUT[1]}];          #B.162 XU8:  AD9, ZX1:   A5

#Look at schematic for allowed uses  #set_property -dict {PACKAGE_PIN   IOSTANDARD LVCMOS18}               [get_ports {GPIO[0]}]; # XU8: MIO41  ZX1: W19
#set_property -dict {PACKAGE_PIN W19  IOSTANDARD LVCMOS33}               [get_ports {GPIO[0]}];              #A.84  XU8: MIO41  ZX1: W19
set_property -dict {PACKAGE_PIN E1   IOSTANDARD LVCMOS18}               [get_ports {GPIO[1]}];              #B.141 XU8: AA10, ZX1:   E1
set_property -dict {PACKAGE_PIN E2   IOSTANDARD LVCMOS18}               [get_ports {GPIO[2]}];              #B.139 XU8:  Y10, ZX1:   E2
set_property -dict {PACKAGE_PIN B1   IOSTANDARD LVCMOS18}               [get_ports {GPIO[3]}];              #B.138 XU8:  AD6, ZX1:   B1
set_property -dict {PACKAGE_PIN F4   IOSTANDARD LVCMOS18}               [get_ports {GPIO[4]}];              #B.131 XU8:   Y1, ZX1:   F4
set_property -dict {PACKAGE_PIN A8   IOSTANDARD LVCMOS18}               [get_ports {GPIO[5]}];              #B.112 XU8:  AE4, ZX1:   A8
set_property -dict {PACKAGE_PIN G4   IOSTANDARD LVCMOS18}               [get_ports {GPIO[6]}];              #B.129 XU8:  AE3, ZX1:   G4
set_property -dict {PACKAGE_PIN A9   IOSTANDARD LVCMOS18}               [get_ports {GPIO[7]}];              #B.110 XU8:  AD4, ZX1:   A9

set_property -dict {PACKAGE_PIN G2   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[0]}];       #B.145 XU8: AA12, ZX1:   G2
set_property -dict {PACKAGE_PIN F2   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[1]}];       #B.147 XU8: AA11, ZX1:   F2
set_property -dict {PACKAGE_PIN D1   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[2]}];       #B.157 XU8: AB11, ZX1:   D1
set_property -dict {PACKAGE_PIN C1   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[3]}];       #B.159 XU8: AC11, ZX1:   C1
set_property -dict {PACKAGE_PIN D4   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[4]}];       #B.163 XU8: AC12, ZX1:   D4
set_property -dict {PACKAGE_PIN D3   IOSTANDARD LVCMOS18 PULLDOWN TRUE} [get_ports {FP_1V8_GPIO[5]}];       #B.165 XU8: AD12, ZX1:   D3










