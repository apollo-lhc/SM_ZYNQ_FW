source ../bd/axi_slave_helpers.tcl
#================================================================================
#  Configure and add AXI slaves
#================================================================================

proc ADD_AXI_SLAVES { } {
    #fp_leds
    [AXI_DEVICE_ADD XVC1    axi_interconnect_0/M00_AXI axi_interconnect_0/M00_ACLK axi_interconnect_0/M00_ARESETN 50000000]
    [AXI_DEVICE_ADD XVC2    axi_interconnect_0/M01_AXI axi_interconnect_0/M01_ACLK axi_interconnect_0/M01_ARESETN 50000000]
    [AXI_DEVICE_ADD C2C1    axi_interconnect_0/M02_AXI axi_interconnect_0/M02_ACLK axi_interconnect_0/M02_ARESETN 50000000]    
#    [AXI_DEVICE_ADD C2C2    axi_interconnect_0/M03_AXI axi_interconnect_0/M03_ACLK axi_interconnect_0/M03_ARESETN 50000000]

    [AXI_DEVICE_ADD C2C1_GT M03 PL_CLK PL_RESET_N 50000000] 
}

proc CONFIGURE_AXI_SLAVES { } {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_MASTER_RST
    global AXI_INTERCONNECT_NAME
    
    #========================================
    #  XVC1 (xilinx axi debug XVC)
    #========================================
    puts "Adding Xilinx XVC1"
    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 XVC1
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE  {3} [get_bd_cells XVC1]
    set_property CONFIG.C_DESIGN_TYPE {0} [get_bd_cells XVC1]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT XVC1 $AXI_BUS_M(XVC1) $AXI_BUS_CLK(XVC1) $AXI_BUS_RST(XVC1)]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK(XVC1)]
    connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_pins $AXI_BUS_RST(XVC1)]

    
    #generate ports for the JTAG signals
    make_bd_pins_external       [get_bd_cells XVC1]
    make_bd_intf_pins_external  [get_bd_cells XVC1]
    
    #build the DTSI chunk for this device to be a UIO
    [AXI_DEV_UIO_DTSI_POST_CHUNK XVC1]

    #========================================
    #  XVC2 (xilinx axi debug XVC)
    #========================================
    puts "Adding Xilinx XVC2"
    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 XVC2
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE  {3} [get_bd_cells XVC2]
    set_property CONFIG.C_DESIGN_TYPE {0} [get_bd_cells XVC2]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT XVC2 $AXI_BUS_M(XVC2) $AXI_BUS_CLK(XVC2) $AXI_BUS_RST(XVC2)]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK(XVC2)]
    connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_pins $AXI_BUS_RST(XVC2)]

    
    #generate ports for the JTAG signals
    make_bd_pins_external       [get_bd_cells XVC2]
    make_bd_intf_pins_external  [get_bd_cells XVC2]
    
    #build the DTSI chunk for this device to be a UIO
    [AXI_DEV_UIO_DTSI_POST_CHUNK XVC2]

    #========================================
    #  AXI C2C 1
    #========================================
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_chip2chip:5.0 C2C1
    set_property CONFIG.C_AXI_STB_WIDTH {4}         [get_bd_cells C2C1]
    set_property CONFIG.C_AXI_DATA_WIDTH {32}	    [get_bd_cells C2C1]
    set_property CONFIG.C_NUM_OF_IO {58.0}	    [get_bd_cells C2C1]
    set_property CONFIG.C_INTERFACE_MODE {0}	    [get_bd_cells C2C1]
    set_property CONFIG.C_INTERFACE_TYPE {2}	    [get_bd_cells C2C1]
    set_property CONFIG.C_AURORA_WIDTH {1.0}        [get_bd_cells C2C1]
    set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells C2C1]

    [AXI_DEV_CONNECT C2C1 $AXI_BUS_M(C2C1) $AXI_BUS_CLK(C2C1) $AXI_BUS_RST(C2C1)]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK(C2C1)]
    connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_pins $AXI_BUS_RST(C2C1)]

    #expose signals to aurora code
    #to USER_DATA_M_AXIS_RX
    make_bd_intf_pins_external  [get_bd_intf_pins C2C1/AXIS_RX]
    #to USER_DATA_M_AXIS_TX
    make_bd_intf_pins_external  [get_bd_intf_pins C2C1/AXIS_TX]
    #to user_clk_out
    make_bd_pins_external  [get_bd_pins C2C1/axi_c2c_phy_clk]
    #to channel up
    make_bd_pins_external  [get_bd_pins C2C1/axi_c2c_aurora_channel_up]
    #to init_clk_out
    make_bd_pins_external  [get_bd_pins C2C1/aurora_init_clk]
    #to mmcm_not_locked_out
    make_bd_pins_external  [get_bd_pins C2C1/aurora_mmcm_not_locked]
    #to pma_init
    make_bd_pins_external  [get_bd_pins C2C1/aurora_pma_init_out]
    #to reset_pb
    make_bd_pins_external  [get_bd_pins C2C1/aurora_reset_pb]           
    
    
    assign_bd_address [get_bd_addr_segs {C2C1/S_AXI/Mem }]


#    #========================================
#    #  AXI C2C 2
#    #========================================
#    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_chip2chip:5.0 C2C2
#    set_property CONFIG.C_AXI_STB_WIDTH {8}         [get_bd_cells C2C2]
#    set_property CONFIG.C_AXI_DATA_WIDTH {64}	    [get_bd_cells C2C2]
#    set_property CONFIG.C_NUM_OF_IO {84.0}	    [get_bd_cells C2C2]
#    set_property CONFIG.C_INTERFACE_MODE {0}	    [get_bd_cells C2C2]
#    set_property CONFIG.C_INTERFACE_TYPE {2}	    [get_bd_cells C2C2]
#    set_property CONFIG.C_AURORA_WIDTH {2.0}        [get_bd_cells C2C2]
#    set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells C2C2]
#
#    [AXI_DEV_CONNECT C2C2 $AXI_BUS_M(C2C2) $AXI_BUS_CLK(C2C2) $AXI_BUS_RST(C2C2)]
#    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK(C2C2)]
#    connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_pins $AXI_BUS_RST(C2C2)]

    
    #========================================
    #  Add non-xilinx AXI slave
    #========================================
    puts "Adding user slaves"
    #AXI_PL_CONNECT creates all the PL slaves in the list passed to it.
    [AXI_PL_CONNECT "C2C1_GT"]                                                                                                                                                        

    validate_bd_design
}
