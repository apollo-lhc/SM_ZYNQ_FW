# -------------------------------------------------------------------------------------------------
# bank 33 & 34
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AH6  IOSTANDARD LVDS}                   [get_ports {ONBOARD_CLK_P}]
set_property -dict {PACKAGE_PIN AJ6  IOSTANDARD LVDS}                   [get_ports {ONBOARD_CLK_N}]
create_clock -period 10.000 -name ONBOARD_CLK_P -add [get_ports ONBOARD_CLK_P]

set_property -dict {PACKAGE_PIN AD7  IOSTANDARD LVDS}                   [get_ports {CLK_LHC_P}]
set_property -dict {PACKAGE_PIN AE7  IOSTANDARD LVDS}                   [get_ports {CLK_LHC_N}]

set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVDS}                   [get_ports {CLK_HQ_P}]
set_property -dict {PACKAGE_PIN AB8  IOSTANDARD LVDS}                   [get_ports {CLK_HQ_N}]

set_property -dict {PACKAGE_PIN AC8  IOSTANDARD LVDS}                   [get_ports {CLK_TTC_P}]
set_property -dict {PACKAGE_PIN AC7  IOSTANDARD LVDS}                   [get_ports {CLK_TTC_N}]

set_clock_groups -asynchronous												                                    \
		 -group [get_clocks clk_pl_0      -include_generated_clocks]						                                    \
		 -group [get_clocks clk_pl_1      -include_generated_clocks]						                                    \
		 		    		    													    \
	         -group [get_clocks onboard_CLK_P   -include_generated_clocks] 										    \
		 		    												 			    \
                 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/XVC_LOCAL/U0/bs_switch/inst/BSCAN_SWITCH.N_EXT_BSCAN.bscan_inst/SERIES7_BSCAN.bscan_inst/INTERNAL_TCK -include_generated_clocks] \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C2_PHY/inst/zynq_bd_C2C2_PHY_0_wrapper_i/zynq_bd_C2C2_PHY_0_multi_gt_i/zynq_bd_C2C2_PHY_0_gt_i/inst/gen_gtwizard_gthe4_top.zynq_bd_C2C2_PHY_0_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_cpll_cal_gthe4.gen_cpll_cal_inst[0].gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_inst/gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O] \
		 -group [get_clocks zynq_bd_wrapper_1/zynq_bd_i/C2C1_PHY/inst/zynq_bd_C2C1_PHY_0_core_i/zynq_bd_C2C1_PHY_0_wrapper_i/zynq_bd_C2C1_PHY_0_multi_gt_i/zynq_bd_C2C1_PHY_0_gt_i/inst/gen_gtwizard_gthe4_top.zynq_bd_C2C1_PHY_0_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_cpll_cal_gthe4.gen_cpll_cal_inst[0].gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_inst/gtwizard_ultrascale_v1_7_4_gthe4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O]
