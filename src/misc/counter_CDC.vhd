-------------------------------------------------------------------------------
-- Generic counter with CDC output
-- Dan Gastler
-- Process count pulses and provide a buffered value of count
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity counter_CDC is

  generic (
    roll_over   : std_logic        := '1';
    end_value   : std_logic_vector(31 downto  0) := x"FFFFFFFF";
    start_value : std_logic_vector(31 downto  0) := x"00000000";
    A_RST_CNT   : std_logic_vector(31 downto  0) := x"00000000";
    DATA_WIDTH  : integer          := 32);
  port (
    clk_in      : in  std_logic;    
    reset_async : in  std_logic;    
    event       : in  std_logic;
    clk_out     : in  std_logic;
    enable      : in  std_logic;
    reset_sync  : in  std_logic;
    count       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    at_max      : out std_logic
    );

end entity counter_CDC;

architecture behavioral of counter_CDC is

  signal count_internal   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal at_max_internal : std_logic;
  signal enable_internal : std_logic;
  signal reset_sync_internal : std_logic;
  
begin
  counter_1: entity work.counter
    generic map (
      roll_over   => roll_over,
      end_value   => end_value,
      start_value => start_value,
      A_RST_CNT   => A_RST_CNT,
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk_in,
      reset_async => reset_async,
      reset_sync  => reset_sync_internal,
      enable      => enable_internal,
      event       => event,
      count       => count_internal,
      at_max      => at_max_internal);

  DC_data_CDC_1: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 2)
    port map (
      clk_in   => clk_out,
      clk_out  => clk_in,
      reset    => '0',
      pass_in(0)  => enable,
      pass_in(1)  => reset_sync,
      pass_out(0) => enable_internal,
      pass_out(1) => reset_sync_internal);

  DC_data_CDC_2: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk_in   => clk_in,
      clk_out  => clk_out,
      reset    => '0',
      pass_in  => count_internal,
      pass_out => count);

  DC_data_CDC_3: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 1)
    port map (
      clk_in   => clk_in,
      clk_out  => clk_out,
      reset    => '0',
      pass_in(0)  => at_max_internal,
      pass_out(0) => at_max);
end architecture behavioral;

