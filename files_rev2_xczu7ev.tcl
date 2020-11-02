set bd_path proj/

set bd_name zynq_bd

set bd_files "\
    src/ZynqPS/build_Zynq_rev2_xczu7ev.tcl \
    "

set vhdl_files "\
     src/top_rev2_xczu7ev.vhd \
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
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/axiReg/axiRegMaster.vhd \
     src/services/services.vhd \
     src/services/SGMII_MON_pkg.vhd \
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
     "

set xdc_files src/top_rev2_xczu7ev.xdc

set xci_files "\
    	      cores/onboard_CLK_USP/onboard_CLK.xci \
              "
