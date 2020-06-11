create_wave_config

#add_wave -regexp /tb_CM_pwr/.*

add_wave -regexp /tb_phy_lane_control/phy_lane_1/.*

source tb_phy_lane_control/run.tcl
