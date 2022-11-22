Files:   Files marked with a (*) are where customizations should happen.

 * create.tcl:                 Top level file called to build the block design.
                               This calls external tcl to build the axi interconnect and the Xilinx/HDL axi slaves.
	                    
 * build_CPU.tcl:              Configuration of the zynq CPU (except the MIO pins)
		            
 * build_CPU_MIO.tcl:          Configuration of the zynq MIO pins.
   			       This includes the arm bank voltages and all the
			       PS peripherals. This is not an exhaustive listing,
			       so it may require many changes




Notes:


 * UIO:
       To make AXI-slave components UIO compatible, you need to append the "generic-uio" to each
       AXI-slave.
       To make sure linux does a scan for these, you also need to add
       "uio_pdrv_genirq.of_id=generic-uio" to the bootargs tag of the chosen block in the device-tree
       system-user.dtsi.
       In this build system there are tcl functions from axi_helpers.tcl (BU-BUILD submodule) that are called after
       creating slaves that generate dtsi_chunk and dtsi_post_chunk files.
       These provide UIO compatible device tree entries (dtsi_chunk) and overrides of the "compatible"
       tags for BD IP AXI slaves that make them UIO compatible (dtsi_post_chunk).
       There is also a "label" tag added to the DTSI files to allow UIO-UHAL to easily determine slave UIO numbers.
