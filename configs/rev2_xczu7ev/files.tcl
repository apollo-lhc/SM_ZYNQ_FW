set bd_path proj/

array set bd_files [list {zynq_bd} {src/ZynqPS/build_Zynq_rev2_xczu7ev.tcl} \
		       ]

set vhdl_files "\
     configs/rev2_xczu7ev/top.vhd \
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
     src/misc/Xilinx/rams_sp_wf.vhd \
     regmap_helper/axiReg/axiRegWidthPkg_32.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
     regmap_helper/axiReg/axiReg.vhd \
     regmap_helper/axiReg/axiRegMaster.vhd \
     regmap_helper/axiReg/bramPortPkg.vhd \
     regmap_helper/axiReg/axiRegBlocking.vhd \
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
     src/MEM_TEST/Mem_test.vhd \
     src/MEM_TEST/MEM_TEST_map.vhd \
     src/MEM_TEST/MEM_TEST_PKG.vhd \
     "

set xdc_files "\
     configs/rev2_xczu7ev/top.xdc \
     "

set xci_files "\
              configs/rev2_xczu7ev/cores/onboardClk.tcl \
              "

