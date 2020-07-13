create_wave_config

add_wave -regexp /tb_TCDS_Monitor/UUT/.*
#add_wave -regexp /tb_TCDS_Monitor/UUT/DC_data_CDC_0/.*

#add_wave -regexp /tb_TCDS_Monitor/UUT/\counter_generator(0)\/PRBS_counter_0/.*
#add_wave -regexp /tb_TCDS_Monitor/UUT/\counter_generator(0)\/capture_CDC_1/.*


source tb_TCDS_Monitor/run.tcl
