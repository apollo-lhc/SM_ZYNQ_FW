#source ${apollo_root_path}/bd/Xilinx_Helpers.tcl

#create a block design called "zynq_bd"
create_bd_design -dir ./ $bd_name

set AXI_ADDR_WIDTH 32

#helpers for building AXI things
source ${apollo_root_path}/bd/axi_helpers.tcl
source ${apollo_root_path}/bd/AXI_Cores/Xilinx_AXI_Endpoints.tcl
source ${apollo_root_path}/bd/Cores/Xilinx_Cores.tcl
source ${apollo_root_path}/bd/utils/add_slaves_from_yaml.tcl
source ${apollo_root_path}/bd/utils/Global_Constants.tcl

#================================================================================
#  Create and configure the basic zynq processing system.
#  build_CPU contains CPU parameters includeing the MIO and peripheral configs
#================================================================================
puts "Building CPU"
source ${apollo_root_path}/src/ZynqPS/xczu7ev/build_CPU_rev2.tcl

global AXI_MASTER_CLK_FREQ
set AXI_MASTER_CLK_FREQ [get_property CONFIG.FREQ_HZ [get_bd_pin ${AXI_MASTER_CLK}]]
Add_Global_Constant AXI_MASTER_CLK_FREQ integer ${AXI_MASTER_CLK_FREQ}
#================================================================================
#  Create an AXI interconnect
#================================================================================
########set AXI_INTERCONNECT_NAME AXI_INTERCONNECT
########set AXI_C2C_INTERCONNECT_NAME AXI_C2C_INTERCONNECT
########
########set PL_MASTER PL
########set PL_M      AXIM_${PL_MASTER}
########set PL_M_CLK  ${AXI_MASTER_CLK}
########set PL_M_RSTN ${AXI_PRIMARY_MASTER_RSTN}
########set PL_M_FREQ [get_property CONFIG.FREQ_HZ [get_bd_pin ${AXI_MASTER_CLK}]]
########AXI_PL_MASTER_PORT "name ${PL_M} axi_clk ${PL_M_CLK} axi_rstn ${PL_M_RSTN} axi_freq ${PL_M_FREQ}"
########
########
########
########set AXI_MASTER_CLK_FREQ [get_property CONFIG.FREQ_HZ [get_bd_pin ${AXI_MASTER_CLK}]]
########Add_Global_Constant AXI_MASTER_CLK_FREQ integer ${AXI_MASTER_CLK_FREQ}
########
#########create the main interconnect
########puts "  Primary interconnect"
########BUILD_AXI_INTERCONNECT \
########     ${AXI_INTERCONNECT_NAME} \
########     ${AXI_MASTER_CLK} \
########     ${AXI_PRIMARY_MASTER_RSTN} \
########     [list ${ZYNQ_NAME}/M_AXI_HPM0_FPD ${PL_M} ] \
########     [list ${AXI_MASTER_CLK} ${AXI_MASTER_CLK}] \
########     [list ${AXI_PRIMARY_MASTER_RSTN} ${AXI_PRIMARY_MASTER_RSTN}] 
########
########
#########build the C2C interconnect
########puts "  C2C interconnect"
########BUILD_AXI_INTERCONNECT \
########    ${AXI_C2C_INTERCONNECT_NAME} \
########    ${AXI_MASTER_CLK} \
########    ${AXI_C2C_MASTER_RSTN} \
########    [list ${ZYNQ_NAME}/M_AXI_HPM1_FPD] \
########    [list ${AXI_MASTER_CLK}] \
########    [list ${AXI_C2C_MASTER_RSTN}]
########set_property CONFIG.STRATEGY {1} [get_bd_cells ${AXI_C2C_INTERCONNECT_NAME}]


########puts "Building interrupt controller"
#########add interrupt controller
########set IRQ0_INTR_CTRL IRQ0_INTR_CTRL
########AXI_IP_IRQ_CTRL [dict create \
########		     device_name ${IRQ0_INTR_CTRL} \
########		     irq_dest ${ZYNQ_NAME}/pl_ps_irq0 \
########		     axi_control [dict create \
########				      axi_interconnect ${AXI_INTERCONNECT_NAME} \
########				      axi_clk ${AXI_MASTER_CLK} \
########				      axi_rstn ${AXI_PRIMARY_SLAVE_RSTN} \
########				      axi_freq ${AXI_MASTER_CLK_FREQ} \
########				     ]\
########		     dt_data { \
########				   interrupt-parent = <&gic>; \
########				   interrupts = <0 89 0>; \
########			       } \
########		    ]

#AXI_IP_IRQ_SIMPLE [dict create \
#		       device_name ${IRQ0_INTR_CTRL} \
#		       irq_dest ${ZYNQ_NAME}/pl_ps_irq0 \
#		      ]


#puts "Adding init clk"
#set INIT_CLK init_clk
#create_bd_port -dir I -type clk ${INIT_CLK}
#set_property CONFIG.FREQ_HZ ${AXI_MASTER_CLK_FREQ} [get_bd_ports ${INIT_CLK}]


#================================================================================
#  Configure and add AXI slaves
#================================================================================
puts "Adding IP from yaml"
source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl
yaml_to_bd "${apollo_root_path}/configs/${build_name}/config.yaml"

GENERATE_AXI_ADDR_MAP_C "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_addrs.h"
GENERATE_AXI_ADDR_MAP_VHDL "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"
read_vhdl "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"
#========================================
#  Finish up
#========================================

regenerate_bd_layout

set_property CONFIG.STRATEGY {1} [get_bd_cells ${::AXI_C2C_INTERCONNECT}]
set_property CONFIG.STRATEGY {1} [get_bd_cells ${::AXI_MAIN_INTERCONNECT}]
validate_bd_design

write_bd_layout -force -format pdf -orientation portrait ${apollo_root_path}/doc/zynq_bd.pdf

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design $bd_name

Generate_Global_package
