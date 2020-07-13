library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.AXIRegPkg.all;

use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity IPMC_i2c_slave is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO;

    linux_booted    : out std_logic;
    
    SDA_o           : out std_logic;
    SDA_t           : out std_logic;
    SDA_i           : in  std_logic;
    SCL             : in  std_logic
    );
end entity IPMC_i2c_slave;

architecture behavioral of IPMC_i2c_slave is

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

  
  --------------------------------------
  -- register map size
  constant REG32_COUNT : integer := 16;  
  constant SLAVE_COUNT : integer := 8;
  
  --------------------------------------
  -- AXI bridge signals
  signal localAddress : slv_32_t;
  signal localAddress_latch : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrData_latch  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  
  --------------------------------------
  -- I2c Slave signals
  signal master_i2c_data : slv_8_t;
  signal master_i2c_dv : std_logic;
  signal slave_i2c_data : slv_8_t;
  signal slave_i2c_data_filtered : slv_8_t;
  signal i2c_address : std_logic_vector(log2(4*REG32_COUNT*SLAVE_COUNT)-1 downto 0);
  signal reset : std_logic;
  signal SDA_en : std_logic;

  signal clk_b : std_logic;  
  signal enB : std_logic;
 
  ---------------------------------------
  -- heart-beat
  signal last_localAddress : slv_32_t;
  signal heart_beat : std_logic;
  signal PS_is_shutdown : std_logic;
  constant I2C_SHUTDOWN_REG : std_logic_vector(log2(4*REG32_COUNT*SLAVE_COUNT)-1 downto 0) := (others => '0');-- reg 0
  constant I2C_SHUTDOWN_BIT : integer := 5;
  
  
begin  -- architecture behavioral
      
  reset <= not reset_axi_n;
  SDA_t <= not SDA_en;
  i2c_slave_1: entity work.i2c_slave
    generic map (
      REGISTER_COUNT_BIT_SIZE => log2(4*REG32_COUNT),
      TIMEOUT_COUNT  =>  x"00100000",
      I2C_ADDR_WILDCARD_BITS => log2(SLAVE_COUNT))
    port map (
      reset            => reset,
      clk              => clk_axi,
      SDA_in           => SDA_i,
      SDA_out          => SDA_o,
      SDA_en           => SDA_en,
      SCL              => SCL,
      address          => "1100000",
      data_out         => master_i2c_data,
      data_out_dv      => master_i2c_dv,
      data_in          => slave_i2c_data_filtered,
      register_address => i2c_address);

  --Filter shutdown reg/bit to allow a PS heartbeat
  i2c_shutdown_filter: process (slave_i2c_data,PS_is_shutdown,i2c_address) is
  begin  -- process i2c_shutdown_filter
    slave_i2c_data_filtered <= slave_i2c_data;
    if (PS_is_shutdown = '1' and i2c_address = I2C_SHUTDOWN_REG) then
      slave_i2c_data_filtered(I2C_SHUTDOWN_BIT) <= '1';
    end if;
  end process i2c_shutdown_filter;
  
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      address     => localAddress,
      rd_data     => localRdData,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);
  AXIRegProc: process (clk_axi, reset_axi_n) is
  begin  -- process AXIRegProc
    if reset_axi_n = '0' then           -- asynchronous reset (active high)
      localRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= localRdReq;      
    end if;
  end process AXIRegProc;

  clk_b <= not clk_axi;
  enB <= not or_reduce(localAddress(15 downto log2(REG32_COUNT*SLAVE_COUNT)));
  asym_ram_tdp_1: entity work.asym_ram_tdp
    generic map (
      WIDTHB     => 32,
      SIZEB      => REG32_COUNT*SLAVE_COUNT,
      ADDRWIDTHB => log2(REG32_COUNT*SLAVE_COUNT),
      WIDTHA     => 8,
      SIZEA      => SLAVE_COUNT*4*REG32_COUNT,
      ADDRWIDTHA => log2(SLAVE_COUNT*4*REG32_COUNT))
    port map (
      clkA  => clk_axi,
      clkB  => clk_b,
      enB   => '1',
      enA   => '1',
      weB   => localWrEn,
      weA   => master_i2c_dv,
      addrB => localAddress(log2(REG32_COUNT*SLAVE_COUNT)-1 downto 0),
      addrA => i2c_address,
      diB   => localWrData,
      diA   => master_i2c_data,
      doB   => localRdData,
      doA   => slave_i2c_data);

  --a heartbeat is any read or write to an address out of the range of the i2c
  --registers
  hb_proc: process (clk_axi) is
  begin  -- process hb_proc
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge 
      heart_beat <= '0';
      last_localAddress <= localAddress;
      if (localAddress(11 downto 0) /= x"7FF" and
          last_localAddress(11 downto 0) = x"7FF") then
        heart_beat <= '1';
      end if;
    end if;
  end process hb_proc;

  linux_booted <= not PS_is_shutdown;
  
  counter_1: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"1DCD6500",
      start_value => x"00000000",
      A_RST_CNT   => x"1DCD6500",
      DATA_WIDTH  => 32)
    port map (
      clk         => clk_axi,
      reset_async => reset,
      reset_sync  => heart_beat,
      enable      => '1',
      event       => '1',
      count       => open,
      at_max      => PS_is_shutdown);
  

  
end architecture behavioral;
