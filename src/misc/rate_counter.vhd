-------------------------------------------------------------------------------
-- rate counter
-- Dan Gastler
-- Measure a rate on another clock domain
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity rate_counter is
  
  generic (
    CLK_A_1_SECOND : unsigned(31 downto 0) := 100000000);  -- 100Mhz

  port (
    clk_A   : in  std_logic;
    clk_B   : in  std_logic;
    reset_A_async : in  std_logic;
    event_b : in  std_logic;
    rate    : out std_logic_vector(31 downto 0));

end entity rate_counter;

architecture behavioral of rate_counter is

  signal measure_A : std_logic;
  signal measured_rate : std_logic_vector(31 downto 0);
  signal measured_rate_valid : std_logic;

  signal measure_B : std_logic;
  signal count_b : std_logic_vector(31 downto 0);
begin  -- architecture behavioral

  --Send out a pulse every CLK_A_1_SECOND clock ticks to request a measurement
  --from the clkB time domain
  counter_clk: entity work.counter
    generic map (
      roll_over   => '1',
      end_value   => CLK_A_1_SECOND)
    port map (
      clk         => clk_A,
      reset_async => '0',
      reset_sync  => '0',
      enable      => '1',
      event       => '1',
      count       => open,
      at_max      => measure_A);
  
  --Count the event on the clk_B time domain
  --Reset the value when measure_b is one
  counter_1: entity work.counter
    generic map (
      roll_over   => '0')
    port map (
      clk         => clk_b,
      reset_async => '0',
      reset_sync  => measure_B,
      enable      => '1',
      event       => event_b,
      count       => count_b,
      at_max      => open);

  --Send a request for a measurement from the clk_A domain to the clk_b domain
  capture_CDC_1: entity work.capture_CDC
    generic map (
      WIDTH => 1)    
    port map (
      clkA       => clk_A,
      clkB       => clk_B,
      inA        => '1',
      inA_valid(0)  => measure_A,
      outB       => '1',
      outB_valid(0) => measure_B);

  --When clk_B gets a measure request from clk_B, capture and reset clk_B's counter
  capture_CDC_2: entity work.capture_CDC
    generic map (
      WIDTH => 32)
    port map (
      clkA       => clk_b,
      clkB       => clk_a,
      inA        => count_b,
      inA_valid  => measure_B,
      outB       => measured_rate,
      outB_valid => measured_rate_valid);

  
  -- purpose: reset_A_async
  -- type   : sequential
  latch_measured_value: process (clk_A, reset_A_async) is
  begin  -- process latch_measured_value
    if reset_A_async = '1' then         -- asynchronous reset (active high)
      rate <= (others => '0');      
    elsif clk_A'event and clk_A = '1' then  -- rising clock edge
      if measured_rate_valid = '1' then
        rate <= measured_rate;
      end if;
    end if;
  end process latch_measured_value;
  
end architecture behavioral;
