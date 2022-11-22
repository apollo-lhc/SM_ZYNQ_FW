# Copied from Echo_Server example design in Tcl / modif. by EBSM
# TCLink_Server --
#	Open the server listening socket
#	and enter the Tcl event loop
#
# Arguments:
#	port	The server's port number

proc TCLink_Server {port} {
    set s [socket -server TCLinkAccept $port]
    vwait forever
}

# TCLink_Accept --
#	Accept a connection from a new client.
#	This is called after a new socket connection
#	has been created by Tcl.
#
# Arguments:
#	sock	The new socket connection to the client
#	addr	The client's IP address
#	port	The client's port number

proc TCLinkAccept {sock addr port} {
    global gty_test

    # Record the client's information

    puts "Accept $sock from $addr port $port"
    set gty_test(addr,$sock) [list $addr $port]

    # Ensure that each "puts" by the server
    # results in a network transmission

    fconfigure $sock -buffering line

    # Set up a callback for when the client sends data

    fileevent $sock readable [list TCLink $sock]
}

# TCLink --
#	This procedure is called when the server
#	can read data from the client
#
# Arguments:
#	sock	The socket connection to the client

proc TCLink {sock} {
    global gty_test
    
    # Check end of file or abnormal connection drop,
    # then gty_test data back to the client.

    if {[eof $sock] || [catch {gets $sock line}]} {
	close $sock
	puts "Close $gty_test(addr,$sock)"
	unset gty_test(addr,$sock)
    } else {
		################################ Process Data #################################
		set rcvd_cmd $line
		
        set ope [lindex $rcvd_cmd 0]
		set probe_name [lindex $rcvd_cmd 1]
		set data [lindex $rcvd_cmd 2]
		
        #puts $ope
        #puts $probe_name
        #puts $data	
		
        switch $ope {
          "fpga_program" {
              puts "FPGA_PROGRAM..."
              program_hw_devices [get_hw_devices xcvu9p_0]
              refresh_hw_device [get_hw_devices xcvu9p_0]
              puts "FPGA_PROGRAM DONE"
			  puts $sock 1
		  }	

          "vio_ri" {
              #puts "Read VIO Input property"
              refresh_hw_vio -update_output_values [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]
              set probes [list $probe_name]			  
              set data [get_property INPUT_VALUE [get_hw_probes $probes -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]]]
			  puts $sock $data
		  }

          "vio_ro" {
              #puts "Read VIO Output property" 
              refresh_hw_vio -update_output_values [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]
              set probes [list $probe_name]			  
              set data [get_property OUTPUT_VALUE [get_hw_probes $probes -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]]]
			  puts $sock $data
		  }

          "vio_w" {
              #puts "Write VIO Output property"
              startgroup
              set probes [list $probe_name]			  
              set_property OUTPUT_VALUE $data [get_hw_probes $probes -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]]
              commit_hw_vio [get_hw_probes $probes -of_objects [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]]
              endgroup
              refresh_hw_vio -update_output_values [get_hw_vios -of_objects [get_hw_devices xcvu9p_0] -filter {CELL_NAME=~"*vio_control"}]
			  puts $sock 1
		  }

          "sysmon_refresh" {
              #puts "Refresh SysMon property"
              refresh_hw_sysmon  [get_hw_sysmons */SYSMON]
			  puts $sock 1
		  }

          "sysmon_r" {
              #puts "Read SysMon property"
              set probes [list $probe_name]				  
              set data [get_property $probes [get_hw_sysmons */SYSMON]]
			  puts $sock $data
		  }

          default {
            puts "Command not recognizable"
			puts $sock -1
          }
        }
		
		################################# End Process Data #################################
		# puts "Finished data processing"
		# puts $sock $line		
		# puts $line
	}
}


#Open Hardware Target
open_hw
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {../../tclink_vcu118/tclink_vcu118.runs/impl_1/system_wrapper_vcu118.bit} [get_hw_devices xcvu9p_0]
set_property PROBES.FILE  {../../tclink_vcu118/tclink_vcu118.runs/impl_1/system_wrapper_vcu118.ltx} [get_hw_devices xcvu9p_0]
current_hw_device [get_hw_devices xcvu9p_0]
refresh_hw_device [get_hw_devices xcvu9p_0]

puts "############ TCLink - TEST CONTROL ##############"
puts "# Socket Port: 8555                                     #"
puts "# IP Address (localhost): 127.0.0.1                     #"
puts "#########################################################"

TCLink_Server 8555
vwait forever
