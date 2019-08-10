library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
Library UNISIM;
use UNISIM.vcomponents.all;


entity uart is
  
  generic (
    --BAUD_COUNT is found by taking clk_freq/(16*baud_rate)
    --  It is up to you to make sure this value is close enough to the desired
    --  baud rate
    BAUD_COUNT : integer);

  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    tx              : out std_logic;
    rx              : in  std_logic;

    write_data      : in  slv_8_t;
    write_en        : in  std_logic;
    write_half_full : out std_logic;
    write_full      : out std_logic;

    read_data       : out slv_8_t;
    read_en         : in  std_logic;
    read_available  : out std_logic;
    read_half_full  : out std_logic;
    read_full       : out std_logic
    
    );

end entity uart;

architecture behavioral of uart is
  function log2 (val: INTEGER) return natural is
    variable res : natural;
  begin
    for i in 0 to 31 loop
      if (val <= (2**i)) then
        res := i;
        exit;
      end if;
    end loop;
    return res;
  end function Log2;

  signal en_16_x_baud : std_logic;
  signal baud_counter : unsigned(log2(BAUD_COUNT) downto 0);
  constant baud_counter_end : unsigned(log2(BAUD_COUNT) downto 0) := to_unsigned(BAUD_COUNT,baud_counter'length);

begin  -- architecture behavioral

  baud_counter_proc: process (clk) is
  begin  -- process baud_counter
    if clk'event and clk = '1' then  -- rising clock edge
      en_16_x_baud <= '0';
      if baud_counter = baud_counter_end then
        baud_counter <= (others => '0');
        en_16_x_baud <= '1';
      else
        baud_counter <= baud_counter + 1;  
      end if;
      
    end if;
  end process baud_counter_proc;

  uart_tx6_1: entity work.uart_tx6
    port map (
      data_in             => write_data,
      en_16_x_baud        => en_16_x_baud,
      serial_out          => tx,
      buffer_write        => write_en,
      buffer_data_present => open,
      buffer_half_full    => write_half_full,
      buffer_full         => write_full,
      buffer_reset        => reset,
      clk                 => clk);


  uart_rx6_1: entity work.uart_rx6
    port map (
      serial_in           => rx,
      en_16_x_baud        => en_16_x_baud,
      data_out            => read_data,
      buffer_read         => read_en,
      buffer_data_present => read_available,
      buffer_half_full    => read_half_full,
      buffer_full         => read_full,
      buffer_reset        => reset,
      clk                 => clk);
  
end architecture behavioral;
