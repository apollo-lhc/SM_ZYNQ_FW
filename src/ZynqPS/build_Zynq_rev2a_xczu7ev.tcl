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

validate_bd_design

write_bd_layout -force -format pdf -orientation portrait ${apollo_root_path}/doc/zynq_bd.pdf

make_wrapper -files [get_files zynq_bd.bd] -top -import -force
save_bd_design

close_bd_design $bd_name

Generate_Global_package
