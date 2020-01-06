library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

use work.types.all;
use work.axiRegPkg.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity tb_cm_monitor is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_cm_monitor;

architecture behavioral of tb_cm_monitor is
  signal counter : integer;

  signal local_reset : std_logic;
  signal reset_axi_n  : std_logic;
  signal readMOSI     : AXIreadMOSI;
  signal readMISO     : AXIreadMISO;
  signal writeMOSI    : AXIwriteMOSI;
  signal writeMISO    : AXIwriteMISO;

  constant baud_16x_count : slv_8_t := slv_8_t(to_unsigned(23,8));
  signal baud_counter : unsigned(7 downto 0);
  signal en_16_x_baud : std_logic;
  signal serial_data : std_logic;
  signal data_in : std_logic_vector(7 downto 0);
  signal buffer_write : std_logic;   
  signal  uart_data_present : std_logic;
  
  signal message : slv_24_t;

  signal channel_active : std_logic;
  signal error_count : slv_16_t;

  signal debug_history   : slv_32_t;
  signal debug_valid     : slv_4_t;

begin  -- architecture behavioral

  tb: process (clk, reset) is
  file out_file_status : text is out "tb_out.txt";
  variable test_result       : line;  

   
  begin  -- process tb
  
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      reset_axi_n <= '0';
      local_reset <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
      buffer_write <= '0';
      case counter is
        when 10 =>
          reset_axi_n <= '1';
          local_reset <= '0';

        when 100000 =>
          message <= x"01ABAD";
        when 100001 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 104000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 108000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 112000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';
          
        when 200000 =>
          message <= x"00CAFE";
        when 200001 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 204000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 208000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 212000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';


        when 300000 =>
          message <= x"04DEAD";
        when 300001 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 304000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 308000 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 312000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';

        when 400000 =>
          message <= x"07ABAD";
        when 400001 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 404000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 408000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 412000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';

        when 500000 =>
          message <= x"07ABAD";

        when 500001 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 504000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 508000 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 512000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';


        when 600000 =>
          message <= x"FFCAFE";
        when 600001 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 604000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 608000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 612000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';

        when 700000 =>
          message <= x"72CAFE";
        when 700001 =>
          data_in(7 downto 6) <= "10";
          data_in(5 downto 0) <= message(23 downto 18);
          buffer_write <= '1';
        when 704000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(17 downto 12);
          buffer_write <= '1';
        when 708000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message(11 downto  6);
          buffer_write <= '1';
        when 712000 =>
          data_in(7 downto 6) <= "00";
          data_in(5 downto 0) <= message( 5 downto  0);
          buffer_write <= '1';

          
        when others => null;
      end case;

      hwrite(test_result,slv_32_t(to_unsigned(counter,32)),right,1);
      hwrite(test_result,error_count,right,1);
      write(test_result,channel_active,right,1);
      
      hwrite(test_result,readMOSI.address,right,1);
      write(test_result,readMOSI.address_valid,right,1);
      write(test_result,readMOSI.ready_for_data,right,1);
      
      write(test_result,readMISO.ready_for_address,right,1);
      hwrite(test_result,readMISO.data,right,1);
      write(test_result,readMISO.data_valid,right,1);
      
      hwrite(test_result,writeMOSI.address,right,1);
      write(test_result,writeMOSI.address_valid,right,1);
      hwrite(test_result,writeMOSI.data,right,1);
      write(test_result,writeMOSI.data_valid,right,1);
      hwrite(test_result,writeMOSI.data_write_strobe,right,1);
      
      write(test_result,writeMISO.ready_for_address,right,1);
      write(test_result,writeMISO.ready_for_data,right,1);
      write(test_result,writeMISO.response_valid,right,1);

      hwrite(test_result,debug_history,right,1);
      hwrite(test_result,debug_valid  ,right,1);

      writeline(out_file_status,test_result);
    end if;
  end process tb;

  baud_counter_proc: process (clk, local_reset) is
  begin  -- process baud_counter_proc
    if local_reset = '1' then                 -- asynchronous reset (active high)
      en_16_x_baud <= '0';
      baud_counter <= x"00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if baud_counter = x"00" then
        baud_counter <= unsigned(baud_16x_count);
        en_16_x_baud <= '1';
      else
        en_16_x_baud <= '0';
        baud_counter <= baud_counter - 1;
      end if;
    end if;
  end process baud_counter_proc;

  uart_tx6_1: entity work.uart_tx6
    port map (
      data_in             => data_in,
      en_16_x_baud        => en_16_x_baud,
      serial_out          => serial_data,
      buffer_write        => buffer_write,
      buffer_data_present => uart_data_present,
      buffer_half_full    => open,
      buffer_full         => open,
      buffer_reset        => local_reset,
      clk                 => clk);

  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS => 8,
      INACTIVE_COUNT => x"0004FFFF")
    port map (
      clk            => clk,
      reset          => local_reset,
      uart_rx        => serial_data,
      baud_16x_count => baud_16x_count,
      readMOSI       => readMOSI,
      readMISO       => readMISO,
      writeMOSI      => writeMOSI,
      writeMISO      => writeMISO,
      debug_history  => debug_history,
      debug_valid    => debug_valid,
      error_count    => error_count,
      channel_active => channel_active);

  IPMC_i2c_slave_1: entity work.IPMC_i2c_slave
    port map (
      clk_axi      => clk,
      reset_axi_n  => reset_axi_n,
      readMOSI     => readMOSI,
      readMISO     => readMISO,
      writeMOSI    => writeMOSI,
      writeMISO    => writeMISO,
      linux_booted => open,
      SDA_o        => open,
      SDA_t        => open,
      SDA_i        => '1',
      SCL          => '1');
end architecture behavioral;
