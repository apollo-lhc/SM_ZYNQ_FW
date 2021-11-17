// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Mon Oct  4 09:50:30 2021
// Host        : tesla.bu.edu running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /work/ichand/SM_ZYNQ_FW/configs/rev1_xc7z035/cores/onboardClk/onboardClk_stub.v
// Design      : onboardClk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z035fbg676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module onboardClk(clk_50Mhz, clk_200Mhz, reset, locked, clk_in1_p, 
  clk_in1_n)
/* synthesis syn_black_box black_box_pad_pin="clk_50Mhz,clk_200Mhz,reset,locked,clk_in1_p,clk_in1_n" */;
  output clk_50Mhz;
  output clk_200Mhz;
  input reset;
  output locked;
  input clk_in1_p;
  input clk_in1_n;
endmodule
