--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.FW_INFO_Ctrl.all;
entity FW_INFO_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  FW_INFO_Mon_t;
    Ctrl             : out FW_INFO_Ctrl_t
    );
end entity FW_INFO_interface;
architecture behavioral of FW_INFO_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 17);
  constant Default_reg_data : slv32_array_t(integer range 0 to 17) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case to_integer(unsigned(localAddress(4 downto 0))) is
        when 0 => --0x0
          localRdData( 1)            <=  Mon.GIT_VALID;                   --
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_1;                  --
        when 2 => --0x2
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_2;                  --
        when 3 => --0x3
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_3;                  --
        when 4 => --0x4
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_4;                  --
        when 5 => --0x5
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_5;                  --
        when 16 => --0x10
          localRdData( 7 downto  0)  <=  reg_data(16)( 7 downto  0);      --
          localRdData(15 downto  8)  <=  reg_data(16)(15 downto  8);      --
          localRdData(31 downto 16)  <=  reg_data(16)(31 downto 16);      --
        when 17 => --0x11
          localRdData( 7 downto  0)  <=  reg_data(17)( 7 downto  0);      --
          localRdData(15 downto  8)  <=  reg_data(17)(15 downto  8);      --
          localRdData(23 downto 16)  <=  reg_data(17)(23 downto 16);      --
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  -- Register mapping to ctrl structures
  Ctrl.BUILD_DATE.YEAR   <=  reg_data(16)(31 downto 16);     
  Ctrl.BUILD_DATE.MONTH  <=  reg_data(16)(15 downto  8);     
  Ctrl.BUILD_DATE.DAY    <=  reg_data(16)( 7 downto  0);     
  Ctrl.BUILD_TIME.SEC    <=  reg_data(17)( 7 downto  0);     
  Ctrl.BUILD_TIME.MIN    <=  reg_data(17)(15 downto  8);     
  Ctrl.BUILD_TIME.HOUR   <=  reg_data(17)(23 downto 16);     



  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(4 downto 0))) is
        when 16 => --0x10
          reg_data(16)( 7 downto  0)  <=  localWrData( 7 downto  0);      --
          reg_data(16)(15 downto  8)  <=  localWrData(15 downto  8);      --
          reg_data(16)(31 downto 16)  <=  localWrData(31 downto 16);      --
        when 17 => --0x11
          reg_data(17)( 7 downto  0)  <=  localWrData( 7 downto  0);      --
          reg_data(17)(15 downto  8)  <=  localWrData(15 downto  8);      --
          reg_data(17)(23 downto 16)  <=  localWrData(23 downto 16);      --
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;

end architecture behavioral;
