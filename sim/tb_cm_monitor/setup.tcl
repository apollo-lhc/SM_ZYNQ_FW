create_wave_config

add_wave -regexp /tb_cm_monitor/.*

set uart_tx [add_wave_group uart_tx]
add_wave -into uart_tx -regexp /tb_cm_monitor/uart_tx6_1/.*

set CM_Monitoring [add_wave_group CM_Monitoring]
add_wave -into CM_Monitoring -regexp /tb_cm_monitor/CM_Monitoring_1/.*

set IPMC_slave [add_wave_group IPMC_slave]
add_wave -into IPMC_slave -regexp /tb_cm_monitor/IPMC_i2c_slave_1/.*

set IPMC_slave_MEM [add_wave_group IPMC_slave_MEM]
add_wave -into IPMC_slave_MEM -regexp /tb_cm_monitor/IPMC_i2c_slave_1/asym_ram_tdp_1/.*


source tb_cm_monitor/run.tcl
