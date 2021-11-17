-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
-- Date        : Mon Oct  4 09:50:30 2021
-- Host        : tesla.bu.edu running 64-bit CentOS Linux release 7.9.2009 (Core)
-- Command     : write_vhdl -force -mode synth_stub
--               /work/ichand/SM_ZYNQ_FW/configs/rev1_xc7z035/cores/onboardClk/onboardClk_stub.vhdl
-- Design      : onboardClk
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z035fbg676-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity onboardClk is
  Port ( 
    clk_50Mhz : out STD_LOGIC;
    clk_200Mhz : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC
  );

end onboardClk;

architecture stub of onboardClk is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_50Mhz,clk_200Mhz,reset,locked,clk_in1_p,clk_in1_n";
begin
end;
