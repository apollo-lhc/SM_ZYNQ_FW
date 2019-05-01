#================================================================================
#  Create and configure the basic zynq 7000 series processing system.
#================================================================================
#This code is directly sourced and builds the Zynq CPU

startgroup
#create basic zynq processing system
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0

#configure zynq system

###############################
#clocking
###############################
#frequency (MHZ)
set_property CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333}	     [get_bd_cells processing_system7_0]
#DDR frequency (MHZ)
set_property CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333374}           [get_bd_cells processing_system7_0]
#CPU frequency
set_property CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {667}	     [get_bd_cells processing_system7_0]
#clock ratio settings
set_property CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1}         [get_bd_cells processing_system7_0]

#connect FCLK_CLK0 to the master AXI_GP0 clock
set AXI_MASTER_CLK [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net $AXI_MASTER_CLK [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]


###############################
#MIO configuration
###############################
#All MIO configurations are in build_CPU_MIO.tcl
source ../bd/build_CPU_MIO.tcl						            
#automatically create FIXED_IO and DDR interfaces.
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]


#validate the design
validate_bd_design
endgroup


