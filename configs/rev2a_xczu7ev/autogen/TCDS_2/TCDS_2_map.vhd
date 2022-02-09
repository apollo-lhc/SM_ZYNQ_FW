--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.BRAMPortPkg.all;
use work.TCDS_2_Ctrl.all;

entity TCDS_2_map is
  generic (
    READ_TIMEOUT     : integer := 2048
    );
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  TCDS_2_Mon_t;
    Ctrl             : out TCDS_2_Ctrl_t
        
    );
end entity TCDS_2_map;
architecture behavioral of TCDS_2_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 2;
--  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
--  signal delayLatchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 10
,			1 => 10);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000800"
,			1 => x"00000C00");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  
  
  signal reg_data :  slv32_array_t(integer range 0 to 4096);
  constant Default_reg_data : slv32_array_t(integer range 0 to 4096) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteRegBlocking
    generic map (
      READ_TIMEOUT => READ_TIMEOUT
      )
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

  -------------------------------------------------------------------------------
  -- Record read decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  latch_reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      localRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= '0';
      
      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck <= '1';
      elsif BRAM_MISO(0).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(0).rd_data;
elsif BRAM_MISO(1).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(1).rd_data;

      end if;
    end if;
  end process latch_reads;

  
  reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      regRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      regRdAck  <= '0';
      localRdData <= x"00000000";
      if localRdReq = '1' then
        regRdAck  <= '1';
        case to_integer(unsigned(localAddress(12 downto 0))) is
          
        when 0 => --0x0
          localRdData( 0)            <=  Mon.TCDS_2.HW_CFG.HAS_SPY_REGISTERS;                        --
          localRdData( 1)            <=  Mon.TCDS_2.HW_CFG.HAS_LINK_TEST_MODE;                       --
        when 8 => --0x8
          localRdData( 0)            <=  reg_data( 8)( 0);                                           --
        when 9 => --0x9
          localRdData( 0)            <=  reg_data( 9)( 0);                                           --
          localRdData( 1)            <=  reg_data( 9)( 1);                                           --
        when 12 => --0xc
          localRdData( 0)            <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_CHK_ERROR;                 --
          localRdData( 1)            <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_CHK_LOCKED;                --
        when 13 => --0xd
          localRdData(31 downto  0)  <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_CHK_UNLOCK_COUNTER;        --
        when 14 => --0xe
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_GEN_O_HINT;                --
          localRdData(15 downto  8)  <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_CHK_I_HINT;                --
          localRdData(23 downto 16)  <=  Mon.TCDS_2.LINK_TEST.STATUS.PRBS_CHK_O_HINT;                --
        when 64 => --0x40
          localRdData( 0)            <=  reg_data(64)( 0);                                           --
          localRdData( 4)            <=  reg_data(64)( 4);                                           --Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
          localRdData( 5)            <=  reg_data(64)( 5);                                           --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 6)            <=  reg_data(64)( 6);                                           --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 7)            <=  reg_data(64)( 7);                                           --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData( 8)            <=  reg_data(64)( 8);                                           --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          localRdData(12)            <=  reg_data(64)(12);                                           --Resets the TCLink channel controller.
          localRdData(13)            <=  reg_data(64)(13);                                           --Enables/disables the TCLink channel controller.
          localRdData(14)            <=  reg_data(64)(14);                                           --When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
          localRdData(16)            <=  reg_data(64)(16);                                           --When high: activates the TCLink phase stabilisation.
        when 65 => --0x41
          localRdData(31 downto  0)  <=  reg_data(65)(31 downto  0);                                 --Lower 32 bits of status.tclink_phase_offset.
        when 66 => --0x42
          localRdData(15 downto  0)  <=  reg_data(66)(15 downto  0);                                 --Upper 16 bits of status.tclink_phase_offset.
        when 67 => --0x43
          localRdData( 9 downto  0)  <=  reg_data(67)( 9 downto  0);                                 --
          localRdData(10)            <=  reg_data(67)(10);                                           --
          localRdData(18 downto 16)  <=  reg_data(67)(18 downto 16);                                 --
          localRdData(19)            <=  reg_data(67)(19);                                           --
          localRdData(30 downto 24)  <=  reg_data(67)(30 downto 24);                                 --
          localRdData(31)            <=  reg_data(67)(31);                                           --
        when 68 => --0x44
          localRdData( 0)            <=  reg_data(68)( 0);                                           --Choice of MGT mode: 1: LPM, 0: DFE.
          localRdData( 1)            <=  reg_data(68)( 1);                                           --Reset to be strobed after changing MGT RXmode (LPM/DFE).
        when 69 => --0x45
          localRdData( 4)            <=  reg_data(69)( 4);                                           --
          localRdData( 5)            <=  reg_data(69)( 5);                                           --
          localRdData( 6)            <=  reg_data(69)( 6);                                           --
          localRdData( 7)            <=  reg_data(69)( 7);                                           --
        when 70 => --0x46
          localRdData( 8)            <=  reg_data(70)( 8);                                           --
          localRdData( 9)            <=  reg_data(70)( 9);                                           --
          localRdData(10)            <=  reg_data(70)(10);                                           --
          localRdData(11)            <=  reg_data(70)(11);                                           --
          localRdData(12)            <=  reg_data(70)(12);                                           --
        when 71 => --0x47
          localRdData( 0)            <=  reg_data(71)( 0);                                           --Reset of the lpGBT FEC monitoring.
        when 72 => --0x48
          localRdData(15 downto  0)  <=  reg_data(72)(15 downto  0);                                 --
        when 73 => --0x49
          localRdData(11 downto  0)  <=  reg_data(73)(11 downto  0);                                 --
        when 74 => --0x4a
          localRdData(31 downto  0)  <=  reg_data(74)(31 downto  0);                                 --
        when 75 => --0x4b
          localRdData(15 downto  0)  <=  reg_data(75)(15 downto  0);                                 --
        when 76 => --0x4c
          localRdData(31 downto  0)  <=  reg_data(76)(31 downto  0);                                 --
        when 77 => --0x4d
          localRdData(15 downto  0)  <=  reg_data(77)(15 downto  0);                                 --
        when 78 => --0x4e
          localRdData( 3 downto  0)  <=  reg_data(78)( 3 downto  0);                                 --
          localRdData( 4)            <=  reg_data(78)( 4);                                           --
          localRdData(11 downto  8)  <=  reg_data(78)(11 downto  8);                                 --
        when 79 => --0x4f
          localRdData(31 downto 16)  <=  reg_data(79)(31 downto 16);                                 --
        when 80 => --0x50
          localRdData( 0)            <=  reg_data(80)( 0);                                           --
        when 81 => --0x51
          localRdData(31 downto  0)  <=  reg_data(81)(31 downto  0);                                 --
        when 82 => --0x52
          localRdData(15 downto  0)  <=  reg_data(82)(15 downto  0);                                 --
        when 96 => --0x60
          localRdData( 0)            <=  Mon.TCDS_2.CSR.STATUS.IS_LINK_OPTICAL;                      --
          localRdData( 1)            <=  Mon.TCDS_2.CSR.STATUS.IS_LINK_SPEED_10G;                    --
          localRdData( 2)            <=  Mon.TCDS_2.CSR.STATUS.IS_LEADER;                            --
          localRdData( 3)            <=  Mon.TCDS_2.CSR.STATUS.IS_QUAD_LEADER;                       --
          localRdData( 4)            <=  Mon.TCDS_2.CSR.STATUS.IS_MGT_RX_MODE_LPM;                   --
        when 97 => --0x61
          localRdData( 0)            <=  Mon.TCDS_2.CSR.STATUS.MMCM_LOCKED;                          --
          localRdData( 1)            <=  Mon.TCDS_2.CSR.STATUS.MGT_POWER_GOOD;                       --
          localRdData( 4)            <=  Mon.TCDS_2.CSR.STATUS.MGT_TX_PLL_LOCKED;                    --
          localRdData( 5)            <=  Mon.TCDS_2.CSR.STATUS.MGT_RX_PLL_LOCKED;                    --
          localRdData( 8)            <=  Mon.TCDS_2.CSR.STATUS.MGT_RESET_TX_DONE;                    --
          localRdData( 9)            <=  Mon.TCDS_2.CSR.STATUS.MGT_RESET_RX_DONE;                    --
          localRdData(12)            <=  Mon.TCDS_2.CSR.STATUS.MGT_TX_READY;                         --
          localRdData(13)            <=  Mon.TCDS_2.CSR.STATUS.MGT_RX_READY;                         --
          localRdData(14)            <=  Mon.TCDS_2.CSR.STATUS.CDC40_TX_READY;                       --
          localRdData(15)            <=  Mon.TCDS_2.CSR.STATUS.CDC40_RX_READY;                       --
          localRdData(16)            <=  Mon.TCDS_2.CSR.STATUS.RX_DATA_NOT_IDLE;                     --
          localRdData(17)            <=  Mon.TCDS_2.CSR.STATUS.RX_FRAME_LOCKED;                      --
          localRdData(18)            <=  Mon.TCDS_2.CSR.STATUS.TX_USER_DATA_READY;                   --
          localRdData(19)            <=  Mon.TCDS_2.CSR.STATUS.RX_USER_DATA_READY;                   --
          localRdData(20)            <=  Mon.TCDS_2.CSR.STATUS.TCLINK_READY;                         --
        when 98 => --0x62
          localRdData(30 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.INITIALIZER_FSM_STATE;                --
          localRdData(31)            <=  Mon.TCDS_2.CSR.STATUS.INITIALIZER_FSM_RUNNING;              --
        when 99 => --0x63
          localRdData(31 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.RX_FRAME_UNLOCK_COUNTER;              --
        when 100 => --0x64
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.PHASE_CDC40_TX_MEASURED;              --
          localRdData(18 downto 16)  <=  Mon.TCDS_2.CSR.STATUS.PHASE_CDC40_RX_MEASURED;              --
          localRdData(30 downto 24)  <=  Mon.TCDS_2.CSR.STATUS.PHASE_PI_TX_MEASURED;                 --
        when 101 => --0x65
          localRdData( 0)            <=  Mon.TCDS_2.CSR.STATUS.FEC_CORRECTION_APPLIED;               --Latched flag indicating that the link is not error-free.
        when 102 => --0x66
          localRdData( 0)            <=  Mon.TCDS_2.CSR.STATUS.TCLINK_LOOP_CLOSED;                   --High if the TCLink control loop is closed (i.e. configured as closed and not internally opened due to issues).
          localRdData( 1)            <=  Mon.TCDS_2.CSR.STATUS.TCLINK_OPERATION_ERROR;               --High if the TCLink encountered a DCO error during operation.
        when 103 => --0x67
          localRdData(31 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.TCLINK_PHASE_MEASURED;                --Phase value measured by the TCLink. Signed two's complement number. Conversion to ps: DDMTD_UNIT / navg * value.
        when 104 => --0x68
          localRdData(31 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.TCLINK_PHASE_ERROR.LO;                --
        when 105 => --0x69
          localRdData(15 downto  0)  <=  Mon.TCDS_2.CSR.STATUS.TCLINK_PHASE_ERROR.HI;                --
        when 256 => --0x100
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD0;                              --
        when 257 => --0x101
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD1;                              --
        when 258 => --0x102
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD2;                              --
        when 259 => --0x103
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD3;                              --
        when 260 => --0x104
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD4;                              --
        when 261 => --0x105
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD5;                              --
        when 262 => --0x106
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD6;                              --
        when 263 => --0x107
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_TX.WORD7;                              --
        when 272 => --0x110
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD0;                              --
        when 273 => --0x111
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD1;                              --
        when 274 => --0x112
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD2;                              --
        when 275 => --0x113
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD3;                              --
        when 276 => --0x114
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD4;                              --
        when 277 => --0x115
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD5;                              --
        when 278 => --0x116
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD6;                              --
        when 279 => --0x117
          localRdData( 9 downto  0)  <=  Mon.TCDS_2.SPY_FRAME_RX.WORD7;                              --
        when 288 => --0x120
          localRdData( 0)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.PHYSICS;              --
          localRdData( 1)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.CALIBRATION;          --
          localRdData( 2)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RANDOM;               --
          localRdData( 3)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.SOFTWARE;             --
          localRdData( 4)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_4;           --
          localRdData( 5)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_5;           --
          localRdData( 6)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_6;           --
          localRdData( 7)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_7;           --
          localRdData( 8)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_8;           --
          localRdData( 9)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_9;           --
          localRdData(10)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_10;          --
          localRdData(11)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_11;          --
          localRdData(12)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_12;          --
          localRdData(13)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_13;          --
          localRdData(14)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_14;          --
          localRdData(15)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.RESERVED_15;          --
        when 289 => --0x121
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.L1A_INFO.PHYSICS_SUBTYPE;      --
        when 290 => --0x122
          localRdData(15 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.BRIL_TRIGGER_INFO;             --
        when 291 => --0x123
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.TIMING_AND_SYNC_INFO.LO;       --
        when 292 => --0x124
          localRdData(16 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.TIMING_AND_SYNC_INFO.HI;       --
        when 293 => --0x125
          localRdData( 4 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.STATUS_INFO;                   --
        when 294 => --0x126
          localRdData(17 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL0.RESERVED;                      --
        when 304 => --0x130
          localRdData( 0)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.PHYSICS;              --
          localRdData( 1)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.CALIBRATION;          --
          localRdData( 2)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RANDOM;               --
          localRdData( 3)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.SOFTWARE;             --
          localRdData( 4)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_4;           --
          localRdData( 5)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_5;           --
          localRdData( 6)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_6;           --
          localRdData( 7)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_7;           --
          localRdData( 8)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_8;           --
          localRdData( 9)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_9;           --
          localRdData(10)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_10;          --
          localRdData(11)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_11;          --
          localRdData(12)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_12;          --
          localRdData(13)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_13;          --
          localRdData(14)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_14;          --
          localRdData(15)            <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.RESERVED_15;          --
        when 305 => --0x131
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.L1A_INFO.PHYSICS_SUBTYPE;      --
        when 306 => --0x132
          localRdData(15 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.BRIL_TRIGGER_INFO;             --
        when 307 => --0x133
          localRdData(31 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.TIMING_AND_SYNC_INFO.LO;       --
        when 308 => --0x134
          localRdData(16 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.TIMING_AND_SYNC_INFO.HI;       --
        when 309 => --0x135
          localRdData( 4 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.STATUS_INFO;                   --
        when 310 => --0x136
          localRdData(17 downto  0)  <=  Mon.TCDS_2.SPY_TTC2_CHANNEL1.RESERVED;                      --
        when 320 => --0x140
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_0;                       --
        when 321 => --0x141
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_1;                       --
        when 322 => --0x142
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_2;                       --
        when 323 => --0x143
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_3;                       --
        when 324 => --0x144
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_4;                       --
        when 325 => --0x145
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_5;                       --
        when 326 => --0x146
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_6;                       --
        when 327 => --0x147
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_7;                       --
        when 328 => --0x148
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_8;                       --
        when 329 => --0x149
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_9;                       --
        when 330 => --0x14a
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_10;                      --
        when 331 => --0x14b
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_11;                      --
        when 332 => --0x14c
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_12;                      --
        when 333 => --0x14d
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL0.VALUE_13;                      --
        when 336 => --0x150
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_0;                       --
        when 337 => --0x151
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_1;                       --
        when 338 => --0x152
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_2;                       --
        when 339 => --0x153
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_3;                       --
        when 340 => --0x154
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_4;                       --
        when 341 => --0x155
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_5;                       --
        when 342 => --0x156
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_6;                       --
        when 343 => --0x157
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_7;                       --
        when 344 => --0x158
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_8;                       --
        when 345 => --0x159
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_9;                       --
        when 346 => --0x15a
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_10;                      --
        when 347 => --0x15b
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_11;                      --
        when 348 => --0x15c
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_12;                      --
        when 349 => --0x15d
          localRdData( 7 downto  0)  <=  Mon.TCDS_2.SPY_TTS2_CHANNEL1.VALUE_13;                      --
        when 768 => --0x300
          localRdData(31 downto  0)  <=  Mon.TCDS2_FREQ;                                             --
        when 769 => --0x301
          localRdData(31 downto  0)  <=  Mon.TCDS2_TX_PCS_FREQ;                                      --
        when 770 => --0x302
          localRdData(31 downto  0)  <=  Mon.TCDS2_RX_PCS_FREQ;                                      --
        when 1040 => --0x410
          localRdData( 0)            <=  Mon.LTCDS(1).STATUS.CONFIG_ERROR;                           --C2C config error
          localRdData( 1)            <=  Mon.LTCDS(1).STATUS.LINK_ERROR;                             --C2C link error
          localRdData( 2)            <=  Mon.LTCDS(1).STATUS.LINK_GOOD;                              --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.LTCDS(1).STATUS.MB_ERROR;                               --C2C multi-bit error
          localRdData( 4)            <=  Mon.LTCDS(1).STATUS.DO_CC;                                  --Aurora do CC
          localRdData( 5)            <=  reg_data(1040)( 5);                                         --C2C initialize
          localRdData( 8)            <=  Mon.LTCDS(1).STATUS.PHY_RESET;                              --Aurora phy in reset
          localRdData( 9)            <=  Mon.LTCDS(1).STATUS.PHY_GT_PLL_LOCK;                        --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.LTCDS(1).STATUS.PHY_MMCM_LOL;                           --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.LTCDS(1).STATUS.PHY_LANE_UP;                            --Aurora phy lanes up
          localRdData(16)            <=  Mon.LTCDS(1).STATUS.PHY_HARD_ERR;                           --Aurora phy hard error
          localRdData(17)            <=  Mon.LTCDS(1).STATUS.PHY_SOFT_ERR;                           --Aurora phy soft error
          localRdData(31)            <=  Mon.LTCDS(1).STATUS.LINK_IN_FW;                             --FW includes this link
        when 1056 => --0x420
          localRdData(15 downto  0)  <=  Mon.LTCDS(1).DEBUG.DMONITOR;                                --DEBUG d monitor
          localRdData(16)            <=  Mon.LTCDS(1).DEBUG.QPLL_LOCK;                               --DEBUG cplllock
          localRdData(20)            <=  Mon.LTCDS(1).DEBUG.CPLL_LOCK;                               --DEBUG cplllock
          localRdData(21)            <=  Mon.LTCDS(1).DEBUG.EYESCAN_DATA_ERROR;                      --DEBUG eyescan data error
          localRdData(23)            <=  reg_data(1056)(23);                                         --DEBUG eyescan trigger
        when 1057 => --0x421
          localRdData(15 downto  0)  <=  reg_data(1057)(15 downto  0);                               --bit 2 is DRP uber reset
        when 1058 => --0x422
          localRdData( 2 downto  0)  <=  Mon.LTCDS(1).DEBUG.RX.BUF_STATUS;                           --DEBUG rx buf status
          localRdData( 5)            <=  Mon.LTCDS(1).DEBUG.RX.PMA_RESET_DONE;                       --DEBUG rx reset done
          localRdData(10)            <=  Mon.LTCDS(1).DEBUG.RX.PRBS_ERR;                             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.LTCDS(1).DEBUG.RX.RESET_DONE;                           --DEBUG rx reset done
          localRdData(13)            <=  reg_data(1058)(13);                                         --DEBUG rx CDR hold
          localRdData(18)            <=  reg_data(1058)(18);                                         --DEBUG rx LPM ENABLE
          localRdData(25)            <=  reg_data(1058)(25);                                         --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(1058)(29 downto 26);                               --DEBUG rx PRBS select
        when 1059 => --0x423
          localRdData( 2 downto  0)  <=  reg_data(1059)( 2 downto  0);                               --DEBUG rx rate
        when 1060 => --0x424
          localRdData( 1 downto  0)  <=  Mon.LTCDS(1).DEBUG.TX.BUF_STATUS;                           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.LTCDS(1).DEBUG.TX.RESET_DONE;                           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(1060)( 7);                                         --DEBUG tx inhibit
          localRdData(17)            <=  reg_data(1060)(17);                                         --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(1060)(22 downto 18);                               --DEBUG post cursor
          localRdData(23)            <=  reg_data(1060)(23);                                         --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(1060)(31 downto 27);                               --DEBUG pre cursor
        when 1061 => --0x425
          localRdData( 3 downto  0)  <=  reg_data(1061)( 3 downto  0);                               --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(1061)( 8 downto  4);                               --DEBUG tx diff control
        when 1072 => --0x430
          localRdData(15 downto  0)  <=  reg_data(1072)(15 downto  0);                               --
          localRdData(31 downto 16)  <=  reg_data(1072)(31 downto 16);                               --
        when 1073 => --0x431
          localRdData( 7 downto  0)  <=  reg_data(1073)( 7 downto  0);                               --
        when 1088 => --0x440
          localRdData(15 downto  0)  <=  Mon.LTCDS(1).RX.CTRL0;                                      --
          localRdData(31 downto 16)  <=  Mon.LTCDS(1).RX.CTRL1;                                      --
        when 1089 => --0x441
          localRdData( 7 downto  0)  <=  Mon.LTCDS(1).RX.CTRL2;                                      --
          localRdData(15 downto  8)  <=  Mon.LTCDS(1).RX.CTRL3;                                      --
        when 1106 => --0x452
          localRdData( 3 downto  0)  <=  reg_data(1106)( 3 downto  0);                               --
        when 1108 => --0x454
          localRdData(31 downto  0)  <=  Mon.LTCDS(1).DATA_CTRL.CAPTURE_D;                           --
        when 1109 => --0x455
          localRdData( 3 downto  0)  <=  Mon.LTCDS(1).DATA_CTRL.CAPTURE_K;                           --
        when 1110 => --0x456
          localRdData(31 downto  0)  <=  reg_data(1110)(31 downto  0);                               --
        when 1111 => --0x457
          localRdData( 3 downto  0)  <=  reg_data(1111)( 3 downto  0);                               --
        when 1120 => --0x460
          localRdData(31 downto  0)  <=  Mon.LTCDS(1).TX_CLK_FREQ;                                   --
        when 1121 => --0x461
          localRdData(31 downto  0)  <=  Mon.LTCDS(1).TX_CLK_PCS_FREQ;                               --
        when 1122 => --0x462
          localRdData(31 downto  0)  <=  Mon.LTCDS(1).RX_CLK_PCS_FREQ;                               --
        when 1123 => --0x463
          localRdData( 2 downto  0)  <=  reg_data(1123)( 2 downto  0);                               --
        when 2064 => --0x810
          localRdData( 0)            <=  Mon.LTCDS(2).STATUS.CONFIG_ERROR;                           --C2C config error
          localRdData( 1)            <=  Mon.LTCDS(2).STATUS.LINK_ERROR;                             --C2C link error
          localRdData( 2)            <=  Mon.LTCDS(2).STATUS.LINK_GOOD;                              --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.LTCDS(2).STATUS.MB_ERROR;                               --C2C multi-bit error
          localRdData( 4)            <=  Mon.LTCDS(2).STATUS.DO_CC;                                  --Aurora do CC
          localRdData( 5)            <=  reg_data(2064)( 5);                                         --C2C initialize
          localRdData( 8)            <=  Mon.LTCDS(2).STATUS.PHY_RESET;                              --Aurora phy in reset
          localRdData( 9)            <=  Mon.LTCDS(2).STATUS.PHY_GT_PLL_LOCK;                        --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.LTCDS(2).STATUS.PHY_MMCM_LOL;                           --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.LTCDS(2).STATUS.PHY_LANE_UP;                            --Aurora phy lanes up
          localRdData(16)            <=  Mon.LTCDS(2).STATUS.PHY_HARD_ERR;                           --Aurora phy hard error
          localRdData(17)            <=  Mon.LTCDS(2).STATUS.PHY_SOFT_ERR;                           --Aurora phy soft error
          localRdData(31)            <=  Mon.LTCDS(2).STATUS.LINK_IN_FW;                             --FW includes this link
        when 2080 => --0x820
          localRdData(15 downto  0)  <=  Mon.LTCDS(2).DEBUG.DMONITOR;                                --DEBUG d monitor
          localRdData(16)            <=  Mon.LTCDS(2).DEBUG.QPLL_LOCK;                               --DEBUG cplllock
          localRdData(20)            <=  Mon.LTCDS(2).DEBUG.CPLL_LOCK;                               --DEBUG cplllock
          localRdData(21)            <=  Mon.LTCDS(2).DEBUG.EYESCAN_DATA_ERROR;                      --DEBUG eyescan data error
          localRdData(23)            <=  reg_data(2080)(23);                                         --DEBUG eyescan trigger
        when 2081 => --0x821
          localRdData(15 downto  0)  <=  reg_data(2081)(15 downto  0);                               --bit 2 is DRP uber reset
        when 2082 => --0x822
          localRdData( 2 downto  0)  <=  Mon.LTCDS(2).DEBUG.RX.BUF_STATUS;                           --DEBUG rx buf status
          localRdData( 5)            <=  Mon.LTCDS(2).DEBUG.RX.PMA_RESET_DONE;                       --DEBUG rx reset done
          localRdData(10)            <=  Mon.LTCDS(2).DEBUG.RX.PRBS_ERR;                             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.LTCDS(2).DEBUG.RX.RESET_DONE;                           --DEBUG rx reset done
          localRdData(13)            <=  reg_data(2082)(13);                                         --DEBUG rx CDR hold
          localRdData(18)            <=  reg_data(2082)(18);                                         --DEBUG rx LPM ENABLE
          localRdData(25)            <=  reg_data(2082)(25);                                         --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(2082)(29 downto 26);                               --DEBUG rx PRBS select
        when 2083 => --0x823
          localRdData( 2 downto  0)  <=  reg_data(2083)( 2 downto  0);                               --DEBUG rx rate
        when 2084 => --0x824
          localRdData( 1 downto  0)  <=  Mon.LTCDS(2).DEBUG.TX.BUF_STATUS;                           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.LTCDS(2).DEBUG.TX.RESET_DONE;                           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(2084)( 7);                                         --DEBUG tx inhibit
          localRdData(17)            <=  reg_data(2084)(17);                                         --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(2084)(22 downto 18);                               --DEBUG post cursor
          localRdData(23)            <=  reg_data(2084)(23);                                         --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(2084)(31 downto 27);                               --DEBUG pre cursor
        when 2085 => --0x825
          localRdData( 3 downto  0)  <=  reg_data(2085)( 3 downto  0);                               --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(2085)( 8 downto  4);                               --DEBUG tx diff control
        when 2096 => --0x830
          localRdData(15 downto  0)  <=  reg_data(2096)(15 downto  0);                               --
          localRdData(31 downto 16)  <=  reg_data(2096)(31 downto 16);                               --
        when 2097 => --0x831
          localRdData( 7 downto  0)  <=  reg_data(2097)( 7 downto  0);                               --
        when 2112 => --0x840
          localRdData(15 downto  0)  <=  Mon.LTCDS(2).RX.CTRL0;                                      --
          localRdData(31 downto 16)  <=  Mon.LTCDS(2).RX.CTRL1;                                      --
        when 2113 => --0x841
          localRdData( 7 downto  0)  <=  Mon.LTCDS(2).RX.CTRL2;                                      --
          localRdData(15 downto  8)  <=  Mon.LTCDS(2).RX.CTRL3;                                      --
        when 2130 => --0x852
          localRdData( 3 downto  0)  <=  reg_data(2130)( 3 downto  0);                               --
        when 2132 => --0x854
          localRdData(31 downto  0)  <=  Mon.LTCDS(2).DATA_CTRL.CAPTURE_D;                           --
        when 2133 => --0x855
          localRdData( 3 downto  0)  <=  Mon.LTCDS(2).DATA_CTRL.CAPTURE_K;                           --
        when 2134 => --0x856
          localRdData(31 downto  0)  <=  reg_data(2134)(31 downto  0);                               --
        when 2135 => --0x857
          localRdData( 3 downto  0)  <=  reg_data(2135)( 3 downto  0);                               --
        when 2144 => --0x860
          localRdData(31 downto  0)  <=  Mon.LTCDS(2).TX_CLK_FREQ;                                   --
        when 2145 => --0x861
          localRdData(31 downto  0)  <=  Mon.LTCDS(2).TX_CLK_PCS_FREQ;                               --
        when 2146 => --0x862
          localRdData(31 downto  0)  <=  Mon.LTCDS(2).RX_CLK_PCS_FREQ;                               --
        when 2147 => --0x863
          localRdData( 2 downto  0)  <=  reg_data(2147)( 2 downto  0);                               --


          when others =>
            regRdAck <= '0';
            localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  -- Register mapping to ctrl structures
  Ctrl.TCDS_2.LINK_TEST.CONTROL.LINK_TEST_MODE                   <=  reg_data( 8)( 0);                 
  Ctrl.TCDS_2.LINK_TEST.CONTROL.PRBS_GEN_RESET                   <=  reg_data( 9)( 0);                 
  Ctrl.TCDS_2.LINK_TEST.CONTROL.PRBS_CHK_RESET                   <=  reg_data( 9)( 1);                 
  Ctrl.TCDS_2.CSR.CONTROL.RESET_ALL                              <=  reg_data(64)( 0);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RESET_ALL                          <=  reg_data(64)( 4);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RESET_TX_PLL_AND_DATAPATH          <=  reg_data(64)( 5);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RESET_TX_DATAPATH                  <=  reg_data(64)( 6);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RESET_RX_PLL_AND_DATAPATH          <=  reg_data(64)( 7);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RESET_RX_DATAPATH                  <=  reg_data(64)( 8);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_RESET              <=  reg_data(64)(12);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_ENABLE             <=  reg_data(64)(13);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_GENTLE             <=  reg_data(64)(14);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_CLOSE_LOOP                      <=  reg_data(64)(16);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PHASE_OFFSET.LO                 <=  reg_data(65)(31 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PHASE_OFFSET.HI                 <=  reg_data(66)(15 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_CDC40_TX_CALIB                   <=  reg_data(67)( 9 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_CDC40_TX_FORCE                   <=  reg_data(67)(10);                 
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_CDC40_RX_CALIB                   <=  reg_data(67)(18 downto 16);       
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_CDC40_RX_FORCE                   <=  reg_data(67)(19);                 
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_PI_TX_CALIB                      <=  reg_data(67)(30 downto 24);       
  Ctrl.TCDS_2.CSR.CONTROL.PHASE_PI_TX_FORCE                      <=  reg_data(67)(31);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RX_DFE_VS_LPM                      <=  reg_data(68)( 0);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RX_DFE_VS_LPM_RESET                <=  reg_data(68)( 1);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMGCOVRDEN      <=  reg_data(69)( 4);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMHFOVRDEN      <=  reg_data(69)( 5);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMLFKLOVRDEN    <=  reg_data(69)( 6);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMOSOVRDEN      <=  reg_data(69)( 7);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXOSOVRDEN         <=  reg_data(70)( 8);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEAGCOVRDEN     <=  reg_data(70)( 9);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFELFOVRDEN      <=  reg_data(70)(10);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEUTOVRDEN      <=  reg_data(70)(11);                 
  Ctrl.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEVPOVRDEN      <=  reg_data(70)(12);                 
  Ctrl.TCDS_2.CSR.CONTROL.FEC_MONITOR_RESET                      <=  reg_data(71)( 0);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_METASTABILITY_DEGLITCH    <=  reg_data(72)(15 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_PHASE_DETECTOR_NAVG       <=  reg_data(73)(11 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MODULO_CARRIER_PERIOD.LO  <=  reg_data(74)(31 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MODULO_CARRIER_PERIOD.HI  <=  reg_data(75)(15 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MASTER_RX_UI_PERIOD.LO    <=  reg_data(76)(31 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MASTER_RX_UI_PERIOD.HI    <=  reg_data(77)(15 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_AIE                       <=  reg_data(78)( 3 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_AIE_ENABLE                <=  reg_data(78)( 4);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_APE                       <=  reg_data(78)(11 downto  8);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_SIGMA_DELTA_CLK_DIV       <=  reg_data(79)(31 downto 16);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ENABLE_MIRROR             <=  reg_data(80)( 0);                 
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ADCO.LO                   <=  reg_data(81)(31 downto  0);       
  Ctrl.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ADCO.HI                   <=  reg_data(82)(15 downto  0);       
  Ctrl.LTCDS(1).STATUS.INITIALIZE                                <=  reg_data(1040)( 5);               
  Ctrl.LTCDS(1).DEBUG.EYESCAN_TRIGGER                            <=  reg_data(1056)(23);               
  Ctrl.LTCDS(1).DEBUG.PCS_RSV_DIN                                <=  reg_data(1057)(15 downto  0);     
  Ctrl.LTCDS(1).DEBUG.RX.CDR_HOLD                                <=  reg_data(1058)(13);               
  Ctrl.LTCDS(1).DEBUG.RX.LPM_EN                                  <=  reg_data(1058)(18);               
  Ctrl.LTCDS(1).DEBUG.RX.PRBS_CNT_RST                            <=  reg_data(1058)(25);               
  Ctrl.LTCDS(1).DEBUG.RX.PRBS_SEL                                <=  reg_data(1058)(29 downto 26);     
  Ctrl.LTCDS(1).DEBUG.RX.RATE                                    <=  reg_data(1059)( 2 downto  0);     
  Ctrl.LTCDS(1).DEBUG.TX.INHIBIT                                 <=  reg_data(1060)( 7);               
  Ctrl.LTCDS(1).DEBUG.TX.POLARITY                                <=  reg_data(1060)(17);               
  Ctrl.LTCDS(1).DEBUG.TX.POST_CURSOR                             <=  reg_data(1060)(22 downto 18);     
  Ctrl.LTCDS(1).DEBUG.TX.PRBS_FORCE_ERR                          <=  reg_data(1060)(23);               
  Ctrl.LTCDS(1).DEBUG.TX.PRE_CURSOR                              <=  reg_data(1060)(31 downto 27);     
  Ctrl.LTCDS(1).DEBUG.TX.PRBS_SEL                                <=  reg_data(1061)( 3 downto  0);     
  Ctrl.LTCDS(1).DEBUG.TX.DIFF_CTRL                               <=  reg_data(1061)( 8 downto  4);     
  Ctrl.LTCDS(1).TX.CTRL0                                         <=  reg_data(1072)(15 downto  0);     
  Ctrl.LTCDS(1).TX.CTRL1                                         <=  reg_data(1072)(31 downto 16);     
  Ctrl.LTCDS(1).TX.CTRL2                                         <=  reg_data(1073)( 7 downto  0);     
  Ctrl.LTCDS(1).DATA_CTRL.MODE                                   <=  reg_data(1106)( 3 downto  0);     
  Ctrl.LTCDS(1).DATA_CTRL.FIXED_SEND_D                           <=  reg_data(1110)(31 downto  0);     
  Ctrl.LTCDS(1).DATA_CTRL.FIXED_SEND_K                           <=  reg_data(1111)( 3 downto  0);     
  Ctrl.LTCDS(1).LOOPBACK                                         <=  reg_data(1123)( 2 downto  0);     
  Ctrl.LTCDS(2).STATUS.INITIALIZE                                <=  reg_data(2064)( 5);               
  Ctrl.LTCDS(2).DEBUG.EYESCAN_TRIGGER                            <=  reg_data(2080)(23);               
  Ctrl.LTCDS(2).DEBUG.PCS_RSV_DIN                                <=  reg_data(2081)(15 downto  0);     
  Ctrl.LTCDS(2).DEBUG.RX.CDR_HOLD                                <=  reg_data(2082)(13);               
  Ctrl.LTCDS(2).DEBUG.RX.LPM_EN                                  <=  reg_data(2082)(18);               
  Ctrl.LTCDS(2).DEBUG.RX.PRBS_CNT_RST                            <=  reg_data(2082)(25);               
  Ctrl.LTCDS(2).DEBUG.RX.PRBS_SEL                                <=  reg_data(2082)(29 downto 26);     
  Ctrl.LTCDS(2).DEBUG.RX.RATE                                    <=  reg_data(2083)( 2 downto  0);     
  Ctrl.LTCDS(2).DEBUG.TX.INHIBIT                                 <=  reg_data(2084)( 7);               
  Ctrl.LTCDS(2).DEBUG.TX.POLARITY                                <=  reg_data(2084)(17);               
  Ctrl.LTCDS(2).DEBUG.TX.POST_CURSOR                             <=  reg_data(2084)(22 downto 18);     
  Ctrl.LTCDS(2).DEBUG.TX.PRBS_FORCE_ERR                          <=  reg_data(2084)(23);               
  Ctrl.LTCDS(2).DEBUG.TX.PRE_CURSOR                              <=  reg_data(2084)(31 downto 27);     
  Ctrl.LTCDS(2).DEBUG.TX.PRBS_SEL                                <=  reg_data(2085)( 3 downto  0);     
  Ctrl.LTCDS(2).DEBUG.TX.DIFF_CTRL                               <=  reg_data(2085)( 8 downto  4);     
  Ctrl.LTCDS(2).TX.CTRL0                                         <=  reg_data(2096)(15 downto  0);     
  Ctrl.LTCDS(2).TX.CTRL1                                         <=  reg_data(2096)(31 downto 16);     
  Ctrl.LTCDS(2).TX.CTRL2                                         <=  reg_data(2097)( 7 downto  0);     
  Ctrl.LTCDS(2).DATA_CTRL.MODE                                   <=  reg_data(2130)( 3 downto  0);     
  Ctrl.LTCDS(2).DATA_CTRL.FIXED_SEND_D                           <=  reg_data(2134)(31 downto  0);     
  Ctrl.LTCDS(2).DATA_CTRL.FIXED_SEND_K                           <=  reg_data(2135)( 3 downto  0);     
  Ctrl.LTCDS(2).LOOPBACK                                         <=  reg_data(2147)( 2 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 8)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.LINK_TEST.CONTROL.LINK_TEST_MODE;
      reg_data( 9)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.LINK_TEST.CONTROL.PRBS_GEN_RESET;
      reg_data( 9)( 1)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.LINK_TEST.CONTROL.PRBS_CHK_RESET;
      reg_data(64)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.RESET_ALL;
      reg_data(64)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RESET_ALL;
      reg_data(64)( 5)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RESET_TX_PLL_AND_DATAPATH;
      reg_data(64)( 6)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RESET_TX_DATAPATH;
      reg_data(64)( 7)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RESET_RX_PLL_AND_DATAPATH;
      reg_data(64)( 8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RESET_RX_DATAPATH;
      reg_data(64)(12)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_RESET;
      reg_data(64)(13)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_ENABLE;
      reg_data(64)(14)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_CHANNEL_CTRL_GENTLE;
      reg_data(64)(16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_CLOSE_LOOP;
      reg_data(65)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PHASE_OFFSET.LO;
      reg_data(66)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PHASE_OFFSET.HI;
      reg_data(67)( 9 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_CDC40_TX_CALIB;
      reg_data(67)(10)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_CDC40_TX_FORCE;
      reg_data(67)(18 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_CDC40_RX_CALIB;
      reg_data(67)(19)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_CDC40_RX_FORCE;
      reg_data(67)(30 downto 24)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_PI_TX_CALIB;
      reg_data(67)(31)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.PHASE_PI_TX_FORCE;
      reg_data(68)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RX_DFE_VS_LPM;
      reg_data(68)( 1)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RX_DFE_VS_LPM_RESET;
      reg_data(69)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMGCOVRDEN;
      reg_data(69)( 5)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMHFOVRDEN;
      reg_data(69)( 6)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMLFKLOVRDEN;
      reg_data(69)( 7)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.LPM.RXLPMOSOVRDEN;
      reg_data(70)( 8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXOSOVRDEN;
      reg_data(70)( 9)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEAGCOVRDEN;
      reg_data(70)(10)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFELFOVRDEN;
      reg_data(70)(11)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEUTOVRDEN;
      reg_data(70)(12)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.MGT_RXEQ_PARAMS.DFE.RXDFEVPOVRDEN;
      reg_data(71)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.FEC_MONITOR_RESET;
      reg_data(72)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_METASTABILITY_DEGLITCH;
      reg_data(73)(11 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_PHASE_DETECTOR_NAVG;
      reg_data(74)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MODULO_CARRIER_PERIOD.LO;
      reg_data(75)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MODULO_CARRIER_PERIOD.HI;
      reg_data(76)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MASTER_RX_UI_PERIOD.LO;
      reg_data(77)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_MASTER_RX_UI_PERIOD.HI;
      reg_data(78)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_AIE;
      reg_data(78)( 4)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_AIE_ENABLE;
      reg_data(78)(11 downto  8)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_APE;
      reg_data(79)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_SIGMA_DELTA_CLK_DIV;
      reg_data(80)( 0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ENABLE_MIRROR;
      reg_data(81)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ADCO.LO;
      reg_data(82)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.TCDS_2.CSR.CONTROL.TCLINK_PARAM_ADCO.HI;
      reg_data(1024)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RESET_ALL;
      reg_data(1024)( 4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.TX_PLL_AND_DATAPATH;
      reg_data(1024)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.TX_DATAPATH;
      reg_data(1024)( 6)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RX_PLL_AND_DATAPATH;
      reg_data(1024)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.RX_DATAPATH;
      reg_data(1024)( 8)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.USERCLK_TX;
      reg_data(1024)( 9)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.USERCLK_RX;
      reg_data(1024)(10)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).RESET.DRP;
      reg_data(1040)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).STATUS.INITIALIZE;
      reg_data(1056)(22)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.EYESCAN_RESET;
      reg_data(1056)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.EYESCAN_TRIGGER;
      reg_data(1057)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.PCS_RSV_DIN;
      reg_data(1058)(12)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.BUF_RESET;
      reg_data(1058)(13)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.CDR_HOLD;
      reg_data(1058)(17)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.DFE_LPM_RESET;
      reg_data(1058)(18)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.LPM_EN;
      reg_data(1058)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.PCS_RESET;
      reg_data(1058)(24)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.PMA_RESET;
      reg_data(1058)(25)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.PRBS_CNT_RST;
      reg_data(1058)(29 downto 26)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.PRBS_SEL;
      reg_data(1059)( 2 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.RX.RATE;
      reg_data(1060)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.INHIBIT;
      reg_data(1060)(15)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.PCS_RESET;
      reg_data(1060)(16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.PMA_RESET;
      reg_data(1060)(17)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.POLARITY;
      reg_data(1060)(22 downto 18)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.POST_CURSOR;
      reg_data(1060)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(1060)(31 downto 27)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.PRE_CURSOR;
      reg_data(1061)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.PRBS_SEL;
      reg_data(1061)( 8 downto  4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DEBUG.TX.DIFF_CTRL;
      reg_data(1072)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL0;
      reg_data(1072)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL1;
      reg_data(1073)( 7 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).TX.CTRL2;
      reg_data(1104)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DATA_CTRL.CAPTURE;
      reg_data(1106)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DATA_CTRL.MODE;
      reg_data(1110)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DATA_CTRL.FIXED_SEND_D;
      reg_data(1111)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).DATA_CTRL.FIXED_SEND_K;
      reg_data(1123)( 2 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(1).LOOPBACK;
      reg_data(2048)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RESET_ALL;
      reg_data(2048)( 4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.TX_PLL_AND_DATAPATH;
      reg_data(2048)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.TX_DATAPATH;
      reg_data(2048)( 6)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RX_PLL_AND_DATAPATH;
      reg_data(2048)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.RX_DATAPATH;
      reg_data(2048)( 8)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.USERCLK_TX;
      reg_data(2048)( 9)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.USERCLK_RX;
      reg_data(2048)(10)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).RESET.DRP;
      reg_data(2064)( 5)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).STATUS.INITIALIZE;
      reg_data(2080)(22)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.EYESCAN_RESET;
      reg_data(2080)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.EYESCAN_TRIGGER;
      reg_data(2081)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.PCS_RSV_DIN;
      reg_data(2082)(12)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.BUF_RESET;
      reg_data(2082)(13)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.CDR_HOLD;
      reg_data(2082)(17)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.DFE_LPM_RESET;
      reg_data(2082)(18)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.LPM_EN;
      reg_data(2082)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.PCS_RESET;
      reg_data(2082)(24)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.PMA_RESET;
      reg_data(2082)(25)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.PRBS_CNT_RST;
      reg_data(2082)(29 downto 26)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.PRBS_SEL;
      reg_data(2083)( 2 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.RX.RATE;
      reg_data(2084)( 7)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.INHIBIT;
      reg_data(2084)(15)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.PCS_RESET;
      reg_data(2084)(16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.PMA_RESET;
      reg_data(2084)(17)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.POLARITY;
      reg_data(2084)(22 downto 18)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.POST_CURSOR;
      reg_data(2084)(23)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(2084)(31 downto 27)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.PRE_CURSOR;
      reg_data(2085)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.PRBS_SEL;
      reg_data(2085)( 8 downto  4)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DEBUG.TX.DIFF_CTRL;
      reg_data(2096)(15 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL0;
      reg_data(2096)(31 downto 16)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL1;
      reg_data(2097)( 7 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).TX.CTRL2;
      reg_data(2128)( 0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DATA_CTRL.CAPTURE;
      reg_data(2130)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DATA_CTRL.MODE;
      reg_data(2134)(31 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DATA_CTRL.FIXED_SEND_D;
      reg_data(2135)( 3 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).DATA_CTRL.FIXED_SEND_K;
      reg_data(2147)( 2 downto  0)  <= DEFAULT_TCDS_2_CTRL_t.LTCDS(2).LOOPBACK;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.LTCDS(1).RESET.RESET_ALL <= '0';
      Ctrl.LTCDS(1).RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.TX_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.RX_DATAPATH <= '0';
      Ctrl.LTCDS(1).RESET.USERCLK_TX <= '0';
      Ctrl.LTCDS(1).RESET.USERCLK_RX <= '0';
      Ctrl.LTCDS(1).RESET.DRP <= '0';
      Ctrl.LTCDS(1).DEBUG.EYESCAN_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.RX.BUF_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.RX.DFE_LPM_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.RX.PCS_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.RX.PMA_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.TX.PCS_RESET <= '0';
      Ctrl.LTCDS(1).DEBUG.TX.PMA_RESET <= '0';
      Ctrl.LTCDS(1).DATA_CTRL.CAPTURE <= '0';
      Ctrl.LTCDS(2).RESET.RESET_ALL <= '0';
      Ctrl.LTCDS(2).RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.TX_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.RX_DATAPATH <= '0';
      Ctrl.LTCDS(2).RESET.USERCLK_TX <= '0';
      Ctrl.LTCDS(2).RESET.USERCLK_RX <= '0';
      Ctrl.LTCDS(2).RESET.DRP <= '0';
      Ctrl.LTCDS(2).DEBUG.EYESCAN_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.RX.BUF_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.RX.DFE_LPM_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.RX.PCS_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.RX.PMA_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.TX.PCS_RESET <= '0';
      Ctrl.LTCDS(2).DEBUG.TX.PMA_RESET <= '0';
      Ctrl.LTCDS(2).DATA_CTRL.CAPTURE <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(12 downto 0))) is
        when 8 => --0x8
          reg_data( 8)( 0)                         <=  localWrData( 0);                --
        when 9 => --0x9
          reg_data( 9)( 0)                         <=  localWrData( 0);                --
          reg_data( 9)( 1)                         <=  localWrData( 1);                --
        when 64 => --0x40
          reg_data(64)( 0)                         <=  localWrData( 0);                --
          reg_data(64)( 4)                         <=  localWrData( 4);                --Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
          reg_data(64)( 5)                         <=  localWrData( 5);                --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 6)                         <=  localWrData( 6);                --Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 7)                         <=  localWrData( 7);                --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)( 8)                         <=  localWrData( 8);                --Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
          reg_data(64)(12)                         <=  localWrData(12);                --Resets the TCLink channel controller.
          reg_data(64)(13)                         <=  localWrData(13);                --Enables/disables the TCLink channel controller.
          reg_data(64)(14)                         <=  localWrData(14);                --When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
          reg_data(64)(16)                         <=  localWrData(16);                --When high: activates the TCLink phase stabilisation.
        when 65 => --0x41
          reg_data(65)(31 downto  0)               <=  localWrData(31 downto  0);      --Lower 32 bits of status.tclink_phase_offset.
        when 66 => --0x42
          reg_data(66)(15 downto  0)               <=  localWrData(15 downto  0);      --Upper 16 bits of status.tclink_phase_offset.
        when 67 => --0x43
          reg_data(67)( 9 downto  0)               <=  localWrData( 9 downto  0);      --
          reg_data(67)(10)                         <=  localWrData(10);                --
          reg_data(67)(18 downto 16)               <=  localWrData(18 downto 16);      --
          reg_data(67)(19)                         <=  localWrData(19);                --
          reg_data(67)(30 downto 24)               <=  localWrData(30 downto 24);      --
          reg_data(67)(31)                         <=  localWrData(31);                --
        when 68 => --0x44
          reg_data(68)( 0)                         <=  localWrData( 0);                --Choice of MGT mode: 1: LPM, 0: DFE.
          reg_data(68)( 1)                         <=  localWrData( 1);                --Reset to be strobed after changing MGT RXmode (LPM/DFE).
        when 69 => --0x45
          reg_data(69)( 4)                         <=  localWrData( 4);                --
          reg_data(69)( 5)                         <=  localWrData( 5);                --
          reg_data(69)( 6)                         <=  localWrData( 6);                --
          reg_data(69)( 7)                         <=  localWrData( 7);                --
        when 70 => --0x46
          reg_data(70)( 8)                         <=  localWrData( 8);                --
          reg_data(70)( 9)                         <=  localWrData( 9);                --
          reg_data(70)(10)                         <=  localWrData(10);                --
          reg_data(70)(11)                         <=  localWrData(11);                --
          reg_data(70)(12)                         <=  localWrData(12);                --
        when 71 => --0x47
          reg_data(71)( 0)                         <=  localWrData( 0);                --Reset of the lpGBT FEC monitoring.
        when 72 => --0x48
          reg_data(72)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 73 => --0x49
          reg_data(73)(11 downto  0)               <=  localWrData(11 downto  0);      --
        when 74 => --0x4a
          reg_data(74)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 75 => --0x4b
          reg_data(75)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 76 => --0x4c
          reg_data(76)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 77 => --0x4d
          reg_data(77)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 78 => --0x4e
          reg_data(78)( 3 downto  0)               <=  localWrData( 3 downto  0);      --
          reg_data(78)( 4)                         <=  localWrData( 4);                --
          reg_data(78)(11 downto  8)               <=  localWrData(11 downto  8);      --
        when 79 => --0x4f
          reg_data(79)(31 downto 16)               <=  localWrData(31 downto 16);      --
        when 80 => --0x50
          reg_data(80)( 0)                         <=  localWrData( 0);                --
        when 81 => --0x51
          reg_data(81)(31 downto  0)               <=  localWrData(31 downto  0);      --
        when 82 => --0x52
          reg_data(82)(15 downto  0)               <=  localWrData(15 downto  0);      --
        when 1024 => --0x400
          Ctrl.LTCDS(1).RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.LTCDS(1).RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.LTCDS(1).RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.LTCDS(1).RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.LTCDS(1).RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.LTCDS(1).RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.LTCDS(1).RESET.USERCLK_RX           <=  localWrData( 9);               
          Ctrl.LTCDS(1).RESET.DRP                  <=  localWrData(10);               
        when 1040 => --0x410
          reg_data(1040)( 5)                       <=  localWrData( 5);                --C2C initialize
        when 1056 => --0x420
          Ctrl.LTCDS(1).DEBUG.EYESCAN_RESET        <=  localWrData(22);               
          reg_data(1056)(23)                       <=  localWrData(23);                --DEBUG eyescan trigger
        when 1057 => --0x421
          reg_data(1057)(15 downto  0)             <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 1058 => --0x422
          Ctrl.LTCDS(1).DEBUG.RX.BUF_RESET         <=  localWrData(12);               
          Ctrl.LTCDS(1).DEBUG.RX.DFE_LPM_RESET     <=  localWrData(17);               
          Ctrl.LTCDS(1).DEBUG.RX.PCS_RESET         <=  localWrData(23);               
          Ctrl.LTCDS(1).DEBUG.RX.PMA_RESET         <=  localWrData(24);               
          reg_data(1058)(13)                       <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(1058)(18)                       <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(1058)(25)                       <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(1058)(29 downto 26)             <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 1059 => --0x423
          reg_data(1059)( 2 downto  0)             <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 1060 => --0x424
          Ctrl.LTCDS(1).DEBUG.TX.PCS_RESET         <=  localWrData(15);               
          Ctrl.LTCDS(1).DEBUG.TX.PMA_RESET         <=  localWrData(16);               
          reg_data(1060)( 7)                       <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(1060)(17)                       <=  localWrData(17);                --DEBUG tx polarity
          reg_data(1060)(22 downto 18)             <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(1060)(23)                       <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(1060)(31 downto 27)             <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 1061 => --0x425
          reg_data(1061)( 3 downto  0)             <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(1061)( 8 downto  4)             <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 1072 => --0x430
          reg_data(1072)(15 downto  0)             <=  localWrData(15 downto  0);      --
          reg_data(1072)(31 downto 16)             <=  localWrData(31 downto 16);      --
        when 1073 => --0x431
          reg_data(1073)( 7 downto  0)             <=  localWrData( 7 downto  0);      --
        when 1104 => --0x450
          Ctrl.LTCDS(1).DATA_CTRL.CAPTURE          <=  localWrData( 0);               
        when 1106 => --0x452
          reg_data(1106)( 3 downto  0)             <=  localWrData( 3 downto  0);      --
        when 1110 => --0x456
          reg_data(1110)(31 downto  0)             <=  localWrData(31 downto  0);      --
        when 1111 => --0x457
          reg_data(1111)( 3 downto  0)             <=  localWrData( 3 downto  0);      --
        when 1123 => --0x463
          reg_data(1123)( 2 downto  0)             <=  localWrData( 2 downto  0);      --
        when 2048 => --0x800
          Ctrl.LTCDS(2).RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.LTCDS(2).RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.LTCDS(2).RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.LTCDS(2).RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.LTCDS(2).RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.LTCDS(2).RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.LTCDS(2).RESET.USERCLK_RX           <=  localWrData( 9);               
          Ctrl.LTCDS(2).RESET.DRP                  <=  localWrData(10);               
        when 2064 => --0x810
          reg_data(2064)( 5)                       <=  localWrData( 5);                --C2C initialize
        when 2080 => --0x820
          Ctrl.LTCDS(2).DEBUG.EYESCAN_RESET        <=  localWrData(22);               
          reg_data(2080)(23)                       <=  localWrData(23);                --DEBUG eyescan trigger
        when 2081 => --0x821
          reg_data(2081)(15 downto  0)             <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 2082 => --0x822
          Ctrl.LTCDS(2).DEBUG.RX.BUF_RESET         <=  localWrData(12);               
          Ctrl.LTCDS(2).DEBUG.RX.DFE_LPM_RESET     <=  localWrData(17);               
          Ctrl.LTCDS(2).DEBUG.RX.PCS_RESET         <=  localWrData(23);               
          Ctrl.LTCDS(2).DEBUG.RX.PMA_RESET         <=  localWrData(24);               
          reg_data(2082)(13)                       <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(2082)(18)                       <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(2082)(25)                       <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(2082)(29 downto 26)             <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 2083 => --0x823
          reg_data(2083)( 2 downto  0)             <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 2084 => --0x824
          Ctrl.LTCDS(2).DEBUG.TX.PCS_RESET         <=  localWrData(15);               
          Ctrl.LTCDS(2).DEBUG.TX.PMA_RESET         <=  localWrData(16);               
          reg_data(2084)( 7)                       <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(2084)(17)                       <=  localWrData(17);                --DEBUG tx polarity
          reg_data(2084)(22 downto 18)             <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(2084)(23)                       <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(2084)(31 downto 27)             <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 2085 => --0x825
          reg_data(2085)( 3 downto  0)             <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(2085)( 8 downto  4)             <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 2096 => --0x830
          reg_data(2096)(15 downto  0)             <=  localWrData(15 downto  0);      --
          reg_data(2096)(31 downto 16)             <=  localWrData(31 downto 16);      --
        when 2097 => --0x831
          reg_data(2097)( 7 downto  0)             <=  localWrData( 7 downto  0);      --
        when 2128 => --0x850
          Ctrl.LTCDS(2).DATA_CTRL.CAPTURE          <=  localWrData( 0);               
        when 2130 => --0x852
          reg_data(2130)( 3 downto  0)             <=  localWrData( 3 downto  0);      --
        when 2134 => --0x856
          reg_data(2134)(31 downto  0)             <=  localWrData(31 downto  0);      --
        when 2135 => --0x857
          reg_data(2135)( 3 downto  0)             <=  localWrData( 3 downto  0);      --
        when 2147 => --0x863
          reg_data(2147)( 2 downto  0)             <=  localWrData( 2 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;



  
  -------------------------------------------------------------------------------
  -- BRAM decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  BRAM_reads: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
        if localAddress(12 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(12 downto BRAM_range(iBRAM)) then
--          latchBRAM(iBRAM) <= localRdReq;
--          BRAM_MOSI(iBRAM).enable  <= '1';
          BRAM_MOSI(iBRAM).enable  <= localRdReq;
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;



  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
  Ctrl.LTCDS(1).DRP.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.LTCDS(1).DRP.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.LTCDS(1).DRP.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.LTCDS(1).DRP.address   <=  BRAM_MOSI(0).address(10-1 downto 0);
  Ctrl.LTCDS(1).DRP.wr_data   <=  BRAM_MOSI(0).wr_data(16-1 downto 0);

  Ctrl.LTCDS(2).DRP.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.LTCDS(2).DRP.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.LTCDS(2).DRP.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.LTCDS(2).DRP.address   <=  BRAM_MOSI(1).address(10-1 downto 0);
  Ctrl.LTCDS(2).DRP.wr_data   <=  BRAM_MOSI(1).wr_data(16-1 downto 0);


  BRAM_MISO(0).rd_data(16-1 downto 0) <= Mon.LTCDS(1).DRP.rd_data;
  BRAM_MISO(0).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(0).rd_data_valid <= Mon.LTCDS(1).DRP.rd_data_valid;

  BRAM_MISO(1).rd_data(16-1 downto 0) <= Mon.LTCDS(2).DRP.rd_data;
  BRAM_MISO(1).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(1).rd_data_valid <= Mon.LTCDS(2).DRP.rd_data_valid;

    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress(12 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(12 downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;


  
end architecture behavioral;