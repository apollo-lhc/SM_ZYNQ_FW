--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.LDAQ_Ctrl.all;

entity LDAQ_map is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  LDAQ_Mon_t;
    Ctrl             : out LDAQ_Ctrl_t
    );
end entity LDAQ_map;
architecture behavioral of LDAQ_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 19);
  constant Default_reg_data : slv32_array_t(integer range 0 to 19) := (others => x"00000000");
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

        when 2 => --0x2
          localRdData( 0)            <=  Mon.STATUS.RESET_RX_CDR_STABLE;      --
          localRdData( 1)            <=  Mon.STATUS.RESET_TX_DONE;            --
          localRdData( 2)            <=  Mon.STATUS.RESET_RX_DONE;            --
          localRdData( 8)            <=  Mon.STATUS.USERCLK_TX_ACTIVE;        --
          localRdData( 9)            <=  Mon.STATUS.USERCLK_RX_ACTIVE;        --
          localRdData(16)            <=  Mon.STATUS.GT_POWER_GOOD;            --
          localRdData(17)            <=  Mon.STATUS.RX_BYTE_ISALIGNED;        --
          localRdData(18)            <=  Mon.STATUS.RX_BYTE_REALIGN;          --
          localRdData(19)            <=  Mon.STATUS.RX_COMMADET;              --
          localRdData(20)            <=  Mon.STATUS.RX_PMA_RESET_DONE;        --
          localRdData(21)            <=  Mon.STATUS.TX_PMA_RESET_DONE;        --
        when 16 => --0x10
          localRdData(15 downto  0)  <=  reg_data(16)(15 downto  0);          --
          localRdData(31 downto 16)  <=  reg_data(16)(31 downto 16);          --
        when 17 => --0x11
          localRdData( 7 downto  0)  <=  reg_data(17)( 7 downto  0);          --
        when 18 => --0x12
          localRdData(15 downto  0)  <=  Mon.RX.CTRL0;                        --
          localRdData(31 downto 16)  <=  Mon.RX.CTRL1;                        --
        when 19 => --0x13
          localRdData( 7 downto  0)  <=  Mon.RX.CTRL2;                        --
          localRdData(15 downto  8)  <=  Mon.RX.CTRL3;                        --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.TX.CTRL0  <=  reg_data(16)(15 downto  0);     
  Ctrl.TX.CTRL1  <=  reg_data(16)(31 downto 16);     
  Ctrl.TX.CTRL2  <=  reg_data(17)( 7 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)( 0)  <= DEFAULT_LDAQ_CTRL_t.RESET.RESET_ALL;
      reg_data( 0)( 4)  <= DEFAULT_LDAQ_CTRL_t.RESET.TX_PLL_AND_DATAPATH;
      reg_data( 0)( 5)  <= DEFAULT_LDAQ_CTRL_t.RESET.TX_DATAPATH;
      reg_data( 0)( 6)  <= DEFAULT_LDAQ_CTRL_t.RESET.RX_PLL_AND_DATAPATH;
      reg_data( 0)( 7)  <= DEFAULT_LDAQ_CTRL_t.RESET.RX_DATAPATH;
      reg_data( 0)( 8)  <= DEFAULT_LDAQ_CTRL_t.RESET.USERCLK_TX;
      reg_data( 0)( 9)  <= DEFAULT_LDAQ_CTRL_t.RESET.USERCLK_RX;
      reg_data(16)(15 downto  0)  <= DEFAULT_LDAQ_CTRL_t.TX.CTRL0;
      reg_data(16)(31 downto 16)  <= DEFAULT_LDAQ_CTRL_t.TX.CTRL1;
      reg_data(17)( 7 downto  0)  <= DEFAULT_LDAQ_CTRL_t.TX.CTRL2;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.RESET.RESET_ALL <= '0';
      Ctrl.RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.RESET.TX_DATAPATH <= '0';
      Ctrl.RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.RESET.RX_DATAPATH <= '0';
      Ctrl.RESET.USERCLK_TX <= '0';
      Ctrl.RESET.USERCLK_RX <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(4 downto 0))) is
        when 0 => --0x0
          Ctrl.RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.RESET.USERCLK_RX           <=  localWrData( 9);               
        when 16 => --0x10
          reg_data(16)(15 downto  0)      <=  localWrData(15 downto  0);      --
          reg_data(16)(31 downto 16)      <=  localWrData(31 downto 16);      --
        when 17 => --0x11
          reg_data(17)( 7 downto  0)      <=  localWrData( 7 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;