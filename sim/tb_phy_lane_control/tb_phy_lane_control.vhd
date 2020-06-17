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
  signal phycontrol_en   : std_logic;
  signal initialize_test : std_logic;
  signal aurora          : std_logic;
  -- For module under testing
  signal enable          : std_logic;
  signal initialize_in   : std_logic;
  signal phy_lane_up     : std_logic;
  signal initialize_out  : std_logic;
  signal lock            : std_logic;
  signal count           : std_logic_vector(31 downto 0);
    
begin  -- architecture behavioral
  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      enable <= '0';
      phy_lane_up <= '0';
            
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
      aurora <= ((initialize_out and enable) or (initialize_test and (not enable)));
      
      case counter is
        ---- test normal procedure
        --when 10 =>
        --  enable <= '1';
        --when 100 =>
        --  phy_lane_up <= '1';
        --when 150 =>
        --  phy_lane_up <= '0';
        --when 200 =>
        --  phy_lane_up <= '1';
        --when 250 =>
        --  enable <= '0';
        --when 300 =>
        --  enable <= '1';
                  
        when others => null;
      end case;
    end if;
  end process tb;

  --Module under testing
  phy_lane_1: entity work.CM_phy_lane_control
    generic map (
      CLKFREQ        => 1000, --WAITING should last 10 clk cycles
      DATA_WIDTH     => 32)    
    port map (
      clk            => clk,
      reset          => reset,
      enable         => phycontrol_en,
      phy_lane_up    => phy_lane_up,
      initialize_out => initialize_out,
      lock           => lock,
      count          => count);
  phycontrol_en <= enable;
  
  
end architecture behavioral;
