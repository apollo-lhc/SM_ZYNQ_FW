library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

use work.types.all;
use work.axiRegPkg.all;


entity tb_axi_helpers is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_axi_helpers;

architecture behavioral of tb_axi_helpers is
  signal counter : integer;

  signal reset_axi_n  : std_logic;
  signal readMOSI     : AXIreadMOSI;
  signal readMISO     : AXIreadMISO;
  signal writeMOSI    : AXIwriteMOSI;
  signal writeMISO    : AXIwriteMISO;

  
  signal slave_address      : slv_32_t;
  signal slave_wr_data      : slv_32_t;
  signal slave_rd_data      : slv_32_t;
  signal slave_write_en     : std_logic;
  signal slave_read_req     : std_logic;
  signal slave_read_ack     : std_logic;
  
  signal master_address       : slv_32_t;
  signal master_rd_en         : std_logic;
  signal master_rd_data       : slv_32_t;
  signal master_rd_data_valid : std_logic;
  signal master_wr_data       : slv_32_t;
  signal master_wr_en         : std_logic;

  signal slave_registers : slv32_array_t(0 to 7) := (x"1FAAFF00",
                                                     x"F055FE01",
                                                     x"1FAAFD02",
                                                     x"F055FC03",
                                                     x"1FAAFB04",
                                                     x"F055FA05",
                                                     x"1FAAF906",
                                                     x"F055F807");


begin  -- architecture behavioral

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
        when 100 =>
          master_address <= x"00000000";
          master_rd_en   <= '1';
        when 150 =>
          master_address <= x"00000000";
          master_wr_data  <= x"badc0ffe";
          master_wr_en   <= '1';
        when 175 =>
          master_address <= x"00000000";
          master_rd_en   <= '1';
        when 200 =>
          master_address <= x"00000004";
          master_rd_en   <= '1';
        when 250 =>
          master_address <= x"00000004";
          master_wr_data  <= x"abadcafe";
          master_wr_en   <= '1';
        when 275 =>
          master_address <= x"00000004";
          master_rd_en   <= '1';
        when 300 =>
          master_address <= x"00000008";
          master_rd_en   <= '1';
        when 350 =>
          master_address <= x"00000008";
          master_wr_data  <= x"deadbeef";
          master_wr_en   <= '1';
        when 375 =>
          master_address <= x"00000008";
          master_rd_en   <= '1';

        when 400 =>
          master_address <= x"00000000";
          master_wr_data  <= x"badc0ffe";
          master_wr_en   <= '1';
          master_address <= x"00000008";
          master_rd_en   <= '1';

        when 450 =>
          master_address <= x"00000000";
          master_wr_data  <= x"badc0ffe";
          master_wr_en   <= '1';
        when 451 =>
          master_address <= x"00000008";
          master_rd_en   <= '1';

        when 500 =>
          master_address <= x"00000000";
          master_wr_data  <= x"badc0ffe";
          master_wr_en   <= '1';
        when 502 =>
          master_address <= x"00000008";
          master_rd_en   <= '1';

        when others => null;
      end case;

--      write(test_result,slave_address ,right,slave_address'length);
      write(test_result,slave_address );       
      write(test_result,slave_wr_data );
      write(test_result,slave_rd_data );
      write(test_result,slave_write_en);
      write(test_result,slave_read_req);
      write(test_result,slave_read_ack);

      write(test_result,master_address      );
      write(test_result,master_rd_en        );
      write(test_result,master_rd_data      );
      write(test_result,master_rd_data_valid);
      write(test_result,master_wr_data      );
      write(test_result,master_wr_en        );

      writeline(out_file_status,test_result);
    end if;
  end process tb;

  

  slave_ack: process (clk, reset) is
  begin  -- process slave_ack
    if reset = '1' then                 -- asynchronous reset (active high)
       slave_read_ack <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      slave_read_ack <= slave_read_req;
      if slave_write_en = '1' then
        slave_registers(to_integer(unsigned(slave_address(2 downto 0)))) <= slave_wr_data;
      end if;
    end if;
  end process slave_ack;
  slave_rd_data <= slave_registers(to_integer(unsigned(slave_address(2 downto 0))));
  
  axiLiteReg_1: entity work.axiLiteReg
    port map (
      clk_axi     => clk,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      address     => slave_address,
      rd_data     => slave_rd_data,
      wr_data     => slave_wr_data,
      write_en    => slave_write_en,
      read_req    => slave_read_req,
      read_ack    => slave_read_ack);

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

  
  
end architecture behavioral;
