----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2020 09:20:14 AM
-- Design Name: 
-- Module Name: sim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim is
generic (TCK_RATIO  : integer := 1;
         IRQ_LENGTH : integer := 1);
end sim;

architecture Behavioral of sim is

component virtualJTAG is
  generic (--TCK_RATIO    : in  integer := 1;                     --ratio of axi_clk to TCK
           IRQ_LENGTH   : in  integer := 2);                    --Length of IRQ in axi_clk ticks, must be greater than 1
  port    (axi_clk      : in  std_logic;                        --Input clk
           reset        : in  std_logic;                        --reset
           TMS_vector   : in  std_logic_vector(31 downto 0);    --axi tms input
           TDI_vector   : in  std_logic_vector(31 downto 0);    --axi tdi input
           TDO          : in  std_logic;                        --JTAG tdo input
           length       : in  std_logic_vector(31 downto 0);    --lenght of operation in bits
           CTRL         : in  std_logic;                        --Enable operation
           TMS          : out std_logic;                        --JTAG tms output
           TDI          : out std_logic;                        --JTAG tdi output
           TDO_vector   : out std_logic_vector(31 downto 0);    --axi tdo output
           TCK          : out std_logic;                        --output clk
           busy         : out std_logic;
           interupt     : out std_logic);                       --interupt
end component;

signal axi_clk, reset, TDO, CTRL, TMS, TDI, TCK, busy, interupt : std_logic;
signal TMS_vector, TDI_vector, length, TDO_vector : std_logic_vector(31 downto 0);

begin

TT : virtualJTAG
generic map (--TCK_RATIO  => TCK_RATIO,
             IRQ_LENGTH => IRQ_LENGTH)
port map (axi_clk       => axi_clk,
           reset        => reset,
           TMS_vector   => TMS_vector,
           TDI_vector   => TDI_vector,
           TDO          => TDO,
           length       => length,
           CTRL         => CTRL,
           TMS          => TMS,
           TDI          => TDI,
           TDO_vector   => TDO_vector,
           TCK          => TCK,
           busy         => busy,
           interupt     => interupt);

end Behavioral;
