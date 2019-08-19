restart
add_force {/tb_IPMC_i2c_slave/clk} -radix hex {1 0ns} {0 10000ps} -repeat_every 20000ps
add_force {/tb_IPMC_i2c_slave/reset} -radix hex {1 0ns}
run 10ns
add_force {/tb_IPMC_i2c_slave/reset} -radix hex {0 0ns}
run 400us
