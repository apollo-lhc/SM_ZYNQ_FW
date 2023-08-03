----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2023 03:10:39 PM
-- Design Name: 
-- Module Name: MUX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.plXVC_CTRL.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX is
  Port ( axi_clk        : in  std_logic;                      --Input axi_clk
         reset          : in  std_logic;                      --reset 
         FIFO           : in  PLXVC_XVC_CTRL_t;
         CTRL_in        : in  PLXVC_XVC_CTRL_t;
         fifo_enable    : in  std_logic;
         CTRL_out       : out PLXVC_XVC_CTRL_t);
end MUX;

architecture Behavioral of MUX is
    signal CTRL         : PLXVC_XVC_CTRL_t;
begin
  
  
  CTRL_out <= CTRL;
  
  Multiplexer: process(axi_clk,reset)
  begin
    if (reset = '1') then

   elsif (axi_clk'event and axi_clk='1') then
      if (fifo_enable = '1') then
        CTRL <= FIFO;
      elsif(fifo_enable = '0') then
        CTRL <= CTRL_in;
      end if;
    end if;
  end process Multiplexer;
   
end Behavioral;
