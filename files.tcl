set bd_path bd/

set bd_name zynq_bd

set vhdl_files "\
     src/top.vhd \
     src/misc/types.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/SGMII/SGMII_INTF_resets.vhd \
     src/SGMII/SGMII_INTF_clocking.vhd \
     src/TCDS/lhc_clock_module.vhd \
     src/TCDS/lhc_gt_usrclk_source.vhd \
     src/TCDS/lhc_support.vhd \
     src/TCDS/TCDS.vhd \
     src/TCDS/MGBT2_common_reset.vhd \
     src/TCDS/MGBT2_common.vhd \
     "

set xdc_files src/top.xdc

set xci_files "\
    	      cores/SGMII_INTF/SGMII_INTF.xci
	      cores/LHC/LHC.xci
	      cores/aurora_64b66b_0/aurora_64b66b_0.xci
    	      "
    
    
