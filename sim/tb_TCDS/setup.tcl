create_wave_config

add_wave -regexp /tb_TCDS/.*

add_wave -regexp /tb_TCDS/axiLiteMaster_1/.*
add_wave -regexp /tb_TCDS/TCDS_1/.*

source tb_TCDS/run.tcl
