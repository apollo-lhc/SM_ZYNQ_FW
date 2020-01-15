library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity TCDS_Control is
  
  port (
    clk_axi      : in  std_logic;
    axi_reset_n  : in  std_logic;    
    mode         : in  slv_4_t;
    fixed_send_d : in  slv_32_t;
    fixed_send_k : in  slv_4_t;
    capture      : in  std_logic;
    capture_d    : out slv_32_t;
    capture_k    : out slv_4_t;
    clk_txrx     : in  std_logic;
    tx_data      : out slv_32_t;
    tx_k_data    : out slv_4_t;
    rx_data      : in  slv_32_t;
    rx_k_data    : in  slv_4_t);

end entity TCDS_Control;


architecture Behavioral of TCDS_Control is

  signal reset : std_logic;
  signal capture_data : std_logic;
  signal int_mode : slv_4_t;

  signal tx_data_fixed : slv_32_t;
  signal tx_k_data_fixed : slv_4_t;
begin  -- architecture Behavioral

  reset <= not axi_reset_n;
  
  pass_std_logic_vector_1: entity work.pass_std_logic_vector
    generic map (
      DATA_WIDTH => 4,
      RESET_VAL  => x"0")
    port map (
      clk_in   => clk_axi,
      clk_out  => clk_txrx,
      reset    => reset,
      pass_in  => mode,
      pass_out => int_mode);   

  --pass fixed data to the txrx domain for sending
  pass_std_logic_vector_2: entity work.pass_std_logic_vector
    generic map (
      DATA_WIDTH => 36,
      RESET_VAL  => x"0"&x"00000000")
    port map (
      clk_in   => clk_axi,
      clk_out  => clk_txrx,
      reset    => reset,
      pass_in(31 downto  0)  => fixed_send_d,
      pass_in(35 downto 32)  => fixed_send_k,
      pass_out(31 downto  0) => tx_data_fixed,
      pass_out(35 downto 32) => tx_k_data_fixed);

  --Capture rx data from the txrx domain via a capture pulse
  pacd_1: entity work.pacd
    port map (
      iPulseA => capture,
      iClkA   => clk_axi,
      iRSTAn  => axi_reset_n,
      iClkB   => clk_txrx,
      iRSTBn  => axi_reset_n,
      oPulseB => capture_data);
  capture_CDC_1: entity work.capture_CDC
    generic map (
      WIDTH => 36)
    port map (
      clkA               => clk_txrx,
      clkB               => clk_axi,
      inA(31 downto  0)  => rx_data,
      inA(35 downto 32)  => rx_k_data,
      inA_valid          => capture_data,
      outB(31 downto  0) => capture_d,
      outB(35 downto 32) => capture_k,
      outB_valid => open);


  
  data_proc: process (clk_txrx, reset) is      
  begin  -- process data_proc  
    if reset = '1' then      -- asynchronous reset (active high)   
      tx_data <= x"BCBCBCBC";  
      tx_k_data <= x"F";       
    elsif clk_txrx'event and clk_txrx = '1' then  -- rising clock edge  
      case int_mode is    
        when x"0"  => 
          tx_data <= rx_data;  
          tx_k_data <= rx_k_data;       
        when x"1" =>  
          tx_data <= x"BCBCBCBC";       
          tx_k_data <= x"F";   
        when x"2" =>  
          tx_data <= fixed_send_d;      
          tx_k_data <= fixed_send_k;    
        when others =>
          tx_data <= x"BCBCBCBC";       
          tx_k_data <= x"F";   
      end case;       
    end if;  
  end process data_proc;    

end architecture Behavioral;
