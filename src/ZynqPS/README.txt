Files:   Files marked with a (*) are where customizations should happen.

 - create.tcl:                 Top level file called to build the block design.
	                    
 * build_CPU.tcl:              Configuration of the zynq CPU (except the MIO pins)
		            
 * build_CPU_MIO.tcl:          Configuration of the zynq MIO pins.
   			       This includes the arm bank voltages and all the
			       PS peripherals. This is not an exhaustive listing,
			       so it may require many changes

 - build_AXI_interconnect.tcl: Generation of the AXI interconnect

 * build_AXI_slaves.tcl:       File where all AXI slave names, and AXI params are added
                               This is also where BD based AXI-slave generation code goes and
			       where non-BD AXI-slaves are generated.
			       This is also where the AXI slave addresses are set.
			       This is currently done by letting Vivado choose the, but the tcl
			       could be modified to suggest the addresses.  This should be added
			       into the global arrays of AXI slave parameters

 - axi_slave_helpers.tcl:      Library of code to help with AXI slave generation and connection.



Notes:


 * UIO:
       To make AXI-slave components UIO compatible, you need to append the "generic-uio" to each
       AXI-slave.
       To make sure linux does a scan for these, you also need to add
       "uio_pdrv_genirq.of_id=generic-uio" to the bootargs tag of the chosen block in the device-tree
       system-user.dtsi.
       In this build system there are tcl functions from axi_slave_helpers.tcl that are called after
       creating slaves in build_AXI_slaves.tcl that generate dtsi_chunk and dtsi_post_chunk files.
       These provide UIO compatible device tree entries (dtsi_chunk) and overrides of the "compatible"
       tags for BD IP AXI slaves that make them UIO compatible (dtsi_post_chunk).
