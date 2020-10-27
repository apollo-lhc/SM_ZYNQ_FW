#================================================================================
#  Create and configure the basic zynq 7000 series processing system.
#================================================================================
#This code is directly sourced and builds the Zynq CPU

set ZYNQ_NAME Zynq7

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
#extra clock for ethernet
set_property CONFIG.PCW_EN_CLK1_PORT {1}                     [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {25}        [get_bd_cells ${ZYNQ_NAME}]



###############################
#RAM
###############################
set_property CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} [get_bd_cells processing_system7_0]

###############################
#AXI MASTERS
###############################
set_property CONFIG.PCW_USE_M_AXI_GP0      {1} [get_bd_cells processing_system7_0]

set_property CONFIG.PCW_USE_M_AXI_GP1      {1} [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {1} [get_bd_cells processing_system7_0]

#connect FCLK_CLK0 to the master AXI_GP0 clock
set AXI_MASTER_CLK processing_system7_0/FCLK_CLK0
make_bd_pins_external -name axi_clk [get_bd_pins ${AXI_MASTER_CLK}]

connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins processing_system7_0/M_AXI_GP1_ACLK]


###############################
#MIO configuration
###############################
#All MIO configurations are in build_CPU_MIO.tcl
source ../src/ZynqPS/xc7z/build_CPU_MIO_rev2.tcl
#automatically create FIXED_IO and DDR interfaces.
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]



#SDIO clock to 25Mhz
set_property CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {25}         [get_bd_cells processing_system7_0]

set SYS_RESETER sys_reseter
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 $SYS_RESETER
#connect external reset
connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins $SYS_RESETER/ext_reset_in]
#connect clock
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $SYS_RESETER/slowest_sync_clk]
#set interconnect reset
set AXI_MASTER_RSTN [get_bd_pins ${SYS_RESETER}/interconnect_aresetn]
set AXI_SLAVE_RSTN [get_bd_pins ${SYS_RESETER}/peripheral_aresetn]
make_bd_pins_external -name axi_rst_n [get_bd_pins ${AXI_SLAVE_RSTN}]

#add interrupts from PL to PS
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]




#validate the design
validate_bd_design
endgroup


