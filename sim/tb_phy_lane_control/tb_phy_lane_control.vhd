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
  signal counter          : integer;
  signal initialize_test  : std_logic;
  signal aurora           : std_logic;
  -- For module under testing
  signal reset_counter    : std_logic;
  signal enable           : std_logic;
  signal phy_lane_up      : std_logic;
  signal phy_lane_stable  : std_logic_vector(31 downto 0);
  signal READ_TIME        : std_logic_vector(23 downto 0);
  signal initialize_out   : std_logic;
  signal lock             : std_logic;
  signal state_out        : std_logic_vector(2 downto 0);
  signal count_error_wait : std_logic_vector(31 downto 0);
  signal count_short      : std_logic_vector(31 downto 0);
  signal count_all        : std_logic_vector(31 downto 0);
    
begin  -- architecture behavioral

  aurora <= ((initialize_out and enable) or (initialize_test and (not enable)));

  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      enable <= '0';
      phy_lane_up <= '0';
      initialize_test <= '0';
      reset_counter <= '0';
      phy_lane_stable <= x"0000_0001";
      READ_TIME <= x"4C_4B40"; --100ms
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
            
      case counter is
        --when 10 =>
        --  initialize_test <= '1';
        --when 15 =>
        --  initialize_test <= '0';
        --when 20 =>
        --  initialize_test <= '1';
        --when 25 =>
        --  enable <= '1';
        --when 70 =>
        --  phy_lane_up <= '1';
        --when 100 =>
        --  enable <= '0';
        --  phy_lane_up <= '0';
        --when 110 =>
        --  initialize_test <= '0';
        --when 120 =>
        --  enable <= '1';
        --  phy_lane_up <='1';
        --when 125 =>
        --  phy_lane_up <= '0';
        --when 130 =>
        --  phy_lane_up <= '1';
        --when 135 =>
        --  phy_lane_up <= '0';
        --when 140 =>
        --  enable <= '0';
        --when 150 =>
        --  enable <= '1';
        --  phy_lane_up <= '1';
        --when 155 =>
        --  phy_lane_up <= '0';
        --when 300 =>
        --  phy_lane_up <= 'X';
          
        when others => null;
      end case;
    end if;
  end process tb;

  --Module under testing
  phy_lane_1: entity work.CM_phy_lane_control
    generic map (
      CLKFREQ          => 1000, --WAITING should last 10 clk cycles
      DATA_WIDTH       => 32,
      ERROR_WAIT_TIME  => 10) --error wait last 10 clks    
    port map (
      clk              => clk,
      reset            => reset,
      reset_counter    => reset_counter,
      enable           => enable,
      phy_lane_up      => phy_lane_up,
      phy_lane_stable  => phy_lane_stable,
      READ_TIME        => READ_TIME,
      initialize_out   => initialize_out,
      lock             => lock,
      state_out        => state_out,
      count_error_wait => count_error_wait,
      count_alltime    => count_all,
      count_shortterm  => count_short);
end architecture behavioral;
