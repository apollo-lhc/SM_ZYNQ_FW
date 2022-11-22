source -notrace ${BD_PATH}/axi_helpers.tcl

proc get_part {} {
    return [get_parts -of_objects [get_projects]]
    }

proc set_default {dict key default} {
    if {[dict exists $dict $key]} {
        return [dict get $dict $key ]
    } else {
        return $default
    }
}

proc AXI_IP_AXI_ILA {params} {

    set_required_values $params {device_name axi_control}
    set_required_values $params {core_clk}

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == ila}] ${device_name}

    set_property -dict [list 
			CONFIG.C_EN_STRG_QUAL {1}
			CONFIG.C_ADV_TRIGGER {true}
			CONFIG.C_PROBE43_MU_CNT {2}
			CONFIG.C_PROBE42_MU_CNT {2}
			CONFIG.C_PROBE41_MU_CNT {2}
			CONFIG.C_PROBE40_MU_CNT {2}
			CONFIG.C_PROBE39_MU_CNT {2}
			CONFIG.C_PROBE38_MU_CNT {2}
			CONFIG.C_PROBE37_MU_CNT {2}
			CONFIG.C_PROBE36_MU_CNT {2}
			CONFIG.C_PROBE35_MU_CNT {2}
			CONFIG.C_PROBE34_MU_CNT {2}
			CONFIG.C_PROBE33_MU_CNT {2}
			CONFIG.C_PROBE32_MU_CNT {2}
			CONFIG.C_PROBE31_MU_CNT {2}
			CONFIG.C_PROBE30_MU_CNT {2}
			CONFIG.C_PROBE29_MU_CNT {2}
			CONFIG.C_PROBE28_MU_CNT {2}
			CONFIG.C_PROBE27_MU_CNT {2}
			CONFIG.C_PROBE26_MU_CNT {2}
			CONFIG.C_PROBE25_MU_CNT {2}
			CONFIG.C_PROBE24_MU_CNT {2}
			CONFIG.C_PROBE23_MU_CNT {2}
			CONFIG.C_PROBE22_MU_CNT {2}
			CONFIG.C_PROBE21_MU_CNT {2}
			CONFIG.C_PROBE20_MU_CNT {2}
			CONFIG.C_PROBE19_MU_CNT {2}
			CONFIG.C_PROBE18_MU_CNT {2}
			CONFIG.C_PROBE17_MU_CNT {2}
			CONFIG.C_PROBE16_MU_CNT {2}
			CONFIG.C_PROBE15_MU_CNT {2}
			CONFIG.C_PROBE14_MU_CNT {2}
			CONFIG.C_PROBE13_MU_CNT {2}
			CONFIG.C_PROBE12_MU_CNT {2}
			CONFIG.C_PROBE11_MU_CNT {2}
			CONFIG.C_PROBE10_MU_CNT {2}
			CONFIG.C_PROBE9_MU_CNT {2}
			CONFIG.C_PROBE8_MU_CNT {2}
			CONFIG.C_PROBE7_MU_CNT {2}
			CONFIG.C_PROBE6_MU_CNT {2}
			CONFIG.C_PROBE5_MU_CNT {2}
			CONFIG.C_PROBE4_MU_CNT {2}
			CONFIG.C_PROBE3_MU_CNT {2}
			CONFIG.C_PROBE2_MU_CNT {2}
			CONFIG.C_PROBE1_MU_CNT {2}
			CONFIG.C_PROBE0_MU_CNT {2}
			CONFIG.C_TRIGIN_EN {true}
			CONFIG.ALL_PROBE_SAME_MU_CNT {2}] [get_bd_cells ${device_name}]

    make_bd_pins_external  -name ${device_name}_TRIG_IN      [get_bd_intf_pins $device_name/trig_in]
    make_bd_pins_external  -name ${device_name}_TRIG_IN_ACK  [get_bd_intf_pins $device_name/trig_in_ack]
    make_bd_pins_external  -name ${device_name}_core_clk     [get_bd_intf_pins $device_name/clk]
    
    [AXI_DEV_CONNECT $params]
    
    
}

proc AXI_IP_DRP_INTF {params} {
    # required values
    set_required_values $params {device_name axi_control }
    set_required_values $params {drp_name init_clk drp_rstn}
    
    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    #turn on the DRP inteface on the transceiver
    set_property CONFIG.drp_mode             {AXI4_LITE}  [get_bd_cells ${drp_name}]    
    #connect this to the interconnect
    AXI_CONNECT  ${drp_name} ${axi_interconnect} ${init_clk} ${drp_rstn} ${axi_freq}
    AXI_SET_ADDR ${drp_name} ${offset} ${range} 
    AXI_GEN_DTSI ${drp_name} ${remote_slave}

}

proc AXI_IP_AXI_FW {params} {

    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {axi_fw_bus}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 4k} remote_slave 0]


    # $axi_fw_bus is the master of the line we want to put a firewall in
    # Get the slave that the master is currently connected to. 
    set get_slave_cmd "get_bd_intf_pins -of_objects \[get_bd_intf_nets -of_objects \[get_bd_intf_pins ${axi_fw_bus} \]\] -filter {MODE == Slave}"
    set get_slave_cmd_fallback "get_bd_intf_pins -of_objects \[get_bd_intf_nets -of_objects \[get_bd_intf_ports ${axi_fw_bus} \]\] -filter {MODE == Slave}"
    set get_master_cmd "get_bd_intf_pins -of_objects \[get_bd_intf_nets -of_objects \[get_bd_intf_pins ${axi_fw_bus} \]\] -filter {MODE == Master}"
    set get_master_cmd_fallback "get_bd_intf_ports -of_objects \[get_bd_intf_nets -of_objects \[get_bd_intf_ports ${axi_fw_bus} \]\]"

    set slave_interface [eval ${get_slave_cmd}]
    if { [llength $slave_interface] == 0} {
	#Didn't find any results, it is possible this is due to vivado thining this is a port, not a pin
	#retry with port (fallback query)
	set slave_interface [eval ${get_slave_cmd_fallback}]
    }
    set master_interface [eval ${get_master_cmd}]
    if { [llength $master_interface] == 0} {
	#Didn't find any results, it is possible this is due to vivado thining this is a port, not a pin
	#retry with port (fallback query)
	set master_interface [eval ${get_master_cmd_fallback}]
    }

    puts "Slave interface: ${slave_interface}"
    puts "Master interface: ${master_interface}"
    
    #delete the net connection
    if { [llength [get_bd_intf_nets -of_objects [get_bd_intf_pins ${axi_fw_bus}]]] != 0 } {
	delete_bd_objs [get_bd_intf_nets -of_objects [get_bd_intf_pins ${axi_fw_bus}]]
    } else {
	delete_bd_objs [get_bd_intf_nets -of_objects [get_bd_intf_ports ${axi_fw_bus}]]
    }
    
    #create the AXI FW IP
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_firewall }] ${device_name}
    
    #connect the master to the new slave on the AXI FW
    #    connect_bd_intf_net [get_bd_intf_pins $device_name/S_AXI] -boundary_type upper [get_bd_intf_pins $master_interface]
    connect_bd_intf_net [get_bd_intf_pins $device_name/S_AXI] -boundary_type upper $master_interface
    #connect the AXI fw to the slave
    connect_bd_intf_net ${slave_interface} -boundary_type upper [get_bd_intf_pins $device_name/M_AXI]
    
#    [AXI_CTL_DEV_CONNECT $device_name $axi_interconnect $axi_clk $axi_rstn $axi_freq $addr_offset $addr_range $remote_slave]    
    [AXI_CTL_DEV_CONNECT $params]    
#    [AXI_DEV_UIO_DTSI_POST_CHUNK ${device_name}]
}

proc AXI_IP_AXI_MONITOR {params} {


    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {core_clk core_rstn}

    # these parameters are special, since they expect lists rather than dicts
    set mon_axi [dict get $params mon_axi]
    set mon_axi_clk [dict get $params mon_axi_clk]
    set mon_axi_rstn [dict get $params mon_axi_rstn]

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 4K} remote_slave 0]

    set mon_slots 0
    #check for an axi bus size mismatch
    if {[llength mon_axi] != [llength mon_clk] || [llength mon_axi] != [llength mon_rstn]} then {
        error "master size mismatch"
    }
    set mon_slots [llength $mon_axi]
    
    #create device
    set NAME ${device_name}
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_perf_mon}] ${NAME}
    set_property CONFIG.C_ENABLE_EVENT_COUNT {1}          [get_bd_cells ${NAME}]
    set_property CONFIG.C_NUM_MONITOR_SLOTS  ${mon_slots} [get_bd_cells ${NAME}]
    set_property CONFIG.ENABLE_EXT_TRIGGERS  {0}          [get_bd_cells ${NAME}]
    set_property CONFIG.C_ENABLE_ADVANCED    {1}          [get_bd_cells ${NAME}]
    set_property CONFIG.C_ENABLE_PROFILE     {0}          [get_bd_cells ${NAME}]
    set_property CONFIG.C_ENABLE_PROFILE     {0}          [get_bd_cells ${NAME}]
    #set the number of counters
    set_property CONFIG.C_NUM_OF_COUNTERS   {10}          [get_bd_cells ${NAME}]

    connect_bd_net [get_bd_pins [format "/%s/core_aclk" ${device_name} ] ] [get_bd_pins ${core_clk}] 
    connect_bd_net [get_bd_pins [format "/%s/core_aresetn" ${device_name} ] ] [get_bd_pins ${core_rstn}] 

    puts "Added Xilinx AXI monitor & AXI Slave: $device_name"
    puts "Monitoring: "
   
    #connect up the busses to be comonitored
    for {set iMon 0} {$iMon < ${mon_slots}} {incr iMon} {

        set slot_AXI [format "/%s/SLOT_%d_AXI" ${device_name} $iMon]
        set slot_clk [format "/%s/slot_%d_axi_aclk" ${device_name} $iMon]
        set slot_rstn [format "/%s/slot_%d_axi_aresetn" ${device_name} $iMon]

        set spy_AXI  [lindex ${mon_axi}      $iMon]
        set spy_clk  [lindex ${mon_axi_clk}  $iMon]
        set spy_rstn [lindex ${mon_axi_rstn} $iMon]

        puts "$iMon:  $spy_AXI"

        # for some reason this sometimes returned "AXI3 AXI3" instead of just AXI3.... so I take the lindex 0
        set_property CONFIG.C_SLOT_${iMon}_AXI_PROTOCOL [lindex [get_property CONFIG.PROTOCOL [get_bd_intf_pins ${spy_AXI}]] 0] [get_bd_cells ${NAME}]

        #connect the AXI bus
        connect_bd_intf_net [get_bd_intf_pins ${slot_AXI}] -boundary_type upper [get_bd_intf_pins ${spy_AXI} ]
        #connet the AXI bus clock
        connect_bd_net [get_bd_pins ${slot_clk}] [get_bd_pins ${spy_clk}]
        #connet the AXI bus resetn
        connect_bd_net [get_bd_pins ${slot_rstn}] [get_bd_pins ${spy_rstn}]

    }

    #connect to AXI, clk, and reset between slave and master
    [AXI_DEV_CONNECT $params]
    puts "Finished Xilinx AXI Monitor: $device_name"
}

proc AXI_IP_I2C {params} {

    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {irq_port}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_iic}] $device_name

    #create external pins
    make_bd_pins_external  -name ${device_name}_scl_i [get_bd_pins $device_name/scl_i]
    make_bd_pins_external  -name ${device_name}_sda_i [get_bd_pins $device_name/sda_i]
    make_bd_pins_external  -name ${device_name}_sda_o [get_bd_pins $device_name/sda_o]
    make_bd_pins_external  -name ${device_name}_scl_o [get_bd_pins $device_name/scl_o]
    make_bd_pins_external  -name ${device_name}_scl_t [get_bd_pins $device_name/scl_t]
    make_bd_pins_external  -name ${device_name}_sda_t [get_bd_pins $device_name/sda_t]
    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    #connect interrupt
    CONNECT_IRQ ${device_name}/iic2intc_irpt ${irq_port}

    puts "Added Xilinx I2C AXI Slave: $device_name"
}

proc AXI_IP_XVC {params} {

    # required values
    set_required_values $params {device_name axi_control}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == debug_bridge}] $device_name
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE  {3} [get_bd_cells $device_name]
    set_property CONFIG.C_DESIGN_TYPE {0} [get_bd_cells $device_name]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    
    #generate ports for the JTAG signals
    make_bd_pins_external       [get_bd_cells $device_name]
    make_bd_intf_pins_external  [get_bd_cells $device_name]

    puts "Added Xilinx XVC AXI Slave: $device_name"
}

proc AXI_IP_LOCAL_XVC {params} {

    # required values
    set_required_values $params {device_name axi_control}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 4k} remote_slave 0]

    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == debug_bridge}] $device_name
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE {2}     [get_bd_cells $device_name]
    set_property CONFIG.C_BSCAN_MUX {2}      [get_bd_cells $device_name]
    set_property CONFIG.C_XVC_HW_ID {0x0001} [get_bd_cells $device_name]

    
    #test
    set_property CONFIG.C_NUM_BS_MASTER {1} [get_bd_cells $device_name]

    
    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]


    #test
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == debug_bridge }] debug_bridge_0
    connect_bd_intf_net [get_bd_intf_pins ${device_name}/m0_bscan] [get_bd_intf_pins debug_bridge_0/S_BSCAN]
    connect_bd_net [get_bd_pins debug_bridge_0/clk] [get_bd_pins $axi_clk]

    puts "Added Xilinx Local XVC AXI Slave: $device_name"
    
}

proc AXI_IP_UART {params} {


    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {baud_rate irq_port}

    # optional values
    # remote_slave -1 means don't generate a dtsi_ file
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave -1 ]

    #Create a xilinx UART
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_uartlite }] $device_name
    #configure the debug bridge to be
    set_property CONFIG.C_BAUDRATE $baud_rate [get_bd_cells $device_name]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    
    #generate ports for the UART
    make_bd_intf_pins_external  -name ${device_name} [get_bd_intf_pins $device_name/UART]

    #connect interrupt
    CONNECT_IRQ ${device_name}/interrupt ${irq_port}

    
    puts "Added Xilinx UART AXI Slave: $device_name"
}

#primary_serdes == 1 means this is the primary serdes, if not 1, then it is the name of the primary_serdes
proc C2C_AURORA {params} {

    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {primary_serdes init_clk refclk_freq}

    set_optional_values $params {speed 5}
    set_optional_values $params {singleend_refclk False}

    if {$primary_serdes == 1} {
	puts "Creating ${device_name} as a primary serdes\n"
    } else {
	puts "Creating ${device_name} using ${primary_serdes} as the primary serdes\n"
    }

    #set names
    set C2C ${device_name}
    set C2C_PHY ${C2C}_PHY    

    #create chip-2-chip aurora     
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == aurora_64b66b }] ${C2C_PHY}        
    set_property CONFIG.C_INIT_CLK.VALUE_SRC PROPAGATED   [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_AURORA_LANES       {1}          [get_bd_cells ${C2C_PHY}]
    set_property CONFIG.C_LINE_RATE          $speed          [get_bd_cells ${C2C_PHY}]
    set_property CONFIG.C_REFCLK_FREQUENCY   ${refclk_freq}    [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.interface_mode       {Streaming}  [get_bd_cells ${C2C_PHY}]
    if {$primary_serdes == 1} {
	set_property CONFIG.SupportLevel     {1}          [get_bd_cells ${C2C_PHY}]
    } else {
	set_property CONFIG.SupportLevel     {0}          [get_bd_cells ${C2C_PHY}]
    }
    set_property CONFIG.SINGLEEND_INITCLK    {true}       [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_USE_CHIPSCOPE      {true}       [get_bd_cells ${C2C_PHY}]
    set_property CONFIG.drp_mode             {NATIVE}     [get_bd_cells ${C2C_PHY}]
    set_property CONFIG.TransceiverControl   {true}       [get_bd_cells ${C2C_PHY}]
   
    set_property CONFIG.SINGLEEND_GTREFCLK   [expr {${singleend_refclk}} ] [get_bd_cells ${C2C_PHY}]

    #expose the DRP interface
    make_bd_intf_pins_external  -name ${C2C_PHY}_DRP                       [get_bd_intf_pins ${C2C_PHY}/*DRP*]
   
    #expose the Aurora core signals to top    
    if {$primary_serdes == 1} {
	#these are only if the serdes is the primary one

	if { [expr {${singleend_refclk}} ] } {
	    make_bd_pins_external       -name ${C2C_PHY}_refclk               [get_bd_pins ${C2C_PHY}/REFCLK1_in]    
	} else {
	    make_bd_intf_pins_external  -name ${C2C_PHY}_refclk               [get_bd_intf_pins ${C2C_PHY}/GT_DIFF_REFCLK1]    
            make_bd_pins_external       -name ${C2C_PHY}_gt_refclk1_out       [get_bd_pins [list ${C2C_PHY}/gt_refclk1_out ${C2C_PHY}/refclk1_in]]
	}

    }								          
    make_bd_intf_pins_external      -name ${C2C_PHY}_Rx                   [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_RX]       
    make_bd_intf_pins_external      -name ${C2C_PHY}_Tx                   [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_TX]
    make_bd_pins_external           -name ${C2C_PHY}_power_down           [get_bd_pins ${C2C_PHY}/power_down]       
    make_bd_pins_external           -name ${C2C_PHY}_gt_pll_lock          [get_bd_pins ${C2C_PHY}/gt_pll_lock]
    make_bd_pins_external           -name ${C2C_PHY}_hard_err             [get_bd_pins ${C2C_PHY}/hard_err]
    make_bd_pins_external           -name ${C2C_PHY}_soft_err             [get_bd_pins ${C2C_PHY}/soft_err]
    make_bd_pins_external           -name ${C2C_PHY}_lane_up              [get_bd_pins ${C2C_PHY}/lane_up]
    make_bd_pins_external           -name ${C2C_PHY}_mmcm_not_locked_out  [get_bd_pins ${C2C_PHY}/mmcm_not_locked_out]       
    make_bd_pins_external           -name ${C2C_PHY}_link_reset_out       [get_bd_pins ${C2C_PHY}/link_reset_out]
    make_bd_pins_external           -name ${C2C_PHY}_channel_up    [get_bd_pins ${C2C_PHY}/channel_up]

    if { [string first u [get_part] ] == -1 && [string first U [get_part] ] == -1 } {   
	#7-series debug name
	make_bd_intf_pins_external  -name ${C2C_PHY}_DEBUG                [get_bd_intf_pins ${C2C_PHY}/TRANSCEIVER_DEBUG0]
    } else {
	#USP debug name
	make_bd_intf_pins_external  -name ${C2C_PHY}_DEBUG                [get_bd_intf_pins ${C2C_PHY}/TRANSCEIVER_DEBUG]
    }

    
    
    #connect C2C core with the C2C-mode Auroroa core   
    connect_bd_intf_net [get_bd_intf_pins ${C2C}/AXIS_TX] [get_bd_intf_pins ${C2C_PHY}/USER_DATA_S_AXIS_TX]        
    connect_bd_intf_net [get_bd_intf_pins ${C2C_PHY}/USER_DATA_M_AXIS_RX]   [get_bd_intf_pins ${C2C}/AXIS_RX]        
    connect_bd_net      [get_bd_pins      ${C2C_PHY}/channel_up]            [get_bd_pins ${C2C}/axi_c2c_aurora_channel_up]     
    connect_bd_net      [get_bd_pins      ${C2C}/aurora_pma_init_out]       [get_bd_pins ${C2C_PHY}/pma_init]        
    connect_bd_net      [get_bd_pins      ${C2C}/aurora_reset_pb]           [get_bd_pins ${C2C_PHY}/reset_pb]        
    if {$primary_serdes == 1} {						    
	connect_bd_net  [get_bd_pins      ${C2C_PHY}/user_clk_out]          [get_bd_pins ${C2C}/axi_c2c_phy_clk]
	connect_bd_net  [get_bd_pins      ${C2C_PHY}/mmcm_not_locked_out]   [get_bd_pins ${C2C}/aurora_mmcm_not_locked]        
    } else {
	connect_bd_net  [get_bd_pins ${primary_serdes}/user_clk_out]        [get_bd_pins ${C2C_PHY}/user_clk]
	connect_bd_net  [get_bd_pins ${primary_serdes}/user_clk_out]        [get_bd_pins ${C2C}/axi_c2c_phy_clk]
	connect_bd_net  [get_bd_pins ${primary_serdes}/mmcm_not_locked_out] [get_bd_pins ${C2C}/aurora_mmcm_not_locked]        
    }
    
    #connect external clock to init clocks      
    connect_bd_net [get_bd_ports ${init_clk}]   [get_bd_pins ${C2C_PHY}/init_clk]       
    connect_bd_net [get_bd_ports ${init_clk}]   [get_bd_pins ${C2C}/aurora_init_clk]    
    #drp port fixed to init clk in USP
    if { [string first u [get_part] ] == -1 && [string first U [get_part] ] == -1 } {
	#connect drp clock explicitly in 7-series
	connect_bd_net [get_bd_ports ${init_clk}]   [get_bd_pins ${C2C_PHY}/drp_clk_in]
	#output the qpll lock in 7series since it isn't in the debug group
	make_bd_pins_external       -name ${C2C_PHY}_gt_qplllock                 [get_bd_pins ${C2C_PHY}/gt_qplllock]
    }

    if {$primary_serdes == 1} {
	#provide a clk output of the C2C_PHY user clock 
	create_bd_port -dir O -type clk ${C2C_PHY}_CLK
        connect_bd_net [get_bd_ports ${C2C_PHY}_CLK] [get_bd_pins ${C2C_PHY}/user_clk_out]	
    } else {
	#connect up clocking resource to primary C2C_PHY
	connect_bd_net [get_bd_pins     [get_bd_pins [list ${primary_serdes}/gt_refclk1_out ${primary_serdes}/refclk1_in]] ]            [get_bd_pins ${C2C_PHY}/refclk1_in]
	if { [string first u [get_part] ] == -1 && [string first U [get_part] ] == -1 } {
	    #only in 7-series
  	    connect_bd_net [get_bd_pins ${primary_serdes}/gt_qpllclk_quad3_out]      [get_bd_pins ${C2C_PHY}/gt_qpllclk_quad3_in]
	    connect_bd_net [get_bd_pins ${primary_serdes}/gt_qpllrefclk_quad3_out]   [get_bd_pins ${C2C_PHY}/gt_qpllrefclk_quad3_in]
	}
	connect_bd_net [get_bd_pins     ${primary_serdes}/sync_clk_out]              [get_bd_pins ${C2C_PHY}/sync_clk]
    }

    #enable eyescans by default
    global post_synth_commands
    if { \
	     [expr [string first xczu [get_parts -of_objects [get_projects] ] ] >= 0 ] || \
	     [expr [string first xcku [get_parts -of_objects [get_projects] ] ] >= 0 ] || \
	     [expr [string first xcvu [get_parts -of_objects [get_projects] ] ] >= 0 ]} {
	lappend post_synth_commands [format "set_property ES_EYE_SCAN_EN True \[get_cells -hierarchical -regexp .*%s/.*CHANNEL_PRIM_INST\]" ${C2C_PHY}]
    } else {
	lappend post_synth_commands [format "set_property ES_EYE_SCAN_EN True \[get_cells -hierarchical -regexp .*%s/.*gtx_inst/gt.*\]" ${C2C_PHY}]
    }
    puts $post_synth_commands
}

proc AXI_C2C_MASTER {params} {

    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {primary_serdes init_clk refclk_freq}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} addr_lite {offset -1 range 64K} irq_port "."]

    set_optional_values $params {c2c_master true}
    set_optional_values $params {singleend_refclk False}
    set_optional_values $params {speed 5}

    #create the actual C2C master
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_chip2chip }] $device_name
    set_property CONFIG.C_AXI_STB_WIDTH     {4}     [get_bd_cells $device_name]
    set_property CONFIG.C_AXI_DATA_WIDTH    {32}    [get_bd_cells $device_name]
    set_property CONFIG.C_NUM_OF_IO         {58.0}  [get_bd_cells $device_name]
    set_property CONFIG.C_INTERFACE_MODE    {0}	    [get_bd_cells $device_name]
    set_property CONFIG.C_INTERFACE_TYPE    {2}	    [get_bd_cells $device_name]
    set_property CONFIG.C_MASTER_FPGA       [expr $c2c_master == true]	    [get_bd_cells $device_name]
    set_property CONFIG.C_INCLUDE_AXILITE   [expr 1 + [expr $c2c_master == false]]	    [get_bd_cells $device_name]
    set_property CONFIG.C_AURORA_WIDTH      {1.0}   [get_bd_cells $device_name]
    set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells $device_name]
#    set_property CONFIG.C_INCLUDE_AXILITE   {1}     [get_bd_cells $device_name]
    set_property CONFIG.C_M_AXI_WUSER_WIDTH {0}     [get_bd_cells $device_name]
    set_property CONFIG.C_M_AXI_ID_WIDTH {0}        [get_bd_cells $device_name]


    #set type of clock connection based on if this is a c2c master or not
    if {$c2c_master == true} {
	set ms_type "s"
    } else {
	set ms_type "m"
    }
    
    #connect AXI interface interconnect (firewall will cut this and insert itself)
    if { [dict exists $params addr] } {
	set AXI_params $params
	dict set AXI_params addr [dict get $params addr]
	dict set AXI_params remote_slave -1
	dict set AXI_params force_mem 1
	[AXI_DEV_CONNECT $AXI_params]    
	BUILD_AXI_ADDR_TABLE ${device_name}_Mem0 ${device_name}_AXI_BRIDGE
    } else {
	AXI_CLK_CONNECT $device_name $axi_clk $axi_rstn $ms_type
    }

    if { [dict exists $params addr_lite] } {
	set AXILite_params $params
	dict set AXILite_params addr [dict get $params addr_lite]
	dict set AXILite_params remote_slave -1
	[AXI_LITE_DEV_CONNECT $AXILite_params]
	BUILD_AXI_ADDR_TABLE ${device_name}_Reg ${device_name}_AXI_LITE_BRIDGE
    } else {
	AXI_LITE_CLK_CONNECT $device_name $axi_clk $axi_rstn $ms_type
    }



    make_bd_pins_external       -name ${device_name}_aurora_pma_init_in          [get_bd_pins ${device_name}/aurora_pma_init_in]
    #expose debugging signals
    make_bd_pins_external       -name ${device_name}_aurora_do_cc                [get_bd_pins ${device_name}/aurora_do_cc]
    make_bd_pins_external       -name ${device_name}_axi_c2c_config_error_out    [get_bd_pins ${device_name}/axi_c2c_config_error_out   ]
    make_bd_pins_external       -name ${device_name}_axi_c2c_link_status_out     [get_bd_pins ${device_name}/axi_c2c_link_status_out    ]
    make_bd_pins_external       -name ${device_name}_axi_c2c_multi_bit_error_out [get_bd_pins ${device_name}/axi_c2c_multi_bit_error_out]
    make_bd_pins_external       -name ${device_name}_axi_c2c_link_error_out      [get_bd_pins ${device_name}/axi_c2c_link_error_out     ]

    
    C2C_AURORA [dict create device_name ${device_name} \
                    axi_control [dict get $params axi_control] \
                    primary_serdes $primary_serdes \
                    init_clk $init_clk \
                    refclk_freq $refclk_freq \
		    speed $speed \
		    singleend_refclk $singleend_refclk \
		   ]
    

    #connect interrupt
    if { ${irq_port} != "."} {
	CONNECT_IRQ ${device_name}/axi_c2c_s2m_intr_out ${irq_port}
    }
    

    #assign_bd_address [get_bd_addr_segs {$device_name/S_AXI/Mem }]
    puts "Added C2C master: $device_name"
}

proc AXI_IP_XADC {params} {

    # required values
    set_required_values $params {device_name axi_control}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    #create XADC AXI slave 
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == xadc_wiz }] ${device_name}

    #disable default user temp monitoring
    set_property CONFIG.USER_TEMP_ALARM {false} [get_bd_cells ${device_name}]

    
    #connect to interconnect
    [AXI_DEV_CONNECT $params]

    
    #expose alarms
    make_bd_pins_external   -name ${device_name}_alarm             [get_bd_pins ${device_name}/alarm_out]
    make_bd_pins_external   -name ${device_name}_vccint_alarm      [get_bd_pins ${device_name}/vccint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccaux_alarm      [get_bd_pins ${device_name}/vccaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccpint_alarm     [get_bd_pins ${device_name}/vccpint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccpaux_alarm     [get_bd_pins ${device_name}/vccpaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccddro_alarm     [get_bd_pins ${device_name}/vccddro_alarm_out]
    make_bd_pins_external   -name ${device_name}_overtemp_alarm    [get_bd_pins ${device_name}/ot_alarm_out]

    puts "Added Xilinx XADC AXI Slave: $device_name"

}

proc AXI_IP_SYS_MGMT {params} {

    # required values
    set_required_values $params {device_name axi_control}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0 enable_i2c_pins 0]
    
    #create system management AXIL lite slave
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == system_management_wiz }] ${device_name}

    #disable default user temp monitoring
    set_property CONFIG.USER_TEMP_ALARM {false}        [get_bd_cells ${device_name}]
    #add i2c interface
    if {$enable_i2c_pins} {
      set_property CONFIG.SERIAL_INTERFACE {Enable_I2C}  [get_bd_cells ${device_name}]
      set_property CONFIG.I2C_ADDRESS_OVERRIDE {false}   [get_bd_cells ${device_name}]
    }
    
    #connect to interconnect
#    [AXI_DEV_CONNECT $params]
    [AXI_DEV_CONNECT $params]

    
    #expose alarms
    make_bd_pins_external   -name ${device_name}_alarm             [get_bd_pins ${device_name}/alarm_out]
    make_bd_pins_external   -name ${device_name}_vccint_alarm      [get_bd_pins ${device_name}/vccint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccaux_alarm      [get_bd_pins ${device_name}/vccaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_overtemp_alarm    [get_bd_pins ${device_name}/ot_out]

    #expose i2c interface
    make_bd_pins_external  -name ${device_name}_sda [get_bd_pins ${device_name}/i2c_sda]
    make_bd_pins_external  -name ${device_name}_scl [get_bd_pins ${device_name}/i2c_sclk]
    
    puts "Added Xilinx XADC AXI Slave: $device_name"

}

proc AXI_IP_BRAM_CONTROL {params} {

    # required values
    set_required_values $params {device_name axi_control}
    set_required_values $params {width}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    # create bd cell
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_bram_ctrl }] ${device_name}

    # convert the address range into a bram controller depth
    set depths [dict create 1k 1024 2k 2048 4k 4096 8k 8192 16k 16384 32k 32768 64k 65536 128k 131072 256k 262144]
    set depth [dict get $depths [string tolower $range]]

    set cell [get_bd_cells $device_name]

    # make connections
    [AXI_DEV_CONNECT $params]

    # set width
    set_property -dict [list CONFIG.MEM_DEPTH $depth CONFIG.READ_WRITE_MODE "READ_WRITE" CONFIG.SINGLE_PORT_BRAM {1} CONFIG.DATA_WIDTH $width] $cell

    # connect to a port
    make_bd_pins_external       -name ${device_name}_port $cell
    make_bd_intf_pins_external  -name ${device_name}_port $cell

    set_property -dict [list CONFIG.READ_WRITE_MODE {READ_WRITE}] [get_bd_intf_ports ${device_name}_port]
}

proc AXI_IP_BRAM {params} {

    # required values
    set_required_values $params {device_name axi_control}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    #create XADC AXI slave
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_bram_ctrl }] ${device_name}

    set_property CONFIG.SINGLE_PORT_BRAM {1} [get_bd_cells ${device_name}]

    
    #connect to interconnect
    [AXI_DEV_CONNECT $params]


    #connect this to a blockram
    set BRAM_NAME ${device_name}_RAM
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == blk_mem_gen }] ${BRAM_NAME}
    set_property CONFIG.Memory_Type            {True_Dual_Port_RAM}   [get_bd_cells ${BRAM_NAME}]
    set_property CONFIG.Assume_Synchronous_Clk {false}                [get_bd_cells ${BRAM_NAME}]

    
    #connect BRAM controller to BRAM
    connect_bd_intf_net [get_bd_intf_pins ${device_name}/BRAM_PORTA] [get_bd_intf_pins ${BRAM_NAME}/BRAM_PORTA]

    #make the other port external to the PL
    make_bd_intf_pins_external  [get_bd_intf_pins ${BRAM_NAME}/BRAM_PORTB]

    puts "Added Xilinx blockram: $device_name"
}


proc AXI_IP_IRQ_CTRL {params} {
    # required values
    set_required_values $params {device_name axi_control irq_dest}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    set_optional_values $params [dict create sw_intr_count 0]

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_intc}] $device_name

    #global value for tracking
    global IRQ_COUNT_${device_name}
    set IRQ_COUNT_${device_name} 0

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    connect_bd_net [get_bd_pins ${device_name}/irq] [get_bd_pins ${irq_dest}]
    set IRQ_CONCAT ${device_name}_IRQ
    create_bd_cell -type ip -vlnv  [get_ipdefs -filter {NAME == xlconcat}] ${IRQ_CONCAT}
    connect_bd_net [get_bd_pins ${IRQ_CONCAT}/dout] [get_bd_pins ${device_name}/intr]
    puts "Added Xilinx Interrupt Controller AXI Slave: $device_name"
}

proc CONNECT_IRQ {irq_src irq_dest} {
    #connect to global for this irq controller
    global IRQ_COUNT_${irq_dest}
    if { [info exists IRQ_COUNT_${irq_dest}] == 0 } {
	set IRQ_COUNT_${irq_dest} 0	
    }

    upvar 0 IRQ_COUNT_${irq_dest} IRQ_COUNT

    if [llength [get_bd_cells -quiet ${irq_dest}_IRQ]] {
	set dest_name ${irq_dest}_IRQ
    
	set input_port_count [get_property CONFIG.NUM_PORTS [get_bd_cells $dest_name]]
    
	if { ${IRQ_COUNT} >= $input_port_count} {
	    #expand the concact part of the controller
	    set_property CONFIG.NUM_PORTS [expr {$input_port_count + 1}] [get_bd_cells $dest_name]
	}

	connect_bd_net [get_bd_pins ${irq_src}] [get_bd_pins ${dest_name}/In${IRQ_COUNT}]  

	puts "Connecting IRQ: ${irq_src} to ${dest_name}/In${IRQ_COUNT}"

	#expand the number of IRQs connected to this
	set IRQ_COUNT [expr {$IRQ_COUNT + 1}]
    } else {
	connect_bd_net [get_bd_pins ${irq_src}] [get_bd_pins ${irq_dest}]  
	puts "Connecting IRQ: ${irq_src} to ${irq_dest}"
    }
}

proc IP_SYS_RESET {params} {
    # required values
    set_required_values $params {device_name external_reset_n slowest_clk}

    # optional values
    set_optional_values $params {aux_reset "NULL"}

    #createIP
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == proc_sys_reset}] $device_name

    #connect external reset
    set_property -dict [list CONFIG.C_AUX_RST_WIDTH {1} CONFIG.C_AUX_RESET_HIGH {0}] [get_bd_cells $device_name]
    connect_bd_net [get_bd_pins ${external_reset_n}] [get_bd_pins ${device_name}/ext_reset_in]
    #connect clock
    connect_bd_net [get_bd_pins ${slowest_clk}] [get_bd_pins ${device_name}/slowest_sync_clk]

    #aux_reset
    if {${aux_reset} != "NULL"} {
	set_property -dict [list CONFIG.C_AUX_RST_WIDTH {1} CONFIG.C_AUX_RESET_HIGH {1}] [get_bd_cells $device_name]
	connect_bd_net [get_bd_pins ${aux_reset}] [get_bd_pins ${device_name}/aux_reset_in]
    }
}

proc AXI_IP_CDMA {params} {
    global AXI_INTERCONNECT_MASTER_SIZE
    # required values
    set_required_values $params {device_name axi_control irq_port zynq_axi zynq_clk}

    # optional values
    set_optional_values $params [dict create addr {offset -1 range 64K} remote_slave 0]

    #createIP
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_cdma}] $device_name

    set_property CONFIG.C_M_AXI_MAX_BURST_LEN {256}  [get_bd_cells $device_name]
    set_property CONFIG.C_INCLUDE_SF {1}             [get_bd_cells $device_name]
    set_property CONFIG.C_INCLUDE_SG {0}             [get_bd_cells $device_name]

    #connect up the master connection
    set CDMAMaster "$device_name/M_AXI"
    set CDMAClk    "$device_name/m_axi_aclk"
    set CDMARstn   "$device_name/m_axi_rstn"

    #connect CDMA master to a slave interface
    if { [llength [array names AXI_INTERCONNECT_MASTER_SIZE -exact $zynq_axi ] ] > 0} {
	#parent is an interconnect
	EXPAND_AXI_INTERCONNECT [dict create interconnect $zynq_axi]
	connect_bd_net -q [get_bd_pins  $zynq_clk ] [get_bd_pins $AXI_MASTER_CLK]
	connect_bd_net -q [get_bd_ports $zynq_clk ] [get_bd_pins $AXI_MASTER_CLK]
	connect_bd_net -q [get_bd_pins  $axi_rstn ] [get_bd_pins $AXI_MASTER_RSTN]
	connect_bd_net -q [get_bd_ports $axi_rstn ] [get_bd_pins $AXI_MASTER_RSTN]
	connect_bd_intf_net [get_bd_intf_pins $AXI_MASTER_BUS] -boundary_type upper \
	    [get_bd_intf_pins $CDMAMaster]		
    } else {
	connect_bd_intf_net [get_bd_intf_pins $zynq_axi] -boundary_type upper [get_bd_intf_pins $CDMAMaster]		
    }

    connect_bd_net -quiet [get_bd_pins $CDMAClk] [get_bd_pins $zynq_clk]
    connect_bd_net -quiet [get_bd_pins $CDMAClk] [get_bd_pins $axi_clk]
    connect_bd_net -quiet [get_bd_pins $zynq_clk] [get_bd_pins $axi_clk]

    
    #connect up AXI_LITE interfacee
    AXI_LITE_DEV_CONNECT $params

    #connect interrupt
    CONNECT_IRQ ${device_name}/cdma_introut ${irq_port}
    puts "finished CDMA"
}

proc AXI_IP_SYSTEM_ILA {params} {
    # required values
    set_required_values $params {device_name axi_clk axi_rstn}
    set_required_values $params {slots} False

    # optional values
    set_optional_values $params [dict create scatter_gather 0]; #0 off, 1 on

    
    #createIP
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == system_ila}] $device_name

    #scatter gather options
    set_property CONFIG.C_INCLUDE_SG $scatter_gather [get_bd_cells ${device_name}]
    
    set slot_count 0
    dict for {slot info} $slots {
	set current_slot ${slot_count}
	incr slot_count
	set_property CONFIG.C_NUM_MONITOR_SLOTS $slot_count  [get_bd_cells ${device_name}]
	dict with info {
	    #connect the AXI bus to monitor
	    connect_bd_intf_net [get_bd_intf_pins $axi_bus] -boundary_type upper [get_bd_intf_pins ${device_name}/SLOT_${current_slot}_AXI]
	}
    }

    #connect up clocks and resets
    connect_bd_net -quiet [get_bd_pins $axi_clk]                         [get_bd_pins ${device_name}/clk]
    connect_bd_net -quiet [get_bd_pins $axi_rstn]                        [get_bd_pins ${device_name}/resetn]    

	
    }
    
    
    
