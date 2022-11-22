add wave -position insertpoint  \
sim:/tb_cdc_tx/c_CLOCK_FREERUN_PERIOD \
sim:/tb_cdc_tx/c_PRBS_POLYNOMIAL \
sim:/tb_cdc_tx/c_STROBE_PERIOD \
sim:/tb_cdc_tx/clk_a \
sim:/tb_cdc_tx/clk_b \
sim:/tb_cdc_tx/clk_freerun \
sim:/tb_cdc_tx/data_a \
sim:/tb_cdc_tx/data_b \
sim:/tb_cdc_tx/phase_calib \
sim:/tb_cdc_tx/phase_force \
sim:/tb_cdc_tx/phase \
sim:/tb_cdc_tx/prbschk_error \
sim:/tb_cdc_tx/prbschk_locked \
sim:/tb_cdc_tx/prbschk_reset \
sim:/tb_cdc_tx/prbsgen_data \
sim:/tb_cdc_tx/prbsgen_data_valid \
sim:/tb_cdc_tx/prbsgen_en \
sim:/tb_cdc_tx/prbsgen_load \
sim:/tb_cdc_tx/prbsgen_reset \
sim:/tb_cdc_tx/prbsgen_seed \
sim:/tb_cdc_tx/strobe_a \
sim:/tb_cdc_tx/ready_b \
sim:/tb_cdc_tx/strobe_b

property wave -radix  unsigned -color "Cyan" /tb_cdc_tx/phase
property wave -format analog-step -height 74 -scale 4.7e-2 -offset 0 /tb_cdc_tx/phase