#================================================================================
#  Create and configure the basic zynq MPSoC series processing system.
#================================================================================
#This code is directly sourced and builds the Zynq CPU

set ZYNQ_NAME ZynqMPSoC

startgroup

#create the zynq MPSoC
#create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.2 zynq_ultra_ps_e_0
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == zynq_ultra_ps_e}] ${ZYNQ_NAME}

#configure the Zynq system

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
set AXI_MASTER_CLK ${ZYNQ_NAME}/pl_clk1
make_bd_pins_external -name axi_clk [get_bd_pins ${AXI_MASTER_CLK}]

set_property CONFIG.PSU__MAXIGP0__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]
set_property CONFIG.PSU__MAXIGP1__DATA_WIDTH {32}		    [get_bd_cells ${ZYNQ_NAME}]

connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm1_fpd_aclk]
#connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins ${ZYNQ_NAME}/maxihpm0_lpd_aclk]

set ZYNQ_RESETN ${ZYNQ_NAME}/pl_resetn0

###############################
#MIO configuration
###############################
#All MIO configurations are in build_CPU_MIO.tcl
source ../src/ZynqPS/xczu7ev/build_CPU_MIO_rev2.tcl



set SYS_RESETER sys_reseter
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == proc_sys_reset}] $SYS_RESETER

#connect external reset
connect_bd_net [get_bd_pins ${ZYNQ_RESETN}] [get_bd_pins $SYS_RESETER/ext_reset_in]
#connect clock
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $SYS_RESETER/slowest_sync_clk]
#set interconnect reset
set AXI_MASTER_RSTN [get_bd_pins ${SYS_RESETER}/interconnect_aresetn]
set AXI_SLAVE_RSTN [get_bd_pins ${SYS_RESETER}/peripheral_aresetn]
make_bd_pins_external -name axi_rst_n [get_bd_pins ${AXI_SLAVE_RSTN}]


#add interrupts from PL to PS
set_property CONFIG.PSU__USE__IRQ0 {1} [get_bd_cells ${ZYNQ_NAME}]

endgroup
