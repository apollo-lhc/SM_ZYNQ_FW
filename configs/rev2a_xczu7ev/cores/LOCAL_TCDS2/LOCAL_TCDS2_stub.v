// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Tue Jul  6 11:43:45 2021
// Host        : tesla.bu.edu running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /work/dan/Apollo/SM_ZYNQ_FW/configs/rev2a_xczu7ev/cores/LOCAL_TCDS2/LOCAL_TCDS2_stub.v
// Design      : LOCAL_TCDS2
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu7ev-fbvb900-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "LOCAL_TCDS2_gtwizard_top,Vivado 2020.2" *)
module LOCAL_TCDS2(gtwiz_userclk_tx_reset_in, 
  gtwiz_userclk_tx_srcclk_out, gtwiz_userclk_tx_usrclk_out, 
  gtwiz_userclk_tx_usrclk2_out, gtwiz_userclk_tx_active_out, gtwiz_userclk_rx_reset_in, 
  gtwiz_userclk_rx_srcclk_out, gtwiz_userclk_rx_usrclk_out, 
  gtwiz_userclk_rx_usrclk2_out, gtwiz_userclk_rx_active_out, 
  gtwiz_reset_clk_freerun_in, gtwiz_reset_all_in, gtwiz_reset_tx_pll_and_datapath_in, 
  gtwiz_reset_tx_datapath_in, gtwiz_reset_rx_pll_and_datapath_in, 
  gtwiz_reset_rx_datapath_in, gtwiz_reset_qpll0lock_in, gtwiz_reset_rx_cdr_stable_out, 
  gtwiz_reset_tx_done_out, gtwiz_reset_rx_done_out, gtwiz_reset_qpll0reset_out, 
  gtwiz_userdata_tx_in, gtwiz_userdata_rx_out, gthrxn_in, gthrxp_in, qpll0clk_in, 
  qpll0refclk_in, qpll1clk_in, qpll1refclk_in, rx8b10ben_in, rxcommadeten_in, 
  rxmcommaalignen_in, rxpcommaalignen_in, tx8b10ben_in, txctrl0_in, txctrl1_in, txctrl2_in, 
  gthtxn_out, gthtxp_out, gtpowergood_out, rxbyteisaligned_out, rxbyterealign_out, 
  rxcommadet_out, rxctrl0_out, rxctrl1_out, rxctrl2_out, rxctrl3_out, rxpmaresetdone_out, 
  txpmaresetdone_out)
/* synthesis syn_black_box black_box_pad_pin="gtwiz_userclk_tx_reset_in[0:0],gtwiz_userclk_tx_srcclk_out[0:0],gtwiz_userclk_tx_usrclk_out[0:0],gtwiz_userclk_tx_usrclk2_out[0:0],gtwiz_userclk_tx_active_out[0:0],gtwiz_userclk_rx_reset_in[0:0],gtwiz_userclk_rx_srcclk_out[0:0],gtwiz_userclk_rx_usrclk_out[0:0],gtwiz_userclk_rx_usrclk2_out[0:0],gtwiz_userclk_rx_active_out[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_qpll0lock_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_reset_qpll0reset_out[0:0],gtwiz_userdata_tx_in[31:0],gtwiz_userdata_rx_out[31:0],gthrxn_in[0:0],gthrxp_in[0:0],qpll0clk_in[0:0],qpll0refclk_in[0:0],qpll1clk_in[0:0],qpll1refclk_in[0:0],rx8b10ben_in[0:0],rxcommadeten_in[0:0],rxmcommaalignen_in[0:0],rxpcommaalignen_in[0:0],tx8b10ben_in[0:0],txctrl0_in[15:0],txctrl1_in[15:0],txctrl2_in[7:0],gthtxn_out[0:0],gthtxp_out[0:0],gtpowergood_out[0:0],rxbyteisaligned_out[0:0],rxbyterealign_out[0:0],rxcommadet_out[0:0],rxctrl0_out[15:0],rxctrl1_out[15:0],rxctrl2_out[7:0],rxctrl3_out[7:0],rxpmaresetdone_out[0:0],txpmaresetdone_out[0:0]" */;
  input [0:0]gtwiz_userclk_tx_reset_in;
  output [0:0]gtwiz_userclk_tx_srcclk_out;
  output [0:0]gtwiz_userclk_tx_usrclk_out;
  output [0:0]gtwiz_userclk_tx_usrclk2_out;
  output [0:0]gtwiz_userclk_tx_active_out;
  input [0:0]gtwiz_userclk_rx_reset_in;
  output [0:0]gtwiz_userclk_rx_srcclk_out;
  output [0:0]gtwiz_userclk_rx_usrclk_out;
  output [0:0]gtwiz_userclk_rx_usrclk2_out;
  output [0:0]gtwiz_userclk_rx_active_out;
  input [0:0]gtwiz_reset_clk_freerun_in;
  input [0:0]gtwiz_reset_all_in;
  input [0:0]gtwiz_reset_tx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_tx_datapath_in;
  input [0:0]gtwiz_reset_rx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_rx_datapath_in;
  input [0:0]gtwiz_reset_qpll0lock_in;
  output [0:0]gtwiz_reset_rx_cdr_stable_out;
  output [0:0]gtwiz_reset_tx_done_out;
  output [0:0]gtwiz_reset_rx_done_out;
  output [0:0]gtwiz_reset_qpll0reset_out;
  input [31:0]gtwiz_userdata_tx_in;
  output [31:0]gtwiz_userdata_rx_out;
  input [0:0]gthrxn_in;
  input [0:0]gthrxp_in;
  input [0:0]qpll0clk_in;
  input [0:0]qpll0refclk_in;
  input [0:0]qpll1clk_in;
  input [0:0]qpll1refclk_in;
  input [0:0]rx8b10ben_in;
  input [0:0]rxcommadeten_in;
  input [0:0]rxmcommaalignen_in;
  input [0:0]rxpcommaalignen_in;
  input [0:0]tx8b10ben_in;
  input [15:0]txctrl0_in;
  input [15:0]txctrl1_in;
  input [7:0]txctrl2_in;
  output [0:0]gthtxn_out;
  output [0:0]gthtxp_out;
  output [0:0]gtpowergood_out;
  output [0:0]rxbyteisaligned_out;
  output [0:0]rxbyterealign_out;
  output [0:0]rxcommadet_out;
  output [15:0]rxctrl0_out;
  output [15:0]rxctrl1_out;
  output [7:0]rxctrl2_out;
  output [7:0]rxctrl3_out;
  output [0:0]rxpmaresetdone_out;
  output [0:0]txpmaresetdone_out;
endmodule
