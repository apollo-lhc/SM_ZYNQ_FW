library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity CM_Monitoring is
  generic (
    BAUD_COUNT_BITS : integer := 8);
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    uart_rx         : in  std_logic;
    baud_16x_count  : in std_logic_vector(BAUD_COUNT_BITS-1 downto 0);
    channel_active  : out std_logic;
    monitoring_data : out std_logic_vector(31 downto 0));

end entity CM_Monitoring;

architecture behavioral of CM_Monitoring is

  signal en_16_x_baud : std_logic;
  signal baud_counter : unsigned(BAUD_COUNT_BITS-1 downto 0);
  signal baud_counter_end : unsigned(BAUD_COUNT_BITS-1 downto 0);
 

begin  -- architecture behavioral

  
  Mon_SM: process (clk, reset) is
  begin  -- process Mon_SM_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      state <= SM_RESET;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when SM_RESET =>
          state <= SM_WAIT_FOR_SOF;
        when SM_WAIT_FOR_SOF =>
          if buffer_data_present = '1' and data_out = SOF_WORD then
            state <= SM_WAIT_FOR_ID;
          end if;
        when SM_WAIT_FOR_ID =>
          if buffer_data_present = '1' then
            state <= SM_WAIT_FOR_DATA1;
          end if;
        when SM_WAIT_FOR_DATA1 =>
          if buffer_data_present = '1' then
            state <= SM_WAIT_FOR_DATA2;
          end if;
        when SM_WAIT_FOR_DATA2 =>
          if buffer_data_present = '1' then
            state <= SM_WAIT_FOR_SOF;
          end if;
        when SM_ERROR =>
          state <= SM_RESET;
        when others =>
          state <=SM_ERROR;
      end case;
    end if;
  end process Mon_SM;


  Mon_SM_proc: process (clk, reset) is
  begin  -- process Mon_SM_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      buffer_read <= '0';
      case state is
        when SM_RESET =>
          reset_timer <= '1';
        when SM_WAIT_FOR_SOF =>
          if buffer_data_present = '1' then
            buffer_read <= '1';
            
          end if;
        when others => null;
      end case;
    end if;
  end process Mon_SM_proc;

  
  baud_counter_end <= unsigned(baud_16x_count);  
  uart_baud_16x_en_proc: process (clk) is
  begin  -- process uart_baud_16x_en_proc
    if clk'event and clk = '1' then  -- rising clock edge
      en_16_x_baud <= '0';
      if baud_counter = baud_counter_end then
        baud_counter <= (others => '0');
        en_16_x_baud <= '1';
      else
        baud_counter <= baud_counter + 1;  
      end if;
    end if;
  end process uart_baud_16x_en_proc;
  uart_rx6_1: entity work.uart_rx6
    port map (
      serial_in           => uart_rx,
      en_16_x_baud        => en_16_x_baud,
      data_out            => data_out,
      buffer_read         => buffer_read,
      buffer_data_present => buffer_data_present,
      buffer_half_full    => buffer_half_full,
      buffer_full         => buffer_full,
      buffer_reset        => buffer_reset,
      clk                 => clk);
  
end architecture behavioral;
