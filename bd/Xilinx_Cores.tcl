source -notrace ${BD_PATH}/axi_helpers.tcl

proc WritePackage {outfile name data} {
    if { [dict size $data] > 0 } {
	puts $outfile "type $name is record"
	dict for {key value} $data {
	    puts $outfile [format "  %-30s : %s;" $key [lindex $value 0] ]
	}
	puts $outfile "end record $name;"
	puts $outfile "type ${name}_array_t is array (integer range <>) of $name;"
    }
}

proc BuildCore {device_name core_type} {
    global build_name
    global apollo_root_path
    global autogen_path

    set output_path ${apollo_root_path}/${autogen_path}/cores/    
    
    #####################################
    #delete IP if it exists
    #####################################    
    if { [file exists ${output_path}/${device_name}/${device_name}.xci] } {
	file delete -force ${output_path}/${device_name}
    }

    #####################################
    #create IP            
    #####################################    

    file mkdir ${output_path}

    #delete if it already exists
    if { [get_ips -quiet $device_name] == $device_name } {
	export_ip_user_files -of_objects  [get_files ${device_name}.xci] -no_script -reset -force -quiet
	remove_files  ${device_name}.xci
    }
    #create
    puts $core_type
    puts $device_name
    puts $output_path
    create_ip -vlnv [get_ipdefs -filter "NAME == $core_type"] -module_name ${device_name} -dir ${output_path}
    #put xci_file in the scope of the calling function
    upvar 1 xci_file x
    set x [get_files ${device_name}.xci]    
}

proc BuildILA {params} {
    global build_name
    global apollo_root_path
    global autogen_path

    set_required_values $params {device_name}
    set_required_values $params {probes} False
    set_optional_values $params [dict create EN_STRG_QUAL 1  ADV_TRIGGER false ALL_PROBE_SAME_MU_CNT 2 ENABLE_ILA_AXI_MON false MONITOR_TYPE Native ]

    #build the core
    BuildCore $device_name ila


    #start a list of properties
    dict create property_list {}

    #add parameters
    dict append property_list CONFIG.C_EN_STRG_QUAL          $EN_STRG_QUAL
    dict append property_list CONFIG.C_ADV_TRIGGER           $ADV_TRIGGER
    dict append property_list CONFIG.ALL_PROBE_SAME_MU_CNT   $ALL_PROBE_SAME_MU_CNT
    dict append property_list CONFIG.C_ENABLE_ILA_AXI_MON    $ENABLE_ILA_AXI_MON
    dict append property_list CONFIG.C_MONITOR_TYPE          $MONITOR_TYPE

    #====================================
    #Parse the probes.
    #====================================
    #set the count of probes
    set probe_count 0
    #build each probe
    dict for {probe probe_info} $probes {
	#set the probe count to the max in the list
	if { $probe > $probe_count } {	    
	    set probe_count $probe
	}
	dict for {key value} $probe_info {
	    if {$key == "TYPE"} {
                # type is 0: data & trigger, 1 data only, 2 trigger only
		dict append property_list CONFIG.C_PROBE${probe}_TYPE $value
	    } elseif {$key == "WIDTH"} {		
		dict append property_list CONFIG.C_PROBE${probe}_WIDTH $value
	    } elseif {$key == "MU_CNT"} {		
		dict append property_list CONFIG.C_PROBE${probe}_MU_CNT $value
	    }
	}
    }
    #probes start from 0, so add 1
    set probe_count [expr $probe_count + 1]

    dict append property_list CONFIG.C_NUM_OF_PROBES $probe_count
    
    #apply all the properties to the IP Core
    set_property -dict $property_list [get_ips ${device_name}]
    generate_target -force {all} [get_ips ${device_name}]
    synth_ip [get_ips ${device_name}]
    
}

proc XMLentry {name addr MSB LSB direction} {
    #set name and address
    set upper_name [string toupper $name]
    set node_line [format "  <node id=\"$upper_name\" address=\"0x%08X\"" $addr]
    
    #build the mask from MSB and LSB ranges
    set node_mask 0
    for {set bit $LSB} {$bit <= $MSB} {incr bit} {
	set node_mask [expr (2**$bit) + $node_mask]
    }
    set node_mask [format 0x%08X $node_mask]
    set node_line "$node_line mask=\"$node_mask\""

    #set read/write
    if {$direction == "output"} {
	set node_line "$node_line permission=\"r\""
    } else {
	set node_line "$node_line permission=\"rw\""
    }
    #end xml entry
    set node_line "$node_line />\n"
    return $node_line
}

proc VerilogIPSignalGrabber {direction MSB LSB name dict_inputs_name dict_outputs_name regs_xml_name reg_count_name} {
    upvar $dict_inputs_name  dict_inputs
    upvar $dict_outputs_name dict_outputs
    upvar $regs_xml_name regs_xml
    upvar $reg_count_name reg_count

    #see if this is a vector or a signal
    set type ""
    if {$MSB == 0} {
	set type "std_logic"			
    } else {
	set type "std_logic_vector($MSB downto 0)"
    }
    set bitsize [expr ($MSB - $LSB)+1]
    #this is a common signal, so just use it
    if {$direction == "output"} {
	dict append dict_outputs $name [list $type $bitsize]
	dict append regs_xml dict_outputs [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
	set reg_count [expr $reg_count + 1]
	
    } elseif {$direction == "input"} {
	dict append dict_inputs  $name [list $type $bitsize]
	dict append regs_xml dict_inputs [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
	set reg_count [expr $reg_count + 1]
    } else {
	error "Invalid in/out type $line"
    }
}

proc BuildMGTCores {params} {
    global build_name
    global apollo_root_path
    global autogen_path

    set_required_values $params {freerun_frequency}
    set_required_values $params {device_name}
    #False means return a full dict instead of a broken up dict
    set_required_values $params {clocking} False
    set_required_values $params {protocol} False
    set_required_values $params {links} False
    set_required_values $params {GT_TYPE}
   

    set_optional_values $params [dict create core {LOCATE_TX_USER_CLOCKING CORE LOCATE_RX_USER_CLOCKING CORE LOCATE_RESET_CONTROLLER CORE LOCATE_COMMON EXAMPLE_DESIGN}]


    dict create GT_TYPEs {}
    dict append GT_TYPEs "UNKNOWN" "\"0000\""
    dict append GT_TYPEs "GTH" "\"0001\""
    dict append GT_TYPEs "GTX" "\"0010\""
    dict append GT_TYPEs "GTY" "\"0011\""



    #build the core
    BuildCore $device_name gtwizard_ultrascale
	

    #start a list of properties
    dict create property_list {}

    #simple properties
    dict append property_list CONFIG.GT_TYPE $GT_TYPE
    dict append property_list CONFIG.FREERUN_FREQUENCY $freerun_frequency
    dict append property_list CONFIG.LOCATE_TX_USER_CLOCKING $LOCATE_TX_USER_CLOCKING
    dict append property_list CONFIG.LOCATE_RX_USER_CLOCKING $LOCATE_RX_USER_CLOCKING
    dict append property_list CONFIG.LOCATE_RESET_CONTROLLER $LOCATE_RESET_CONTROLLER
    dict append property_list CONFIG.LOCATE_COMMON $LOCATE_COMMON

    #add optional ports to the device
    set optional_ports [list cplllock_out eyescanreset_in eyescantrigger_in eyescandataerror_out dmonitorout_out pcsrsvdin_in rxbufstatus_out rxprbserr_out rxresetdone_out rxbufreset_in rxcdrhold_in rxdfelpmreset_in rxlpmen_in rxpcsreset_in rxpmareset_in rxprbscntreset_in rxprbssel_in rxrate_in txbufstatus_out txresetdone_out txinhibit_in txpcsreset_in txpmareset_in txpolarity_in txpostcursor_in txprbsforceerr_in txprecursor_in txprbssel_in txdiffctrl_in drpaddr_in drpclk_in drpdi_in drpen_in drprst_in drpwe_in drpdo_out drprdy_out rxctrl2_out txctrl2_in loopback_in]
    if {[dict exists $params optional]} {
	set additional_optional_ports [dict get $params optional]
	set optional_ports [concat $optional_ports $additional_optional_ports]
	puts "Adding optional values: $additional_optional_ports"
    } else {
	puts "no additional optional values"
    }
    dict append property_list CONFIG.ENABLE_OPTIONAL_PORTS $optional_ports



    #clocking
    foreach {dict_key dict_value} $clocking {
	foreach {key value} $dict_value {
	    dict append property_list CONFIG.${dict_key}_${key} $value
	}
    }
    #protocol
    foreach {dict_key dict_value} $protocol {
	foreach {key value} $dict_value {
	    dict append property_list CONFIG.${dict_key}_${key} $value
	}
    }
    #links
    set enabled_links {}
    dict create rx_clocks {}
    dict create tx_clocks {}
    foreach {dict_key dict_value} $links {
	lappend enabled_links $dict_key 
	foreach {key value} $dict_value {
	    if {$key == "RX"} {
		dict append rx_clocks $dict_key $value
	    } elseif {$key == "TX"} {
		dict append tx_clocks $dict_key $value
	    }
	}
    }
    dict append property_list CONFIG.CHANNEL_ENABLE $enabled_links
    dict append property_list CONFIG.TX_REFCLK_SOURCE $tx_clocks
    dict append property_list CONFIG.RX_REFCLK_SOURCE $rx_clocks
    
    #apply all the properties to the IP Core
    set_property -dict $property_list [get_ips ${device_name}]
    generate_target -force {all} [get_ips ${device_name}]
    synth_ip [get_ips ${device_name}]

    #####################################
    #create a wrapper 
    #####################################
    set tx_count [dict size $tx_clocks]
    set rx_count [dict size $rx_clocks]

    if {$tx_count != $rx_count} {
	error "tx_count and rx_count don't match"
    }

    set example_verilog_filename [get_files -filter "PARENT_COMPOSITE_FILE == ${xci_file}" "*/synth/${device_name}.v"]
    set example_verilog_file [open ${example_verilog_filename} r]
    set file_data [read ${example_verilog_file}]
    set data [split ${file_data} "\n"]
    close $example_verilog_file
    dict create common_in  {}
    dict create common_out {}
    dict create clocks_in  {}
    dict create clocks_out {}
    dict create channel_in  {}
    dict create channel_out {}
    set component_info {}
    dict append channel_out TXRX_TYPE {"std_logic_vector(3 downto 0)" 4}

    set reg_count 0
    set regs_xml [dict create clocks_in "\n" clocks_out "\n" common_in "\n" common_out "\n" channel_in "\n" channel_out "\n"]
    foreach line $data {
	if {[regexp { *(output|input) *wire *\[([0-9]*) *: *([0-9]*)\] *([a-zA-Z_0-9]*);} ${line}  full_match direction MSB LSB name] == 1} {
	    #build a list of IOs for the vhdl component
	    set component_line "$name : "
	    if {$direction == "output"} {
		append component_line "out "
	    } elseif {$direction == "input"} {
		append component_line "in  "
	    }
	    append component_line "std_logic_vector($MSB downto $LSB)"
	    lappend component_info $component_line

	    #this has passed a regex for a verilog wire line, so we need to process it. 
	    #unless it is a userdata signal, since we want to split that up by channel
	    if { [string first "refclk" $name] >= 0 || ([string first "qpll" $name] >= 0 && [string first "clk" $name] >= 0) } {
#		VerilogIPSignalGrabber $direction $MSB $LSB $name clocks_in clocks_out regs_xml reg_count
		#see if this is a vector or a signal
		set type ""
		if {$MSB == 0} {
		    set type "std_logic"			
		} else {
		    set type "std_logic_vector($MSB downto 0)"
		}
		set bitsize [expr ($MSB - $LSB)+1]
		#this is a common signal, so just use it
		if {$direction == "output"} {
		    dict append clocks_out $name [list $type $bitsize]
		    dict append regs_xml clocks_out [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
		    set reg_count [expr $reg_count + 1]

		} elseif {$direction == "input"} {
		    dict append clocks_in  $name [list $type $bitsize]
		    dict append regs_xml clocks_in [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
		    set reg_count [expr $reg_count + 1]
		} else {
		    error "Invalid in/out type $line"
		}
	    } elseif { [string range $name 0 5] == "gtwiz_" && [string first "userdata" $name] == -1 || [string first "qpll" $name] >= 0 } {
#		VerilogIPSignalGrabber $direction $MSB $LSB $name common_in common_out regs_xml reg_count
		#see if this is a vector or a signal
		set type ""
		if {$MSB == 0} {
		    set type "std_logic"			
		} else {
		    set type "std_logic_vector($MSB downto 0)"
		}
		set bitsize [expr ($MSB - $LSB)+1]
		#this is a common signal, so just use it
		if {$direction == "output"} {
		    dict append common_out $name [list $type $bitsize]
		    dict append regs_xml common_out [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
		    set reg_count [expr $reg_count + 1]
		} elseif {$direction == "input"} {
		    dict append common_in  $name [list $type $bitsize]
		    dict append regs_xml common_in [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
		    set reg_count [expr $reg_count + 1]
		} else {
		    error "Invalid in/out type $line"
		}
	    } else {
		#this isn't a common signal, so we need to figure out how to split it up
		if {$LSB != 0} {
		    error "Somehow this wire doesn't start at bit 0"
		}
		if { [expr {($MSB + 1) % $tx_count}] != 0 } {
		    error "Signal $name doens't divide properly by tx_count"
		} else {
		    #determine the type for this variable
		    set bitsize [expr {($MSB + 1) / $tx_count}]
		    set type ""
		    if {$bitsize == 1} {
			set type "std_logic"			
		    } else {
			set type "std_logic_vector($bitsize -1 downto 0)"
		    }
		    #save the line
		    if {$direction == "output"} {
			dict append channel_out $name [list $type $bitsize]
			dict append regs_xml channel_out [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
			set reg_count [expr $reg_count + 1]
		    } elseif {$direction == "input"} {
			dict append channel_in  $name [list $type $bitsize]
			dict append regs_xml channel_in [XMLentry $name $reg_count [expr $bitsize -1] 0 $direction]
			set reg_count [expr $reg_count + 1]
		    } else {
			error "Invalid in/out type $line"
		    }				    
		}
		

	    }
	    
	}
    }

    #write out example xml regs
    dict for {key value} $regs_xml {
	set xml_filename "${apollo_root_path}/${autogen_path}/cores/${device_name}/${device_name}_regs_$key.xml"
	set xml_file [open ${xml_filename} w]
	puts $xml_file "<node id=\"$key\">"
	puts $xml_file [dict get $regs_xml $key]
	puts $xml_file "</node>"
	close $xml_file
    }

    
    #write the packages for this wrapper
    set package_filename "${apollo_root_path}/${autogen_path}/cores/${device_name}/${device_name}_pkg.vhd"
    set package_file [open ${package_filename} w]
    puts $package_file "----------------------------------------------------------------------------------"
    puts $package_file "--"
    puts $package_file "----------------------------------------------------------------------------------"
    puts $package_file ""
    puts $package_file "library ieee;"
    puts $package_file "use ieee.std_logic_1164.all;"
    puts $package_file ""
    puts $package_file "package ${device_name}_PKG is"
 
    WritePackage $package_file "${device_name}_CommonIn"   $common_in
    WritePackage $package_file "${device_name}_CommonOut"  $common_out
    if { [info exists clocks_in]} {
	WritePackage $package_file "${device_name}_ClocksIn"   $clocks_in
    }
    if { [info exists clocks_out]} {
	WritePackage $package_file "${device_name}_ClocksOut"  $clocks_out
    }
    WritePackage $package_file "${device_name}_ChannelIn"  $channel_in
    WritePackage $package_file "${device_name}_ChannelOut" $channel_out
    
    puts $package_file "end package ${device_name}_PKG;"
    close $package_file
    read_vhdl ${package_filename}

    #write the warpper
    set wrapper_filename "${apollo_root_path}/${autogen_path}/cores/${device_name}/${device_name}_wrapper.vhd"
    set wrapper_file [open ${wrapper_filename} w]
    puts $wrapper_file "library ieee;"
    puts $wrapper_file "use ieee.std_logic_1164.all;\n"
    puts $wrapper_file "use work.${device_name}_PKG.all;\n"
    puts $wrapper_file "entity ${device_name}_wrapper is\n"
    puts $wrapper_file "  port ("
    puts $wrapper_file "    common_in   : in  ${device_name}_CommonIn;"
    puts $wrapper_file "    common_out  : out ${device_name}_CommonOut;"
    if { [info exists clocks_in]} {
	puts $wrapper_file "    clocks_in   : in  ${device_name}_ClocksIn;"
    }
    if { [info exists clocks_out]} {
	puts $wrapper_file "    clocks_out  : out ${device_name}_ClocksOut;"
    }
    puts $wrapper_file "    channel_in  : in  ${device_name}_ChannelIn_array_t($tx_count downto 1);"
    puts $wrapper_file "    channel_out : out ${device_name}_ChannelOut_array_t($tx_count downto 1));"
    puts $wrapper_file "end entity ${device_name}_wrapper;\n"
    puts $wrapper_file "architecture behavioral of ${device_name}_wrapper is"
    #component declaration for verilog interface
    
    puts $wrapper_file "component ${device_name}"
    puts $wrapper_file "  port("
    for {set i 0} {$i < [expr [llength $component_info]-1]} {incr i } {
	puts -nonewline $wrapper_file [lindex $component_info $i]
	puts $wrapper_file ";"
    }
    puts -nonewline $wrapper_file [lindex $component_info [expr [llength $component_info]-1] ]
    puts $wrapper_file "  );"
    puts $wrapper_file "END COMPONENT;"


    puts $wrapper_file "begin"
    puts $wrapper_file "${device_name}_inst : entity work.${device_name}"
    puts $wrapper_file "  port map ("
    #helps keep the final comma missing 
    set needsComma " "
    foreach {key value} $common_in {
	if { [lindex $value 1] == 1} {
	    puts -nonewline $wrapper_file  "$needsComma \n    $key (0) => Common_In.$key"
	} else {
	    puts -nonewline $wrapper_file  "$needsComma \n    $key ("
	    puts -nonewline $wrapper_file  [lindex $value 1] 
	    puts -nonewline $wrapper_file  " -1 downto 0) => Common_In.$key"
	}
	set needsComma ","
    }
    foreach {key value} $common_out {
	if { [lindex $value 1] == 1} {
	    puts -nonewline $wrapper_file  "$needsComma \n    $key (0) => Common_Out.$key"
	} else {
	    puts -nonewline $wrapper_file  "$needsComma \n    $key ("
	    puts -nonewline $wrapper_file  [lindex $value 1] 
	    puts -nonewline $wrapper_file  " -1 downto 0) => Common_Out.$key"
	}
	set needsComma ","
    }
    if { [info exists clocks_in]} {
	foreach {key value} $clocks_in {
	    if {[lindex $value 1] == 1} {
		puts -nonewline $wrapper_file  "$needsComma \n    $key (0) => Clocks_In.$key"
		set needsComma ","
	    } else {
		puts -nonewline $wrapper_file  "$needsComma \n    $key     => Clocks_In.$key"
		set needsComma ","
	    }
	}    
    }
    if { [info exists clocks_out]} {
	foreach {key value} $clocks_out {
	    if {[lindex $value 1] == 1} {
		puts -nonewline $wrapper_file  "$needsComma \n    $key (0) => Clocks_Out.$key"
		set needsComma ","
	    } else {
		puts -nonewline $wrapper_file  "$needsComma \n    $key     => Clocks_Out.$key"
		set needsComma ","
	    }
	}
    }
    foreach {key value} $channel_in {
	puts $wrapper_file  "$needsComma \n    $key => std_logic_vector'( \"\" &"
	for {set i $tx_count} {$i > 1} {incr i -1} {
	    puts $wrapper_file "             Channel_In($i).$key  &"
	}
	puts -nonewline $wrapper_file "              Channel_In(1).$key)"
	set needsComma ","
    }
    foreach {key value } $channel_out {
	if {$key != "TXRX_TYPE"} {
	    set value_size [lindex $value 1]
	    for {set i 0} {$i < $tx_count} {incr i} {
		if { $value_size == 1 } {
		    puts $wrapper_file  "$needsComma \n    $key ($i) => Channel_Out($i + 1).$key"
		} else {
		    puts $wrapper_file  "$needsComma \n    $key (($value_size*($i+1))-1 downto ($value_size*$i)) => Channel_Out($i + 1).$key"
		}
	    }
	    set needsComma ","
	}
    }
    puts $wrapper_file ");"

    
    for {set i $tx_count} {$i > 0} {incr i -1} {
	puts -nonewline $wrapper_file "channel_out($i).TXRX_TYPE <= "
	puts -nonewline $wrapper_file [dict get $GT_TYPEs $GT_TYPE]
	puts $wrapper_file ";"
    }
    puts $wrapper_file "end architecture behavioral;"
    close $wrapper_file
    read_vhdl ${wrapper_filename}

}


proc CheckExists { source_dict keys } {
    set missing_elements False

    foreach key $keys {
	if {! [dict exists $source_dict $key] } {
	    puts "Missing key $key"
	    set missing_elements True
	}    
    }
    if { $missing_elements == True} {
	error "Dictionary missing required elements"
    }
}

proc BuildFIFO {params} {
    global build_name
    global apollo_root_path
    global autogen_path

    set_required_values $params {device_name}
    set_required_values $params {Input} False
    set_required_values $params {Output} False
    set_required_values $params Type

    #build the core
    BuildCore $device_name fifo_generator
	
    #start a list of properties
    dict create property_list {}
    
    #do some more checking
    CheckExists $Input {Width Depth}
    CheckExists $Output {Width Depth}

    #handle input side settings
    dict append property_list CONFIG.Input_Data_Width [dict get $Input Width]
    dict append property_list CONFIG.Input_Depth      [dict get $Input Depth]
    dict append property_list CONFIG.Output_Data_Width [dict get $Output Width]
    dict append property_list CONFIG.Output_Depth      [dict get $Output Depth]
    if { [dict exists $Output Valid_Flag] } {
	dict append property_list CONFIG.Valid_Flag    {true}
    }
    if { [dict exists $Output Fall_Through] } {
	dict append property_list CONFIG.Performance_Options {First_Word_Fall_Through}
    }
    dict append property_list CONFIG.Fifo_Implementation $Type

    #apply all the properties to the IP Core
    set_property -dict $property_list [get_ips ${device_name}]
    generate_target -force {all} [get_ips ${device_name}]
    synth_ip [get_ips ${device_name}]
}


proc BuildClockWizard {params} {
    global build_name
    global apollo_root_path
    global autogen_path

    set_required_values $params {device_name}
    set_required_values $params {in_clk_type}
    set_required_values $params {in_clk_freq_MHZ}
    set_required_values $params {out_clks} False

    #build the core
    BuildCore $device_name clk_wiz


    #start a list of properties
    dict create property_list {}

    #add parameters
    dict append property_list CONFIG.PRIM_SOURCE             ${in_clk_type}
    dict append property_list CONFIG.PRIM_IN_FREQ            ${in_clk_freq_MHZ}
    dict append property_list CONFIG.PRIMARY_PORT            ${device_name}_[]

    #====================================
    #Parse the output clocks
    #====================================
    #set the count of probes
    set clk_count 0
    #build each probe
    dict for {clk clk_freq} $out_clks {
	#set the probe count to the max in the list
	if { $clk > $clk_count } {	    
	    set clk_count $clk
	}
	if {$clk == 0} {
	    error "clk == 0 is not allowed, numbering starts at 1"
	}

	#set out clock name
	dict append property_list CONFIG.CLK_OUT${clk}_PORT clk_[string map {"." "_"} ${clk_freq}]MHz
	#set out clock frequency
	dict append property_list CONFIG.CLKOUT${clk}_REQUESTED_OUT_FREQ ${clk_freq}

	#set the clock to be used (clk 1 is assumed used)
	if {$clk > 1} {
	    dict append property_list CONFIG.CLKOUT${clk}_USED true
	}
    }

    dict append property_list CONFIG.NUM_OUT_CLKS $clk_count
    
    #apply all the properties to the IP Core
    set_property -dict $property_list [get_ips ${device_name}]
    generate_target -force {all} [get_ips ${device_name}]
    synth_ip [get_ips ${device_name}]
    
}


proc Build_iBERT {params} {
    global build_name
    global apollo_root_path
    global autogen_path

    set_required_values $params {device_name}
    set_required_values $params {links}

    #build the core
    BuildCore $device_name in_system_ibert

   #links
    set_property CONFIG.C_GTS_USED ${links} [get_ips ${device_name}]

    #CONFIG.C_ENABLE_INPUT_PORTS {false}] [get_ips in_system_ibert_0]
}
