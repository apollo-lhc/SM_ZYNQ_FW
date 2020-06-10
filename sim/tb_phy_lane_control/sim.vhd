library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim is
  generic (CM_COUNT : integer := 1; 
           CLKFREQ  : integer := 50);
end sim;

architecture Behavioral of sim is
  component phy_lane_control is
    generic (
      CM_COUNT : integer range 1 to 2 := 1;
      CLKFREQ : integer := 100);
    port (
      clk             : in  std_logic;
      reset           : in  std_logic;
      initialize_in1  : in  std_logic;
      initialize_in2  : in  std_logic;
      phy_lane_1      : in  std_logic;
      phy_lane_2      : in  std_logic;
      initialize_out1 : out std_logic;
      initialize_out2 : out std_logic);
  end component;
  
  signal clk, reset, initialize_in1, initialize_in2, phy_lane_1, phy_lane_2, initialize_out1, initialize_out2 : std_logic;

begin

  TT : phy_lane_control
    generic map (
      CM_COUNT => CM_COUNT,
      CLKFREQ => CLKFREQ)
    port map (
      clk             => clk,
      reset           => reset,
      initialize_in1  => initialize_in1,
      initialize_in2  => initialize_in2,
      phy_lane_1      => phy_lane_1,
      phy_lane_2      => phy_lane_2,
      initialize_out1 => initialize_out1,
      initialize_out2 => initialize_out2);
end Behavioral;
