proc Add_Global_Constant {name type value} {
    #connect to global variable for this
    global global_constants
    if { [info exists global_constants] == 0 } {
	set global_constants [dict create ${name} [dict create type ${type} value ${value}]]
    } else {
	dict append global_constants ${name} [dict create type ${type} value ${value}]
    }
   
}

proc Generate_Global_package {} {
    global build_name
    global apollo_root_path
    global autogen_path

    #global files set
    set filename "${apollo_root_path}/${autogen_path}/Global_PKG.vhd"
    set outfile [open ${filename} w]
    
    puts $outfile "----------------------------------------------------------------------------------"
    puts $outfile "--"
    puts $outfile "----------------------------------------------------------------------------------"
    puts $outfile ""
    puts $outfile "library ieee;"
    puts $outfile "use ieee.std_logic_1164.all;"
    puts $outfile ""
    puts $outfile "package Global_PKG is"



    global global_constants
    if { [info exists global_constants] == 1 } {
	#output constants
	dict for {parameter value} $global_constants {	    
	    puts $outfile [format "  constant  %-30s : %-10s := %-10s;" $parameter [dict get $value type] [dict get $value value] ]
	}
    }

    puts $outfile "end package Global_PKG;"
    close $outfile
    #load the new VHDL file
    read_vhdl $filename
}
