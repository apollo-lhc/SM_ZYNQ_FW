set bd_path proj/

array set bd_files [list {zynq_bd} {src/ZynqPS/build_Zynq_rev2a_xczu7ev.tcl} \
		       ]

set vhdl_files "\
     configs/rev2a_xczu7ev/src/top_ibert.vhd \
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
     regmap_helper/axiReg/axiRegWidthPkg_32.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
     regmap_helper/axiReg/axiReg.vhd \
     regmap_helper/axiReg/axiRegMaster.vhd \
     regmap_helper/axiReg/bramPortPkg.vhd \
     regmap_helper/axiReg/axiRegBlocking.vhd \
     src/services/services_rev2.vhd \
     ${autogen_path}/SERV/SERV_map.vhd \
     ${autogen_path}/SERV/SERV_PKG.vhd \
     src/IPMC_i2c_slave/i2c_slave.vhd \
     src/IPMC_i2c_slave/IPMC_i2c_slave.vhd \
     ${autogen_path}/CM/CM_map.vhd \
     ${autogen_path}/CM/CM_PKG.vhd \
     src/CM_interface/CM_interface.vhd \
     src/CM_interface/CM_Monitoring.vhd \
     src/CM_interface/CM_pwr.vhd \
     src/CM_interface/CM_package.vhd \
     src/CM_interface/CM_phy_lane_control.vhd \
     src/CM_interface/picoblaze/picoblaze/cli.vhd \
     src/CM_interface/picoblaze/picoblaze/kcpsm6.vhd \
     src/CM_interface/picoblaze/uart_rx6.vhd \
     src/CM_interface/picoblaze/uart_tx6.vhd \
     src/CM_interface/picoblaze/uC.vhd \     
     src/front_panel/Button_Debouncer.vhd \
     src/front_panel/Button_Decoder.vhd \
     src/front_panel/FrontPanel_UI.vhd \
     src/front_panel/LED_Encoder.vhd \
     src/front_panel/SR_Out.vhd \
     src/front_panel/LED_Paterns.vhd \
     ${autogen_path}/SM_INFO/SM_INFO_map.vhd \
     ${autogen_path}/SM_INFO/SM_INFO_PKG.vhd \
     src/SM_info/SM_info.vhd \
     ${autogen_path}/PLXVC/PLXVC_map.vhd \
     ${autogen_path}/PLXVC/PLXVC_PKG.vhd \
     src/plXVC/plXVC_intf.vhd \
     src/plXVC/virtualJTAG.vhd \
     configs/rev2a_xczu7ev/src/iBert/example_ibert_ultrascale_gth_0.v \
     "

set xdc_files "\
     configs/rev2a_xczu7ev/src/top.xdc \
     configs/rev2a_xczu7ev/src/top_clocks.xdc \
     configs/rev2a_xczu7ev/src/top_MGMT.xdc \
     configs/rev2a_xczu7ev/src/iBert/example_ibert_ultrascale_gth_0.xdc \
     configs/rev2a_xczu7ev/src/iBert/ibert_ultrascale_gth_ip_example.xdc \
     "

set xci_files "\
              src/TCDS/tclink/firmware/source/transceiver/ip_mgt_timing/gthe4_slave_timing_10g.xcix \
              configs/rev2a_xczu7ev/cores/iBert.tcl \
              "
