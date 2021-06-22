proc build_rev2_xczu7ev {} {
    #================================================================================
    #  Create and configure the basic zynq MPSoC series processing system.
    #================================================================================
    #This code is directly sourced and builds the Zynq CPU
    
    set ZYNQ_NAME ZynqMPSoC
    
    startgroup
    
    #create the zynq MPSoC
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == zynq_ultra_ps_e}] ${ZYNQ_NAME}

    #configure the Zynq system

    ###############################
    #clocking
    ###############################
    #CPU frequency
    set_property CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200}	        [get_bd_cells ${ZYNQ_NAME}]
    #other clocks
    set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {50}	[get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {500}    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500}	[get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250}    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500}    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500}      [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__FPGA_PL1_ENABLE {1}                        [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {50}        [get_bd_cells ${ZYNQ_NAME}]
    upvar 1 AXI_MASTER_CLK_FREQ AXI_MASTER_CLK_FREQ
    set AXI_MASTER_CLK_FREQ 49999500

         
    ###############################
    #RAM (PS DDR)
    ###############################
    set_property -dict [list CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200}     \
			    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400T}           \
			    CONFIG.PSU__DDRC__CWL {12}                         \
			    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1}		       \
			    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits}     \
			    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits}	       \
			    CONFIG.PSU__DDRC__ECC {Enabled}		       \
			    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16}]      [get_bd_cells ${ZYNQ_NAME}]
    
    ###############################
    #AXI MASTERS
    ###############################
    #LPD
    set_property CONFIG.PSU__USE__M_AXI_GP2 {0}			    [get_bd_cells ${ZYNQ_NAME}]
    #FPD0
    set_property CONFIG.PSU__USE__M_AXI_GP0 {1}			    [get_bd_cells ${ZYNQ_NAME}]
    upvar 1 AXI_MASTER_LOCAL_PORT AXI_MASTER_LOCAL_PORT
    set AXI_MASTER_LOCAL_PORT ${ZYNQ_NAME}/M_AXI_HPM0_FPD
    #FPD1
    set_property CONFIG.PSU__USE__M_AXI_GP1 {1}			    [get_bd_cells ${ZYNQ_NAME}]
    upvar 1 AXI_MASTER_C2C_PORT AXI_MASTER_C2C_PORT
    set AXI_MASTER_C2C_PORT ${ZYNQ_NAME}/M_AXI_HPM1_FPD

    #connect FCLK_CLK0 to the master AXI_GP0 clock
    set AXI_MASTER_CLK ${ZYNQ_NAME}/pl_clk1
    make_bd_pins_external -name axi_clk [get_bd_pins ${AXI_MASTER_CLK}]

    set_property CONFIG.PSU__MAXIGP0__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__MAXIGP1__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]
    
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm0_fpd_aclk]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm1_fpd_aclk]


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
    set_property CONFIG.PSU_MIO_76_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}] 
    set_property CONFIG.PSU_MIO_77_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
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
    set_property CONFIG.PSU_MIO_46_PULLUPDOWN {pullup}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_47_PULLUPDOWN {pullup}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_48_PULLUPDOWN {pullup}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_49_PULLUPDOWN {pullup}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_50_PULLUPDOWN {pullup}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_51_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_46_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_47_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_48_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_49_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_50_SLEW {slow}                          [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_51_SLEW {FAST}                          [get_bd_cells ${ZYNQ_NAME}]
    #SDIO clock
    set_property CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {50}	    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL}    [get_bd_cells ${ZYNQ_NAME}]
    
    #uart
    set_property -dict [list CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1}       \
			    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 38 .. 39}]\
			                                            [get_bd_cells ${ZYNQ_NAME}]


    #SD eMMC
    set_property CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__SD0__SLOT_TYPE {eMMC}			    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_13_PULLUPDOWN {disable}                 [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_14_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_15_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_16_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_17_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_18_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_19_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_20_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_21_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_22_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]


    #gpios
    set_property CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} 	    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} 	    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_12_PULLUPDOWN {disable}                 [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_23_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_38_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU_MIO_39_PULLUPDOWN {disable}		    [get_bd_cells ${ZYNQ_NAME}]
    
    #SSD
    set_property CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1}               [get_bd_cells ${ZYNQ_NAME}] 
    set_property CONFIG.PSU__SATA__LANE0__ENABLE {1}                    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__SATA__LANE1__ENABLE {0}                    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__SATA__LANE0__IO {GT Lane2}                 [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk0}               [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__SATA__REF_CLK_FREQ {125}                   [get_bd_cells ${ZYNQ_NAME}]
    
    
    #other
    set_property CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1}		    [get_bd_cells ${ZYNQ_NAME}]
    set_property CONFIG.PSU__FPGA_PL1_ENABLE {1}                        [get_bd_cells ${ZYNQ_NAME}]
    

    ###############################
    # System reset core
    ###############################
    set SYS_RESETER sys_reseter
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == proc_sys_reset}] $SYS_RESETER
    
    #connect external reset
    connect_bd_net [get_bd_pins ${ZYNQ_RESETN}] [get_bd_pins $SYS_RESETER/ext_reset_in]
    #connect clock
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $SYS_RESETER/slowest_sync_clk]
    #set interconnect reset
    set AXI_MASTER_RSTN [get_bd_pins ${SYS_RESETER}/interconnect_aresetn]
    set AXI_SLAVE_RSTN [get_bd_pins ${SYS_RESETER}/peripheral_aresetn]
    make_bd_pins_external -name axi_rst_n [get_bd_pins ${AXI_SLAVE_RSTN}]
    
    #add interrupts from PL to PS
    set_property CONFIG.PSU__USE__IRQ0 {1} [get_bd_cells ${ZYNQ_NAME}]
    upvar 1 IRQ_PORT IRQ_PORT
    set IRQ_PORT ${ZYNQ_NAME}/pl_ps_irq0

    endgroup
}
