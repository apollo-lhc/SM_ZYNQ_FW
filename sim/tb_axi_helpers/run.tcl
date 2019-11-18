restart
add_force {/tb_axi_helpers/clk} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/tb_axi_helpers/reset} -radix hex {1 0ns}
run 10ns
add_force {/tb_axi_helpers/reset} -radix hex {0 0ns}
run 30us
#quit
