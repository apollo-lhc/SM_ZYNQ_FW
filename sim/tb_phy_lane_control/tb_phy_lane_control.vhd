library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
--use work.types.all;

entity tb_phy_lane_control is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_phy_lane_control;

architecture behavioral of tb_phy_lane_control is

  signal counter        : integer;

  signal enable         : std_logic;
  signal initialize_in  : std_logic;
  signal phy_lane_up    : std_logic;
  signal initialize_out : std_logic;
  signal locked         : std_logic;
  
begin  -- architecture behavioral

  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      enable <= '0';
      initialize_in <= '0';
      phy_lane_up <= '0';
      initialize_out <= '0';
      locked <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;

      case counter is
        --test normal procedure
        when 10 =>
          enable <= '1';
        when 100 =>
          phy_lane_up <= '1';
        when 150 =>
          phy_lane_up <= '0';
        when 200 =>
          phy_lane_up <= '1';
        when 250 =>
          enable <= '0';
        when 300 =>
          enable <= '1';
                  
        when others => null;
      end case;
    end if;
  end process tb;


  phy_lane_1: entity work.phy_lane_control
    generic map (
      CLKFREQ => 10000) --WAITING should last 10 clk cycles
    port map (
      clk => clk,
      reset => reset,
      enable => enable,
      initialize_in => initialize_in,
      phy_lane_up => phy_lane_up,
      initialize_out => initialize_out,
      locked => locked);

  
end architecture behavioral;
