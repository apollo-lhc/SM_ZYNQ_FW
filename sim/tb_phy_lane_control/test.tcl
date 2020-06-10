#Relaunch Sim
relaunch_sim

#set inputs to 0
add_force {/sim/phy_lane_1}     -radix hex {0 0ns}
add_force {/sim/phy_lane_2}     -radix hex {0 0ns}
add_force {/sim/initialize_in1} -radix hex {0 0ns}
add_force {/sim/initialize_in2} -radix hex {0 0ns}


#Set 100MHz axi_clk
add_force {/sim/clk} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
run 20ns

#reset
add_force {/sim/reset} -radix hex {1 0ns}
run 20ns
add_force {/sim/reset} -radix hex {0 0ns}
run 20ns

#set phylane1
run 100ns
add_force {/sim/phy_lane_1}     -radix hex {1 0ns}
add_force {/sim/phy_lane_2}     -radix hex {0 0ns}
add_force {/sim/initialize_in1} -radix hex {0 0ns}
add_force {/sim/initialize_in2} -radix hex {0 0ns}
run 100ns
