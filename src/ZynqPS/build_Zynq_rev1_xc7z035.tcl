#create a block design called "zynq_bd"
create_bd_design -dir ./ "zynq_bd"

#helpers for building AXI things
source -quiet ${apollo_root_path}/bd/axi_helpers.tcl
source -quiet ${apollo_root_path}/bd/Xilinx_AXI_slaves.tcl

#================================================================================
#  Create and configure the basic zynq processing system.
#  build_CPU contains CPU parameters includeing the MIO and peripheral configs
#================================================================================
puts "Building CPU"
source ${apollo_root_path}/src/ZynqPS/xc7z/build_CPU_rev1.tcl

#================================================================================
#  Create an AXI interconnect
#================================================================================
set AXI_INTERCONNECT_NAME AXI_INTERCONNECT
set AXI_C2C_INTERCONNECT_NAME AXI_C2C_INTERCONNECT

set PL_MASTER PL
set PL_M      AXIM_${PL_MASTER}
set PL_M_CLK  AXI_CLK_${PL_MASTER}
set PL_M_RSTN AXI_RSTN_${PL_MASTER}
set PL_M_FREQ 50000000
[AXI_PL_MASTER_PORT ${PL_M} ${PL_M_CLK} ${PL_M_RSTN} ${PL_M_FREQ}]

set AXI_MASTER_CLK_FREQ 50000000




#create the main interconnect (connected to the PL master and the Zynq(via FW))
[BUILD_AXI_INTERCONNECT ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_PRIMARY_MASTER_RSTN} [list ${ZYNQ_NAME}/M_AXI_GP0 ${PL_M}] [list ${AXI_MASTER_CLK} ${PL_M_CLK}] [list ${AXI_PRIMARY_MASTER_RSTN} ${PL_M_RSTN}]]


#build the C2C interconnect
[BUILD_AXI_INTERCONNECT ${AXI_C2C_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_C2C_MASTER_RSTN} [list ${ZYNQ_NAME}/M_AXI_GP1] [list ${AXI_MASTER_CLK}] [list ${AXI_C2C_MASTER_RSTN}]]
set_property CONFIG.STRATEGY {1} [get_bd_cells ${AXI_C2C_INTERCONNECT_NAME}]


#add interrupt controller
set IRQ0_INTR_CTRL IRQ0_INTR_CTRL
AXI_IP_IRQ_CTRL [dict create \
		 device_name ${IRQ0_INTR_CTRL} \
		 irq_dest ${ZYNQ_NAME}/IRQ_F2P \
		 axi_control {[dict create \
		    axi_interconnect "${::AXI_INTERCONNECT_NAME}" \
		    axi_clk "${::AXI_MASTER_CLK}" \
		    axi_rstn "${::AXI_PRIMARY_SLAVE_RSTN}" \
		    axi_freq "${::AXI_MASTER_CLK_FREQ}" \		 
		    ]}\
		 dt_data {    compatible = "xlnx,axi-intc-4.1", "xlnx,xps-intc-1.00.a"; \
                              interrupt-parent = <&intc>; \
                              interrupts = <0 29 0>; \
                              xlnx,kind-of-intr = <0x0>; \
                              label = "$device_name"; \
                              linux,uio-name = "$device_name";\
                         }
		]

set INIT_CLK init_clk
create_bd_port -dir I -type clk ${INIT_CLK}
set_property CONFIG.FREQ_HZ ${AXI_MASTER_CLK_FREQ} [get_bd_ports ${INIT_CLK}]

#================================================================================
#  Configure and add AXI slaves
#================================================================================
source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl
yaml_to_bd "${apollo_root_path}/configs/${build_name}/slaves.yaml"

GENERATE_AXI_ADDR_MAP_C "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_addrs.h"
GENERATE_AXI_ADDR_MAP_VHDL "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"
read_vhdl "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"

#========================================
#  Finish up
#========================================

regenerate_bd_layout

set_property CONFIG.STRATEGY {1} [get_bd_cells ${AXI_C2C_INTERCONNECT_NAME}]
validate_bd_design

write_bd_layout -force -format pdf -orientation portrait ${apollo_root_path}/doc/zynq_bd.pdf

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design "zynq_bd"

