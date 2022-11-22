library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.types.all;

use work.AXIRegPkg.all;

library unisim;
use unisim.vcomponents.all;


entity tb_IPMC_i2c_slave is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_IPMC_i2c_slave;

architecture behavioral of tb_IPMC_i2c_slave is
  signal counter : integer;

  signal reset_axi_n : std_logic;

  signal readMOSI        : AXIReadMOSI := DefaultAXIReadMOSI;
  signal readMISO        : AXIReadMISO;
  signal writeMOSI       : AXIWriteMOSI := DefaultAXIWriteMOSI;
  signal writeMISO       : AXIWriteMISO;

  signal SDA_o           : std_logic;
  signal SDA_t           : std_logic;
  signal SDA_i           : std_logic;

  signal SCL             : std_logic;

  component I2C_reg_master is
    generic (
      I2C_QUARTER_PERIOD_CLOCK_COUNT : integer;
      IGNORE_ACK                     : std_logic;
      REG_ADDR_BYTE_COUNT            : integer;
      USE_RESTART_FOR_READ_SEQUENCE  : std_logic);
    port (
      clk_sys     : in    std_logic;
      reset       : in    std_logic;
      I2C_Address : in    std_logic_vector(6 downto 0);
      run         : in    std_logic;
      rw          : in    std_logic;
      reg_addr    : in    std_logic_vector((REG_ADDR_BYTE_COUNT*8) -1 downto 0);
      rd_data     : out   std_logic_vector(31 downto 0);
      wr_data     : in    std_logic_vector(31 downto 0);
      byte_count  : in    std_logic_vector(2 downto 0);
      done        : out   std_logic := '0';
      error       : out   std_logic;
      SDA_t       : out std_logic;
      SDA_o       : out std_logic;
      SDA_i       : in std_logic;
      SCLK        : out std_logic);
  end component I2C_reg_master;


  signal run         :  std_logic;
  signal rw          :  std_logic; --0 write 1 read
  signal reg_addr    :  std_logic_vector((1*8) -1 downto 0);
  signal rd_data     :  std_logic_vector(31 downto 0);
  signal wr_data     :  std_logic_vector(31 downto 0);
  signal SDA_m_o           : std_logic;
  signal SDA_m_t           : std_logic;
  signal SDA_m_i           : std_logic;
  signal done  : std_logic;
  signal i2c_addr : std_logic_vector(6 downto 0);
  
begin  -- architecture behavioral

  I2C_reg_master_1: entity work.I2C_reg_master
    generic map (
      I2C_QUARTER_PERIOD_CLOCK_COUNT => 2,
      IGNORE_ACK                     => '0',
      REG_ADDR_BYTE_COUNT            => 1,
      USE_RESTART_FOR_READ_SEQUENCE  => '0')
    port map (
      clk_sys     => clk,
      reset       => reset,
      I2C_Address => i2c_addr,
      run         => run,
      rw          => rw,
      reg_addr    => reg_addr,
      rd_data     => rd_data,
      wr_data     => wr_data,
      byte_count  => "100",
      done        => done,
      error       => open,
      SDA_t       => SDA_m_t,
      SDA_o       => SDA_m_o,
      SDA_i       => SDA_m_i,
      SCLK        => SCL);
  

  -- purpose: SD
  -- type   : combinational
  -- inputs : SDA_t
  -- outputs: 
  sda_proc: process (SDA_t,SDA_o,SDA_i,SDA_m_o,SDA_m_i,SDA_m_t) is
  begin  -- process sda_proc
    if SDA_t = '0' and SDA_m_t = '0' then
      SDA_i <= SDA_m_o and SDA_o;
      SDA_m_i <= SDA_m_o and SDA_o;
    elsif SDA_t = '0' then
      SDA_i <= SDA_o;      
      SDA_m_i <= SDA_o;
    elsif SDA_m_t = '0' then
      SDA_i <= SDA_m_o;
      SDA_m_i <= SDA_m_o;      
    else
      SDA_i <= '1';
      SDA_m_i <= '1';        
    end if;
    
  end process sda_proc;
  
--  sda_buf :  IOBUF
--    port map (
--      T  => SDA_t,
--      I  => SDA_o,
--      O  => SDA_i,
--      IO => SDA_m);
  
  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      reset_axi_n <= '0';
--      SDA_i <= '1';
      counter <= 0;
      run <= '0';
      rw <= '0';
      wr_data <= x"00000000";
      reg_addr <= x"00";
      i2c_addr <= "0000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;
      readMOSI.address_valid <= '0';
      writeMOSI.address_valid <= '0';
      writeMOSI.data_valid <= '0';

      run <= '0';
      case counter is
        when 10 =>
          reset_axi_n <= '1';

        -- Write 1 32bit word via i2c at slave 0 reg32_addr 1
        when 100 =>
          i2c_addr <= "1100000";
          reg_addr <= x"04";
          wr_data <= x"12345678";
          run <= '1';
          rw <= '0';

        -- read 1 32bit word via i2c at slave 0 reg32_addr 1
        when 1100 =>
          i2c_addr <= "1100000";
          reg_addr <= x"04";
          run <= '1';
          rw <= '1';
        -- read 1 32bit word via i2c at invaid address 0x78
        when 3100 =>
          i2c_addr <= "1111000";
          reg_addr <= x"04";
          run <= '1';
          rw <= '1';

        -- read register 1 from slave 0 via AXI
        when 4000 =>
          readMOSI.address <= x"00000004";
          readMOSI.address_valid <= '1';
          readMOSI.ready_for_data <= '1';
        -- write register 3 of slave 0 via AXI
        when 4200 =>
          writeMOSI.address <= x"0000000c";
          writeMOSI.address_valid <= '1';
          writeMOSI.ready_for_response <= '1';
        -- read register 3 from slave 0 via AXI
        when 4202 =>
          writeMOSI.data    <= x"deadbeef";
          writeMOSI.data_valid <= '1';
        when 4400 =>
          readMOSI.address <= x"0000000c";
          readMOSI.address_valid <= '1';
          readMOSI.ready_for_data <= '1';


        -- Write 32bit word via i2c at slave 0 invalid register 17
        -- Should update register 1  
        when 5000 =>
          i2c_addr <= "1100000";
          reg_addr <= x"44";
          wr_data <= x"a5a5a5a5";
          run <= '1';
          rw <= '0';
        when 6000 =>
          i2c_addr <= "1100000";
          reg_addr <= x"04";
          run <= '1';
          rw <= '1';

        -- Write 32bit word via i2c at slave 1 invalid register 0
        when 8000 =>
          i2c_addr <= "1100001";
          reg_addr <= x"00";
          wr_data <= x"aaaaaaaa";
          run <= '1';
          rw <= '0';
        when 9000 =>
          i2c_addr <= "1100001";
          reg_addr <= x"00";
          run <= '1';
          rw <= '1';

        -- read register 1 from slave 0 via AXI
        when 11000 =>
          readMOSI.address <= x"00000004";
          readMOSI.address_valid <= '1';
          readMOSI.ready_for_data <= '1';
        -- read register 0 from slave 1 via AXI
        when 11100 =>
          readMOSI.address <= x"00000020";
          readMOSI.address_valid <= '1';
          readMOSI.ready_for_data <= '1';

          
        when others => null;
      end case;
    end if;
  end process tb;

  IPMC_i2c_slave_1: entity work.IPMC_i2c_slave
    port map (
      clk_axi     => clk,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      SDA_o       => SDA_o,
      SDA_t       => SDA_t,
      SDA_i       => SDA_i,
      SCL         => SCL);
  
end architecture behavioral;
