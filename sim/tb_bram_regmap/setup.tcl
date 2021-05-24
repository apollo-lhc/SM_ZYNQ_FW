create_wave_config

add_wave -regexp /tb_bram_regmap/.*
add_wave_divider AXI_Slave
add_wave -regexp /tb_bram_regmap/mem_test_1/.*
add_wave_divider bram
add_wave {{/tb_bram_regmap/mem_test_1/blockram}} 
add_wave_divider MEM_TEST_interface
add_wave {{/tb_bram_regmap/mem_test_1/MEM_TEST_interface_1}} 
add_wave_divider axi_bridge
add_wave {{/tb_bram_regmap/mem_test_1/MEM_TEST_interface_1/AXIRegBridge}} 

#add_wave_divider AXI_Master
#add_wave -regexp /tb_bram_regmap/axiLiteMaster_1/.*


source tb_bram_regmap/run.tcl
