###############################
#MIO configuration
###############################
#io voltage
set_property CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V}   [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 3.3V}   [get_bd_cells processing_system7_0]

#spi
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}	     [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1}           [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1}            [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        [get_bd_cells processing_system7_0]

#ethernet					             
set_property CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1}          [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27}        [get_bd_cells processing_system7_0]
#ethernet mdio interface			             
set_property CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1}            [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53}     [get_bd_cells processing_system7_0]

#USB
set_property CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1}	     [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39}	     [get_bd_cells processing_system7_0]

#uart
set_property CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1}	     [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0}	     [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_UART0_UART0_IO {MIO 46 .. 47}	     [get_bd_cells processing_system7_0]
						            
#SGMII ethernet (also generate external connections for PL IP)
set_property CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {1}          [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {1}            [get_bd_cells processing_system7_0]
make_bd_pins_external                                        [get_bd_pins processing_system7_0/ENET1_MDIO_MDC]
make_bd_pins_external                                        [get_bd_pins processing_system7_0/ENET1_MDIO_I]
make_bd_pins_external                                        [get_bd_pins processing_system7_0/ENET1_MDIO_O]
make_bd_intf_pins_external                                   [get_bd_intf_pins processing_system7_0/GMII_ETHERNET_1]
make_bd_pins_external                                        [get_bd_pins processing_system7_0/ENET1_EXT_INTIN]
