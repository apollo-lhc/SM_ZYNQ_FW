library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

use work.types.all;
use work.axiRegPkg.all;



entity tb_bram_regmap is

--    clk     : in std_logic;
--    reset   : in std_logic);

end entity tb_bram_regmap;

architecture behavioral of tb_bram_regmap is
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal counter : integer;

  signal reset_axi_n  : std_logic;
  signal readMOSI     : AXIreadMOSI;
  signal readMISO     : AXIreadMISO;
  signal writeMOSI    : AXIwriteMOSI;
  signal writeMISO    : AXIwriteMISO;
  
  signal master_address       : slv_32_t;
  signal master_rd_en         : std_logic;
  signal master_rd_data       : slv_32_t;
  signal master_rd_data_valid : std_logic;
  signal master_wr_data       : slv_32_t;
  signal master_wr_en         : std_logic;

begin  -- architecture behavioral

  clk <= not clk after 10 ns;
  reset <= '0' after 100 ns;
  
  tb: process (clk, reset) is
  file out_file_status : text is out "tb_out.txt";
  variable test_result       : line;  
    
  begin  -- process tb
  
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      reset_axi_n <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;

      master_rd_en    <= '0';
      master_wr_en <= '0';
      
      case counter is
        when 10 =>
          reset_axi_n <= '1';
--        when 100 =>
--          master_address <= x"00000000";
--          master_rd_en   <= '1';
--        when 150 =>
--          master_address <= x"00000000";
--          master_wr_data  <= x"badc0ffe";
--          master_wr_en   <= '1';
--        when 175 =>
--          master_address <= x"00000000";
--          master_rd_en   <= '1';
        when 200 =>
          master_address <= x"00000004";
          master_rd_en   <= '1';
--        when 250 =>
--          master_address <= x"00000004";
--          master_wr_data  <= x"abadcafe";
--          master_wr_en   <= '1';
--        when 275 =>
--          master_address <= x"00000004";
--          master_rd_en   <= '1';
--        when 300 =>
--          master_address <= x"00000008";
--          master_rd_en   <= '1';
--        when 350 =>
--          master_address <= x"00000008";
--          master_wr_data  <= x"deadbeef";
--          master_wr_en   <= '1';
        when 375 =>
          master_address <= x"00000400";
          master_rd_en   <= '1';

        when 400 =>
          master_address <= x"00000408";
          master_wr_data  <= x"badc0ffe";
          master_wr_en   <= '1';

        when 425 =>
          master_address <= x"00000408";
          master_rd_en   <= '1';

--        when 450 =>
--          master_address <= x"00000000";
--          master_wr_data  <= x"badc0ffe";
--          master_wr_en   <= '1';
--        when 451 =>
--          master_address <= x"00000008";
--          master_rd_en   <= '1';
--
--        when 500 =>
--          master_address <= x"00000000";
--          master_wr_data  <= x"badc0ffe";
--          master_wr_en   <= '1';
--        when 502 =>
--          master_address <= x"00000008";
--          master_rd_en   <= '1';

        when others => null;
      end case;

--      write(test_result,slave_address ,right,slave_address'length);

      write(test_result,master_address      );
      write(test_result,master_rd_en        );
      write(test_result,master_rd_data      );
      write(test_result,master_rd_data_valid);
      write(test_result,master_wr_data      );
      write(test_result,master_wr_en        );

      writeline(out_file_status,test_result);
    end if;
  end process tb;

  

  axiLiteMaster_1: entity work.axiLiteMaster
    port map (
      clk_axi       => clk,
      reset_axi_n   => reset_axi_n,
      readMOSI      => readMOSI,
      readMISO      => readMISO,
      writeMOSI     => writeMOSI,
      writeMISO     => writeMISO,
      address       => master_address,
      rd_en         => master_rd_en,
      rd_data       => master_rd_data,
      rd_data_valid => master_rd_data_valid,
      wr_data       => master_wr_data,
      wr_en         => master_wr_en);

  mem_test_1: entity work.mem_test
    port map (
      clk_axi     => clk,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO);
  
end architecture behavioral;
