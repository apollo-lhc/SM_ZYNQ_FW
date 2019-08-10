source ../bd/axi_slave_helpers.tcl
source ../bd/Xilinx_AXI_slaves.tcl
#================================================================================
#  Configure and add AXI slaves
#================================================================================

proc ADD_AXI_SLAVES { } {
    [SET_AXI_INTERCONNECT_NAME axi_interconnect]
    global AXI_INTERCONNECT_NAME
    [AXI_DEVICE_ADD SI     ${AXI_INTERCONNECT_NAME}/M00_AXI ${AXI_INTERCONNECT_NAME}/M00_ACLK ${AXI_INTERCONNECT_NAME}/M00_ARESETN 50000000]    
    [AXI_DEVICE_ADD SERV M01 PL_CLK PL_RESET_N 50000000]
    
    [AXI_DEVICE_ADD XVC1    ${AXI_INTERCONNECT_NAME}/M02_AXI ${AXI_INTERCONNECT_NAME}/M02_ACLK ${AXI_INTERCONNECT_NAME}/M02_ARESETN 50000000]
    [AXI_DEVICE_ADD XVC2    ${AXI_INTERCONNECT_NAME}/M03_AXI ${AXI_INTERCONNECT_NAME}/M03_ACLK ${AXI_INTERCONNECT_NAME}/M03_ARESETN 50000000]

    [AXI_DEVICE_ADD SLAVE_I2C M04 PL_CLK PL_RESET_N 50000000]
    [AXI_DEVICE_ADD CM M05 PL_CLK PL_RESET_N 50000000]

    [AXI_DEVICE_ADD C2C1      ${AXI_INTERCONNECT_NAME}/M06_AXI ${AXI_INTERCONNECT_NAME}/M06_ACLK ${AXI_INTERCONNECT_NAME}/M06_ARESETN 50000000]
    [AXI_DEVICE_ADD MONITOR   ${AXI_INTERCONNECT_NAME}/M07_AXI ${AXI_INTERCONNECT_NAME}/M07_ACLK ${AXI_INTERCONNECT_NAME}/M07_ARESETN 50000000]

    [AXI_DEVICE_ADD XVC_LOCAL   ${AXI_INTERCONNECT_NAME}/M08_AXI ${AXI_INTERCONNECT_NAME}/M08_ACLK ${AXI_INTERCONNECT_NAME}/M08_ARESETN 50000000]
    [AXI_DEVICE_ADD C2C1_LITE ${AXI_INTERCONNECT_NAME}/M09_AXI ${AXI_INTERCONNECT_NAME}/M09_ACLK ${AXI_INTERCONNECT_NAME}/M09_ARESETN 50000000]    
#    [AXI_DEVICE_ADD C2C1_A_GT M08 PL_CLK PL_RESET_N 50000000]
#    [AXI_DEVICE_ADD C2C1_B_GT M08 PL_CLK PL_RESET_N 50000000] 
}

proc CONFIGURE_AXI_SLAVES { } {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_MASTER_RSTN
    global AXI_INTERCONNECT_NAME


    #========================================
    # Si5344 I2C master
    #========================================
    [AXI_IP_I2C SI]
    
    #========================================
    #  XVC1 (xilinx axi debug XVC)
    #========================================
    puts "Adding Xilinx XVC1"
    [AXI_IP_XVC XVC1]
    #========================================
    #  XVC2 (xilinx axi debug XVC)
    #========================================
    puts "Adding Xilinx XVC2"
    [AXI_IP_XVC XVC2]
    #========================================
    #  XVC_Local (xilinx axi debug XVC)
    #========================================
    puts "Adding Local Xilinx XVC"
    [AXI_IP_LOCAL_XVC XVC_LOCAL]

    
    #========================================
    #  MONITOR (xilinx axi XADC)
    #========================================
    puts "Adding Xilinx XADC Monitor"
    [AXI_IP_XADC MONITOR]

    
    #========================================
    #  AXI C2C 1
    #========================================
    set INIT_CLK init_clk
    create_bd_port -dir I -type clk ${INIT_CLK}
    set_property CONFIG.FREQ_HZ 50000000 [get_bd_ports ${INIT_CLK}]            
    [AXI_C2C_MASTER C2C1]
    
    #========================================
    #  Add non-xilinx AXI slave
    #========================================
    puts "Adding user slaves"
    #AXI_PL_CONNECT creates all the PL slaves in the list passed to it.
    [AXI_PL_CONNECT "SERV SLAVE_I2C CM "]

    validate_bd_design
}

