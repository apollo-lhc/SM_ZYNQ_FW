--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.CM_Ctrl.all;
entity CM_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  CM_Mon_t;
    Ctrl             : out CM_Ctrl_t
    );
end entity CM_interface;
architecture behavioral of CM_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 87);
  constant Default_reg_data : slv32_array_t(integer range 0 to 87) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(6 downto 0))) is

        when 0 => --0x0
          localRdData( 0)            <=  reg_data( 0)( 0);                                 --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data( 0)( 1);                                 --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data( 0)( 2);                                 --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(1).CTRL.PWR_GOOD;                          --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(1).CTRL.STATE;                             --CM power up state
          localRdData( 8)            <=  reg_data( 0)( 8);                                 --CM power is good
          localRdData( 9)            <=  Mon.CM(1).CTRL.PWR_ENABLED;                       --power is enabled
          localRdData(10)            <=  Mon.CM(1).CTRL.IOS_ENABLED;                       --IOs to CM are enabled
          localRdData(11)            <=  reg_data( 0)(11);                                 --phy_lane_control is enabled
        when 1 => --0x1
          localRdData(31 downto  0)  <=  reg_data( 1)(31 downto  0);                       --Contious phy_lane_up signals required to lock phylane control
        when 2 => --0x2
          localRdData(23 downto  0)  <=  reg_data( 2)(23 downto  0);                       --Time spent waiting for phylane to stabilize
        when 20 => --0x14
          localRdData( 0)            <=  Mon.CM(1).C2C.CONFIG_ERROR;                       --C2C config error
          localRdData( 1)            <=  Mon.CM(1).C2C.LINK_ERROR;                         --C2C link error
          localRdData( 2)            <=  Mon.CM(1).C2C.LINK_GOOD;                          --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(1).C2C.MB_ERROR;                           --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(1).C2C.DO_CC;                              --Aurora do CC
          localRdData( 5)            <=  reg_data(20)( 5);                                 --C2C initialize
          localRdData( 8)            <=  Mon.CM(1).C2C.PHY_RESET;                          --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(1).C2C.PHY_GT_PLL_LOCK;                    --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(1).C2C.PHY_MMCM_LOL;                       --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(1).C2C.PHY_LANE_UP;                        --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(1).C2C.PHY_HARD_ERR;                       --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(1).C2C.PHY_SOFT_ERR;                       --Aurora phy soft error
          localRdData(20)            <=  Mon.CM(1).C2C.CPLL_LOCK;                          --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(1).C2C.EYESCAN_DATA_ERROR;                 --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(20)(22);                                 --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(20)(23);                                 --DEBUG eyescan trigger
          localRdData(31 downto 24)  <=  Mon.CM(1).C2C.DMONITOR;                           --DEBUG d monitor
        when 21 => --0x15
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C.RX.BUF_STATUS;                      --DEBUG rx buf status
          localRdData( 9 downto  3)  <=  Mon.CM(1).C2C.RX.MONITOR;                         --DEBUG rx status
          localRdData(10)            <=  Mon.CM(1).C2C.RX.PRBS_ERR;                        --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(1).C2C.RX.RESET_DONE;                      --DEBUG rx reset done
          localRdData(12)            <=  reg_data(21)(12);                                 --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(21)(13);                                 --DEBUG rx CDR hold
          localRdData(14)            <=  reg_data(21)(14);                                 --DEBUG rx DFE AGC HOLD
          localRdData(15)            <=  reg_data(21)(15);                                 --DEBUG rx DFE AGC OVERRIDE
          localRdData(16)            <=  reg_data(21)(16);                                 --DEBUG rx DFE LF HOLD
          localRdData(17)            <=  reg_data(21)(17);                                 --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(21)(18);                                 --DEBUG rx LPM ENABLE
          localRdData(19)            <=  reg_data(21)(19);                                 --DEBUG rx LPM HF OVERRIDE enable
          localRdData(20)            <=  reg_data(21)(20);                                 --DEBUG rx LPM LFKL override
          localRdData(22 downto 21)  <=  reg_data(21)(22 downto 21);                       --DEBUG rx monitor select
          localRdData(23)            <=  reg_data(21)(23);                                 --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(21)(24);                                 --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(21)(25);                                 --DEBUG rx PRBS counter reset
          localRdData(28 downto 26)  <=  reg_data(21)(28 downto 26);                       --DEBUG rx PRBS select
        when 22 => --0x16
          localRdData( 1 downto  0)  <=  Mon.CM(1).C2C.TX.BUF_STATUS;                      --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(1).C2C.TX.RESET_DONE;                      --DEBUG tx reset done
          localRdData( 6 downto  3)  <=  reg_data(22)( 6 downto  3);                       --DEBUG tx diff control
          localRdData( 7)            <=  reg_data(22)( 7);                                 --DEBUG tx inhibit
          localRdData(14 downto  8)  <=  reg_data(22)(14 downto  8);                       --DEBUG tx main cursor
          localRdData(15)            <=  reg_data(22)(15);                                 --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(22)(16);                                 --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(22)(17);                                 --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(22)(22 downto 18);                       --DEBUG post cursor
          localRdData(23)            <=  reg_data(22)(23);                                 --DEBUG force PRBS error
          localRdData(26 downto 24)  <=  reg_data(22)(26 downto 24);                       --DEBUG PRBS select
          localRdData(31 downto 27)  <=  reg_data(22)(31 downto 27);                       --DEBUG pre cursor
        when 23 => --0x17
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 24 => --0x18
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 25 => --0x19
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 26 => --0x1a
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 27 => --0x1b
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 28 => --0x1c
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 29 => --0x1d
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 30 => --0x1e
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C.CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 32 => --0x20
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C.CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 33 => --0x21
          localRdData( 7 downto  0)  <=  reg_data(33)( 7 downto  0);                       --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(1).MONITOR.ACTIVE;                         --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(1).MONITOR.HISTORY_VALID;                  --bytes valid in debug history
        when 34 => --0x22
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.HISTORY;                        --4 bytes of uart history
        when 35 => --0x23
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ADDR;                 --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.BAD_TRANS.DATA;                 --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ERROR_MASK;           --Sensor error bits
        when 36 => --0x24
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ADDR;                --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.LAST_TRANS.DATA;                --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ERROR_MASK;          --Sensor error bits
        when 37 => --0x25
          localRdData( 0)            <=  reg_data(37)( 0);                                 --Reset monitoring error counters
        when 38 => --0x26
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BAD_SOF;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;      --Monitoring errors. Count of invalid byte types in parsing.
        when 39 => --0x27
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
        when 40 => --0x28
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_TIMEOUT;             --Monitoring errors. Count of invalid byte types in parsing.
        when 41 => --0x29
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_UNKNOWN;             --Monitoring errors. Count of invalid byte types in parsing.
        when 42 => --0x2a
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.UART_BYTES;                     --Count of UART bytes from CM MCU
        when 43 => --0x2b
          localRdData(31 downto  0)  <=  reg_data(43)(31 downto  0);                       --Count to wait for in state machine before timing out (50Mhz clk)
        when 44 => --0x2c
          localRdData( 0)            <=  reg_data(44)( 0);                                 --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data(44)( 1);                                 --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data(44)( 2);                                 --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(2).CTRL.PWR_GOOD;                          --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(2).CTRL.STATE;                             --CM power up state
          localRdData( 8)            <=  reg_data(44)( 8);                                 --CM power is good
          localRdData( 9)            <=  Mon.CM(2).CTRL.PWR_ENABLED;                       --power is enabled
          localRdData(10)            <=  Mon.CM(2).CTRL.IOS_ENABLED;                       --IOs to CM are enabled
          localRdData(11)            <=  reg_data(44)(11);                                 --phy_lane_control is enabled
        when 45 => --0x2d
          localRdData(31 downto  0)  <=  reg_data(45)(31 downto  0);                       --Contious phy_lane_up signals required to lock phylane control
        when 46 => --0x2e
          localRdData(23 downto  0)  <=  reg_data(46)(23 downto  0);                       --Time spent waiting for phylane to stabilize
        when 64 => --0x40
          localRdData( 0)            <=  Mon.CM(2).C2C.CONFIG_ERROR;                       --C2C config error
          localRdData( 1)            <=  Mon.CM(2).C2C.LINK_ERROR;                         --C2C link error
          localRdData( 2)            <=  Mon.CM(2).C2C.LINK_GOOD;                          --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(2).C2C.MB_ERROR;                           --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(2).C2C.DO_CC;                              --Aurora do CC
          localRdData( 5)            <=  reg_data(64)( 5);                                 --C2C initialize
          localRdData( 8)            <=  Mon.CM(2).C2C.PHY_RESET;                          --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(2).C2C.PHY_GT_PLL_LOCK;                    --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(2).C2C.PHY_MMCM_LOL;                       --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(2).C2C.PHY_LANE_UP;                        --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(2).C2C.PHY_HARD_ERR;                       --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(2).C2C.PHY_SOFT_ERR;                       --Aurora phy soft error
          localRdData(20)            <=  Mon.CM(2).C2C.CPLL_LOCK;                          --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(2).C2C.EYESCAN_DATA_ERROR;                 --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(64)(22);                                 --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(64)(23);                                 --DEBUG eyescan trigger
          localRdData(31 downto 24)  <=  Mon.CM(2).C2C.DMONITOR;                           --DEBUG d monitor
        when 65 => --0x41
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C.RX.BUF_STATUS;                      --DEBUG rx buf status
          localRdData( 9 downto  3)  <=  Mon.CM(2).C2C.RX.MONITOR;                         --DEBUG rx status
          localRdData(10)            <=  Mon.CM(2).C2C.RX.PRBS_ERR;                        --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(2).C2C.RX.RESET_DONE;                      --DEBUG rx reset done
          localRdData(12)            <=  reg_data(65)(12);                                 --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(65)(13);                                 --DEBUG rx CDR hold
          localRdData(14)            <=  reg_data(65)(14);                                 --DEBUG rx DFE AGC HOLD
          localRdData(15)            <=  reg_data(65)(15);                                 --DEBUG rx DFE AGC OVERRIDE
          localRdData(16)            <=  reg_data(65)(16);                                 --DEBUG rx DFE LF HOLD
          localRdData(17)            <=  reg_data(65)(17);                                 --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(65)(18);                                 --DEBUG rx LPM ENABLE
          localRdData(19)            <=  reg_data(65)(19);                                 --DEBUG rx LPM HF OVERRIDE enable
          localRdData(20)            <=  reg_data(65)(20);                                 --DEBUG rx LPM LFKL override
          localRdData(22 downto 21)  <=  reg_data(65)(22 downto 21);                       --DEBUG rx monitor select
          localRdData(23)            <=  reg_data(65)(23);                                 --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(65)(24);                                 --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(65)(25);                                 --DEBUG rx PRBS counter reset
          localRdData(28 downto 26)  <=  reg_data(65)(28 downto 26);                       --DEBUG rx PRBS select
        when 66 => --0x42
          localRdData( 1 downto  0)  <=  Mon.CM(2).C2C.TX.BUF_STATUS;                      --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(2).C2C.TX.RESET_DONE;                      --DEBUG tx reset done
          localRdData( 6 downto  3)  <=  reg_data(66)( 6 downto  3);                       --DEBUG tx diff control
          localRdData( 7)            <=  reg_data(66)( 7);                                 --DEBUG tx inhibit
          localRdData(14 downto  8)  <=  reg_data(66)(14 downto  8);                       --DEBUG tx main cursor
          localRdData(15)            <=  reg_data(66)(15);                                 --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(66)(16);                                 --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(66)(17);                                 --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(66)(22 downto 18);                       --DEBUG post cursor
          localRdData(23)            <=  reg_data(66)(23);                                 --DEBUG force PRBS error
          localRdData(26 downto 24)  <=  reg_data(66)(26 downto 24);                       --DEBUG PRBS select
          localRdData(31 downto 27)  <=  reg_data(66)(31 downto 27);                       --DEBUG pre cursor
        when 67 => --0x43
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 68 => --0x44
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 69 => --0x45
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 70 => --0x46
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 71 => --0x47
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 72 => --0x48
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 73 => --0x49
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 74 => --0x4a
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C.CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 76 => --0x4c
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C.CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 77 => --0x4d
          localRdData( 7 downto  0)  <=  reg_data(77)( 7 downto  0);                       --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(2).MONITOR.ACTIVE;                         --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(2).MONITOR.HISTORY_VALID;                  --bytes valid in debug history
        when 78 => --0x4e
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.HISTORY;                        --4 bytes of uart history
        when 79 => --0x4f
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ADDR;                 --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.BAD_TRANS.DATA;                 --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ERROR_MASK;           --Sensor error bits
        when 80 => --0x50
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ADDR;                --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.LAST_TRANS.DATA;                --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ERROR_MASK;          --Sensor error bits
        when 81 => --0x51
          localRdData( 0)            <=  reg_data(81)( 0);                                 --Reset monitoring error counters
        when 82 => --0x52
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BAD_SOF;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;      --Monitoring errors. Count of invalid byte types in parsing.
        when 83 => --0x53
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
        when 84 => --0x54
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;      --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_TIMEOUT;             --Monitoring errors. Count of invalid byte types in parsing.
        when 85 => --0x55
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_UNKNOWN;             --Monitoring errors. Count of invalid byte types in parsing.
        when 86 => --0x56
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.UART_BYTES;                     --Count of UART bytes from CM MCU
        when 87 => --0x57
          localRdData(31 downto  0)  <=  reg_data(87)(31 downto  0);                       --Count to wait for in state machine before timing out (50Mhz clk)


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.CM(1).CTRL.ENABLE_UC            <=  reg_data( 0)( 0);               
  Ctrl.CM(1).CTRL.ENABLE_PWR           <=  reg_data( 0)( 1);               
  Ctrl.CM(1).CTRL.OVERRIDE_PWR_GOOD    <=  reg_data( 0)( 2);               
  Ctrl.CM(1).CTRL.ERROR_STATE_RESET    <=  reg_data( 0)( 8);               
  Ctrl.CM(1).CTRL.ENABLE_PHY_CTRL      <=  reg_data( 0)(11);               
  Ctrl.CM(1).CTRL.PHY_READ_TIME        <=  reg_data( 2)(23 downto  0);     
  Ctrl.CM(1).CTRL.PHY_LANE_STABLE      <=  reg_data( 1)(31 downto  0);     
  Ctrl.CM(1).C2C.EYESCAN_TRIGGER       <=  reg_data(20)(23);               
  Ctrl.CM(1).C2C.EYESCAN_RESET         <=  reg_data(20)(22);               
  Ctrl.CM(1).C2C.INITIALIZE            <=  reg_data(20)( 5);               
  Ctrl.CM(1).C2C.RX.DFE_LPM_RESET      <=  reg_data(21)(17);               
  Ctrl.CM(1).C2C.RX.PRBS_SEL           <=  reg_data(21)(28 downto 26);     
  Ctrl.CM(1).C2C.RX.PRBS_CNT_RST       <=  reg_data(21)(25);               
  Ctrl.CM(1).C2C.RX.PMA_RESET          <=  reg_data(21)(24);               
  Ctrl.CM(1).C2C.RX.PCS_RESET          <=  reg_data(21)(23);               
  Ctrl.CM(1).C2C.RX.MON_SEL            <=  reg_data(21)(22 downto 21);     
  Ctrl.CM(1).C2C.RX.LPM_LFKL_OVERRIDE  <=  reg_data(21)(20);               
  Ctrl.CM(1).C2C.RX.LPM_HF_OVERRIDE    <=  reg_data(21)(19);               
  Ctrl.CM(1).C2C.RX.LPM_EN             <=  reg_data(21)(18);               
  Ctrl.CM(1).C2C.RX.DFE_LF_HOLD        <=  reg_data(21)(16);               
  Ctrl.CM(1).C2C.RX.DFE_AGC_OVERRIDE   <=  reg_data(21)(15);               
  Ctrl.CM(1).C2C.RX.DFE_AGC_HOLD       <=  reg_data(21)(14);               
  Ctrl.CM(1).C2C.RX.CDR_HOLD           <=  reg_data(21)(13);               
  Ctrl.CM(1).C2C.RX.BUF_RESET          <=  reg_data(21)(12);               
  Ctrl.CM(1).C2C.TX.DIFF_CTRL          <=  reg_data(22)( 6 downto  3);     
  Ctrl.CM(1).C2C.TX.INHIBIT            <=  reg_data(22)( 7);               
  Ctrl.CM(1).C2C.TX.MAIN_CURSOR        <=  reg_data(22)(14 downto  8);     
  Ctrl.CM(1).C2C.TX.PCS_RESET          <=  reg_data(22)(15);               
  Ctrl.CM(1).C2C.TX.PMA_RESET          <=  reg_data(22)(16);               
  Ctrl.CM(1).C2C.TX.POLARITY           <=  reg_data(22)(17);               
  Ctrl.CM(1).C2C.TX.POST_CURSOR        <=  reg_data(22)(22 downto 18);     
  Ctrl.CM(1).C2C.TX.PRBS_FORCE_ERR     <=  reg_data(22)(23);               
  Ctrl.CM(1).C2C.TX.PRBS_SEL           <=  reg_data(22)(26 downto 24);     
  Ctrl.CM(1).C2C.TX.PRE_CURSOR         <=  reg_data(22)(31 downto 27);     
  Ctrl.CM(1).MONITOR.COUNT_16X_BAUD    <=  reg_data(33)( 7 downto  0);     
  Ctrl.CM(1).MONITOR.ERRORS.RESET      <=  reg_data(37)( 0);               
  Ctrl.CM(1).MONITOR.SM_TIMEOUT        <=  reg_data(43)(31 downto  0);     
  Ctrl.CM(2).CTRL.ENABLE_UC            <=  reg_data(44)( 0);               
  Ctrl.CM(2).CTRL.ENABLE_PWR           <=  reg_data(44)( 1);               
  Ctrl.CM(2).CTRL.OVERRIDE_PWR_GOOD    <=  reg_data(44)( 2);               
  Ctrl.CM(2).CTRL.ERROR_STATE_RESET    <=  reg_data(44)( 8);               
  Ctrl.CM(2).CTRL.ENABLE_PHY_CTRL      <=  reg_data(44)(11);               
  Ctrl.CM(2).CTRL.PHY_READ_TIME        <=  reg_data(46)(23 downto  0);     
  Ctrl.CM(2).CTRL.PHY_LANE_STABLE      <=  reg_data(45)(31 downto  0);     
  Ctrl.CM(2).C2C.EYESCAN_TRIGGER       <=  reg_data(64)(23);               
  Ctrl.CM(2).C2C.EYESCAN_RESET         <=  reg_data(64)(22);               
  Ctrl.CM(2).C2C.INITIALIZE            <=  reg_data(64)( 5);               
  Ctrl.CM(2).C2C.RX.DFE_LPM_RESET      <=  reg_data(65)(17);               
  Ctrl.CM(2).C2C.RX.PRBS_SEL           <=  reg_data(65)(28 downto 26);     
  Ctrl.CM(2).C2C.RX.PRBS_CNT_RST       <=  reg_data(65)(25);               
  Ctrl.CM(2).C2C.RX.PMA_RESET          <=  reg_data(65)(24);               
  Ctrl.CM(2).C2C.RX.PCS_RESET          <=  reg_data(65)(23);               
  Ctrl.CM(2).C2C.RX.MON_SEL            <=  reg_data(65)(22 downto 21);     
  Ctrl.CM(2).C2C.RX.LPM_LFKL_OVERRIDE  <=  reg_data(65)(20);               
  Ctrl.CM(2).C2C.RX.LPM_HF_OVERRIDE    <=  reg_data(65)(19);               
  Ctrl.CM(2).C2C.RX.LPM_EN             <=  reg_data(65)(18);               
  Ctrl.CM(2).C2C.RX.DFE_LF_HOLD        <=  reg_data(65)(16);               
  Ctrl.CM(2).C2C.RX.DFE_AGC_OVERRIDE   <=  reg_data(65)(15);               
  Ctrl.CM(2).C2C.RX.DFE_AGC_HOLD       <=  reg_data(65)(14);               
  Ctrl.CM(2).C2C.RX.CDR_HOLD           <=  reg_data(65)(13);               
  Ctrl.CM(2).C2C.RX.BUF_RESET          <=  reg_data(65)(12);               
  Ctrl.CM(2).C2C.TX.DIFF_CTRL          <=  reg_data(66)( 6 downto  3);     
  Ctrl.CM(2).C2C.TX.INHIBIT            <=  reg_data(66)( 7);               
  Ctrl.CM(2).C2C.TX.MAIN_CURSOR        <=  reg_data(66)(14 downto  8);     
  Ctrl.CM(2).C2C.TX.PCS_RESET          <=  reg_data(66)(15);               
  Ctrl.CM(2).C2C.TX.PMA_RESET          <=  reg_data(66)(16);               
  Ctrl.CM(2).C2C.TX.POLARITY           <=  reg_data(66)(17);               
  Ctrl.CM(2).C2C.TX.POST_CURSOR        <=  reg_data(66)(22 downto 18);     
  Ctrl.CM(2).C2C.TX.PRBS_FORCE_ERR     <=  reg_data(66)(23);               
  Ctrl.CM(2).C2C.TX.PRBS_SEL           <=  reg_data(66)(26 downto 24);     
  Ctrl.CM(2).C2C.TX.PRE_CURSOR         <=  reg_data(66)(31 downto 27);     
  Ctrl.CM(2).MONITOR.COUNT_16X_BAUD    <=  reg_data(77)( 7 downto  0);     
  Ctrl.CM(2).MONITOR.ERRORS.RESET      <=  reg_data(81)( 0);               
  Ctrl.CM(2).MONITOR.SM_TIMEOUT        <=  reg_data(87)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)( 0)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ENABLE_UC;
      reg_data( 0)( 1)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ENABLE_PWR;
      reg_data( 0)( 2)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.OVERRIDE_PWR_GOOD;
      reg_data( 0)( 8)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ERROR_STATE_RESET;
      reg_data( 0)(11)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ENABLE_PHY_CTRL;
      reg_data( 2)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.PHY_READ_TIME;
      reg_data( 1)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.PHY_LANE_STABLE;
      reg_data(20)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.EYESCAN_TRIGGER;
      reg_data(20)(22)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.EYESCAN_RESET;
      reg_data(20)( 5)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.INITIALIZE;
      reg_data(21)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.DFE_LPM_RESET;
      reg_data(21)(28 downto 26)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.PRBS_SEL;
      reg_data(21)(25)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.PRBS_CNT_RST;
      reg_data(21)(24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.PMA_RESET;
      reg_data(21)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.PCS_RESET;
      reg_data(21)(22 downto 21)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.MON_SEL;
      reg_data(21)(20)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.LPM_LFKL_OVERRIDE;
      reg_data(21)(19)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.LPM_HF_OVERRIDE;
      reg_data(21)(18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.LPM_EN;
      reg_data(21)(16)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.DFE_LF_HOLD;
      reg_data(21)(15)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.DFE_AGC_OVERRIDE;
      reg_data(21)(14)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.DFE_AGC_HOLD;
      reg_data(21)(13)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.CDR_HOLD;
      reg_data(21)(12)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.RX.BUF_RESET;
      reg_data(22)( 6 downto  3)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.DIFF_CTRL;
      reg_data(22)( 7)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.INHIBIT;
      reg_data(22)(14 downto  8)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.MAIN_CURSOR;
      reg_data(22)(15)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.PCS_RESET;
      reg_data(22)(16)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.PMA_RESET;
      reg_data(22)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.POLARITY;
      reg_data(22)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.POST_CURSOR;
      reg_data(22)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.PRBS_FORCE_ERR;
      reg_data(22)(26 downto 24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.PRBS_SEL;
      reg_data(22)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(1).C2C.TX.PRE_CURSOR;
      reg_data(33)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.COUNT_16X_BAUD;
      reg_data(37)( 0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.ERRORS.RESET;
      reg_data(43)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.SM_TIMEOUT;
      reg_data(44)( 0)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ENABLE_UC;
      reg_data(44)( 1)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ENABLE_PWR;
      reg_data(44)( 2)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.OVERRIDE_PWR_GOOD;
      reg_data(44)( 8)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ERROR_STATE_RESET;
      reg_data(44)(11)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ENABLE_PHY_CTRL;
      reg_data(46)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.PHY_READ_TIME;
      reg_data(45)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.PHY_LANE_STABLE;
      reg_data(64)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.EYESCAN_TRIGGER;
      reg_data(64)(22)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.EYESCAN_RESET;
      reg_data(64)( 5)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.INITIALIZE;
      reg_data(65)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.DFE_LPM_RESET;
      reg_data(65)(28 downto 26)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.PRBS_SEL;
      reg_data(65)(25)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.PRBS_CNT_RST;
      reg_data(65)(24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.PMA_RESET;
      reg_data(65)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.PCS_RESET;
      reg_data(65)(22 downto 21)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.MON_SEL;
      reg_data(65)(20)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.LPM_LFKL_OVERRIDE;
      reg_data(65)(19)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.LPM_HF_OVERRIDE;
      reg_data(65)(18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.LPM_EN;
      reg_data(65)(16)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.DFE_LF_HOLD;
      reg_data(65)(15)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.DFE_AGC_OVERRIDE;
      reg_data(65)(14)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.DFE_AGC_HOLD;
      reg_data(65)(13)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.CDR_HOLD;
      reg_data(65)(12)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.RX.BUF_RESET;
      reg_data(66)( 6 downto  3)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.DIFF_CTRL;
      reg_data(66)( 7)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.INHIBIT;
      reg_data(66)(14 downto  8)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.MAIN_CURSOR;
      reg_data(66)(15)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.PCS_RESET;
      reg_data(66)(16)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.PMA_RESET;
      reg_data(66)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.POLARITY;
      reg_data(66)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.POST_CURSOR;
      reg_data(66)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.PRBS_FORCE_ERR;
      reg_data(66)(26 downto 24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.PRBS_SEL;
      reg_data(66)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(2).C2C.TX.PRE_CURSOR;
      reg_data(77)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.COUNT_16X_BAUD;
      reg_data(81)( 0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.ERRORS.RESET;
      reg_data(87)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.SM_TIMEOUT;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.CM(1).C2C.CNT.RESET_COUNTERS <= '0';
      Ctrl.CM(2).C2C.CNT.RESET_COUNTERS <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(6 downto 0))) is
        when 0 => --0x0
          reg_data( 0)( 0)                   <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data( 0)( 1)                   <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data( 0)( 2)                   <=  localWrData( 2);                --Ignore power good from CM
          reg_data( 0)( 8)                   <=  localWrData( 8);                --CM power is good
          reg_data( 0)(11)                   <=  localWrData(11);                --phy_lane_control is enabled
        when 1 => --0x1
          reg_data( 1)(31 downto  0)         <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 2 => --0x2
          reg_data( 2)(23 downto  0)         <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 75 => --0x4b
          Ctrl.CM(2).C2C.CNT.RESET_COUNTERS  <=  localWrData( 0);               
        when 66 => --0x42
          reg_data(66)( 6 downto  3)         <=  localWrData( 6 downto  3);      --DEBUG tx diff control
          reg_data(66)( 7)                   <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(66)(14 downto  8)         <=  localWrData(14 downto  8);      --DEBUG tx main cursor
          reg_data(66)(15)                   <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(66)(16)                   <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(66)(17)                   <=  localWrData(17);                --DEBUG tx polarity
          reg_data(66)(22 downto 18)         <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(66)(23)                   <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(66)(26 downto 24)         <=  localWrData(26 downto 24);      --DEBUG PRBS select
          reg_data(66)(31 downto 27)         <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 37 => --0x25
          reg_data(37)( 0)                   <=  localWrData( 0);                --Reset monitoring error counters
        when 65 => --0x41
          reg_data(65)(12)                   <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(65)(13)                   <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(65)(14)                   <=  localWrData(14);                --DEBUG rx DFE AGC HOLD
          reg_data(65)(15)                   <=  localWrData(15);                --DEBUG rx DFE AGC OVERRIDE
          reg_data(65)(16)                   <=  localWrData(16);                --DEBUG rx DFE LF HOLD
          reg_data(65)(17)                   <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(65)(18)                   <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(65)(19)                   <=  localWrData(19);                --DEBUG rx LPM HF OVERRIDE enable
          reg_data(65)(20)                   <=  localWrData(20);                --DEBUG rx LPM LFKL override
          reg_data(65)(22 downto 21)         <=  localWrData(22 downto 21);      --DEBUG rx monitor select
          reg_data(65)(23)                   <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(65)(24)                   <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(65)(25)                   <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(65)(28 downto 26)         <=  localWrData(28 downto 26);      --DEBUG rx PRBS select
        when 33 => --0x21
          reg_data(33)( 7 downto  0)         <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
        when 64 => --0x40
          reg_data(64)( 5)                   <=  localWrData( 5);                --C2C initialize
          reg_data(64)(22)                   <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(64)(23)                   <=  localWrData(23);                --DEBUG eyescan trigger
        when 43 => --0x2b
          reg_data(43)(31 downto  0)         <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)
        when 44 => --0x2c
          reg_data(44)( 0)                   <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data(44)( 1)                   <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data(44)( 2)                   <=  localWrData( 2);                --Ignore power good from CM
          reg_data(44)( 8)                   <=  localWrData( 8);                --CM power is good
          reg_data(44)(11)                   <=  localWrData(11);                --phy_lane_control is enabled
        when 45 => --0x2d
          reg_data(45)(31 downto  0)         <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 46 => --0x2e
          reg_data(46)(23 downto  0)         <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 77 => --0x4d
          reg_data(77)( 7 downto  0)         <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
        when 81 => --0x51
          reg_data(81)( 0)                   <=  localWrData( 0);                --Reset monitoring error counters
        when 20 => --0x14
          reg_data(20)( 5)                   <=  localWrData( 5);                --C2C initialize
          reg_data(20)(22)                   <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(20)(23)                   <=  localWrData(23);                --DEBUG eyescan trigger
        when 21 => --0x15
          reg_data(21)(12)                   <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(21)(13)                   <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(21)(14)                   <=  localWrData(14);                --DEBUG rx DFE AGC HOLD
          reg_data(21)(15)                   <=  localWrData(15);                --DEBUG rx DFE AGC OVERRIDE
          reg_data(21)(16)                   <=  localWrData(16);                --DEBUG rx DFE LF HOLD
          reg_data(21)(17)                   <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(21)(18)                   <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(21)(19)                   <=  localWrData(19);                --DEBUG rx LPM HF OVERRIDE enable
          reg_data(21)(20)                   <=  localWrData(20);                --DEBUG rx LPM LFKL override
          reg_data(21)(22 downto 21)         <=  localWrData(22 downto 21);      --DEBUG rx monitor select
          reg_data(21)(23)                   <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(21)(24)                   <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(21)(25)                   <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(21)(28 downto 26)         <=  localWrData(28 downto 26);      --DEBUG rx PRBS select
        when 22 => --0x16
          reg_data(22)( 6 downto  3)         <=  localWrData( 6 downto  3);      --DEBUG tx diff control
          reg_data(22)( 7)                   <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(22)(14 downto  8)         <=  localWrData(14 downto  8);      --DEBUG tx main cursor
          reg_data(22)(15)                   <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(22)(16)                   <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(22)(17)                   <=  localWrData(17);                --DEBUG tx polarity
          reg_data(22)(22 downto 18)         <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(22)(23)                   <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(22)(26 downto 24)         <=  localWrData(26 downto 24);      --DEBUG PRBS select
          reg_data(22)(31 downto 27)         <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 87 => --0x57
          reg_data(87)(31 downto  0)         <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)
        when 31 => --0x1f
          Ctrl.CM(1).C2C.CNT.RESET_COUNTERS  <=  localWrData( 0);               

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;