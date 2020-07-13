library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity TCDS_Control is
  
  port (
    clk_axi      : in  std_logic;
    axi_reset_n  : in  std_logic;
    clk_txrx     : in  std_logic;
    mode         : in  slv_4_t;
    fixed_send_d : in  slv_32_t;
    fixed_send_k : in  slv_4_t;
    capture      : in  std_logic;
    capture_d    : out slv_32_t;
    capture_k    : out slv_4_t;
    tx_data      : out slv_32_t;
    tx_k_data    : out slv_4_t;
    rx_data      : in  slv_32_t;
    rx_k_data    : in  slv_4_t);

end entity TCDS_Control;


architecture Behavioral of TCDS_Control is

  signal reset : std_logic;
  signal capture_data : std_logic;

  signal local_mode         : slv_4_t;
  signal local_fixed_send_d : slv_32_t;
  signal local_fixed_send_k : slv_4_t;

  
  signal tx_data_fixed : slv_32_t;
  signal tx_k_data_fixed : slv_4_t;
begin  -- architecture Behavioral

  reset <= not axi_reset_n;

  pass_std_logic_vector_1: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 40)
    port map (
      clk_in   => clk_axi,
      clk_out  => clk_txrx,
      reset    => '0',
      pass_in( 3 downto  0)  => mode,
      pass_in(35 downto  4)  => fixed_send_d,
      pass_in(39 downto 36)  => fixed_send_k,
      pass_out( 3 downto  0) => local_mode,
      pass_out(35 downto  4) => local_fixed_send_d,
      pass_out(39 downto 36) => local_fixed_send_k);

  capture_CDC_1: entity work.capture_CDC
    generic map (
      WIDTH => 36)
    port map (
      clkA           => clk_axi,
      resetA         => reset,
      clkB           => clk_txrx,
      resetB         => '0',
      capture_pulseA => capture,
      outA(35 downto  4) => capture_d,
      outA( 3 downto  0) => capture_k,
      outA_valid     => open,     
      inB(35 downto  4) => rx_data,
      inB( 3 downto  0) => rx_k_data,
      inB_valid      => '1');
  
  data_proc: process (clk_axi, reset) is      
  begin  -- process data_proc  
    if reset = '1' then      -- asynchronous reset (active high)   
      tx_data <= x"BCBCBCBC";  
      tx_k_data <= x"F";       
    elsif clk_txrx'event and clk_txrx = '1' then  -- rising clock edge  
      case local_mode is    
        when x"0"  => 
          tx_data <= rx_data;  
          tx_k_data <= rx_k_data;       
        when x"1" =>  
          tx_data <= x"BCBCBCBC";       
          tx_k_data <= x"F";   
        when x"2" =>  
          tx_data <= local_fixed_send_d;      
          tx_k_data <= local_fixed_send_k;    
        when others =>
          tx_data <= x"BCBCBCBC";       
          tx_k_data <= x"F";   
      end case;       
    end if;  
  end process data_proc;    

end architecture Behavioral;
