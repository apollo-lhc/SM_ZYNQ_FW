set name LDAQ_MGBT

set output_path ${apollo_root_path}/configs/${build_name}/cores/

file mkdir ${output_path}

if { [file exists ${output_path}/${name}/${name}.xci] && ([file mtime ${output_path}/${name}/${name}.xci] > [file mtime ${output_path}/${name}.tcl])} {
    set filename "${output_path}/${name}/${name}.xci"
    set ip_name [file rootname [file tail $filename]]
    #normal xci file
    read_ip $filename
    set isLocked [get_property IS_LOCKED [get_ips $ip_name]]
    puts "IP $ip_name : locked = $isLocked"
    set upgrade  [get_property UPGRADE_VERSIONS [get_ips $ip_name]]
    if {$isLocked && $upgrade != ""} {
	puts "Upgrading IP"
	upgrade_ip [get_ips $ip_name]
    }    
} else {
    file delete -force ${apollo_root_path}/configs/${build_name}/cores/${name}

    #create the gtwizard_ultrascale ip
    create_ip -vlnv [get_ipdefs -filter {NAME == gtwizard_ultrascale}] -module_name ${name} -dir ${output_path}

    #modify the properties
    set_property -dict [list \
			    CONFIG.LOCATE_COMMON {CORE}               \
			    CONFIG.LOCATE_TX_USER_CLOCKING {CORE}     \
			    CONFIG.LOCATE_RX_USER_CLOCKING {CORE}     \
			    CONFIG.TX_LINE_RATE {10.260224}           \
			    CONFIG.TX_PLL_TYPE {QPLL0}                \
			    CONFIG.TX_REFCLK_FREQUENCY {320.632}  \
			    CONFIG.TX_DATA_ENCODING {8B10B}           \
			    CONFIG.TX_INT_DATA_WIDTH {40}             \
			    CONFIG.RX_LINE_RATE {10.260224}           \
			    CONFIG.RX_REFCLK_FREQUENCY {320.632}  \
			    CONFIG.RX_DATA_DECODING {8B10B}           \
			    CONFIG.RX_INT_DATA_WIDTH {40}             \
			    CONFIG.RX_JTOL_FC {6.1549034}             \
			    CONFIG.RX_COMMA_P_ENABLE {true}           \
			    CONFIG.RX_COMMA_M_ENABLE {true}           \
			    CONFIG.RX_COMMA_MASK {1111111111}         \
			    CONFIG.RX_COMMA_ALIGN_WORD {4}            \
			    CONFIG.TXPROGDIV_FREQ_SOURCE {QPLL0}      \
			    CONFIG.FREERUN_FREQUENCY {50}             \
			    CONFIG.Component_Name ${name}             \
			   ] [get_ips ${name}]
}




#			    CONFIG.RX_REFCLK_SOURCE {X0Y4 clk0+2}     \
#			    CONFIG.TX_REFCLK_SOURCE {X0Y4 clk0+2}     \
