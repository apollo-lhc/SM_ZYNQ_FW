## BU_BUILD
This is a collection of tcl code that is used for building Xilinx IP.
It can be included from other tcl and called directly or it can be called via the yaml files parsed by this collection.

## Contents 
### axi_helpers.tcl & AXI_HELPERS/* 
These files help connect AXI devices to AXI masters. 
The masters are usually AXI Interconnects also built by this code, but other situations are also supported. 
As a part of connecting up AXI devices, the dtsi_helpers.tcl file is referenced for building device-tree files

### dtsi_helpers.tcl 
This code helps set/auto-set and keep track AXI addresses for AXI devices.
It will generate dtsi_chunk,dtsi_post_chunk, and dtsi overlay files for use in Linux for mapping these devices.
The default config is to use the Linux UIO driver and make a UIO device for each AXI device.
Output types:
* .dtsi_chunk: This generates a full device tree entry for non-Xilinx IP (usually a HDL PL slave).  This is also can be used for Xilinx IP that is at the end of the C2C link.  This file will be built directly into the device tree and build time.
* .dtsi_post_chunk:  This genreates an update entry in the device tree to configure UIO parameters for entries already created by Vivado and its IP. This file will be built directly into the device tree and build time.
* .dtsi:   This is the base for a dtsi overlay file that can be loaded at runtime.  It will need to be converted to a dtbo file to be used and can be loaded maunually via sysfs or automatically via Apollo daemon's.

### Xilinx_AXI_Slaves.tcl
This is a collection of tcl functions that build Xilinx AXI BD IP via a common configuration structure.

### Xilinx_Cores.tcl
This is a collection of tcl that can generate traditional Xilinx PL IP (clocks, MGTs, etc)
It uses the same configuration structre as the Xilinx_AXI_Slaves code

### Xilinx_Helpers.tcl 
This allows the above libraries to set constants that will be turned into a global constants package. 

### add_slaves_from_yaml.tcl 
This code processes yaml files that list and describe what AXI Interconnects, AXI_slaves, and Xilinx IP Cores to build and use in the design. 
All configuration data used for IPs generated in this submodule can be created from this. 

### AXI_DRP_include.tcl / IP/packaged_ip 
This is legacy code for connecting to MGT DRP interfaces via AXI.  Now just embed these as memories in other AXI slaves. 
