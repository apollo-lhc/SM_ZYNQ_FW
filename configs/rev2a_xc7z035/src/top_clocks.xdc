# -------------------------------------------------------------------------------------------------
# bank 33 & 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN L4   IOSTANDARD LVDS}                   [get_ports {ONBOARD_CLK_N}];  #XXXX  XU8:  AH6, ZX1:  L4
set_property -dict {PACKAGE_PIN L5   IOSTANDARD LVDS}                   [get_ports {ONBOARD_CLK_P}];  #XXXX  XU8:  AJ6, ZX1:  L5
create_clock -period 5.000 -name ONBOARD_CLK_P -add [get_ports ONBOARD_CLK_P]

set_property -dict {PACKAGE_PIN J4   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_P}];      #B.151 XU8:  AD7, ZX1:   J4
set_property -dict {PACKAGE_PIN J3   IOSTANDARD LVDS}                   [get_ports {CLK_LHC_N}];      #B.153 XU8:  AE7, ZX1:   J3
create_clock -period 24.95 -name CLK_LHC_P -add [get_ports CLK_LHC_P]

set_property -dict {PACKAGE_PIN C8   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_P}];       #B.154 XU8:  AA8, ZX1:   C8
set_property -dict {PACKAGE_PIN C7   IOSTANDARD LVDS}                   [get_ports {CLK_HQ_N}];       #B.156 XU8:  AB8, ZX1:   C7
create_clock -period 3.12 -name CLK_HQ_P -add [get_ports CLK_HQ_P]

set_property -dict {PACKAGE_PIN G7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_P}];      #B.78  XU8:  AC8, ZX1:   G7
set_property -dict {PACKAGE_PIN F7   IOSTANDARD LVDS}                   [get_ports {CLK_TTC_N}];      #B.80  XU8:  AC7, ZX1:   F7
create_clock -period 6.24 -name CLK_TTC_P -add [get_ports CLK_TTC_P]

set_property -dict {PACKAGE_PIN F3   IOSTANDARD LVDS}                   [get_ports {CLK_REC_OUT_P}];  #B.133 XU8: AD11, ZX1:   F3
set_property -dict {PACKAGE_PIN E3   IOSTANDARD LVDS}                   [get_ports {CLK_REC_OUT_N}];  #B.135 XU8: AD10, ZX1:   E3

####set_clock_groups -asynchronous												                                    \
####		 -group [get_clocks clk_pl_0      -include_generated_clocks]						                                    \
####		 -group [get_clocks clk_pl_1      -include_generated_clocks]						                                    \
####		 		    		    													    \
####	         -group [get_clocks onboard_CLK_P   -include_generated_clocks] 										    \
####		 		    												 			    \
####                 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/XVC_LOCAL/U0/bs_switch/inst/BSCAN_SWITCH.N_EXT_BSCAN.bscan_inst/SERIES7_BSCAN.bscan_inst/INTERNAL_TCK -include_generated_clocks] \
####		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gt_i/inst/gen_gtwizard_gthe4_top.zynq_bd_C2C2_PHY_0_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_cpll_cal_gthe4.gen_cpll_cal_inst[0].gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_inst/gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O] \
####		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gt_i/inst/gen_gtwizard_gthe4_top.zynq_bd_C2C1_PHY_0_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_cpll_cal_gthe4.gen_cpll_cal_inst[0].gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_inst/gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O]


set_clock_groups -asynchronous \
	-group [get_clocks CLK_HQ_P      -include_generated_clocks] \
	-group [get_clocks CLK_LHC_P      -include_generated_clocks] \
	-group [get_clocks CLK_TTC_P      -include_generated_clocks] \
	-group [get_clocks ONBOARD_CLK_P      -include_generated_clocks] \
	-group [get_clocks clk_50MHz_onboardclk      -include_generated_clocks] \
	-group [get_clocks clkfbout_onboardclk      -include_generated_clocks] \
	-group [get_clocks clk_fpga_0      -include_generated_clocks] \
	-group [get_clocks clk_fpga_1      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1B_PHY/inst/zynq_bd_C2C1B_PHY_0_wrapper_i/zynq_bd_C2C1B_PHY_0_multi_gt_i/zynq_bd_C2C1B_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1B_PHY/inst/zynq_bd_C2C1B_PHY_0_wrapper_i/zynq_bd_C2C1B_PHY_0_multi_gt_i/zynq_bd_C2C1B_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK      -include_generated_clocks] \
	-group [get_clocks clkfbout      -include_generated_clocks] \
	-group [get_clocks sync_clk_i      -include_generated_clocks] \
	-group [get_clocks user_clk_i      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2B_PHY/inst/zynq_bd_C2C2B_PHY_0_core_i/zynq_bd_C2C2B_PHY_0_wrapper_i/zynq_bd_C2C2B_PHY_0_multi_gt_i/zynq_bd_C2C2B_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2B_PHY/inst/zynq_bd_C2C2B_PHY_0_core_i/zynq_bd_C2C2B_PHY_0_wrapper_i/zynq_bd_C2C2B_PHY_0_multi_gt_i/zynq_bd_C2C2B_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK      -include_generated_clocks] \
	-group [get_clocks clkfbout_1      -include_generated_clocks] \
	-group [get_clocks sync_clk_i_1      -include_generated_clocks] \
	-group [get_clocks user_clk_i_1      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/RXOUTCLK      -include_generated_clocks] \
	-group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gtx_inst/gtxe2_i/TXOUTCLK      -include_generated_clocks] 
