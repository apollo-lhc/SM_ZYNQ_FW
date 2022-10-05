--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Mon Oct  3 15:34:00 2022
--Host        : pgkounto-Latitude-5591 running 64-bit Ubuntu 22.04.1 LTS
--Command     : generate_target zynq_bd_wrapper.bd
--Design      : zynq_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity zynq_bd_wrapper is
  port (
    AXIM_PL_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIM_PL_arready : out STD_LOGIC;
    AXIM_PL_arvalid : in STD_LOGIC;
    AXIM_PL_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIM_PL_awready : out STD_LOGIC;
    AXIM_PL_awvalid : in STD_LOGIC;
    AXIM_PL_bready : in STD_LOGIC;
    AXIM_PL_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIM_PL_bvalid : out STD_LOGIC;
    AXIM_PL_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_rready : in STD_LOGIC;
    AXIM_PL_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIM_PL_rvalid : out STD_LOGIC;
    AXIM_PL_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_wready : out STD_LOGIC;
    AXIM_PL_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    AXIM_PL_wvalid : in STD_LOGIC;
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_rst : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1B_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1B_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1B_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1B_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C1B_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1B_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C1B_PHY_DRP_den : in STD_LOGIC;
    C2C1B_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DRP_drdy : out STD_LOGIC;
    C2C1B_PHY_DRP_dwe : in STD_LOGIC;
    C2C1B_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_channel_up : out STD_LOGIC;
    C2C1B_PHY_gt_pll_lock : out STD_LOGIC;
    C2C1B_PHY_hard_err : out STD_LOGIC;
    C2C1B_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_link_reset_out : out STD_LOGIC;
    C2C1B_PHY_power_down : in STD_LOGIC;
    C2C1B_PHY_soft_err : out STD_LOGIC;
    C2C1B_aurora_do_cc : out STD_LOGIC;
    C2C1B_aurora_pma_init_in : in STD_LOGIC;
    C2C1B_axi_c2c_config_error_out : out STD_LOGIC;
    C2C1B_axi_c2c_link_error_out : out STD_LOGIC;
    C2C1B_axi_c2c_link_status_out : out STD_LOGIC;
    C2C1B_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C1_PHY_CLK : out STD_LOGIC;
    C2C1_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C1_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C1_PHY_DRP_den : in STD_LOGIC;
    C2C1_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DRP_drdy : out STD_LOGIC;
    C2C1_PHY_DRP_dwe : in STD_LOGIC;
    C2C1_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_channel_up : out STD_LOGIC;
    C2C1_PHY_gt_pll_lock : out STD_LOGIC;
    C2C1_PHY_gt_refclk1_out : out STD_LOGIC;
    C2C1_PHY_hard_err : out STD_LOGIC;
    C2C1_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_link_reset_out : out STD_LOGIC;
    C2C1_PHY_mmcm_not_locked_out : out STD_LOGIC;
    C2C1_PHY_power_down : in STD_LOGIC;
    C2C1_PHY_refclk_clk_n : in STD_LOGIC;
    C2C1_PHY_refclk_clk_p : in STD_LOGIC;
    C2C1_PHY_soft_err : out STD_LOGIC;
    C2C1_aurora_do_cc : out STD_LOGIC;
    C2C1_aurora_pma_init_in : in STD_LOGIC;
    C2C1_axi_c2c_config_error_out : out STD_LOGIC;
    C2C1_axi_c2c_link_error_out : out STD_LOGIC;
    C2C1_axi_c2c_link_status_out : out STD_LOGIC;
    C2C1_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C2B_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2B_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2B_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2B_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C2B_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2B_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C2B_PHY_DRP_den : in STD_LOGIC;
    C2C2B_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DRP_drdy : out STD_LOGIC;
    C2C2B_PHY_DRP_dwe : in STD_LOGIC;
    C2C2B_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_channel_up : out STD_LOGIC;
    C2C2B_PHY_gt_pll_lock : out STD_LOGIC;
    C2C2B_PHY_hard_err : out STD_LOGIC;
    C2C2B_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_link_reset_out : out STD_LOGIC;
    C2C2B_PHY_power_down : in STD_LOGIC;
    C2C2B_PHY_soft_err : out STD_LOGIC;
    C2C2B_aurora_do_cc : out STD_LOGIC;
    C2C2B_aurora_pma_init_in : in STD_LOGIC;
    C2C2B_axi_c2c_config_error_out : out STD_LOGIC;
    C2C2B_axi_c2c_link_error_out : out STD_LOGIC;
    C2C2B_axi_c2c_link_status_out : out STD_LOGIC;
    C2C2B_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C2_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C2_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C2_PHY_DRP_den : in STD_LOGIC;
    C2C2_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DRP_drdy : out STD_LOGIC;
    C2C2_PHY_DRP_dwe : in STD_LOGIC;
    C2C2_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_channel_up : out STD_LOGIC;
    C2C2_PHY_gt_pll_lock : out STD_LOGIC;
    C2C2_PHY_hard_err : out STD_LOGIC;
    C2C2_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_link_reset_out : out STD_LOGIC;
    C2C2_PHY_power_down : in STD_LOGIC;
    C2C2_PHY_soft_err : out STD_LOGIC;
    C2C2_aurora_do_cc : out STD_LOGIC;
    C2C2_aurora_pma_init_in : in STD_LOGIC;
    C2C2_axi_c2c_config_error_out : out STD_LOGIC;
    C2C2_axi_c2c_link_error_out : out STD_LOGIC;
    C2C2_axi_c2c_link_status_out : out STD_LOGIC;
    C2C2_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    CM1_UART_rxd : in STD_LOGIC;
    CM1_UART_txd : out STD_LOGIC;
    CM2_UART_rxd : in STD_LOGIC;
    CM2_UART_txd : out STD_LOGIC;
    CM_PB_UART_rxd : in STD_LOGIC;
    CM_PB_UART_txd : out STD_LOGIC;
    CM_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    CM_arready : in STD_LOGIC;
    CM_arvalid : out STD_LOGIC;
    CM_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    CM_awready : in STD_LOGIC;
    CM_awvalid : out STD_LOGIC;
    CM_bready : out STD_LOGIC;
    CM_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    CM_bvalid : in STD_LOGIC;
    CM_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_rready : out STD_LOGIC;
    CM_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    CM_rvalid : in STD_LOGIC;
    CM_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_wready : in STD_LOGIC;
    CM_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    CM_wvalid : out STD_LOGIC;
    ESM_UART_rxd : in STD_LOGIC;
    ESM_UART_txd : out STD_LOGIC;
    MONITOR_alarm : out STD_LOGIC;
    MONITOR_overtemp_alarm : out STD_LOGIC;
    MONITOR_vccaux_alarm : out STD_LOGIC;
    MONITOR_vccint_alarm : out STD_LOGIC;
    PLXVC_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    PLXVC_arready : in STD_LOGIC;
    PLXVC_arvalid : out STD_LOGIC;
    PLXVC_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    PLXVC_awready : in STD_LOGIC;
    PLXVC_awvalid : out STD_LOGIC;
    PLXVC_bready : out STD_LOGIC;
    PLXVC_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    PLXVC_bvalid : in STD_LOGIC;
    PLXVC_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_rready : out STD_LOGIC;
    PLXVC_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    PLXVC_rvalid : in STD_LOGIC;
    PLXVC_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_wready : in STD_LOGIC;
    PLXVC_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    PLXVC_wvalid : out STD_LOGIC;
    SERV_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SERV_arready : in STD_LOGIC;
    SERV_arvalid : out STD_LOGIC;
    SERV_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SERV_awready : in STD_LOGIC;
    SERV_awvalid : out STD_LOGIC;
    SERV_bready : out STD_LOGIC;
    SERV_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SERV_bvalid : in STD_LOGIC;
    SERV_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_rready : out STD_LOGIC;
    SERV_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SERV_rvalid : in STD_LOGIC;
    SERV_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_wready : in STD_LOGIC;
    SERV_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SERV_wvalid : out STD_LOGIC;
    SI_scl_i : in STD_LOGIC;
    SI_scl_o : out STD_LOGIC;
    SI_scl_t : out STD_LOGIC;
    SI_sda_i : in STD_LOGIC;
    SI_sda_o : out STD_LOGIC;
    SI_sda_t : out STD_LOGIC;
    SLAVE_I2C_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SLAVE_I2C_arready : in STD_LOGIC;
    SLAVE_I2C_arvalid : out STD_LOGIC;
    SLAVE_I2C_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SLAVE_I2C_awready : in STD_LOGIC;
    SLAVE_I2C_awvalid : out STD_LOGIC;
    SLAVE_I2C_bready : out STD_LOGIC;
    SLAVE_I2C_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SLAVE_I2C_bvalid : in STD_LOGIC;
    SLAVE_I2C_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_rready : out STD_LOGIC;
    SLAVE_I2C_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SLAVE_I2C_rvalid : in STD_LOGIC;
    SLAVE_I2C_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_wready : in STD_LOGIC;
    SLAVE_I2C_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SLAVE_I2C_wvalid : out STD_LOGIC;
    SM_INFO_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SM_INFO_arready : in STD_LOGIC;
    SM_INFO_arvalid : out STD_LOGIC;
    SM_INFO_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SM_INFO_awready : in STD_LOGIC;
    SM_INFO_awvalid : out STD_LOGIC;
    SM_INFO_bready : out STD_LOGIC;
    SM_INFO_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SM_INFO_bvalid : in STD_LOGIC;
    SM_INFO_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_rready : out STD_LOGIC;
    SM_INFO_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SM_INFO_rvalid : in STD_LOGIC;
    SM_INFO_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_wready : in STD_LOGIC;
    SM_INFO_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SM_INFO_wvalid : out STD_LOGIC;
    axi_c2c_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    axi_clk : out STD_LOGIC;
    axi_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c2c_interconnect_reset : in STD_LOGIC;
    init_clk : in STD_LOGIC
  );
end zynq_bd_wrapper;

architecture STRUCTURE of zynq_bd_wrapper is
  component zynq_bd is
  port (
    axi_clk : out STD_LOGIC;
    axi_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c2c_interconnect_reset : in STD_LOGIC;
    axi_c2c_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    init_clk : in STD_LOGIC;
    C2C1_aurora_pma_init_in : in STD_LOGIC;
    C2C1_aurora_do_cc : out STD_LOGIC;
    C2C1_axi_c2c_config_error_out : out STD_LOGIC;
    C2C1_axi_c2c_link_status_out : out STD_LOGIC;
    C2C1_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C1_axi_c2c_link_error_out : out STD_LOGIC;
    C2C1_PHY_gt_refclk1_out : out STD_LOGIC;
    C2C1_PHY_power_down : in STD_LOGIC;
    C2C1_PHY_gt_pll_lock : out STD_LOGIC;
    C2C1_PHY_hard_err : out STD_LOGIC;
    C2C1_PHY_soft_err : out STD_LOGIC;
    C2C1_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_mmcm_not_locked_out : out STD_LOGIC;
    C2C1_PHY_link_reset_out : out STD_LOGIC;
    C2C1_PHY_channel_up : out STD_LOGIC;
    C2C1_PHY_CLK : out STD_LOGIC;
    C2C1B_aurora_pma_init_in : in STD_LOGIC;
    C2C1B_aurora_do_cc : out STD_LOGIC;
    C2C1B_axi_c2c_config_error_out : out STD_LOGIC;
    C2C1B_axi_c2c_link_status_out : out STD_LOGIC;
    C2C1B_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C1B_axi_c2c_link_error_out : out STD_LOGIC;
    C2C1B_PHY_power_down : in STD_LOGIC;
    C2C1B_PHY_gt_pll_lock : out STD_LOGIC;
    C2C1B_PHY_hard_err : out STD_LOGIC;
    C2C1B_PHY_soft_err : out STD_LOGIC;
    C2C1B_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_link_reset_out : out STD_LOGIC;
    C2C1B_PHY_channel_up : out STD_LOGIC;
    C2C2_aurora_pma_init_in : in STD_LOGIC;
    C2C2_aurora_do_cc : out STD_LOGIC;
    C2C2_axi_c2c_config_error_out : out STD_LOGIC;
    C2C2_axi_c2c_link_status_out : out STD_LOGIC;
    C2C2_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C2_axi_c2c_link_error_out : out STD_LOGIC;
    C2C2_PHY_power_down : in STD_LOGIC;
    C2C2_PHY_gt_pll_lock : out STD_LOGIC;
    C2C2_PHY_hard_err : out STD_LOGIC;
    C2C2_PHY_soft_err : out STD_LOGIC;
    C2C2_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_link_reset_out : out STD_LOGIC;
    C2C2_PHY_channel_up : out STD_LOGIC;
    C2C2B_aurora_pma_init_in : in STD_LOGIC;
    C2C2B_aurora_do_cc : out STD_LOGIC;
    C2C2B_axi_c2c_config_error_out : out STD_LOGIC;
    C2C2B_axi_c2c_link_status_out : out STD_LOGIC;
    C2C2B_axi_c2c_multi_bit_error_out : out STD_LOGIC;
    C2C2B_axi_c2c_link_error_out : out STD_LOGIC;
    C2C2B_PHY_power_down : in STD_LOGIC;
    C2C2B_PHY_gt_pll_lock : out STD_LOGIC;
    C2C2B_PHY_hard_err : out STD_LOGIC;
    C2C2B_PHY_soft_err : out STD_LOGIC;
    C2C2B_PHY_lane_up : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_link_reset_out : out STD_LOGIC;
    C2C2B_PHY_channel_up : out STD_LOGIC;
    SI_scl_i : in STD_LOGIC;
    SI_sda_i : in STD_LOGIC;
    SI_sda_o : out STD_LOGIC;
    SI_scl_o : out STD_LOGIC;
    SI_scl_t : out STD_LOGIC;
    SI_sda_t : out STD_LOGIC;
    MONITOR_alarm : out STD_LOGIC;
    MONITOR_vccint_alarm : out STD_LOGIC;
    MONITOR_vccaux_alarm : out STD_LOGIC;
    MONITOR_overtemp_alarm : out STD_LOGIC;
    CM1_UART_rxd : in STD_LOGIC;
    CM1_UART_txd : out STD_LOGIC;
    CM_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    CM_awvalid : out STD_LOGIC;
    CM_awready : in STD_LOGIC;
    CM_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    CM_wvalid : out STD_LOGIC;
    CM_wready : in STD_LOGIC;
    CM_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    CM_bvalid : in STD_LOGIC;
    CM_bready : out STD_LOGIC;
    CM_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    CM_arvalid : out STD_LOGIC;
    CM_arready : in STD_LOGIC;
    CM_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    CM_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    CM_rvalid : in STD_LOGIC;
    CM_rready : out STD_LOGIC;
    C2C1_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C1_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    AXIM_PL_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIM_PL_arready : out STD_LOGIC;
    AXIM_PL_arvalid : in STD_LOGIC;
    AXIM_PL_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    AXIM_PL_awready : out STD_LOGIC;
    AXIM_PL_awvalid : in STD_LOGIC;
    AXIM_PL_bready : in STD_LOGIC;
    AXIM_PL_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIM_PL_bvalid : out STD_LOGIC;
    AXIM_PL_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_rready : in STD_LOGIC;
    AXIM_PL_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    AXIM_PL_rvalid : out STD_LOGIC;
    AXIM_PL_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    AXIM_PL_wready : out STD_LOGIC;
    AXIM_PL_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    AXIM_PL_wvalid : in STD_LOGIC;
    C2C1_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1_PHY_refclk_clk_n : in STD_LOGIC;
    C2C1_PHY_refclk_clk_p : in STD_LOGIC;
    C2C1_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C1_PHY_DRP_den : in STD_LOGIC;
    C2C1_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1_PHY_DRP_drdy : out STD_LOGIC;
    C2C1_PHY_DRP_dwe : in STD_LOGIC;
    PLXVC_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    PLXVC_awvalid : out STD_LOGIC;
    PLXVC_awready : in STD_LOGIC;
    PLXVC_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    PLXVC_wvalid : out STD_LOGIC;
    PLXVC_wready : in STD_LOGIC;
    PLXVC_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    PLXVC_bvalid : in STD_LOGIC;
    PLXVC_bready : out STD_LOGIC;
    PLXVC_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    PLXVC_arvalid : out STD_LOGIC;
    PLXVC_arready : in STD_LOGIC;
    PLXVC_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    PLXVC_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    PLXVC_rvalid : in STD_LOGIC;
    PLXVC_rready : out STD_LOGIC;
    C2C1B_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C1B_PHY_DRP_den : in STD_LOGIC;
    C2C1B_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DRP_drdy : out STD_LOGIC;
    C2C1B_PHY_DRP_dwe : in STD_LOGIC;
    ESM_UART_rxd : in STD_LOGIC;
    ESM_UART_txd : out STD_LOGIC;
    C2C2_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C2_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    CM2_UART_rxd : in STD_LOGIC;
    CM2_UART_txd : out STD_LOGIC;
    CM_PB_UART_rxd : in STD_LOGIC;
    CM_PB_UART_txd : out STD_LOGIC;
    SM_INFO_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SM_INFO_awvalid : out STD_LOGIC;
    SM_INFO_awready : in STD_LOGIC;
    SM_INFO_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SM_INFO_wvalid : out STD_LOGIC;
    SM_INFO_wready : in STD_LOGIC;
    SM_INFO_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SM_INFO_bvalid : in STD_LOGIC;
    SM_INFO_bready : out STD_LOGIC;
    SM_INFO_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SM_INFO_arvalid : out STD_LOGIC;
    SM_INFO_arready : in STD_LOGIC;
    SM_INFO_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SM_INFO_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SM_INFO_rvalid : in STD_LOGIC;
    SM_INFO_rready : out STD_LOGIC;
    C2C1B_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    SERV_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SERV_awvalid : out STD_LOGIC;
    SERV_awready : in STD_LOGIC;
    SERV_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SERV_wvalid : out STD_LOGIC;
    SERV_wready : in STD_LOGIC;
    SERV_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SERV_bvalid : in STD_LOGIC;
    SERV_bready : out STD_LOGIC;
    SERV_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SERV_arvalid : out STD_LOGIC;
    SERV_arready : in STD_LOGIC;
    SERV_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SERV_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SERV_rvalid : in STD_LOGIC;
    SERV_rready : out STD_LOGIC;
    C2C2B_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C2B_PHY_DRP_den : in STD_LOGIC;
    C2C2B_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DRP_drdy : out STD_LOGIC;
    C2C2B_PHY_DRP_dwe : in STD_LOGIC;
    C2C2B_PHY_Rx_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Rx_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2B_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2B_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2B_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C2B_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C2B_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2B_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C2B_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C2B_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Tx_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_Tx_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_cplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_dmonitorout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DEBUG_eyescandataerror : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_eyescanreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_eyescantrigger : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_pcsrsvdin : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C1B_PHY_DEBUG_qplllock : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxbufreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxbufstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1B_PHY_DEBUG_rxcdrhold : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxdfelpmreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxlpmen : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxpmaresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbscntreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbserr : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_rxprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1B_PHY_DEBUG_rxrate : in STD_LOGIC_VECTOR ( 2 downto 0 );
    C2C1B_PHY_DEBUG_rxresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txbufstatus : out STD_LOGIC_VECTOR ( 1 downto 0 );
    C2C1B_PHY_DEBUG_txdiffctrl : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txinhibit : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpcsreset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpmareset : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txpostcursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txprbsforceerr : in STD_LOGIC_VECTOR ( 0 to 0 );
    C2C1B_PHY_DEBUG_txprbssel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    C2C1B_PHY_DEBUG_txprecursor : in STD_LOGIC_VECTOR ( 4 downto 0 );
    C2C1B_PHY_DEBUG_txresetdone : out STD_LOGIC_VECTOR ( 0 to 0 );
    C2C2_PHY_DRP_daddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    C2C2_PHY_DRP_den : in STD_LOGIC;
    C2C2_PHY_DRP_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DRP_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    C2C2_PHY_DRP_drdy : out STD_LOGIC;
    C2C2_PHY_DRP_dwe : in STD_LOGIC;
    SLAVE_I2C_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SLAVE_I2C_awvalid : out STD_LOGIC;
    SLAVE_I2C_awready : in STD_LOGIC;
    SLAVE_I2C_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SLAVE_I2C_wvalid : out STD_LOGIC;
    SLAVE_I2C_wready : in STD_LOGIC;
    SLAVE_I2C_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SLAVE_I2C_bvalid : in STD_LOGIC;
    SLAVE_I2C_bready : out STD_LOGIC;
    SLAVE_I2C_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SLAVE_I2C_arvalid : out STD_LOGIC;
    SLAVE_I2C_arready : in STD_LOGIC;
    SLAVE_I2C_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLAVE_I2C_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SLAVE_I2C_rvalid : in STD_LOGIC;
    SLAVE_I2C_rready : out STD_LOGIC;
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_rst : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  end component zynq_bd;
begin
zynq_bd_i: component zynq_bd
     port map (
      AXIM_PL_araddr(31 downto 0) => AXIM_PL_araddr(31 downto 0),
      AXIM_PL_arprot(2 downto 0) => AXIM_PL_arprot(2 downto 0),
      AXIM_PL_arready => AXIM_PL_arready,
      AXIM_PL_arvalid => AXIM_PL_arvalid,
      AXIM_PL_awaddr(31 downto 0) => AXIM_PL_awaddr(31 downto 0),
      AXIM_PL_awprot(2 downto 0) => AXIM_PL_awprot(2 downto 0),
      AXIM_PL_awready => AXIM_PL_awready,
      AXIM_PL_awvalid => AXIM_PL_awvalid,
      AXIM_PL_bready => AXIM_PL_bready,
      AXIM_PL_bresp(1 downto 0) => AXIM_PL_bresp(1 downto 0),
      AXIM_PL_bvalid => AXIM_PL_bvalid,
      AXIM_PL_rdata(31 downto 0) => AXIM_PL_rdata(31 downto 0),
      AXIM_PL_rready => AXIM_PL_rready,
      AXIM_PL_rresp(1 downto 0) => AXIM_PL_rresp(1 downto 0),
      AXIM_PL_rvalid => AXIM_PL_rvalid,
      AXIM_PL_wdata(31 downto 0) => AXIM_PL_wdata(31 downto 0),
      AXIM_PL_wready => AXIM_PL_wready,
      AXIM_PL_wstrb(3 downto 0) => AXIM_PL_wstrb(3 downto 0),
      AXIM_PL_wvalid => AXIM_PL_wvalid,
      BRAM_PORTB_0_addr(31 downto 0) => BRAM_PORTB_0_addr(31 downto 0),
      BRAM_PORTB_0_clk => BRAM_PORTB_0_clk,
      BRAM_PORTB_0_din(31 downto 0) => BRAM_PORTB_0_din(31 downto 0),
      BRAM_PORTB_0_dout(31 downto 0) => BRAM_PORTB_0_dout(31 downto 0),
      BRAM_PORTB_0_en => BRAM_PORTB_0_en,
      BRAM_PORTB_0_rst => BRAM_PORTB_0_rst,
      BRAM_PORTB_0_we(3 downto 0) => BRAM_PORTB_0_we(3 downto 0),
      C2C1B_PHY_DEBUG_cplllock(0) => C2C1B_PHY_DEBUG_cplllock(0),
      C2C1B_PHY_DEBUG_dmonitorout(15 downto 0) => C2C1B_PHY_DEBUG_dmonitorout(15 downto 0),
      C2C1B_PHY_DEBUG_eyescandataerror(0) => C2C1B_PHY_DEBUG_eyescandataerror(0),
      C2C1B_PHY_DEBUG_eyescanreset(0) => C2C1B_PHY_DEBUG_eyescanreset(0),
      C2C1B_PHY_DEBUG_eyescantrigger(0) => C2C1B_PHY_DEBUG_eyescantrigger(0),
      C2C1B_PHY_DEBUG_pcsrsvdin(15 downto 0) => C2C1B_PHY_DEBUG_pcsrsvdin(15 downto 0),
      C2C1B_PHY_DEBUG_qplllock(0) => C2C1B_PHY_DEBUG_qplllock(0),
      C2C1B_PHY_DEBUG_rxbufreset(0) => C2C1B_PHY_DEBUG_rxbufreset(0),
      C2C1B_PHY_DEBUG_rxbufstatus(2 downto 0) => C2C1B_PHY_DEBUG_rxbufstatus(2 downto 0),
      C2C1B_PHY_DEBUG_rxcdrhold(0) => C2C1B_PHY_DEBUG_rxcdrhold(0),
      C2C1B_PHY_DEBUG_rxdfelpmreset(0) => C2C1B_PHY_DEBUG_rxdfelpmreset(0),
      C2C1B_PHY_DEBUG_rxlpmen(0) => C2C1B_PHY_DEBUG_rxlpmen(0),
      C2C1B_PHY_DEBUG_rxpcsreset(0) => C2C1B_PHY_DEBUG_rxpcsreset(0),
      C2C1B_PHY_DEBUG_rxpmareset(0) => C2C1B_PHY_DEBUG_rxpmareset(0),
      C2C1B_PHY_DEBUG_rxpmaresetdone(0) => C2C1B_PHY_DEBUG_rxpmaresetdone(0),
      C2C1B_PHY_DEBUG_rxprbscntreset(0) => C2C1B_PHY_DEBUG_rxprbscntreset(0),
      C2C1B_PHY_DEBUG_rxprbserr(0) => C2C1B_PHY_DEBUG_rxprbserr(0),
      C2C1B_PHY_DEBUG_rxprbssel(3 downto 0) => C2C1B_PHY_DEBUG_rxprbssel(3 downto 0),
      C2C1B_PHY_DEBUG_rxrate(2 downto 0) => C2C1B_PHY_DEBUG_rxrate(2 downto 0),
      C2C1B_PHY_DEBUG_rxresetdone(0) => C2C1B_PHY_DEBUG_rxresetdone(0),
      C2C1B_PHY_DEBUG_txbufstatus(1 downto 0) => C2C1B_PHY_DEBUG_txbufstatus(1 downto 0),
      C2C1B_PHY_DEBUG_txdiffctrl(4 downto 0) => C2C1B_PHY_DEBUG_txdiffctrl(4 downto 0),
      C2C1B_PHY_DEBUG_txinhibit(0) => C2C1B_PHY_DEBUG_txinhibit(0),
      C2C1B_PHY_DEBUG_txpcsreset(0) => C2C1B_PHY_DEBUG_txpcsreset(0),
      C2C1B_PHY_DEBUG_txpmareset(0) => C2C1B_PHY_DEBUG_txpmareset(0),
      C2C1B_PHY_DEBUG_txpolarity(0) => C2C1B_PHY_DEBUG_txpolarity(0),
      C2C1B_PHY_DEBUG_txpostcursor(4 downto 0) => C2C1B_PHY_DEBUG_txpostcursor(4 downto 0),
      C2C1B_PHY_DEBUG_txprbsforceerr(0) => C2C1B_PHY_DEBUG_txprbsforceerr(0),
      C2C1B_PHY_DEBUG_txprbssel(3 downto 0) => C2C1B_PHY_DEBUG_txprbssel(3 downto 0),
      C2C1B_PHY_DEBUG_txprecursor(4 downto 0) => C2C1B_PHY_DEBUG_txprecursor(4 downto 0),
      C2C1B_PHY_DEBUG_txresetdone(0) => C2C1B_PHY_DEBUG_txresetdone(0),
      C2C1B_PHY_DRP_daddr(9 downto 0) => C2C1B_PHY_DRP_daddr(9 downto 0),
      C2C1B_PHY_DRP_den => C2C1B_PHY_DRP_den,
      C2C1B_PHY_DRP_di(15 downto 0) => C2C1B_PHY_DRP_di(15 downto 0),
      C2C1B_PHY_DRP_do(15 downto 0) => C2C1B_PHY_DRP_do(15 downto 0),
      C2C1B_PHY_DRP_drdy => C2C1B_PHY_DRP_drdy,
      C2C1B_PHY_DRP_dwe => C2C1B_PHY_DRP_dwe,
      C2C1B_PHY_Rx_rxn(0) => C2C1B_PHY_Rx_rxn(0),
      C2C1B_PHY_Rx_rxp(0) => C2C1B_PHY_Rx_rxp(0),
      C2C1B_PHY_Tx_txn(0) => C2C1B_PHY_Tx_txn(0),
      C2C1B_PHY_Tx_txp(0) => C2C1B_PHY_Tx_txp(0),
      C2C1B_PHY_channel_up => C2C1B_PHY_channel_up,
      C2C1B_PHY_gt_pll_lock => C2C1B_PHY_gt_pll_lock,
      C2C1B_PHY_hard_err => C2C1B_PHY_hard_err,
      C2C1B_PHY_lane_up(0) => C2C1B_PHY_lane_up(0),
      C2C1B_PHY_link_reset_out => C2C1B_PHY_link_reset_out,
      C2C1B_PHY_power_down => C2C1B_PHY_power_down,
      C2C1B_PHY_soft_err => C2C1B_PHY_soft_err,
      C2C1B_aurora_do_cc => C2C1B_aurora_do_cc,
      C2C1B_aurora_pma_init_in => C2C1B_aurora_pma_init_in,
      C2C1B_axi_c2c_config_error_out => C2C1B_axi_c2c_config_error_out,
      C2C1B_axi_c2c_link_error_out => C2C1B_axi_c2c_link_error_out,
      C2C1B_axi_c2c_link_status_out => C2C1B_axi_c2c_link_status_out,
      C2C1B_axi_c2c_multi_bit_error_out => C2C1B_axi_c2c_multi_bit_error_out,
      C2C1_PHY_CLK => C2C1_PHY_CLK,
      C2C1_PHY_DEBUG_cplllock(0) => C2C1_PHY_DEBUG_cplllock(0),
      C2C1_PHY_DEBUG_dmonitorout(15 downto 0) => C2C1_PHY_DEBUG_dmonitorout(15 downto 0),
      C2C1_PHY_DEBUG_eyescandataerror(0) => C2C1_PHY_DEBUG_eyescandataerror(0),
      C2C1_PHY_DEBUG_eyescanreset(0) => C2C1_PHY_DEBUG_eyescanreset(0),
      C2C1_PHY_DEBUG_eyescantrigger(0) => C2C1_PHY_DEBUG_eyescantrigger(0),
      C2C1_PHY_DEBUG_pcsrsvdin(15 downto 0) => C2C1_PHY_DEBUG_pcsrsvdin(15 downto 0),
      C2C1_PHY_DEBUG_qplllock(0) => C2C1_PHY_DEBUG_qplllock(0),
      C2C1_PHY_DEBUG_rxbufreset(0) => C2C1_PHY_DEBUG_rxbufreset(0),
      C2C1_PHY_DEBUG_rxbufstatus(2 downto 0) => C2C1_PHY_DEBUG_rxbufstatus(2 downto 0),
      C2C1_PHY_DEBUG_rxcdrhold(0) => C2C1_PHY_DEBUG_rxcdrhold(0),
      C2C1_PHY_DEBUG_rxdfelpmreset(0) => C2C1_PHY_DEBUG_rxdfelpmreset(0),
      C2C1_PHY_DEBUG_rxlpmen(0) => C2C1_PHY_DEBUG_rxlpmen(0),
      C2C1_PHY_DEBUG_rxpcsreset(0) => C2C1_PHY_DEBUG_rxpcsreset(0),
      C2C1_PHY_DEBUG_rxpmareset(0) => C2C1_PHY_DEBUG_rxpmareset(0),
      C2C1_PHY_DEBUG_rxpmaresetdone(0) => C2C1_PHY_DEBUG_rxpmaresetdone(0),
      C2C1_PHY_DEBUG_rxprbscntreset(0) => C2C1_PHY_DEBUG_rxprbscntreset(0),
      C2C1_PHY_DEBUG_rxprbserr(0) => C2C1_PHY_DEBUG_rxprbserr(0),
      C2C1_PHY_DEBUG_rxprbssel(3 downto 0) => C2C1_PHY_DEBUG_rxprbssel(3 downto 0),
      C2C1_PHY_DEBUG_rxrate(2 downto 0) => C2C1_PHY_DEBUG_rxrate(2 downto 0),
      C2C1_PHY_DEBUG_rxresetdone(0) => C2C1_PHY_DEBUG_rxresetdone(0),
      C2C1_PHY_DEBUG_txbufstatus(1 downto 0) => C2C1_PHY_DEBUG_txbufstatus(1 downto 0),
      C2C1_PHY_DEBUG_txdiffctrl(4 downto 0) => C2C1_PHY_DEBUG_txdiffctrl(4 downto 0),
      C2C1_PHY_DEBUG_txinhibit(0) => C2C1_PHY_DEBUG_txinhibit(0),
      C2C1_PHY_DEBUG_txpcsreset(0) => C2C1_PHY_DEBUG_txpcsreset(0),
      C2C1_PHY_DEBUG_txpmareset(0) => C2C1_PHY_DEBUG_txpmareset(0),
      C2C1_PHY_DEBUG_txpolarity(0) => C2C1_PHY_DEBUG_txpolarity(0),
      C2C1_PHY_DEBUG_txpostcursor(4 downto 0) => C2C1_PHY_DEBUG_txpostcursor(4 downto 0),
      C2C1_PHY_DEBUG_txprbsforceerr(0) => C2C1_PHY_DEBUG_txprbsforceerr(0),
      C2C1_PHY_DEBUG_txprbssel(3 downto 0) => C2C1_PHY_DEBUG_txprbssel(3 downto 0),
      C2C1_PHY_DEBUG_txprecursor(4 downto 0) => C2C1_PHY_DEBUG_txprecursor(4 downto 0),
      C2C1_PHY_DEBUG_txresetdone(0) => C2C1_PHY_DEBUG_txresetdone(0),
      C2C1_PHY_DRP_daddr(9 downto 0) => C2C1_PHY_DRP_daddr(9 downto 0),
      C2C1_PHY_DRP_den => C2C1_PHY_DRP_den,
      C2C1_PHY_DRP_di(15 downto 0) => C2C1_PHY_DRP_di(15 downto 0),
      C2C1_PHY_DRP_do(15 downto 0) => C2C1_PHY_DRP_do(15 downto 0),
      C2C1_PHY_DRP_drdy => C2C1_PHY_DRP_drdy,
      C2C1_PHY_DRP_dwe => C2C1_PHY_DRP_dwe,
      C2C1_PHY_Rx_rxn(0) => C2C1_PHY_Rx_rxn(0),
      C2C1_PHY_Rx_rxp(0) => C2C1_PHY_Rx_rxp(0),
      C2C1_PHY_Tx_txn(0) => C2C1_PHY_Tx_txn(0),
      C2C1_PHY_Tx_txp(0) => C2C1_PHY_Tx_txp(0),
      C2C1_PHY_channel_up => C2C1_PHY_channel_up,
      C2C1_PHY_gt_pll_lock => C2C1_PHY_gt_pll_lock,
      C2C1_PHY_gt_refclk1_out => C2C1_PHY_gt_refclk1_out,
      C2C1_PHY_hard_err => C2C1_PHY_hard_err,
      C2C1_PHY_lane_up(0) => C2C1_PHY_lane_up(0),
      C2C1_PHY_link_reset_out => C2C1_PHY_link_reset_out,
      C2C1_PHY_mmcm_not_locked_out => C2C1_PHY_mmcm_not_locked_out,
      C2C1_PHY_power_down => C2C1_PHY_power_down,
      C2C1_PHY_refclk_clk_n => C2C1_PHY_refclk_clk_n,
      C2C1_PHY_refclk_clk_p => C2C1_PHY_refclk_clk_p,
      C2C1_PHY_soft_err => C2C1_PHY_soft_err,
      C2C1_aurora_do_cc => C2C1_aurora_do_cc,
      C2C1_aurora_pma_init_in => C2C1_aurora_pma_init_in,
      C2C1_axi_c2c_config_error_out => C2C1_axi_c2c_config_error_out,
      C2C1_axi_c2c_link_error_out => C2C1_axi_c2c_link_error_out,
      C2C1_axi_c2c_link_status_out => C2C1_axi_c2c_link_status_out,
      C2C1_axi_c2c_multi_bit_error_out => C2C1_axi_c2c_multi_bit_error_out,
      C2C2B_PHY_DEBUG_cplllock(0) => C2C2B_PHY_DEBUG_cplllock(0),
      C2C2B_PHY_DEBUG_dmonitorout(15 downto 0) => C2C2B_PHY_DEBUG_dmonitorout(15 downto 0),
      C2C2B_PHY_DEBUG_eyescandataerror(0) => C2C2B_PHY_DEBUG_eyescandataerror(0),
      C2C2B_PHY_DEBUG_eyescanreset(0) => C2C2B_PHY_DEBUG_eyescanreset(0),
      C2C2B_PHY_DEBUG_eyescantrigger(0) => C2C2B_PHY_DEBUG_eyescantrigger(0),
      C2C2B_PHY_DEBUG_pcsrsvdin(15 downto 0) => C2C2B_PHY_DEBUG_pcsrsvdin(15 downto 0),
      C2C2B_PHY_DEBUG_qplllock(0) => C2C2B_PHY_DEBUG_qplllock(0),
      C2C2B_PHY_DEBUG_rxbufreset(0) => C2C2B_PHY_DEBUG_rxbufreset(0),
      C2C2B_PHY_DEBUG_rxbufstatus(2 downto 0) => C2C2B_PHY_DEBUG_rxbufstatus(2 downto 0),
      C2C2B_PHY_DEBUG_rxcdrhold(0) => C2C2B_PHY_DEBUG_rxcdrhold(0),
      C2C2B_PHY_DEBUG_rxdfelpmreset(0) => C2C2B_PHY_DEBUG_rxdfelpmreset(0),
      C2C2B_PHY_DEBUG_rxlpmen(0) => C2C2B_PHY_DEBUG_rxlpmen(0),
      C2C2B_PHY_DEBUG_rxpcsreset(0) => C2C2B_PHY_DEBUG_rxpcsreset(0),
      C2C2B_PHY_DEBUG_rxpmareset(0) => C2C2B_PHY_DEBUG_rxpmareset(0),
      C2C2B_PHY_DEBUG_rxpmaresetdone(0) => C2C2B_PHY_DEBUG_rxpmaresetdone(0),
      C2C2B_PHY_DEBUG_rxprbscntreset(0) => C2C2B_PHY_DEBUG_rxprbscntreset(0),
      C2C2B_PHY_DEBUG_rxprbserr(0) => C2C2B_PHY_DEBUG_rxprbserr(0),
      C2C2B_PHY_DEBUG_rxprbssel(3 downto 0) => C2C2B_PHY_DEBUG_rxprbssel(3 downto 0),
      C2C2B_PHY_DEBUG_rxrate(2 downto 0) => C2C2B_PHY_DEBUG_rxrate(2 downto 0),
      C2C2B_PHY_DEBUG_rxresetdone(0) => C2C2B_PHY_DEBUG_rxresetdone(0),
      C2C2B_PHY_DEBUG_txbufstatus(1 downto 0) => C2C2B_PHY_DEBUG_txbufstatus(1 downto 0),
      C2C2B_PHY_DEBUG_txdiffctrl(4 downto 0) => C2C2B_PHY_DEBUG_txdiffctrl(4 downto 0),
      C2C2B_PHY_DEBUG_txinhibit(0) => C2C2B_PHY_DEBUG_txinhibit(0),
      C2C2B_PHY_DEBUG_txpcsreset(0) => C2C2B_PHY_DEBUG_txpcsreset(0),
      C2C2B_PHY_DEBUG_txpmareset(0) => C2C2B_PHY_DEBUG_txpmareset(0),
      C2C2B_PHY_DEBUG_txpolarity(0) => C2C2B_PHY_DEBUG_txpolarity(0),
      C2C2B_PHY_DEBUG_txpostcursor(4 downto 0) => C2C2B_PHY_DEBUG_txpostcursor(4 downto 0),
      C2C2B_PHY_DEBUG_txprbsforceerr(0) => C2C2B_PHY_DEBUG_txprbsforceerr(0),
      C2C2B_PHY_DEBUG_txprbssel(3 downto 0) => C2C2B_PHY_DEBUG_txprbssel(3 downto 0),
      C2C2B_PHY_DEBUG_txprecursor(4 downto 0) => C2C2B_PHY_DEBUG_txprecursor(4 downto 0),
      C2C2B_PHY_DEBUG_txresetdone(0) => C2C2B_PHY_DEBUG_txresetdone(0),
      C2C2B_PHY_DRP_daddr(9 downto 0) => C2C2B_PHY_DRP_daddr(9 downto 0),
      C2C2B_PHY_DRP_den => C2C2B_PHY_DRP_den,
      C2C2B_PHY_DRP_di(15 downto 0) => C2C2B_PHY_DRP_di(15 downto 0),
      C2C2B_PHY_DRP_do(15 downto 0) => C2C2B_PHY_DRP_do(15 downto 0),
      C2C2B_PHY_DRP_drdy => C2C2B_PHY_DRP_drdy,
      C2C2B_PHY_DRP_dwe => C2C2B_PHY_DRP_dwe,
      C2C2B_PHY_Rx_rxn(0) => C2C2B_PHY_Rx_rxn(0),
      C2C2B_PHY_Rx_rxp(0) => C2C2B_PHY_Rx_rxp(0),
      C2C2B_PHY_Tx_txn(0) => C2C2B_PHY_Tx_txn(0),
      C2C2B_PHY_Tx_txp(0) => C2C2B_PHY_Tx_txp(0),
      C2C2B_PHY_channel_up => C2C2B_PHY_channel_up,
      C2C2B_PHY_gt_pll_lock => C2C2B_PHY_gt_pll_lock,
      C2C2B_PHY_hard_err => C2C2B_PHY_hard_err,
      C2C2B_PHY_lane_up(0) => C2C2B_PHY_lane_up(0),
      C2C2B_PHY_link_reset_out => C2C2B_PHY_link_reset_out,
      C2C2B_PHY_power_down => C2C2B_PHY_power_down,
      C2C2B_PHY_soft_err => C2C2B_PHY_soft_err,
      C2C2B_aurora_do_cc => C2C2B_aurora_do_cc,
      C2C2B_aurora_pma_init_in => C2C2B_aurora_pma_init_in,
      C2C2B_axi_c2c_config_error_out => C2C2B_axi_c2c_config_error_out,
      C2C2B_axi_c2c_link_error_out => C2C2B_axi_c2c_link_error_out,
      C2C2B_axi_c2c_link_status_out => C2C2B_axi_c2c_link_status_out,
      C2C2B_axi_c2c_multi_bit_error_out => C2C2B_axi_c2c_multi_bit_error_out,
      C2C2_PHY_DEBUG_cplllock(0) => C2C2_PHY_DEBUG_cplllock(0),
      C2C2_PHY_DEBUG_dmonitorout(15 downto 0) => C2C2_PHY_DEBUG_dmonitorout(15 downto 0),
      C2C2_PHY_DEBUG_eyescandataerror(0) => C2C2_PHY_DEBUG_eyescandataerror(0),
      C2C2_PHY_DEBUG_eyescanreset(0) => C2C2_PHY_DEBUG_eyescanreset(0),
      C2C2_PHY_DEBUG_eyescantrigger(0) => C2C2_PHY_DEBUG_eyescantrigger(0),
      C2C2_PHY_DEBUG_pcsrsvdin(15 downto 0) => C2C2_PHY_DEBUG_pcsrsvdin(15 downto 0),
      C2C2_PHY_DEBUG_qplllock(0) => C2C2_PHY_DEBUG_qplllock(0),
      C2C2_PHY_DEBUG_rxbufreset(0) => C2C2_PHY_DEBUG_rxbufreset(0),
      C2C2_PHY_DEBUG_rxbufstatus(2 downto 0) => C2C2_PHY_DEBUG_rxbufstatus(2 downto 0),
      C2C2_PHY_DEBUG_rxcdrhold(0) => C2C2_PHY_DEBUG_rxcdrhold(0),
      C2C2_PHY_DEBUG_rxdfelpmreset(0) => C2C2_PHY_DEBUG_rxdfelpmreset(0),
      C2C2_PHY_DEBUG_rxlpmen(0) => C2C2_PHY_DEBUG_rxlpmen(0),
      C2C2_PHY_DEBUG_rxpcsreset(0) => C2C2_PHY_DEBUG_rxpcsreset(0),
      C2C2_PHY_DEBUG_rxpmareset(0) => C2C2_PHY_DEBUG_rxpmareset(0),
      C2C2_PHY_DEBUG_rxpmaresetdone(0) => C2C2_PHY_DEBUG_rxpmaresetdone(0),
      C2C2_PHY_DEBUG_rxprbscntreset(0) => C2C2_PHY_DEBUG_rxprbscntreset(0),
      C2C2_PHY_DEBUG_rxprbserr(0) => C2C2_PHY_DEBUG_rxprbserr(0),
      C2C2_PHY_DEBUG_rxprbssel(3 downto 0) => C2C2_PHY_DEBUG_rxprbssel(3 downto 0),
      C2C2_PHY_DEBUG_rxrate(2 downto 0) => C2C2_PHY_DEBUG_rxrate(2 downto 0),
      C2C2_PHY_DEBUG_rxresetdone(0) => C2C2_PHY_DEBUG_rxresetdone(0),
      C2C2_PHY_DEBUG_txbufstatus(1 downto 0) => C2C2_PHY_DEBUG_txbufstatus(1 downto 0),
      C2C2_PHY_DEBUG_txdiffctrl(4 downto 0) => C2C2_PHY_DEBUG_txdiffctrl(4 downto 0),
      C2C2_PHY_DEBUG_txinhibit(0) => C2C2_PHY_DEBUG_txinhibit(0),
      C2C2_PHY_DEBUG_txpcsreset(0) => C2C2_PHY_DEBUG_txpcsreset(0),
      C2C2_PHY_DEBUG_txpmareset(0) => C2C2_PHY_DEBUG_txpmareset(0),
      C2C2_PHY_DEBUG_txpolarity(0) => C2C2_PHY_DEBUG_txpolarity(0),
      C2C2_PHY_DEBUG_txpostcursor(4 downto 0) => C2C2_PHY_DEBUG_txpostcursor(4 downto 0),
      C2C2_PHY_DEBUG_txprbsforceerr(0) => C2C2_PHY_DEBUG_txprbsforceerr(0),
      C2C2_PHY_DEBUG_txprbssel(3 downto 0) => C2C2_PHY_DEBUG_txprbssel(3 downto 0),
      C2C2_PHY_DEBUG_txprecursor(4 downto 0) => C2C2_PHY_DEBUG_txprecursor(4 downto 0),
      C2C2_PHY_DEBUG_txresetdone(0) => C2C2_PHY_DEBUG_txresetdone(0),
      C2C2_PHY_DRP_daddr(9 downto 0) => C2C2_PHY_DRP_daddr(9 downto 0),
      C2C2_PHY_DRP_den => C2C2_PHY_DRP_den,
      C2C2_PHY_DRP_di(15 downto 0) => C2C2_PHY_DRP_di(15 downto 0),
      C2C2_PHY_DRP_do(15 downto 0) => C2C2_PHY_DRP_do(15 downto 0),
      C2C2_PHY_DRP_drdy => C2C2_PHY_DRP_drdy,
      C2C2_PHY_DRP_dwe => C2C2_PHY_DRP_dwe,
      C2C2_PHY_Rx_rxn(0) => C2C2_PHY_Rx_rxn(0),
      C2C2_PHY_Rx_rxp(0) => C2C2_PHY_Rx_rxp(0),
      C2C2_PHY_Tx_txn(0) => C2C2_PHY_Tx_txn(0),
      C2C2_PHY_Tx_txp(0) => C2C2_PHY_Tx_txp(0),
      C2C2_PHY_channel_up => C2C2_PHY_channel_up,
      C2C2_PHY_gt_pll_lock => C2C2_PHY_gt_pll_lock,
      C2C2_PHY_hard_err => C2C2_PHY_hard_err,
      C2C2_PHY_lane_up(0) => C2C2_PHY_lane_up(0),
      C2C2_PHY_link_reset_out => C2C2_PHY_link_reset_out,
      C2C2_PHY_power_down => C2C2_PHY_power_down,
      C2C2_PHY_soft_err => C2C2_PHY_soft_err,
      C2C2_aurora_do_cc => C2C2_aurora_do_cc,
      C2C2_aurora_pma_init_in => C2C2_aurora_pma_init_in,
      C2C2_axi_c2c_config_error_out => C2C2_axi_c2c_config_error_out,
      C2C2_axi_c2c_link_error_out => C2C2_axi_c2c_link_error_out,
      C2C2_axi_c2c_link_status_out => C2C2_axi_c2c_link_status_out,
      C2C2_axi_c2c_multi_bit_error_out => C2C2_axi_c2c_multi_bit_error_out,
      CM1_UART_rxd => CM1_UART_rxd,
      CM1_UART_txd => CM1_UART_txd,
      CM2_UART_rxd => CM2_UART_rxd,
      CM2_UART_txd => CM2_UART_txd,
      CM_PB_UART_rxd => CM_PB_UART_rxd,
      CM_PB_UART_txd => CM_PB_UART_txd,
      CM_araddr(31 downto 0) => CM_araddr(31 downto 0),
      CM_arprot(2 downto 0) => CM_arprot(2 downto 0),
      CM_arready => CM_arready,
      CM_arvalid => CM_arvalid,
      CM_awaddr(31 downto 0) => CM_awaddr(31 downto 0),
      CM_awprot(2 downto 0) => CM_awprot(2 downto 0),
      CM_awready => CM_awready,
      CM_awvalid => CM_awvalid,
      CM_bready => CM_bready,
      CM_bresp(1 downto 0) => CM_bresp(1 downto 0),
      CM_bvalid => CM_bvalid,
      CM_rdata(31 downto 0) => CM_rdata(31 downto 0),
      CM_rready => CM_rready,
      CM_rresp(1 downto 0) => CM_rresp(1 downto 0),
      CM_rvalid => CM_rvalid,
      CM_wdata(31 downto 0) => CM_wdata(31 downto 0),
      CM_wready => CM_wready,
      CM_wstrb(3 downto 0) => CM_wstrb(3 downto 0),
      CM_wvalid => CM_wvalid,
      ESM_UART_rxd => ESM_UART_rxd,
      ESM_UART_txd => ESM_UART_txd,
      MONITOR_alarm => MONITOR_alarm,
      MONITOR_overtemp_alarm => MONITOR_overtemp_alarm,
      MONITOR_vccaux_alarm => MONITOR_vccaux_alarm,
      MONITOR_vccint_alarm => MONITOR_vccint_alarm,
      PLXVC_araddr(31 downto 0) => PLXVC_araddr(31 downto 0),
      PLXVC_arprot(2 downto 0) => PLXVC_arprot(2 downto 0),
      PLXVC_arready => PLXVC_arready,
      PLXVC_arvalid => PLXVC_arvalid,
      PLXVC_awaddr(31 downto 0) => PLXVC_awaddr(31 downto 0),
      PLXVC_awprot(2 downto 0) => PLXVC_awprot(2 downto 0),
      PLXVC_awready => PLXVC_awready,
      PLXVC_awvalid => PLXVC_awvalid,
      PLXVC_bready => PLXVC_bready,
      PLXVC_bresp(1 downto 0) => PLXVC_bresp(1 downto 0),
      PLXVC_bvalid => PLXVC_bvalid,
      PLXVC_rdata(31 downto 0) => PLXVC_rdata(31 downto 0),
      PLXVC_rready => PLXVC_rready,
      PLXVC_rresp(1 downto 0) => PLXVC_rresp(1 downto 0),
      PLXVC_rvalid => PLXVC_rvalid,
      PLXVC_wdata(31 downto 0) => PLXVC_wdata(31 downto 0),
      PLXVC_wready => PLXVC_wready,
      PLXVC_wstrb(3 downto 0) => PLXVC_wstrb(3 downto 0),
      PLXVC_wvalid => PLXVC_wvalid,
      SERV_araddr(31 downto 0) => SERV_araddr(31 downto 0),
      SERV_arprot(2 downto 0) => SERV_arprot(2 downto 0),
      SERV_arready => SERV_arready,
      SERV_arvalid => SERV_arvalid,
      SERV_awaddr(31 downto 0) => SERV_awaddr(31 downto 0),
      SERV_awprot(2 downto 0) => SERV_awprot(2 downto 0),
      SERV_awready => SERV_awready,
      SERV_awvalid => SERV_awvalid,
      SERV_bready => SERV_bready,
      SERV_bresp(1 downto 0) => SERV_bresp(1 downto 0),
      SERV_bvalid => SERV_bvalid,
      SERV_rdata(31 downto 0) => SERV_rdata(31 downto 0),
      SERV_rready => SERV_rready,
      SERV_rresp(1 downto 0) => SERV_rresp(1 downto 0),
      SERV_rvalid => SERV_rvalid,
      SERV_wdata(31 downto 0) => SERV_wdata(31 downto 0),
      SERV_wready => SERV_wready,
      SERV_wstrb(3 downto 0) => SERV_wstrb(3 downto 0),
      SERV_wvalid => SERV_wvalid,
      SI_scl_i => SI_scl_i,
      SI_scl_o => SI_scl_o,
      SI_scl_t => SI_scl_t,
      SI_sda_i => SI_sda_i,
      SI_sda_o => SI_sda_o,
      SI_sda_t => SI_sda_t,
      SLAVE_I2C_araddr(31 downto 0) => SLAVE_I2C_araddr(31 downto 0),
      SLAVE_I2C_arprot(2 downto 0) => SLAVE_I2C_arprot(2 downto 0),
      SLAVE_I2C_arready => SLAVE_I2C_arready,
      SLAVE_I2C_arvalid => SLAVE_I2C_arvalid,
      SLAVE_I2C_awaddr(31 downto 0) => SLAVE_I2C_awaddr(31 downto 0),
      SLAVE_I2C_awprot(2 downto 0) => SLAVE_I2C_awprot(2 downto 0),
      SLAVE_I2C_awready => SLAVE_I2C_awready,
      SLAVE_I2C_awvalid => SLAVE_I2C_awvalid,
      SLAVE_I2C_bready => SLAVE_I2C_bready,
      SLAVE_I2C_bresp(1 downto 0) => SLAVE_I2C_bresp(1 downto 0),
      SLAVE_I2C_bvalid => SLAVE_I2C_bvalid,
      SLAVE_I2C_rdata(31 downto 0) => SLAVE_I2C_rdata(31 downto 0),
      SLAVE_I2C_rready => SLAVE_I2C_rready,
      SLAVE_I2C_rresp(1 downto 0) => SLAVE_I2C_rresp(1 downto 0),
      SLAVE_I2C_rvalid => SLAVE_I2C_rvalid,
      SLAVE_I2C_wdata(31 downto 0) => SLAVE_I2C_wdata(31 downto 0),
      SLAVE_I2C_wready => SLAVE_I2C_wready,
      SLAVE_I2C_wstrb(3 downto 0) => SLAVE_I2C_wstrb(3 downto 0),
      SLAVE_I2C_wvalid => SLAVE_I2C_wvalid,
      SM_INFO_araddr(31 downto 0) => SM_INFO_araddr(31 downto 0),
      SM_INFO_arprot(2 downto 0) => SM_INFO_arprot(2 downto 0),
      SM_INFO_arready => SM_INFO_arready,
      SM_INFO_arvalid => SM_INFO_arvalid,
      SM_INFO_awaddr(31 downto 0) => SM_INFO_awaddr(31 downto 0),
      SM_INFO_awprot(2 downto 0) => SM_INFO_awprot(2 downto 0),
      SM_INFO_awready => SM_INFO_awready,
      SM_INFO_awvalid => SM_INFO_awvalid,
      SM_INFO_bready => SM_INFO_bready,
      SM_INFO_bresp(1 downto 0) => SM_INFO_bresp(1 downto 0),
      SM_INFO_bvalid => SM_INFO_bvalid,
      SM_INFO_rdata(31 downto 0) => SM_INFO_rdata(31 downto 0),
      SM_INFO_rready => SM_INFO_rready,
      SM_INFO_rresp(1 downto 0) => SM_INFO_rresp(1 downto 0),
      SM_INFO_rvalid => SM_INFO_rvalid,
      SM_INFO_wdata(31 downto 0) => SM_INFO_wdata(31 downto 0),
      SM_INFO_wready => SM_INFO_wready,
      SM_INFO_wstrb(3 downto 0) => SM_INFO_wstrb(3 downto 0),
      SM_INFO_wvalid => SM_INFO_wvalid,
      axi_c2c_rst_n(0) => axi_c2c_rst_n(0),
      axi_clk => axi_clk,
      axi_rst_n(0) => axi_rst_n(0),
      c2c_interconnect_reset => c2c_interconnect_reset,
      init_clk => init_clk
    );
end STRUCTURE;
