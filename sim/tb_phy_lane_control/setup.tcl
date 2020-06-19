create_wave_config

#add_wave -regexp /tb_CM_pwr/.*

add_wave -regexp /tb_phy_lane_control/phy_lane_1/.*
add_wave -regexp /tb_phy_lane_control/initialize_test
add_wave -regexp /tb_phy_lane_control/aurora

source tb_phy_lane_control/run.tcl
