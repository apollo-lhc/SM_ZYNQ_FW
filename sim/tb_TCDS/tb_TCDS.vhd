library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

use work.types.all;
use work.axiRegPkg.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity tb_TCDS is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_TCDS;

architecture behavioral of tb_TCDS is
  signal counter : integer;

  signal local_reset : std_logic;
  signal readMOSI     : AXIreadMOSI       := DefaultAXIReadMOSI;
  signal readMISO     : AXIreadMISO;
  signal writeMOSI    : AXIwriteMOSI      := DefaultAXIWriteMOSI;
  signal writeMISO    : AXIwriteMISO;

  signal DRP_readMOSI     : AXIreadMOSI   := DefaultAXIReadMOSI;
  signal DRP_readMISO     : AXIreadMISO;
  signal DRP_writeMOSI    : AXIwriteMOSI  := DefaultAXIWriteMOSI;
  signal DRP_writeMISO    : AXIwriteMISO;


  signal clk_axi              :  std_logic;
  signal reset_axi_n          :  std_logic;
  signal tx_P                 :  std_logic_vector(2 downto 0);
  signal tx_N                 :  std_logic_vector(2 downto 0);
  signal rx_P                 :  std_logic_vector(2 downto 0);
  signal rx_N                 :  std_logic_vector(2 downto 0);


  signal busy              : std_logic;
  signal address           : slv_32_t;
  signal rd_en             : std_logic;
  signal rd_data           : slv_32_t;
  signal rd_data_valid     : std_logic;
  signal wr_data           : slv_32_t;
  signal wr_en             : std_logic;


  
begin  -- architecture behavioral

  clk_axi <= clk;
  tb: process (clk, reset) is
  file out_file_status : text is out "tb_out.txt";
  variable test_result       : line;  

  begin  -- process tb
  
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      reset_axi_n <= '0';
      local_reset <= '1';
      address     <= x"00000000";
      rd_en       <= '0'; 
      wr_data     <= x"00000000";
      wr_en       <= '0';
        
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
      rd_en <= '0';
      wr_en <= '0';
      case counter is
        when 10 =>
          reset_axi_n <= '1';
          local_reset <= '0';
        when 100 =>
          address <= x"00000008";
          rd_en <= '1';
        when 300 =>
          wr_data <= x"abadcafe";
          wr_en   <= '1';
        when 600 =>
          rd_en <= '1';
        when others => null;
      end case;

      hwrite(test_result,slv_32_t(to_unsigned(counter,32)),right,1);
      
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


      writeline(out_file_status,test_result);
    end if;
  end process tb;

  axiLiteMaster_1: entity work.axiLiteMaster
    port map (
      clk_axi       => clk_axi,
      reset_axi_n   => reset_axi_n,
      readMOSI      => readMOSI,
      readMISO      => readMISO,
      writeMOSI     => writeMOSI,
      writeMISO     => writeMISO,
      busy          => busy,
      address       => address,
      rd_en         => rd_en,
      rd_data       => rd_data,
      rd_data_valid => rd_data_valid,
      wr_data       => wr_data,
      wr_en         => wr_en);

  TCDS_1: entity work.TCDS
    port map (
      clk_axi          => clk_axi,
      reset_axi_n      => reset_axi_n,
      clk_axi_DRP      => clk_axi,
      reset_axi_DRP_n  => reset_axi_n,
      readMOSI         => readMOSI,
      readMISO         => readMISO,
      writeMOSI        => writeMOSI,
      writeMISO        => writeMISO,
      DRP_readMOSI     => DRP_readMOSI,
      DRP_readMISO     => DRP_readMISO,
      DRP_writeMOSI    => DRP_writeMOSI,
      DRP_writeMISO    => DRP_writeMISO,
      refclk_p         => '1',
      refclk_n         => '0',
      QPLL_CLK         => '0',
      QPLL_REF_CLK     => '0',
      clk_TCDS         => open,
      clk_TCDS_reset_n => open,
      tx_P             => tx_P,
      tx_N             => tx_N,
      rx_P             => rx_P,
      rx_N             => rx_N);


end architecture behavioral;
