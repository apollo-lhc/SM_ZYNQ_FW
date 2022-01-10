The slaves.yaml file stores the information for all BD and HDL AXI slaves.
This is a user editable file and version controlled.

This includes:
 - the TCL to create or connect them to the AXI bus
 - the uHAL address they will have
 - the address tables to use for the uHAL address table
 - whether to generate hdl address decoding and register packages

This file is used by scripts/preBuild.py to generate the following:
 - AddSlaves.tcl in src/ZynqPS for use in the FW build
 - slaves.yaml in kernel/ to list the dtsi_chunk/dtsi_post_chunk files to use in the linux kernel device tree
 - slaves.yaml in os/ to build the full uHAL address table and which xml files should be copied to the final image

Do not modify these output files outside of the scripts/preBuild.py (make prebuild)

Structure:
 - The top node of the yaml file is AXI_SLAVES:
   - NAME: Each child node of that is an AXI slave to be used in the FW/kernel/FW/SW build. 
     - TCL_CALL: is the tcl call to be put in the AddSlaves.tcl file for slave generation
     - XML: is a listing of xml files that will be needed in the final OS image
         The first XML file is the primary one that will be used as the "top" file for the slave
     - UHAL_BASE: this is the uHAL address to be use for the base address of the slave. 
     - HDL: causes the generation of  _PKG.vhd and _MAP.vhd files.
       - out_dir (optional)  Path to place these files (configs/name/autogen if not specified)
       - map_template:  Map template file to use for generation
     - SUB_SLAVES:  This node contains another level of slaves to be generated that require the partent slave to already exist. 
         The name of the sub-slave is its listed name appened to the name of its parent.


