#================================================================================
#  Create and configure the basic zynq 7000 series processing system.
#================================================================================
#This code is directly sourced and builds the Zynq CPU
set ZYNQ_NAME Zynq7

startgroup
#create basic zynq processing system
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ${ZYNQ_NAME}

#configure zynq system

###############################
#clocking
###############################
#frequency (MHZ)
set_property CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333}	     [get_bd_cells ${ZYNQ_NAME}]
#DDR frequency (MHZ)
set_property CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333374}           [get_bd_cells ${ZYNQ_NAME}]
#CPU frequency
set_property CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {667}	     [get_bd_cells ${ZYNQ_NAME}]
#clock ratio settings
set_property CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1}         [get_bd_cells ${ZYNQ_NAME}]


###############################
#RAM
###############################
set_property CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} [get_bd_cells ${ZYNQ_NAME}]

###############################
#AXI MASTERS
###############################
set_property CONFIG.PCW_USE_M_AXI_GP0      {1} [get_bd_cells ${ZYNQ_NAME}]

set_property CONFIG.PCW_USE_M_AXI_GP1      {1} [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {1} [get_bd_cells ${ZYNQ_NAME}]

#connect FCLK_CLK0 to the master AXI_GP0 clock
set AXI_MASTER_CLK ${ZYNQ_NAME}/FCLK_CLK0
make_bd_pins_external -name axi_clk [get_bd_pins ${AXI_MASTER_CLK}]

connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/M_AXI_GP1_ACLK]

set ZYNQ_RESETN ${ZYNQ_NAME}/FCLK_RESET0_N

###############################
#MIO configuration
###############################
#All MIO configurations are in build_CPU_MIO.tcl
source ../src/ZynqPS/xc7z/build_CPU_MIO_rev1.tcl
#automatically create FIXED_IO and DDR interfaces.
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells ${ZYNQ_NAME}]



#SDIO clock to 25Mhz
set_property CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {25}         [get_bd_cells ${ZYNQ_NAME}]

#master reset circuit
set SYS_RESETTER_PRIMARY sys_resetter_primary
IP_SYS_RESET [dict create \
	          device_name ${SYS_RESETTER_PRIMARY} \
		  external_reset_n ${ZYNQ_RESETN} \
		  slowest_clk ${AXI_MASTER_CLK}]

####set interconnect reset
set AXI_PRIMARY_MASTER_RSTN [get_bd_pins ${SYS_RESETTER_PRIMARY}/interconnect_aresetn]
set AXI_PRIMARY_SLAVE_RSTN [get_bd_pins ${SYS_RESETTER_PRIMARY}/peripheral_aresetn]
make_bd_pins_external -name axi_rst_n [get_bd_pins ${AXI_PRIMARY_SLAVE_RSTN}]



#c2c interconnect reset circuit
set SYS_RESETTER_C2C sys_resetter_c2c
set SYS_RESETTER_C2C_RST c2c_interconnect_reset
create_bd_port -dir I -type rst ${SYS_RESETTER_C2C_RST}
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports ${SYS_RESETTER_C2C_RST}]
IP_SYS_RESET [dict create \
	          device_name ${SYS_RESETTER_C2C} \
		  external_reset_n ${ZYNQ_RESETN} \
		  slowest_clk ${AXI_MASTER_CLK} \
		  aux_reset ${SYS_RESETTER_C2C_RST} \
	     ]
set AXI_C2C_MASTER_RSTN [get_bd_pins ${SYS_RESETTER_C2C}/interconnect_aresetn]
set AXI_C2C_SLAVE_RSTN [get_bd_pins ${SYS_RESETTER_C2C}/peripheral_aresetn]
make_bd_pins_external -name axi_c2c_rst_n [get_bd_pins ${AXI_C2C_SLAVE_RSTN}]


#add interrupts from PL to PS
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1}] [get_bd_cells ${ZYNQ_NAME}]
set_property -dict [list CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells ${ZYNQ_NAME}]




#validate the design
validate_bd_design
endgroup


