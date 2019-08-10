#create a block design called "zynq_bd"
create_bd_design -dir ../bd "zynq_bd"

#================================================================================
#  List the AXI devices to be added (needed for AXI interconnect sizing)
#================================================================================
source ../bd/build_AXI_slaves.tcl

#puts "Adding list of AXI slaves"
ADD_AXI_SLAVES

#================================================================================
#  Create and configure the basic zynq processing system.
#  build_CPU contains CPU parameters includeing the MIO and peripheral configs
#================================================================================
puts "Building CPU"
source ../bd/build_CPU.tcl

#================================================================================
#  Create an AXI interconnect
#================================================================================
#puts "Building AXI interconnect"
source ../bd/build_AXI_interconnect.tcl

[BUILD_AXI_INTERCONNECT ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} [list processing_system7_0/M_AXI_GP0] [list ${AXI_MASTER_CLK}] [list ${AXI_MASTER_RSTN}]]



#================================================================================
#  Configure and add AXI slaves
#================================================================================
#puts $AXI_MASTER_CLK
#puts $AXI_MASTER_RST
CONFIGURE_AXI_SLAVES

#========================================
#  Finish up
#========================================
validate_bd_design

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design "zynq_bd"

