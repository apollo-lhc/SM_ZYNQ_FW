###############################
#MIO configuration
###############################
#io voltage
set_property CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V}   [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 3.3V}   [get_bd_cells ${ZYNQ_NAME}]

#spi
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}	     [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1}           [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1}            [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        [get_bd_cells ${ZYNQ_NAME}]

#ethernet0					             
set_property CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1}          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27}        [get_bd_cells ${ZYNQ_NAME}]
#ethernet mdio interface			             
set_property CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1}            [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53}     [get_bd_cells ${ZYNQ_NAME}]




#USB
set_property CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0}           [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1}	     [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39}	     [get_bd_cells ${ZYNQ_NAME}]

#uart
set_property CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1}	     [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0}	     [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_UART0_UART0_IO {MIO 46 .. 47}	     [get_bd_cells ${ZYNQ_NAME}]

#add second ethernet port
# CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}
set_property CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {1}          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {1}            [get_bd_cells ${ZYNQ_NAME}]
make_bd_intf_pins_external                                   [get_bd_intf_pins ${ZYNQ_NAME}/GMII_ETHERNET_1]
make_bd_intf_pins_external                                   [get_bd_intf_pins ${ZYNQ_NAME}/MDIO_ETHERNET_1]
make_bd_pins_external                                        [get_bd_pins ${ZYNQ_NAME}/FCLK_CLK1]
connect_bd_net [get_bd_pins ${ZYNQ_NAME}/FCLK_CLK1]          [get_bd_pins ${ZYNQ_NAME}/ENET1_GMII_RX_CLK]
connect_bd_net [get_bd_pins ${ZYNQ_NAME}/FCLK_CLK1]          [get_bd_pins ${ZYNQ_NAME}/ENET1_GMII_TX_CLK]

#i2c (iic) for RTC
set_property CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1}           [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_I2C0_I2C0_IO {EMIO}                  [get_bd_cells ${ZYNQ_NAME}]
make_bd_intf_pins_external  [get_bd_intf_pins ${ZYNQ_NAME}/IIC_0]
