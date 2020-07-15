set bd_path proj/

set bd_name zynq_bd

set bd_files "\
    src/ZynqPS/create.tcl \
    "

set vhdl_files "\
     src/top.vhd \
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
     src/SGMII/SGMII.vhd \
     src/SGMII/SGMII_INTF_clocking.vhd \
     src/SGMII/SGMII_INTF_resets.vhd \
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
     src/SM_info/FW_INFO_map.vhd \
     src/SM_info/FW_INFO_PKG.vhd \
     src/SM_info/SM_info.vhd \
     src/TCDS/lhc_gt_usrclk_source.vhd \
     src/TCDS/MGBT2_common_reset.vhd \
     src/TCDS/MGBT2_common.vhd \
     src/TCDS/TCDS.vhd \
     src/TCDS/TCDS_Control.vhd \
     src/TCDS/TCDS_Monitor.vhd \
     src/TCDS/TCDS_map.vhd \
     src/TCDS/TCDS_PKG.vhd \
     src/plXVC/plXVC_map.vhd \
     src/plXVC/plXVC_PKG.vhd \
     src/plXVC/plXVC_intf.vhd \
     src/plXVC/virtualJTAG.vhd \
     "

set xdc_files src/top.xdc

set xci_files "\
    	      cores/SGMII_INTF/SGMII_INTF.xci \
    	      cores/onboard_CLK/onboard_CLK.xci \
              cores/LHC/LHC.xci \
              cores/TCDS_DRP_BRIDGE/TCDS_DRP_BRIDGE.xci \
    	      "

#DRP ip
set ip_repo_path ../bd/IP
set_property  ip_repo_paths ${ip_repo_path}  [current_project]
update_ip_catalog
