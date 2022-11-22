restart
add_force {/tb_TCDS_Monitor/clk_axi} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/tb_TCDS_Monitor/clk_TCDS} -radix hex {1 0ns} {0 3119ps} -repeat_every 6238ps
add_force {/tb_TCDS_Monitor/reset} -radix hex {1 0ns}
run 35ns
add_force {/tb_TCDS_Monitor/reset} -radix hex {0 0ns}
run 5us
