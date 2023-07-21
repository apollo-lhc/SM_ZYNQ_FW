#================================================================================
#  Create and configure the basic zynq MPSoC series processing system.
#================================================================================
#This code is directly sourced and builds the Zynq CPU

global ZYNQ_NAME
set ZYNQ_NAME ZynqMPSoC

startgroup

#create the zynq MPSoC
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == zynq_ultra_ps_e}] ${ZYNQ_NAME}

#configure the Zynq system

#puts [list_property [get_bd_cells ${ZYNQ_NAME}] *]

###############################
#clocking
###############################
#CPU frequency
set_property CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200}	    [get_bd_cells ${ZYNQ_NAME}]
#other clocks
set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {50}	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {500}    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500}	    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250}    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500}    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500}      [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__FPGA_PL1_ENABLE {1}                        [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {80}        [get_bd_cells ${ZYNQ_NAME}]
#set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {71.427856}        [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {50}        [get_bd_cells ${ZYNQ_NAME}]


###############################
#RAM (PS DDR)
###############################
set_property -dict [list CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200}         \
			CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400T}               \
                        CONFIG.PSU__DDRC__CWL {12}                             \
			CONFIG.PSU__DDRC__BG_ADDR_COUNT {1}		       \
			CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits}	       \
			CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits}		       \
			CONFIG.PSU__DDRC__ECC {Enabled}			       \
			CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16}]      [get_bd_cells ${ZYNQ_NAME}]


###############################
#AXI MASTERS
###############################
set_property CONFIG.PSU__USE__M_AXI_GP2 {0}			    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__USE__M_AXI_GP0 {1}			    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__USE__M_AXI_GP1 {1}			    [get_bd_cells ${ZYNQ_NAME}]

#connect FCLK_CLK0 to the master AXI_GP0 clock
#set AXI_MASTER_CLK ${ZYNQ_NAME}/pl_clk1
global AXI_MASTER_CLK
set AXI_MASTER_CLK ${ZYNQ_NAME}/pl_clk1
make_bd_pins_external -name axi_clk [get_bd_pins ${AXI_MASTER_CLK}]

set_property CONFIG.PSU__MAXIGP0__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__MAXIGP1__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]

connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm1_fpd_aclk]

global ZYNQ_RESETN
set ZYNQ_RESETN ${ZYNQ_NAME}/pl_resetn0

###############################
#MIO configuration
###############################
#All MIO configurations are in build_CPU_MIO.tcl
source ../src/ZynqPS/xczu7ev/build_CPU_MIO_rev2.tcl

#master reset circuit
set SYS_RESETTER_PRIMARY sys_resetter_primary
IP_SYS_RESET [dict create \
	          device_name ${SYS_RESETTER_PRIMARY} \
		  external_reset_n ${ZYNQ_RESETN} \
		  slowest_clk ${AXI_MASTER_CLK}]
####set interconnect reset
global AXI_PRIMARY_MASTER_RSTN
set AXI_PRIMARY_MASTER_RSTN [get_bd_pins ${SYS_RESETTER_PRIMARY}/interconnect_aresetn]
global AXI_PRIMARY_SLAVE_RSTN
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
global AXI_C2C_MASTER_RSTN
set AXI_C2C_MASTER_RSTN [get_bd_pins ${SYS_RESETTER_C2C}/interconnect_aresetn]
global AXI_C2C_SLAVE_RSTN
set AXI_C2C_SLAVE_RSTN [get_bd_pins ${SYS_RESETTER_C2C}/peripheral_aresetn]
make_bd_pins_external -name axi_c2c_rst_n [get_bd_pins ${AXI_C2C_SLAVE_RSTN}]


#add interrupts from PL to PS
set_property CONFIG.PSU__USE__IRQ0 {1} [get_bd_cells ${ZYNQ_NAME}]

#validate the design
validate_bd_design
endgroup
