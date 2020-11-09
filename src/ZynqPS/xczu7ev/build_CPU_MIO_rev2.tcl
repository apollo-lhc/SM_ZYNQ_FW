###############################
#MIO configuration
###############################
#io voltage (banks 0 and 2 have level shifters on the enclustra to map to connA IOBs)
set_property CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS33}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS33}		    [get_bd_cells ${ZYNQ_NAME}]

#i2c for rtc
set_property CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} 		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11}        [get_bd_cells ${ZYNQ_NAME}]

#spi
set_property CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4}	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {50}	    [get_bd_cells ${ZYNQ_NAME}]

#ethernet 0
set_property CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} 		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {1} 		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__ENET0__GRP_MDIO__IO {MIO 76 .. 77}         [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_26_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_27_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_28_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_29_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_30_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_31_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_32_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_33_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_34_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_35_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_36_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_37_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]

#ethernet 1
set_property CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} 		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_64_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_65_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_66_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_67_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_68_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_69_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_70_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_71_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_72_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_73_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_74_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_75_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]


#SD Card
set_property CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51}	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_46_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_47_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_48_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_49_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_50_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_51_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_46_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_47_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_48_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_49_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_50_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_51_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]

#uart
set_property -dict [list CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1}       \
			CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 38 .. 39}]\
			                                            [get_bd_cells ${ZYNQ_NAME}]


#SD eMMC
set_property CONFIG.PSU__SD0__PERIPHERAL__ENABLE {0}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU__SD0__SLOT_TYPE {eMMC}			    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_13_PULLUPDOWN {disable}                 [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_14_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_15_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_16_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_17_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_18_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_19_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_20_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_21_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU_MIO_22_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]


#gpios
set_property CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} 	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} 	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_12_PULLUPDOWN {disable}                 [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_23_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_38_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU_MIO_39_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]

#SSD
set_property CONFIG.PSU__SATA__PERIPHERAL__ENABLE {0}               [get_bd_cells ${ZYNQ_NAME}]

#other
set_property CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__FPGA_PL1_ENABLE {1}                        [get_bd_cells ${ZYNQ_NAME}]

