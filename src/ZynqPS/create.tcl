#create a block design called "zynq_bd"
create_bd_design -dir ./ "zynq_bd"


#helpers for building AXI things
source ../bd/axi_helpers.tcl
source ../bd/Xilinx_AXI_slaves.tcl

#================================================================================
#  Create and configure the basic zynq processing system.
#  build_CPU contains CPU parameters includeing the MIO and peripheral configs
#================================================================================
puts "Building CPU"
source ../src/ZynqPS/build_CPU.tcl

#================================================================================
#  Create an AXI interconnect
#================================================================================
set AXI_INTERCONNECT_NAME AXI_INTERCONNECT

[BUILD_AXI_INTERCONNECT ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} [list processing_system7_0/M_AXI_GP0] [list ${AXI_MASTER_CLK}] [list ${AXI_MASTER_RSTN}]]


#================================================================================
#  Configure and add AXI slaves
#================================================================================

#SI chip i2c core (addr fixed for FSBL)
[AXI_IP_I2C SI                ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 0x41600000]

# SM services slave (addr fixed for FSBL)
[AXI_PL_DEV_CONNECT SERV      ${AXI_INTERCONNECT_NAME} PL_CLK PL_RESET_N 5000000 0x43C20000]


#C2C link for kintex (FIXED ADDRESS)
set INIT_CLK init_clk
create_bd_port -dir I -type clk ${INIT_CLK}
set_property CONFIG.FREQ_HZ 50000000 [get_bd_ports ${INIT_CLK}]
[AXI_C2C_MASTER C2C1          ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 1 ${INIT_CLK} 0x7aa00000 64K 0x43c40000 64K]
[AXI_C2C_MASTER C2C2          ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 C2C1_PHY ${INIT_CLK} 0x7aa10000 64K 0x43d40000 64K]

		              
#XVC cores	              
[AXI_IP_XVC XVC1              ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000]
[AXI_IP_XVC XVC2              ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000]
[AXI_IP_LOCAL_XVC XVC_LOCAL   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000]

#PL slaves
[AXI_PL_DEV_CONNECT SLAVE_I2C ${AXI_INTERCONNECT_NAME} PL_CLK PL_RESET_N 5000000]
[AXI_PL_DEV_CONNECT CM        ${AXI_INTERCONNECT_NAME} PL_CLK PL_RESET_N 5000000]
[AXI_PL_DEV_CONNECT SM_INFO   ${AXI_INTERCONNECT_NAME} PL_CLK PL_RESET_N 5000000]

#XADC monitor
[AXI_IP_XADC MONITOR          ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000]

#========================================
#  Finish up
#========================================
validate_bd_design

write_bd_layout -force -format pdf -orientation portrait ../doc/zynq_bd.pdf

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design "zynq_bd"

