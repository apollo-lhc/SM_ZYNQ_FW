library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.types.all;

entity tb_phy_lane_control is
  port (
    clk     : in std_logic;
    reset   : in std_logic);
end entity tb_phy_lane_control;

architecture behavioral of tb_phy_lane_control is

  -- For testing
  signal counter         : integer;
  signal initialize_test : std_logic;
  signal aurora          : std_logic;
  signal aurora_good     : std_logic;
  -- For module under testing
  signal enable          : std_logic;
  signal phy_lane_up     : std_logic;
  signal initialize_out  : std_logic;
  signal lock            : std_logic;
  signal count           : std_logic_vector(31 downto 0);
    
begin  -- architecture behavioral

  aurora <= ((initialize_out and enable) or (initialize_test and (not enable)));

  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      enable <= '0';
      phy_lane_up <= '0';
      initialize_test <= '0';
      aurora_good <= '0';
            
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
      
      
      case counter is
        when 10 =>
          initialize_test <= '1';
          aurora_good <= '1';
        when 15 =>
          initialize_test <= '0';
          aurora_good <= '0';
        when 20 =>
          initialize_test <= '1';
          aurora_good <= '1';
        when 25 =>
          enable <= '1';
          aurora_good <= '0';
        when 35 =>
          aurora_good <= '1';
        when 67 =>
          aurora_good <= '0';
        when 70 =>
          phy_lane_up <= '1';
        when 100 =>
          enable <= '0';
          phy_lane_up <= '0';
          aurora_good <= '1';
        when 110 =>
          initialize_test <= '0';
          aurora_good <= '0';
        when 120 =>
          enable <= '1';
        when 130 =>
          aurora_good <= '1';
        when 140 =>
          aurora_good <= 'X';
          
        when others => null;
      end case;
    end if;
  end process tb;

  --Module under testing
  phy_lane_1: entity work.CM_phy_lane_control
    generic map (
      CLKFREQ        => 10, --WAITING should last 10 clk cycles
      DATA_WIDTH     => 32)    
    port map (
      clk            => clk,
      reset          => reset,
      enable         => enable,
      phy_lane_up    => phy_lane_up,
      initialize_out => initialize_out,
      lock           => lock,
      count          => count);
end architecture behavioral;
