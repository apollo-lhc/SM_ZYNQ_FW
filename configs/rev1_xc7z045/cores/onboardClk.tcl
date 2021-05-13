set name onboardClk

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

    #create IP
    create_ip -vlnv [get_ipdefs -filter {NAME == clk_wiz}] -module_name ${name} -dir ${output_path}


    set_property -dict [list \
			    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
			    CONFIG.PRIM_IN_FREQ {200} \
			    CONFIG.PRIMARY_PORT {clk_in} \
			    CONFIG.NUM_OUT_CLKS {2} \
			    CONFIG.CLKOUT2_USED {true} \
			    CONFIG.CLKOUT3_USED {true} \
			    CONFIG.CLK_OUT1_PORT {clk_50Mhz} \
			    CONFIG.CLK_OUT2_PORT {clk_200Mhz} \
			    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
			    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200} \
			   ] [get_ips ${name} ]
}


