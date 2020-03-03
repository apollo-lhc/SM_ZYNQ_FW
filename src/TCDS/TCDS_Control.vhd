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
    tx_data      : out slv_32_t;
    tx_k_data    : out slv_4_t;
    rx_data      : in  slv_32_t;
    rx_k_data    : in  slv_4_t);

end entity TCDS_Control;


architecture Behavioral of TCDS_Control is

  signal reset : std_logic;
  signal capture_data : std_logic;

  signal tx_data_fixed : slv_32_t;
  signal tx_k_data_fixed : slv_4_t;
begin  -- architecture Behavioral

  reset <= not axi_reset_n;
  
  capture_d <= rx_data;
  capture_k <= rx_k_data;
  
  data_proc: process (clk_axi, reset) is      
  begin  -- process data_proc  
    if reset = '1' then      -- asynchronous reset (active high)   
      tx_data <= x"BCBCBCBC";  
      tx_k_data <= x"F";       
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge  
      case mode is    
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
