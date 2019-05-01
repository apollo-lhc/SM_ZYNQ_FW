source ../bd/axi_slave_helpers.tcl
#================================================================================
#  Configure and add AXI slaves
#================================================================================

proc ADD_AXI_SLAVES { } {
    #fp_leds
    [AXI_DEVICE_ADD XVC1    axi_interconnect_0/M00_AXI axi_interconnect_0/M00_ACLK axi_interconnect_0/M00_ARESETN 50000000]
    [AXI_DEVICE_ADD XVC2    axi_interconnect_0/M01_AXI axi_interconnect_0/M01_ACLK axi_interconnect_0/M01_ARESETN 50000000]

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
    #  Add non-xilinx AXI slave
    #========================================
    puts "Adding user slaves"
    #AXI_PL_CONNECT creates all the PL slaves in the list passed to it.

    validate_bd_design
}
