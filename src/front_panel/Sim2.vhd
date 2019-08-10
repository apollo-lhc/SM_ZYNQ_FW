----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2019 02:24:48 PM
-- Design Name: 
-- Module Name: TopSim - Behavioral
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

entity TopSim is
--  Port ( );
end TopSim;

architecture Behavioral of TopSim is

component FrontGrande
generic (clkfreq    : integer;
         steps      : integer;
         max        : integer);
    Port (clk       : in std_logic;
          reset     : in std_logic;
          buttonin  : in std_logic;
          dataout   : out std_logic_vector (7 downto 0);
          busy      : out std_logic;
          SCK       : out std_logic;
          SDA       : out std_logic;
          tshort    : out std_logic;
          tlong     : out std_logic;
          ttwo      : out std_logic);
end component;

--inputs
signal clk, reset, buttonin : std_logic;
--outputs
signal dataout : std_logic_vector (7 downto 0);
signal busy, SCK, SDA : std_logic; 
--test outputs
signal tshort, tlong, ttwo : std_logic;



begin

Sim: FrontGrande 
generic map (clkfreq => 100,
             steps => 10,
             max => 10)
port map    (clk => clk,
             reset => reset,
             buttonin => buttonin,
             dataout => dataout,
             busy => busy,
             SCK => SCK,
             SDA => SDA,
             tshort => tshort,
             tlong => tlong,
             ttwo => ttwo);
              
end Behavioral;
