#-----------------------------------------------------
# Bit synchronizer
#-----------------------------------------------------
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_synchronizer/i_in_meta_reg}]

#-----------------------------------------------------
# Reset synchronizer
#-----------------------------------------------------
set_false_path -to [get_pins -filter REF_PIN_NAME=~*D -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta*}]]
set_false_path -to [get_pins -filter REF_PIN_NAME=~*PRE -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta*}]]
set_false_path -to [get_pins -filter REF_PIN_NAME=~*PRE -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync1*}]]
set_false_path -to [get_pins -filter REF_PIN_NAME=~*PRE -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync2*}]]
set_false_path -to [get_pins -filter REF_PIN_NAME=~*PRE -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync3*}]]
set_false_path -to [get_pins -filter REF_PIN_NAME=~*PRE -of_objects [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_out*}]]
#-----------------------------------------------------
# MGT Tx/Rx active
#-----------------------------------------------------
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *gtwiz_userclk_tx_active*reg*}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *gtwiz_userclk_rx_active*reg*}]

#-----------------------------------------------------
# CDC TX and RX
#-----------------------------------------------------
set_max_delay -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/data_a_reg_reg*}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/data_b_reg_reg*}] -filter {REF_PIN_NAME == D}] -datapath_only 6.25
set_max_delay -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/reset_a_strobe_sync_reg}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/reset_b_meta_reg}] -filter {REF_PIN_NAME == D}] -datapath_only 6.25
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/reset_freerun_meta_reg}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/xormeas_meta_reg}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/advance_toggle_meta_reg}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/retard_toggle_meta_reg}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_tx/ready_b_meta_reg}] -filter {REF_PIN_NAME == D}]

set_max_delay -from  [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/data_a_reg_reg*}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/data_b_reg_reg*}] -filter {REF_PIN_NAME == D}] -datapath_only 6.25
set_max_delay -from  [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/strobe_b_toggle_reg}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/strobe_b_toggle_meta_reg}] -filter {REF_PIN_NAME == D}] -datapath_only 6.25
set_false_path -to   [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/phase_calib_a_reg*}] -filter {REF_PIN_NAME == D}]
set_false_path -to   [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/phase_force_a_reg}] -filter {REF_PIN_NAME == D}]
set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_cdc_rx/phase_o_reg*}] -filter {REF_PIN_NAME == C}]

#-----------------------------------------------------
# lpGBT10G Rx - lpGBT-FPGA - MASTER + SLAVE
#-----------------------------------------------------
# Uplink constraints: Values depend on the c_multicyleDelay. Shall be the same one for setup time and -1 for the hold time
set_multicycle_path 3 -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbtfpga_uplink/frame_pipelined_s_reg[*]}] -filter {REF_PIN_NAME == C}] -setup
set_multicycle_path 2 -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbtfpga_uplink/frame_pipelined_s_reg[*]}] -filter {REF_PIN_NAME == C}] -hold
#set_multicycle_path 3 -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbtfpga_uplink/*descrambledData_reg[*]}] -filter {REF_PIN_NAME == C}] -setup
#set_multicycle_path 2 -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbtfpga_uplink/*descrambledData_reg[*]}] -filter {REF_PIN_NAME == C}] -hold

#-----------------------------------------------------
# lpGBT10G Tx - lpGBT-FE Tx - MASTER + SLAVE
#-----------------------------------------------------
set_multicycle_path 7 -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbt_fe_tx/txgearbox_inst/dataWord_reg*}] -filter {REF_PIN_NAME == D}] -through [get_nets -hierarchical -filter {NAME =~ *cmp_lpgbt_fe_tx/txdatapath_inst/fec5*}] -setup
set_multicycle_path 6 -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_lpgbt_fe_tx/txgearbox_inst/dataWord_reg*}] -filter {REF_PIN_NAME == D}] -through [get_nets -hierarchical -filter {NAME =~ *cmp_lpgbt_fe_tx/txdatapath_inst/fec5*}] -hold

#-----------------------------------------------------
# HPTD IP Core - MASTER + SLAVE
#-----------------------------------------------------
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/*meta*}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/cmp_fifo_fill_level_acc/phase_detector_o*}] -filter {REF_PIN_NAME == D}]
set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/*cmp_tx_phase_aligner_fsm/*}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/cmp_fifo_fill_level_acc/phase_detector_acc_reg*}] -filter {REF_PIN_NAME == CE}]
set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/*cmp_tx_phase_aligner_fsm/*}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/cmp_fifo_fill_level_acc/hits_acc_reg*}] -filter {REF_PIN_NAME == CE}]
set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/*cmp_tx_phase_aligner_fsm/*}] -filter {REF_PIN_NAME == C}] -to [get_pins -of [get_cells -hierarchical -filter {NAME =~ *cmp_tx_phase_aligner/cmp_fifo_fill_level_acc/done_reg}] -filter {REF_PIN_NAME == D}]
