set bd_path proj/

set bd_name zynq_bd

set bd_files "\
    src/ZynqPS/create.tcl \
    "

set vhdl_files "\
     src/top.vhd \
     src/misc/types.vhd \
     src/misc/counter.vhd \
     src/misc/asym_dualport_ram.vhd \
     src/misc/uart_rx6.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/axiReg/axiRegMaster.vhd \
     src/SGMII/SGMII.vhd \
     src/SGMII/SGMII_INTF_clocking.vhd \
     src/SGMII/SGMII_INTF_resets.vhd \
     src/services/services.vhd \
     src/services/SGMII_MON_pkg.vhd \
     src/IPMC_i2c_slave/i2c_slave.vhd \
     src/IPMC_i2c_slave/IPMC_i2c_slave.vhd \
     src/CM_interface/CM_interface.vhd \
     src/CM_interface/CM_Monitoring.vhd \
     src/CM_interface/CM_pwr.vhd \
     src/CM_interface/CM_package.vhd \
     src/front_panel/Button_Debouncer.vhd \
     src/front_panel/Button_Decoder.vhd \
     src/front_panel/FrontPanel_UI.vhd \
     src/front_panel/LED_Encoder.vhd \
     src/front_panel/SR_Out.vhd \
     src/front_panel/LED_Paterns.vhd \
     src/SM_info/SM_info.vhd \
     src/misc/pass_time_domain.vhd \
     src/TCDS/lhc_gt_usrclk_source.vhd \
     src/TCDS/MGBT2_common_reset.vhd \
     src/TCDS/MGBT2_common.vhd \
     src/TCDS/TCDS.vhd \
     src/TCDS/TCDS_Control.vhd \
     src/TCDS/TCDS_map.vhd \
     src/TCDS/TCDS_PKG.vhd \
     "

set xdc_files src/top.xdc

set xci_files "\
    	      cores/SGMII_INTF/SGMII_INTF.xci \
    	      cores/onboard_CLK/onboard_CLK.xci \
              cores/LHC/LHC.xci \
              cores/TCDS_DRP_BRIDGE/TCDS_DRP_BRIDGE.xci \
    	      "
#	      cores/ila_i2c_debug/ila_i2c_debug.xci \
#	      cores/c2c_ibert/c2c_ibert.xci \
