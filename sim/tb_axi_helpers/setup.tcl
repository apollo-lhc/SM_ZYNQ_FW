create_wave_config

add_wave -regexp /tb_axi_helpers/.*
add_wave_divider AXI_Slave
add_wave -regexp /tb_axi_helpers/axiLiteReg_1/.*
add_wave_divider AXI_Master
add_wave -regexp /tb_axi_helpers/axiLiteMaster_1/.*


source tb_axi_helpers/run.tcl
