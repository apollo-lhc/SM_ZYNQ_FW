#create a block design called "zynq_bd"
create_bd_design -dir ../bd "zynq_bd"

#================================================================================
#  List the AXI devices to be added (needed for AXI interconnect sizing)
#================================================================================
source ../bd/build_AXI_slaves.tcl

puts "Adding list of AXI slaves"
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
puts "Building AXI interconnect"
source ../bd/build_AXI_interconnect.tcl


#================================================================================
#  Configure and add AXI slaves
#================================================================================
puts $AXI_MASTER_CLK
puts $AXI_MASTER_RST
CONFIGURE_AXI_SLAVES


######========================================
######  FP LEDs (xilinx axi gpio)
######========================================
######add a GPIO device to the interconnect
#####create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 FP_LEDs
#####set_property CONFIG.C_GPIO_WIDTH  {4} [get_bd_cells FP_LEDs]
#####set_property CONFIG.C_ALL_OUTPUTS {1} [get_bd_cells FP_LEDs]
######connect to AXI, clk, and reset
#####[AXI_DEV_CONNECT FP_LEDs $AXI_BUS_M(FP_LEDs) $AXI_MASTER_CLK $AXI_MASTER_RST]
######make external pins
#####apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins FP_LEDs/GPIO]
#####connect_bd_net $AXI_MASTER_CLK [get_bd_pins $AXI_BUS_CLK(FP_LEDs)]
#####connect_bd_net $AXI_MASTER_RST [get_bd_pins $AXI_BUS_RST(FP_LEDs)]
#####[AXI_DEV_UIO_DTSI_CHUNK FP_LEDs]
######========================================
######  Add non-xilinx AXI slave
######========================================
######[AXI_PL_DEV_CONNECT myReg $AXI_INTERCONNECT_NAME $AXI_BUS_M(MY_REG) PL_CLK PL_RESET_N 125000000]
#####[AXI_PL_DEV_CONNECT myReg $AXI_INTERCONNECT_NAME $AXI_BUS_M(MY_REG) $AXI_BUS_CLK(MY_REG) $AXI_BUS_RST(MY_REG) 125000000]
#####

#========================================
#  Finish up
#========================================
validate_bd_design

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design "zynq_bd"

