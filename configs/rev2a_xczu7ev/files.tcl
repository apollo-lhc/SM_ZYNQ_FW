set bd_path proj/

array set bd_files [list {zynq_bd} {src/ZynqPS/build_Zynq_rev2a_xczu7ev.tcl} \
		       ]

set vhdl_files "\
     configs/rev2a_xczu7ev/top.vhd \
     src/misc/types.vhd \
     src/misc/counter.vhd \
     src/misc/counter_CDC.vhd \
     src/misc/asym_dualport_ram.vhd \
     src/misc/uart_rx6.vhd \
     src/misc/DC_data_CDC.vhd \
     src/misc/data_CDC.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/pacd.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/rate_counter.vhd \
     src/axiReg/axiRegWidthPkg_32.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/axiReg/axiRegMaster.vhd \
     src/services/services_rev2.vhd \
     src/services/SERV_map.vhd \
     src/services/SERV_PKG.vhd \
     src/IPMC_i2c_slave/i2c_slave.vhd \
     src/IPMC_i2c_slave/IPMC_i2c_slave.vhd \
     src/CM_interface/CM_map.vhd \
     src/CM_interface/CM_PKG.vhd \
     src/CM_interface/CM_interface.vhd \
     src/CM_interface/CM_Monitoring.vhd \
     src/CM_interface/CM_pwr.vhd \
     src/CM_interface/CM_package.vhd \
     src/CM_interface/CM_phy_lane_control.vhd \
     src/front_panel/Button_Debouncer.vhd \
     src/front_panel/Button_Decoder.vhd \
     src/front_panel/FrontPanel_UI.vhd \
     src/front_panel/LED_Encoder.vhd \
     src/front_panel/SR_Out.vhd \
     src/front_panel/LED_Paterns.vhd \
     src/SM_info/SM_INFO_map.vhd \
     src/SM_info/SM_INFO_PKG.vhd \
     src/SM_info/SM_info.vhd \
     src/plXVC/PLXVC_map.vhd \
     src/plXVC/PLXVC_PKG.vhd \
     src/plXVC/plXVC_intf.vhd \
     src/plXVC/virtualJTAG.vhd \
     src/TCDS/tclink/firmware/source/common/bit_synchronizer.vhd \
     src/TCDS/tclink/firmware/source/common/reset_synchronizer.vhd \
     src/TCDS/tclink/firmware/source/datapath/cdc_user/cdc_rx.vhd \
     src/TCDS/tclink/firmware/source/datapath/cdc_user/cdc_tx.vhd \
     src/TCDS/tclink/firmware/source/datapath/hprbs_framing/prbs_chk.vhd \
     src/TCDS/tclink/firmware/source/datapath/hprbs_framing/prbs_gen.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_add_4.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_add_5.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_multBy2_4.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_multBy2_5.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_multBy3_4.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/gf_multBy3_5.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/rs_encoder_N15K13.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/rs_encoder_N31K29.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/scrambler51bitOrder49.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/scrambler53bitOrder49.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/scrambler58bitOrder58.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/scrambler60bitOrder58.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkDataSelect.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkFECEncoder.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkInterleaver.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkScrambler.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkTxDataPath.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt-fe/upLinkTxGearBox.v \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fe/lpgbt_fe_tx.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/lpgbtfpga_package.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/lpgbtfpga_uplink.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/descrambler_51bitOrder49.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/descrambler_53bitOrder49.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/descrambler_58bitOrder58.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/descrambler_60bitOrder58.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/fec_rsDecoderN15K13.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/fec_rsDecoderN31K29.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/lpgbtfpga_decoder.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/lpgbtfpga_deinterleaver.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/lpgbtfpga_descrambler.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/lpgbtfpga_framealigner.vhd \
     src/TCDS/tclink/firmware/source/datapath/lpgbt-fpga/uplink/lpgbtfpga_rxgearbox.vhd \
     src/TCDS/tclink/firmware/source/tclink/master_rx_slide_compensation.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/dco_controller.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/phase_offset_removal.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/pi_controller.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/scaler.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/sigma_delta_modulator.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_controller/tclink_controller.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_channel_controller.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_phase_detector/dmtd_phase_meas.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_phase_detector/dmtd_with_deglitcher.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_phase_detector/gc_extend_pulse.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_phase_detector/gc_pulse_synchronizer.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_phase_detector/gc_sync_ffs.vhd \
     src/TCDS/tclink/firmware/source/tclink/tclink_tester/tclink_tester_unit.vhd \
     src/TCDS/tclink/firmware/source/tclink_lpgbt.vhd \
     src/TCDS/tclink/firmware/source/tclink_lpgbt_pkg.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/drp_arbiter.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/hptd_ip_core/fifo_fill_level_acc.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/hptd_ip_core/tx_phase_aligner.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/hptd_ip_core/tx_phase_aligner_fsm.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/hptd_ip_core/tx_pi_ctrl.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_fixed_phase/mgt_fixed_phase.vhd \
     src/TCDS/tclink/firmware/source/transceiver/mgt_user_clock.vhd \
     src/TCDS/top_secret/counters/firmware/hdl/unlock_counter.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface_pkg.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface_choice_speed_10g.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface_with_mgt.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface_choice_mgt_usp_gth.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface.vhd \
     src/TCDS/top_secret/tcds2_interface/firmware/hdl/tcds2_interface_mgt.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/ttc2_frame_splitter.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tts2_frame_builder.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_choice_speed_10g.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_link_pkg.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_link_speed_pkg.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_streams_pkg.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_link_medium_pkg.vhd \
     src/TCDS/top_secret/tcds2_link/firmware/hdl/tcds2_link_csr_pkg.vhd \
     src/TCDS/top_secret/constants/firmware/hdl/constants_tcds2.vhd \
     src/TCDS/top_secret/board_and_fw_id/firmware/hdl/board_and_fw_id_pkg.vhd \
     src/TCDS/TCDS_2_map.vhd \
     src/TCDS/TCDS_2_PKG.vhd \
     src/TCDS/TCDS.vhd \
     src/LDAQ/LDAQ_map.vhd \
     src/LDAQ/LDAQ_PKG.vhd \
     src/LDAQ/LDAQ.vhd \
     "

set xdc_files "\
     configs/rev2a_xczu7ev/top.xdc \
     configs/rev2a_xczu7ev/top_clocks.xdc \
     configs/rev2a_xczu7ev/top_MGMT.xdc \
     "

set xci_files "\
    	      cores/onboard_CLK_USP/onboard_CLK.xci \
              src/TCDS/tclink/firmware/source/transceiver/ip_mgt_timing/gthe3_slave_timing_10g.xcix \
              configs/rev2a_xczu7ev/cores/LDAQ_MGBT.tcl \
              configs/rev2a_xczu7ev/cores/LOCAL_TCDS2.tcl \
              "

