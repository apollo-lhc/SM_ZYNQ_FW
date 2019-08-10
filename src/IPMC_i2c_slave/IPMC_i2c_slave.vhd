library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;

entity IPMC_i2c_slave is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO;

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
  
  --------------------------------------
  -- AXI bridge signals
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  
  --------------------------------------
  -- I2c Slave signals
  signal master_i2c_data : slv_8_t;
  signal master_i2c_dv : std_logic;
  signal slave_i2c_data : slv_8_t;
  signal i2c_address : std_logic_vector(log2(4*REG32_COUNT)-1 downto 0);
  signal reset : std_logic;
  signal SDA_en : std_logic;

  
  signal enB : std_logic;
  signal reg_data :  slv32_array_t(integer range 0 to REG32_COUNT-1);
  constant Default_reg_data : slv32_array_t(integer range 0 to REG32_COUNT-1) :=
    (0 => x"00000003",
     4 => x"00000001",
     5 => x"00001010",
     8 => x"00000000",
     others => x"00000000");
  
  
  
begin  -- architecture behavioral

  reset <= not reset_axi_n;
  SDA_t <= not SDA_en;
  i2c_slave_1: entity work.i2c_slave
    generic map (
      REGISTER_COUNT_BIT_SIZE => log2(4*REG32_COUNT),
      TIMEOUT_COUNT  =>  x"00100000")
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
      data_in          => x"a5",--slave_i2c_data,
      register_address => i2c_address);
  
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

  enB <= localRdReq or localWrEn;
  asym_ram_tdp_1: entity work.asym_ram_tdp
    generic map (
      WIDTHB     => 32,
      SIZEB      => REG32_COUNT,
      ADDRWIDTHB => log2(REG32_COUNT),
      WIDTHA     => 8,
      SIZEA      => 4*REG32_COUNT,
      ADDRWIDTHA => log2(4*REG32_COUNT))
    port map (
      clkA  => clk_axi,
      clkB  => clk_axi,
      enB   => enB,
      enA   => '1',
      weB   => localWrEn,
      weA   => master_i2c_dv,
      addrB => localAddress(3 downto 0),
      addrA => i2c_address,
      diB   => localWrData,
      diA   => master_i2c_data,
      doB   => localRdData,
      doA   => slave_i2c_data);

  

  

  
end architecture behavioral;
