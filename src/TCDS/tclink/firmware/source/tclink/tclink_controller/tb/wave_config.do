add wave -position insertpoint  \
sim:/tb_tclink_controller/Adco \
sim:/tb_tclink_controller/Aie \
sim:/tb_tclink_controller/Aie_enable \
sim:/tb_tclink_controller/Ape \
sim:/tb_tclink_controller/enable_mirror \
sim:/tb_tclink_controller/sigma_delta_osr \
sim:/tb_tclink_controller/modulo_carrier_period \
sim:/tb_tclink_controller/TEST_BENCH_STATUS \
sim:/tb_tclink_controller/reference_signal \
sim:/tb_tclink_controller/output_signal \
sim:/tb_tclink_controller/error_signal \
sim:/tb_tclink_controller/error_beat \
sim:/tb_tclink_controller/error_cntr \
sim:/tb_tclink_controller/sigma_delta_beat \
sim:/tb_tclink_controller/sigma_delta_cntr \
sim:/tb_tclink_controller/clk_sys_i \
sim:/tb_tclink_controller/reset_i \
sim:/tb_tclink_controller/clk_en_error_i \
sim:/tb_tclink_controller/error_i \
sim:/tb_tclink_controller/offset_error_i \
sim:/tb_tclink_controller/modulo_carrier_period_i \
sim:/tb_tclink_controller/error_processed_o \
sim:/tb_tclink_controller/close_loop_i \
sim:/tb_tclink_controller/Aie_i \
sim:/tb_tclink_controller/Aie_enable_i \
sim:/tb_tclink_controller/Ape_i \
sim:/tb_tclink_controller/clk_en_sigma_delta_i \
sim:/tb_tclink_controller/enable_mirror_i \
sim:/tb_tclink_controller/Adco_i \
sim:/tb_tclink_controller/phase_acc_o \
sim:/tb_tclink_controller/strobe_o \
sim:/tb_tclink_controller/done_i \
sim:/tb_tclink_controller/c_PERIOD_SYSCLK \
sim:/tb_tclink_controller/c_PERIOD_ERROR \
sim:/tb_tclink_controller/c_PERIOD_SIGMA_DELTA

property wave -radix  decimal -color "Violet"     /tb_tclink_controller/reference_signal
property wave -format analog-step -height 74 -scale 4e-7 -offset 8.2e7 /tb_tclink_controller/reference_signal

property wave -radix  decimal -color "Cyan"     /tb_tclink_controller/output_signal
property wave -format analog-step -height 74 -scale 4e-7 -offset 8.2e7 /tb_tclink_controller/output_signal
