create_wave_config

add_wave -regexp /tb_IPMC_i2c_slave/.*

add_wave_divider IPMC_i2c_slave

add_wave -regexp /tb_IPMC_i2c_slave/IPMC_i2c_slave_1/.*

add_wave_divider RAM

add_wave -regexp /tb_IPMC_i2c_slave/IPMC_i2c_slave_1/asym_ram_tdp_1/.*

add_wave_divider RAM

add_wave -regexp /tb_IPMC_i2c_slave/IPMC_i2c_slave_1/i2c_slave_1/.*

source tb_IPMC_i2c_slave/run.tcl
