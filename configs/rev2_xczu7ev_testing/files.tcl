set bd_path proj/

array set bd_files [list {zynq_bd} {src/ZynqPS/build_Zynq_rev2_xczu7ev_testing.tcl} \
		       ]

set vhdl_files "\
     configs/rev2_xczu7ev_testing//top.vhd \
     src/misc/types.vhd \
     regmap_helper/axiReg/axiRegWidthPkg_40.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
     regmap_helper/axiReg/axiReg.vhd \
     src/SM_info/SM_INFO_map.vhd \
     src/SM_info/SM_INFO_PKG.vhd \
     src/SM_info/SM_info.vhd \
     "

set xdc_files "\
              configs/rev2_xczu7ev_testing/top.xdc \
              "

set xci_files "\
    	      cores/onboard_CLK_USP/onboard_CLK.xci \
              "

