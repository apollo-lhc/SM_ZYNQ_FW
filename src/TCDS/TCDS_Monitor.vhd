library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity TCDS_Monitor is
  
  port (
    clk_axi        : in  std_logic;
    axi_reset_n    : in  std_logic;    
    counters_en    : in  std_logic;
    prbs_err_count : out std_logic_vector(31 downto 0);
    bad_word_count : out std_logic_vector(31 downto 0);
    disp_err_count : out std_logic_vector(31 downto 0);
    clk_txrx       : in  std_logic;
    prbs_error     : in  std_logic;
    bad_word       : in  std_logic;
    disp_error     : in  std_logic);

end entity TCDS_Monitor;


architecture Behavioral of TCDS_Monitor is

  signal reset : std_logic;
  
  
  signal counter_reset : std_logic;
  signal n_counters_en : std_logic;
  
  constant N_counters  : integer := 3;
  signal counter_event : std_logic_vector(N_counters-1 downto 0);
  signal count_txrx    : slv32_array_t(0 to N_counters-1);
  signal count_axi     : slv32_array_t(0 to N_counters-1);
  type poll_sr_t is array (0 to N_counters-1) of std_logic_vector(2 downto 0);
  signal poll          : poll_sr_t;--std_logic_vector(N_counters-1 downto 0);
  signal outA_valid    : std_logic_vector(N_counters-1 downto 0);
  
begin  -- architecture Behavioral

  reset <= not axi_reset_n;

  counter_event(0) <= prbs_error;
  prbs_err_count <=  count_axi(0);

  counter_event(1) <= bad_word;
  bad_word_count <=  count_axi(1);

  counter_event(2) <= disp_error;
  disp_err_count <=  count_axi(2);

  
  -- CDC for counter start signal
  n_counters_en <= not counters_en;
  DC_data_CDC_0: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 1)
    port map (
      clk_in   => clk_axi,
      clk_out  => clk_txrx,
      reset    => reset,
      pass_in(0)  => n_counters_en,
      pass_out(0) => counter_reset);


  -- for each counter, generate the counter on the clk_txrx domain,
  -- then poll it via a CDC handshake.
  counter_generator: for iCounter in 0 to N_counters-1 generate
    PRBS_counter_0: entity work.counter
      generic map (
        roll_over   => '0')
      port map (
        clk         => clk_txrx,
        reset_async => reset,
        reset_sync  => counter_reset,
        enable      => '1',
        event       => counter_event(iCounter),
        count       => count_txrx(iCounter),
        at_max      => open);

    --polling process that waits for a new value from the clk_txrx domain to be
    --valid, then request a new one
    poll_process: process (clk_axi,reset) is
    begin  -- process poll
      if reset = '1' then
        poll(iCounter) <= "000";
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        if counters_en = '0' then
          poll(iCounter) <= "100";
        else
          poll(iCounter)(2)           <= outA_valid(iCounter);
          poll(iCounter)(1 downto 0)  <= poll(iCounter)(2 downto 1);
        end if;
      end if;
    end process poll_process;

    --Polling process requests a latched value from the clk_txrx domain to be
    --passed to the clk_axi domain.
    capture_CDC_1: entity work.capture_CDC
      generic map (
        WIDTH => 32)
      port map (
        clkA           => clk_axi,
        resetA         => reset,
        clkB           => clk_txrx,
        resetB         => counter_reset,
        capture_pulseA => poll(iCounter)(0),
        outA           => count_axi(iCounter),
        outA_valid     => outA_valid(iCounter),     
        inB            => count_txrx(iCounter),
        inB_valid      => '1');    
  end generate counter_generator;


end architecture Behavioral;
