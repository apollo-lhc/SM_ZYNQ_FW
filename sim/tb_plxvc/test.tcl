#Relaunch Sim
relaunch_sim

#Set initial conditions
add_force {/sim/TMS_vector} -radix hex {0 0ns}
add_force {/sim/TDI_vector} -radix hex {0 0ns}
add_force {/sim/length} -radix hex {0 0ns}
add_force {/sim/CTRL} -radix hex {0 0ns}
add_force {/sim/axi_clk} -radix hex {0 0ns}
run 10ns

#Set 100MHz axi_clk
add_force {/sim/axi_clk} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
run 20ns

#reset
add_force {/sim/reset} -radix hex {1 0ns}
run 20ns
add_force {/sim/reset} -radix hex {0 0ns}
run 20ns

#run Test1
add_force {/sim/CTRL} -radix hex {1 0ns}
add_force {/sim/length} -radix unsigned {4 0ns}
add_force {/sim/TMS_vector} -radix hex {0000000A 0ns}
add_force {/sim/TDI_vector} -radix hex {00000005 0ns}
add_force {/sim/TDO} -radix hex {1 0ns}
run 30ns
add_force {/sim/CTRL} -radix hex {0 0ns}
run 300ns

#run Test2
add_force {/sim/CTRL} -radix hex {1 0ns}
add_force {/sim/length} -radix unsigned {32 0ns}
add_force {/sim/TMS_vector} -radix hex {A5A5A5A5 0ns}
add_force {/sim/TDI_vector} -radix hex {5A5A5A5A 0ns}
add_force {/sim/TDO} -radix hex {1 0ns}
run 30ns
add_force {/sim/CTRL} -radix hex {0 0ns}
run 1200ns

#run Test3 with interupt by reset
add_force {/sim/CTRL} -radix hex {1 0ns}
add_force {/sim/length} -radix unsigned {32 0ns}
add_force {/sim/TMS_vector} -radix hex {A5A5A5A5 0ns}
add_force {/sim/TDI_vector} -radix hex {5A5A5A5A 0ns}
add_force {/sim/TDO} -radix hex {1 0ns}
run 100ns
add_force {/sim/CTRL} -radix hex {0 0ns}
add_force {/sim/reset} -radix hex {1 0ns}
run 10ns
add_force {/sim/reset} -radix hex {0 0ns}
run 50ns
