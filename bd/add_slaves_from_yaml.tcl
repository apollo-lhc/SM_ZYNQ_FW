proc huddle_to_bd {huddle parent} {    
    foreach key [huddle keys $huddle] {
        if { 0 == [string compare "TCL_CALL" $key] } {
            set tcl_call_huddle [huddle get $huddle $key]
            set command "[huddle gets $tcl_call_huddle command]"
            set pairs [dict create]

            # set a default device name based on the node..
            # it will be overwritten later if you set device name explicitly
            dict append pairs device_name $parent

            foreach pairkey [huddle keys $tcl_call_huddle] {
                if { 0 != [string compare "command" $pairkey]} {
                    dict set pairs $pairkey [subst [huddle gets $tcl_call_huddle $pairkey]]
                }}
	    puts "\n\n\n"
	    puts "================================================================================"
            puts "Executing command from YAML: $command \[dict create $pairs\]"
            eval $command {$pairs}
	    
        }
        if { 0 == [string compare "dict" [huddle type [huddle get $huddle $key]]]} {
            huddle_to_bd [huddle get $huddle $key] $key
        }}}

proc yaml_to_bd {yaml_file} {
    yaml_to_control_sets $yaml_file
    set my_huddle [yaml::yaml2huddle -file $yaml_file]

    if [catch {set cores_huddle [huddle get $my_huddle "CORES"]}] {	
	puts "No IP Cores found"
    } else {
	puts "Adding IP Cores"
	huddle_to_bd $cores_huddle ""
    }
    if [catch {set slaves_huddle [huddle get $my_huddle "AXI_SLAVES"]}] {	
	puts "No slaves found"
    } else {
	puts "Adding slaves"
	huddle_to_bd $slaves_huddle ""
    }
}

proc yaml_to_control_sets {yaml_file} {
    set dict [dict get [yaml::yaml2dict -file $yaml_file] "AXI_CONTROL_SETS"]
    puts "Adding AXI Control Sets"
    foreach key [dict keys $dict] {
        global $key
        upvar 0 $key x ;# tie the calling value to variable x
        set x [dict get $dict $key]
    }
}
