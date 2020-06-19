restart
add_force {/tb_phy_lane_control/clk} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/tb_phy_lane_control/reset} -radix hex {1 0ns}
run 10ns
add_force {/tb_phy_lane_control/reset} -radix hex {0 0ns}
run 6200ns
