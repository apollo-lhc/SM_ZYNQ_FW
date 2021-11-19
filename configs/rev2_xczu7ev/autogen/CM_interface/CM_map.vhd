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
use work.CM_Ctrl.all;

entity CM_map is
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
    
    Mon              : in  CM_Mon_t;
    Ctrl             : out CM_Ctrl_t
        
    );
end entity CM_map;
architecture behavioral of CM_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 4;
--  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
--  signal delayLatchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 10
,			1 => 10
,			2 => 10
,			3 => 10);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000000"
,			1 => x"00000800"
,			2 => x"00001000"
,			3 => x"00001800");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  
  
  signal reg_data :  slv32_array_t(integer range 0 to 7221);
  constant Default_reg_data : slv32_array_t(integer range 0 to 7221) := (others => x"00000000");
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
elsif BRAM_MISO(2).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(2).rd_data;
elsif BRAM_MISO(3).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(3).rd_data;

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
          
        when 1024 => --0x400
          localRdData( 0)            <=  Mon.CM(1).C2C(1).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.CM(1).C2C(1).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.CM(1).C2C(1).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(1).C2C(1).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(1).C2C(1).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(1024)( 5);                                      --C2C initialize
          localRdData( 8)            <=  Mon.CM(1).C2C(1).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(1).C2C(1).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(1).C2C(1).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(1).C2C(1).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(1).C2C(1).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(1).C2C(1).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(1).C2C(1).STATUS.LINK_IN_FW;                      --FW includes this link
        when 1028 => --0x404
          localRdData(15 downto  0)  <=  Mon.CM(1).C2C(1).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(1).C2C(1).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(1).C2C(1).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(1).C2C(1).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(1028)(22);                                      --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(1028)(23);                                      --DEBUG eyescan trigger
        when 1029 => --0x405
          localRdData(15 downto  0)  <=  reg_data(1029)(15 downto  0);                            --bit 2 is DRP uber reset
        when 1030 => --0x406
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(1).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.CM(1).C2C(1).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.CM(1).C2C(1).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(1).C2C(1).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(12)            <=  reg_data(1030)(12);                                      --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(1030)(13);                                      --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(1030)(17);                                      --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(1030)(18);                                      --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(1030)(23);                                      --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(1030)(24);                                      --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(1030)(25);                                      --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(1030)(29 downto 26);                            --DEBUG rx PRBS select
        when 1031 => --0x407
          localRdData( 2 downto  0)  <=  reg_data(1031)( 2 downto  0);                            --DEBUG rx rate
        when 1032 => --0x408
          localRdData( 1 downto  0)  <=  Mon.CM(1).C2C(1).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(1).C2C(1).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(1032)( 7);                                      --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(1032)(15);                                      --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(1032)(16);                                      --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(1032)(17);                                      --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(1032)(22 downto 18);                            --DEBUG post cursor
          localRdData(23)            <=  reg_data(1032)(23);                                      --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(1032)(31 downto 27);                            --DEBUG pre cursor
        when 1033 => --0x409
          localRdData( 3 downto  0)  <=  reg_data(1033)( 3 downto  0);                            --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(1033)( 8 downto  4);                            --DEBUG tx diff control
        when 1040 => --0x410
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 1041 => --0x411
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 1042 => --0x412
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 1043 => --0x413
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 1044 => --0x414
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 1045 => --0x415
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 1046 => --0x416
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 1047 => --0x417
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 1049 => --0x419
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 1050 => --0x41a
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 1051 => --0x41b
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 1052 => --0x41c
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).COUNTERS.WAITING_TIMEOUTS;              --Count for phylane in error state
        when 1056 => --0x420
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.ADDR_LSB;               --
        when 1057 => --0x421
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.ADDR_MSB;               --
        when 1058 => --0x422
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.SIZE;                   --
        when 1059 => --0x423
          localRdData( 0)            <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXI.VALID;                  --
        when 1060 => --0x424
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.ADDR_LSB;           --
        when 1061 => --0x425
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.ADDR_MSB;           --
        when 1062 => --0x426
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.SIZE;               --
        when 1063 => --0x427
          localRdData( 0)            <=  Mon.CM(1).C2C(1).BRIDGE_INFO.AXILITE.VALID;              --
        when 1072 => --0x430
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).USER_FREQ;                              --Measured Freq of clock
        when 1073 => --0x431
          localRdData(23 downto  0)  <=  reg_data(1073)(23 downto  0);                            --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(1073)(24);                                      --phy_lane_control is enabled
        when 1074 => --0x432
          localRdData(19 downto  0)  <=  reg_data(1074)(19 downto  0);                            --Contious phy_lane_up signals required to lock phylane control
        when 1075 => --0x433
          localRdData( 7 downto  0)  <=  reg_data(1075)( 7 downto  0);                            --Number of failures before we reset the pma
        when 1076 => --0x434
          localRdData(31 downto  0)  <=  reg_data(1076)(31 downto  0);                            --Max single bit error rate
        when 1077 => --0x435
          localRdData(31 downto  0)  <=  reg_data(1077)(31 downto  0);                            --Max multi  bit error rate
        when 3072 => --0xc00
          localRdData( 0)            <=  Mon.CM(1).C2C(2).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.CM(1).C2C(2).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.CM(1).C2C(2).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(1).C2C(2).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(1).C2C(2).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(3072)( 5);                                      --C2C initialize
          localRdData( 8)            <=  Mon.CM(1).C2C(2).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(1).C2C(2).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(1).C2C(2).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(1).C2C(2).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(1).C2C(2).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(1).C2C(2).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(1).C2C(2).STATUS.LINK_IN_FW;                      --FW includes this link
        when 3076 => --0xc04
          localRdData(15 downto  0)  <=  Mon.CM(1).C2C(2).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(1).C2C(2).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(1).C2C(2).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(1).C2C(2).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(3076)(22);                                      --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(3076)(23);                                      --DEBUG eyescan trigger
        when 3077 => --0xc05
          localRdData(15 downto  0)  <=  reg_data(3077)(15 downto  0);                            --bit 2 is DRP uber reset
        when 3078 => --0xc06
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(2).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.CM(1).C2C(2).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.CM(1).C2C(2).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(1).C2C(2).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(12)            <=  reg_data(3078)(12);                                      --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(3078)(13);                                      --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(3078)(17);                                      --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(3078)(18);                                      --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(3078)(23);                                      --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(3078)(24);                                      --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(3078)(25);                                      --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(3078)(29 downto 26);                            --DEBUG rx PRBS select
        when 3079 => --0xc07
          localRdData( 2 downto  0)  <=  reg_data(3079)( 2 downto  0);                            --DEBUG rx rate
        when 3080 => --0xc08
          localRdData( 1 downto  0)  <=  Mon.CM(1).C2C(2).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(1).C2C(2).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(3080)( 7);                                      --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(3080)(15);                                      --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(3080)(16);                                      --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(3080)(17);                                      --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(3080)(22 downto 18);                            --DEBUG post cursor
          localRdData(23)            <=  reg_data(3080)(23);                                      --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(3080)(31 downto 27);                            --DEBUG pre cursor
        when 3081 => --0xc09
          localRdData( 3 downto  0)  <=  reg_data(3081)( 3 downto  0);                            --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(3081)( 8 downto  4);                            --DEBUG tx diff control
        when 3088 => --0xc10
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 3089 => --0xc11
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 3090 => --0xc12
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 3091 => --0xc13
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 3092 => --0xc14
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 3093 => --0xc15
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 3094 => --0xc16
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 3095 => --0xc17
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 3097 => --0xc19
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 3098 => --0xc1a
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 3099 => --0xc1b
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 3100 => --0xc1c
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).COUNTERS.WAITING_TIMEOUTS;              --Count for phylane in error state
        when 3104 => --0xc20
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.ADDR_LSB;               --
        when 3105 => --0xc21
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.ADDR_MSB;               --
        when 3106 => --0xc22
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.SIZE;                   --
        when 3107 => --0xc23
          localRdData( 0)            <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXI.VALID;                  --
        when 3108 => --0xc24
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.ADDR_LSB;           --
        when 3109 => --0xc25
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.ADDR_MSB;           --
        when 3110 => --0xc26
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.SIZE;               --
        when 3111 => --0xc27
          localRdData( 0)            <=  Mon.CM(1).C2C(2).BRIDGE_INFO.AXILITE.VALID;              --
        when 3120 => --0xc30
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).USER_FREQ;                              --Measured Freq of clock
        when 3121 => --0xc31
          localRdData(23 downto  0)  <=  reg_data(3121)(23 downto  0);                            --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(3121)(24);                                      --phy_lane_control is enabled
        when 3122 => --0xc32
          localRdData(19 downto  0)  <=  reg_data(3122)(19 downto  0);                            --Contious phy_lane_up signals required to lock phylane control
        when 3123 => --0xc33
          localRdData( 7 downto  0)  <=  reg_data(3123)( 7 downto  0);                            --Number of failures before we reset the pma
        when 3124 => --0xc34
          localRdData(31 downto  0)  <=  reg_data(3124)(31 downto  0);                            --Max single bit error rate
        when 3125 => --0xc35
          localRdData(31 downto  0)  <=  reg_data(3125)(31 downto  0);                            --Max multi  bit error rate
        when 0 => --0x0
          localRdData( 0)            <=  reg_data( 0)( 0);                                        --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data( 0)( 1);                                        --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data( 0)( 2);                                        --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(1).CTRL.PWR_GOOD;                                 --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(1).CTRL.STATE;                                    --CM power up state
          localRdData( 8)            <=  reg_data( 0)( 8);                                        --CM power is good
          localRdData( 9)            <=  Mon.CM(1).CTRL.PWR_ENABLED;                              --power is enabled
          localRdData(10)            <=  Mon.CM(1).CTRL.IOS_ENABLED;                              --IOs to CM are enabled
        when 112 => --0x70
          localRdData( 7 downto  0)  <=  reg_data(112)( 7 downto  0);                             --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(1).MONITOR.ACTIVE;                                --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(1).MONITOR.HISTORY_VALID;                         --bytes valid in debug history
          localRdData(16)            <=  reg_data(112)(16);                                       --Enable readout
        when 113 => --0x71
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.HISTORY;                               --4 bytes of uart history
        when 114 => --0x72
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ADDR;                        --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.BAD_TRANS.DATA;                        --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ERROR_MASK;                  --Sensor error bits
        when 115 => --0x73
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ADDR;                       --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.LAST_TRANS.DATA;                       --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ERROR_MASK;                 --Sensor error bits
        when 116 => --0x74
          localRdData( 0)            <=  reg_data(116)( 0);                                       --Reset monitoring error counters
        when 117 => --0x75
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BAD_SOF;                    --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;             --Monitoring errors. Count of invalid byte types in parsing.
        when 118 => --0x76
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
        when 119 => --0x77
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_TIMEOUT;                    --Monitoring errors. Count of invalid byte types in parsing.
        when 120 => --0x78
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_UNKNOWN;                    --Monitoring errors. Count of invalid byte types in parsing.
        when 121 => --0x79
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.UART_BYTES;                            --Count of UART bytes from CM MCU
        when 122 => --0x7a
          localRdData(31 downto  0)  <=  reg_data(122)(31 downto  0);                             --Count to wait for in state machine before timing out (50Mhz clk)
        when 5120 => --0x1400
          localRdData( 0)            <=  Mon.CM(2).C2C(1).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.CM(2).C2C(1).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.CM(2).C2C(1).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(2).C2C(1).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(2).C2C(1).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(5120)( 5);                                      --C2C initialize
          localRdData( 8)            <=  Mon.CM(2).C2C(1).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(2).C2C(1).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(2).C2C(1).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(2).C2C(1).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(2).C2C(1).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(2).C2C(1).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(2).C2C(1).STATUS.LINK_IN_FW;                      --FW includes this link
        when 5124 => --0x1404
          localRdData(15 downto  0)  <=  Mon.CM(2).C2C(1).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(2).C2C(1).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(2).C2C(1).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(2).C2C(1).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(5124)(22);                                      --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(5124)(23);                                      --DEBUG eyescan trigger
        when 5125 => --0x1405
          localRdData(15 downto  0)  <=  reg_data(5125)(15 downto  0);                            --bit 2 is DRP uber reset
        when 5126 => --0x1406
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(1).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.CM(2).C2C(1).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.CM(2).C2C(1).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(2).C2C(1).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(12)            <=  reg_data(5126)(12);                                      --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(5126)(13);                                      --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(5126)(17);                                      --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(5126)(18);                                      --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(5126)(23);                                      --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(5126)(24);                                      --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(5126)(25);                                      --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(5126)(29 downto 26);                            --DEBUG rx PRBS select
        when 5127 => --0x1407
          localRdData( 2 downto  0)  <=  reg_data(5127)( 2 downto  0);                            --DEBUG rx rate
        when 5128 => --0x1408
          localRdData( 1 downto  0)  <=  Mon.CM(2).C2C(1).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(2).C2C(1).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(5128)( 7);                                      --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(5128)(15);                                      --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(5128)(16);                                      --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(5128)(17);                                      --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(5128)(22 downto 18);                            --DEBUG post cursor
          localRdData(23)            <=  reg_data(5128)(23);                                      --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(5128)(31 downto 27);                            --DEBUG pre cursor
        when 5129 => --0x1409
          localRdData( 3 downto  0)  <=  reg_data(5129)( 3 downto  0);                            --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(5129)( 8 downto  4);                            --DEBUG tx diff control
        when 5136 => --0x1410
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 5137 => --0x1411
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 5138 => --0x1412
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 5139 => --0x1413
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 5140 => --0x1414
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 5141 => --0x1415
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 5142 => --0x1416
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 5143 => --0x1417
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 5145 => --0x1419
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 5146 => --0x141a
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 5147 => --0x141b
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 5148 => --0x141c
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).COUNTERS.WAITING_TIMEOUTS;              --Count for phylane in error state
        when 5152 => --0x1420
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.ADDR_LSB;               --
        when 5153 => --0x1421
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.ADDR_MSB;               --
        when 5154 => --0x1422
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.SIZE;                   --
        when 5155 => --0x1423
          localRdData( 0)            <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXI.VALID;                  --
        when 5156 => --0x1424
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.ADDR_LSB;           --
        when 5157 => --0x1425
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.ADDR_MSB;           --
        when 5158 => --0x1426
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.SIZE;               --
        when 5159 => --0x1427
          localRdData( 0)            <=  Mon.CM(2).C2C(1).BRIDGE_INFO.AXILITE.VALID;              --
        when 5168 => --0x1430
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).USER_FREQ;                              --Measured Freq of clock
        when 5169 => --0x1431
          localRdData(23 downto  0)  <=  reg_data(5169)(23 downto  0);                            --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(5169)(24);                                      --phy_lane_control is enabled
        when 5170 => --0x1432
          localRdData(19 downto  0)  <=  reg_data(5170)(19 downto  0);                            --Contious phy_lane_up signals required to lock phylane control
        when 5171 => --0x1433
          localRdData( 7 downto  0)  <=  reg_data(5171)( 7 downto  0);                            --Number of failures before we reset the pma
        when 5172 => --0x1434
          localRdData(31 downto  0)  <=  reg_data(5172)(31 downto  0);                            --Max single bit error rate
        when 5173 => --0x1435
          localRdData(31 downto  0)  <=  reg_data(5173)(31 downto  0);                            --Max multi  bit error rate
        when 7168 => --0x1c00
          localRdData( 0)            <=  Mon.CM(2).C2C(2).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.CM(2).C2C(2).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.CM(2).C2C(2).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(2).C2C(2).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(2).C2C(2).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(7168)( 5);                                      --C2C initialize
          localRdData( 8)            <=  Mon.CM(2).C2C(2).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(2).C2C(2).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(2).C2C(2).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(2).C2C(2).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(2).C2C(2).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(2).C2C(2).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(2).C2C(2).STATUS.LINK_IN_FW;                      --FW includes this link
        when 7172 => --0x1c04
          localRdData(15 downto  0)  <=  Mon.CM(2).C2C(2).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(2).C2C(2).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(2).C2C(2).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(2).C2C(2).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(7172)(22);                                      --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(7172)(23);                                      --DEBUG eyescan trigger
        when 7173 => --0x1c05
          localRdData(15 downto  0)  <=  reg_data(7173)(15 downto  0);                            --bit 2 is DRP uber reset
        when 7174 => --0x1c06
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(2).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.CM(2).C2C(2).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.CM(2).C2C(2).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(2).C2C(2).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(12)            <=  reg_data(7174)(12);                                      --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(7174)(13);                                      --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(7174)(17);                                      --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(7174)(18);                                      --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(7174)(23);                                      --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(7174)(24);                                      --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(7174)(25);                                      --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(7174)(29 downto 26);                            --DEBUG rx PRBS select
        when 7175 => --0x1c07
          localRdData( 2 downto  0)  <=  reg_data(7175)( 2 downto  0);                            --DEBUG rx rate
        when 7176 => --0x1c08
          localRdData( 1 downto  0)  <=  Mon.CM(2).C2C(2).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(2).C2C(2).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(7176)( 7);                                      --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(7176)(15);                                      --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(7176)(16);                                      --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(7176)(17);                                      --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(7176)(22 downto 18);                            --DEBUG post cursor
          localRdData(23)            <=  reg_data(7176)(23);                                      --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(7176)(31 downto 27);                            --DEBUG pre cursor
        when 7177 => --0x1c09
          localRdData( 3 downto  0)  <=  reg_data(7177)( 3 downto  0);                            --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(7177)( 8 downto  4);                            --DEBUG tx diff control
        when 7184 => --0x1c10
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 7185 => --0x1c11
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 7186 => --0x1c12
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 7187 => --0x1c13
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 7188 => --0x1c14
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 7189 => --0x1c15
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 7190 => --0x1c16
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 7191 => --0x1c17
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 7193 => --0x1c19
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 7194 => --0x1c1a
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 7195 => --0x1c1b
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 7196 => --0x1c1c
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).COUNTERS.WAITING_TIMEOUTS;              --Count for phylane in error state
        when 7200 => --0x1c20
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.ADDR_LSB;               --
        when 7201 => --0x1c21
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.ADDR_MSB;               --
        when 7202 => --0x1c22
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.SIZE;                   --
        when 7203 => --0x1c23
          localRdData( 0)            <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXI.VALID;                  --
        when 7204 => --0x1c24
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.ADDR_LSB;           --
        when 7205 => --0x1c25
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.ADDR_MSB;           --
        when 7206 => --0x1c26
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.SIZE;               --
        when 7207 => --0x1c27
          localRdData( 0)            <=  Mon.CM(2).C2C(2).BRIDGE_INFO.AXILITE.VALID;              --
        when 7216 => --0x1c30
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).USER_FREQ;                              --Measured Freq of clock
        when 7217 => --0x1c31
          localRdData(23 downto  0)  <=  reg_data(7217)(23 downto  0);                            --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(7217)(24);                                      --phy_lane_control is enabled
        when 7218 => --0x1c32
          localRdData(19 downto  0)  <=  reg_data(7218)(19 downto  0);                            --Contious phy_lane_up signals required to lock phylane control
        when 7219 => --0x1c33
          localRdData( 7 downto  0)  <=  reg_data(7219)( 7 downto  0);                            --Number of failures before we reset the pma
        when 7220 => --0x1c34
          localRdData(31 downto  0)  <=  reg_data(7220)(31 downto  0);                            --Max single bit error rate
        when 7221 => --0x1c35
          localRdData(31 downto  0)  <=  reg_data(7221)(31 downto  0);                            --Max multi  bit error rate
        when 4096 => --0x1000
          localRdData( 0)            <=  reg_data(4096)( 0);                                      --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data(4096)( 1);                                      --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data(4096)( 2);                                      --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(2).CTRL.PWR_GOOD;                                 --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(2).CTRL.STATE;                                    --CM power up state
          localRdData( 8)            <=  reg_data(4096)( 8);                                      --CM power is good
          localRdData( 9)            <=  Mon.CM(2).CTRL.PWR_ENABLED;                              --power is enabled
          localRdData(10)            <=  Mon.CM(2).CTRL.IOS_ENABLED;                              --IOs to CM are enabled
        when 4208 => --0x1070
          localRdData( 7 downto  0)  <=  reg_data(4208)( 7 downto  0);                            --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(2).MONITOR.ACTIVE;                                --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(2).MONITOR.HISTORY_VALID;                         --bytes valid in debug history
          localRdData(16)            <=  reg_data(4208)(16);                                      --Enable readout
        when 4209 => --0x1071
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.HISTORY;                               --4 bytes of uart history
        when 4210 => --0x1072
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ADDR;                        --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.BAD_TRANS.DATA;                        --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ERROR_MASK;                  --Sensor error bits
        when 4211 => --0x1073
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ADDR;                       --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.LAST_TRANS.DATA;                       --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ERROR_MASK;                 --Sensor error bits
        when 4212 => --0x1074
          localRdData( 0)            <=  reg_data(4212)( 0);                                      --Reset monitoring error counters
        when 4213 => --0x1075
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BAD_SOF;                    --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;             --Monitoring errors. Count of invalid byte types in parsing.
        when 4214 => --0x1076
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
        when 4215 => --0x1077
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;             --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_TIMEOUT;                    --Monitoring errors. Count of invalid byte types in parsing.
        when 4216 => --0x1078
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_UNKNOWN;                    --Monitoring errors. Count of invalid byte types in parsing.
        when 4217 => --0x1079
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.UART_BYTES;                            --Count of UART bytes from CM MCU
        when 4218 => --0x107a
          localRdData(31 downto  0)  <=  reg_data(4218)(31 downto  0);                            --Count to wait for in state machine before timing out (50Mhz clk)


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
  Ctrl.CM(1).C2C(1).STATUS.INITIALIZE              <=  reg_data(1024)( 5);               
  Ctrl.CM(1).C2C(1).DEBUG.EYESCAN_RESET            <=  reg_data(1028)(22);               
  Ctrl.CM(1).C2C(1).DEBUG.EYESCAN_TRIGGER          <=  reg_data(1028)(23);               
  Ctrl.CM(1).C2C(1).DEBUG.PCS_RSV_DIN              <=  reg_data(1029)(15 downto  0);     
  Ctrl.CM(1).C2C(1).DEBUG.RX.BUF_RESET             <=  reg_data(1030)(12);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.CDR_HOLD              <=  reg_data(1030)(13);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.DFE_LPM_RESET         <=  reg_data(1030)(17);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.LPM_EN                <=  reg_data(1030)(18);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.PCS_RESET             <=  reg_data(1030)(23);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.PMA_RESET             <=  reg_data(1030)(24);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(1030)(25);               
  Ctrl.CM(1).C2C(1).DEBUG.RX.PRBS_SEL              <=  reg_data(1030)(29 downto 26);     
  Ctrl.CM(1).C2C(1).DEBUG.RX.RATE                  <=  reg_data(1031)( 2 downto  0);     
  Ctrl.CM(1).C2C(1).DEBUG.TX.INHIBIT               <=  reg_data(1032)( 7);               
  Ctrl.CM(1).C2C(1).DEBUG.TX.PCS_RESET             <=  reg_data(1032)(15);               
  Ctrl.CM(1).C2C(1).DEBUG.TX.PMA_RESET             <=  reg_data(1032)(16);               
  Ctrl.CM(1).C2C(1).DEBUG.TX.POLARITY              <=  reg_data(1032)(17);               
  Ctrl.CM(1).C2C(1).DEBUG.TX.POST_CURSOR           <=  reg_data(1032)(22 downto 18);     
  Ctrl.CM(1).C2C(1).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(1032)(23);               
  Ctrl.CM(1).C2C(1).DEBUG.TX.PRE_CURSOR            <=  reg_data(1032)(31 downto 27);     
  Ctrl.CM(1).C2C(1).DEBUG.TX.PRBS_SEL              <=  reg_data(1033)( 3 downto  0);     
  Ctrl.CM(1).C2C(1).DEBUG.TX.DIFF_CTRL             <=  reg_data(1033)( 8 downto  4);     
  Ctrl.CM(1).C2C(1).PHY_READ_TIME                  <=  reg_data(1073)(23 downto  0);     
  Ctrl.CM(1).C2C(1).ENABLE_PHY_CTRL                <=  reg_data(1073)(24);               
  Ctrl.CM(1).C2C(1).PHY_LANE_STABLE                <=  reg_data(1074)(19 downto  0);     
  Ctrl.CM(1).C2C(1).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(1075)( 7 downto  0);     
  Ctrl.CM(1).C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(1076)(31 downto  0);     
  Ctrl.CM(1).C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(1077)(31 downto  0);     
  Ctrl.CM(1).C2C(2).STATUS.INITIALIZE              <=  reg_data(3072)( 5);               
  Ctrl.CM(1).C2C(2).DEBUG.EYESCAN_RESET            <=  reg_data(3076)(22);               
  Ctrl.CM(1).C2C(2).DEBUG.EYESCAN_TRIGGER          <=  reg_data(3076)(23);               
  Ctrl.CM(1).C2C(2).DEBUG.PCS_RSV_DIN              <=  reg_data(3077)(15 downto  0);     
  Ctrl.CM(1).C2C(2).DEBUG.RX.BUF_RESET             <=  reg_data(3078)(12);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.CDR_HOLD              <=  reg_data(3078)(13);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.DFE_LPM_RESET         <=  reg_data(3078)(17);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.LPM_EN                <=  reg_data(3078)(18);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.PCS_RESET             <=  reg_data(3078)(23);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.PMA_RESET             <=  reg_data(3078)(24);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(3078)(25);               
  Ctrl.CM(1).C2C(2).DEBUG.RX.PRBS_SEL              <=  reg_data(3078)(29 downto 26);     
  Ctrl.CM(1).C2C(2).DEBUG.RX.RATE                  <=  reg_data(3079)( 2 downto  0);     
  Ctrl.CM(1).C2C(2).DEBUG.TX.INHIBIT               <=  reg_data(3080)( 7);               
  Ctrl.CM(1).C2C(2).DEBUG.TX.PCS_RESET             <=  reg_data(3080)(15);               
  Ctrl.CM(1).C2C(2).DEBUG.TX.PMA_RESET             <=  reg_data(3080)(16);               
  Ctrl.CM(1).C2C(2).DEBUG.TX.POLARITY              <=  reg_data(3080)(17);               
  Ctrl.CM(1).C2C(2).DEBUG.TX.POST_CURSOR           <=  reg_data(3080)(22 downto 18);     
  Ctrl.CM(1).C2C(2).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(3080)(23);               
  Ctrl.CM(1).C2C(2).DEBUG.TX.PRE_CURSOR            <=  reg_data(3080)(31 downto 27);     
  Ctrl.CM(1).C2C(2).DEBUG.TX.PRBS_SEL              <=  reg_data(3081)( 3 downto  0);     
  Ctrl.CM(1).C2C(2).DEBUG.TX.DIFF_CTRL             <=  reg_data(3081)( 8 downto  4);     
  Ctrl.CM(1).C2C(2).PHY_READ_TIME                  <=  reg_data(3121)(23 downto  0);     
  Ctrl.CM(1).C2C(2).ENABLE_PHY_CTRL                <=  reg_data(3121)(24);               
  Ctrl.CM(1).C2C(2).PHY_LANE_STABLE                <=  reg_data(3122)(19 downto  0);     
  Ctrl.CM(1).C2C(2).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(3123)( 7 downto  0);     
  Ctrl.CM(1).C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(3124)(31 downto  0);     
  Ctrl.CM(1).C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(3125)(31 downto  0);     
  Ctrl.CM(1).CTRL.ENABLE_UC                        <=  reg_data( 0)( 0);                 
  Ctrl.CM(1).CTRL.ENABLE_PWR                       <=  reg_data( 0)( 1);                 
  Ctrl.CM(1).CTRL.OVERRIDE_PWR_GOOD                <=  reg_data( 0)( 2);                 
  Ctrl.CM(1).CTRL.ERROR_STATE_RESET                <=  reg_data( 0)( 8);                 
  Ctrl.CM(1).MONITOR.COUNT_16X_BAUD                <=  reg_data(112)( 7 downto  0);      
  Ctrl.CM(1).MONITOR.ENABLE                        <=  reg_data(112)(16);                
  Ctrl.CM(1).MONITOR.ERRORS.RESET                  <=  reg_data(116)( 0);                
  Ctrl.CM(1).MONITOR.SM_TIMEOUT                    <=  reg_data(122)(31 downto  0);      
  Ctrl.CM(2).C2C(1).STATUS.INITIALIZE              <=  reg_data(5120)( 5);               
  Ctrl.CM(2).C2C(1).DEBUG.EYESCAN_RESET            <=  reg_data(5124)(22);               
  Ctrl.CM(2).C2C(1).DEBUG.EYESCAN_TRIGGER          <=  reg_data(5124)(23);               
  Ctrl.CM(2).C2C(1).DEBUG.PCS_RSV_DIN              <=  reg_data(5125)(15 downto  0);     
  Ctrl.CM(2).C2C(1).DEBUG.RX.BUF_RESET             <=  reg_data(5126)(12);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.CDR_HOLD              <=  reg_data(5126)(13);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.DFE_LPM_RESET         <=  reg_data(5126)(17);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.LPM_EN                <=  reg_data(5126)(18);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.PCS_RESET             <=  reg_data(5126)(23);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.PMA_RESET             <=  reg_data(5126)(24);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(5126)(25);               
  Ctrl.CM(2).C2C(1).DEBUG.RX.PRBS_SEL              <=  reg_data(5126)(29 downto 26);     
  Ctrl.CM(2).C2C(1).DEBUG.RX.RATE                  <=  reg_data(5127)( 2 downto  0);     
  Ctrl.CM(2).C2C(1).DEBUG.TX.INHIBIT               <=  reg_data(5128)( 7);               
  Ctrl.CM(2).C2C(1).DEBUG.TX.PCS_RESET             <=  reg_data(5128)(15);               
  Ctrl.CM(2).C2C(1).DEBUG.TX.PMA_RESET             <=  reg_data(5128)(16);               
  Ctrl.CM(2).C2C(1).DEBUG.TX.POLARITY              <=  reg_data(5128)(17);               
  Ctrl.CM(2).C2C(1).DEBUG.TX.POST_CURSOR           <=  reg_data(5128)(22 downto 18);     
  Ctrl.CM(2).C2C(1).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(5128)(23);               
  Ctrl.CM(2).C2C(1).DEBUG.TX.PRE_CURSOR            <=  reg_data(5128)(31 downto 27);     
  Ctrl.CM(2).C2C(1).DEBUG.TX.PRBS_SEL              <=  reg_data(5129)( 3 downto  0);     
  Ctrl.CM(2).C2C(1).DEBUG.TX.DIFF_CTRL             <=  reg_data(5129)( 8 downto  4);     
  Ctrl.CM(2).C2C(1).PHY_READ_TIME                  <=  reg_data(5169)(23 downto  0);     
  Ctrl.CM(2).C2C(1).ENABLE_PHY_CTRL                <=  reg_data(5169)(24);               
  Ctrl.CM(2).C2C(1).PHY_LANE_STABLE                <=  reg_data(5170)(19 downto  0);     
  Ctrl.CM(2).C2C(1).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(5171)( 7 downto  0);     
  Ctrl.CM(2).C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(5172)(31 downto  0);     
  Ctrl.CM(2).C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(5173)(31 downto  0);     
  Ctrl.CM(2).C2C(2).STATUS.INITIALIZE              <=  reg_data(7168)( 5);               
  Ctrl.CM(2).C2C(2).DEBUG.EYESCAN_RESET            <=  reg_data(7172)(22);               
  Ctrl.CM(2).C2C(2).DEBUG.EYESCAN_TRIGGER          <=  reg_data(7172)(23);               
  Ctrl.CM(2).C2C(2).DEBUG.PCS_RSV_DIN              <=  reg_data(7173)(15 downto  0);     
  Ctrl.CM(2).C2C(2).DEBUG.RX.BUF_RESET             <=  reg_data(7174)(12);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.CDR_HOLD              <=  reg_data(7174)(13);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.DFE_LPM_RESET         <=  reg_data(7174)(17);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.LPM_EN                <=  reg_data(7174)(18);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.PCS_RESET             <=  reg_data(7174)(23);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.PMA_RESET             <=  reg_data(7174)(24);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(7174)(25);               
  Ctrl.CM(2).C2C(2).DEBUG.RX.PRBS_SEL              <=  reg_data(7174)(29 downto 26);     
  Ctrl.CM(2).C2C(2).DEBUG.RX.RATE                  <=  reg_data(7175)( 2 downto  0);     
  Ctrl.CM(2).C2C(2).DEBUG.TX.INHIBIT               <=  reg_data(7176)( 7);               
  Ctrl.CM(2).C2C(2).DEBUG.TX.PCS_RESET             <=  reg_data(7176)(15);               
  Ctrl.CM(2).C2C(2).DEBUG.TX.PMA_RESET             <=  reg_data(7176)(16);               
  Ctrl.CM(2).C2C(2).DEBUG.TX.POLARITY              <=  reg_data(7176)(17);               
  Ctrl.CM(2).C2C(2).DEBUG.TX.POST_CURSOR           <=  reg_data(7176)(22 downto 18);     
  Ctrl.CM(2).C2C(2).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(7176)(23);               
  Ctrl.CM(2).C2C(2).DEBUG.TX.PRE_CURSOR            <=  reg_data(7176)(31 downto 27);     
  Ctrl.CM(2).C2C(2).DEBUG.TX.PRBS_SEL              <=  reg_data(7177)( 3 downto  0);     
  Ctrl.CM(2).C2C(2).DEBUG.TX.DIFF_CTRL             <=  reg_data(7177)( 8 downto  4);     
  Ctrl.CM(2).C2C(2).PHY_READ_TIME                  <=  reg_data(7217)(23 downto  0);     
  Ctrl.CM(2).C2C(2).ENABLE_PHY_CTRL                <=  reg_data(7217)(24);               
  Ctrl.CM(2).C2C(2).PHY_LANE_STABLE                <=  reg_data(7218)(19 downto  0);     
  Ctrl.CM(2).C2C(2).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(7219)( 7 downto  0);     
  Ctrl.CM(2).C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(7220)(31 downto  0);     
  Ctrl.CM(2).C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(7221)(31 downto  0);     
  Ctrl.CM(2).CTRL.ENABLE_UC                        <=  reg_data(4096)( 0);               
  Ctrl.CM(2).CTRL.ENABLE_PWR                       <=  reg_data(4096)( 1);               
  Ctrl.CM(2).CTRL.OVERRIDE_PWR_GOOD                <=  reg_data(4096)( 2);               
  Ctrl.CM(2).CTRL.ERROR_STATE_RESET                <=  reg_data(4096)( 8);               
  Ctrl.CM(2).MONITOR.COUNT_16X_BAUD                <=  reg_data(4208)( 7 downto  0);     
  Ctrl.CM(2).MONITOR.ENABLE                        <=  reg_data(4208)(16);               
  Ctrl.CM(2).MONITOR.ERRORS.RESET                  <=  reg_data(4212)( 0);               
  Ctrl.CM(2).MONITOR.SM_TIMEOUT                    <=  reg_data(4218)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(1024)( 5)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).STATUS.INITIALIZE;
      reg_data(1028)(22)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.EYESCAN_RESET;
      reg_data(1028)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.EYESCAN_TRIGGER;
      reg_data(1029)(15 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.PCS_RSV_DIN;
      reg_data(1030)(12)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.BUF_RESET;
      reg_data(1030)(13)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.CDR_HOLD;
      reg_data(1030)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.DFE_LPM_RESET;
      reg_data(1030)(18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.LPM_EN;
      reg_data(1030)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.PCS_RESET;
      reg_data(1030)(24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.PMA_RESET;
      reg_data(1030)(25)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.PRBS_CNT_RST;
      reg_data(1030)(29 downto 26)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.PRBS_SEL;
      reg_data(1031)( 2 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.RX.RATE;
      reg_data(1032)( 7)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.INHIBIT;
      reg_data(1032)(15)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.PCS_RESET;
      reg_data(1032)(16)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.PMA_RESET;
      reg_data(1032)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.POLARITY;
      reg_data(1032)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.POST_CURSOR;
      reg_data(1032)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(1032)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.PRE_CURSOR;
      reg_data(1033)( 3 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.PRBS_SEL;
      reg_data(1033)( 8 downto  4)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).DEBUG.TX.DIFF_CTRL;
      reg_data(1073)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).PHY_READ_TIME;
      reg_data(1073)(24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).ENABLE_PHY_CTRL;
      reg_data(1074)(19 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).PHY_LANE_STABLE;
      reg_data(1075)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).PHY_LANE_ERRORS_TO_RESET;
      reg_data(1076)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(1077)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data(3072)( 5)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).STATUS.INITIALIZE;
      reg_data(3076)(22)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.EYESCAN_RESET;
      reg_data(3076)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.EYESCAN_TRIGGER;
      reg_data(3077)(15 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.PCS_RSV_DIN;
      reg_data(3078)(12)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.BUF_RESET;
      reg_data(3078)(13)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.CDR_HOLD;
      reg_data(3078)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.DFE_LPM_RESET;
      reg_data(3078)(18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.LPM_EN;
      reg_data(3078)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.PCS_RESET;
      reg_data(3078)(24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.PMA_RESET;
      reg_data(3078)(25)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.PRBS_CNT_RST;
      reg_data(3078)(29 downto 26)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.PRBS_SEL;
      reg_data(3079)( 2 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.RX.RATE;
      reg_data(3080)( 7)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.INHIBIT;
      reg_data(3080)(15)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.PCS_RESET;
      reg_data(3080)(16)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.PMA_RESET;
      reg_data(3080)(17)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.POLARITY;
      reg_data(3080)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.POST_CURSOR;
      reg_data(3080)(23)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(3080)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.PRE_CURSOR;
      reg_data(3081)( 3 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.PRBS_SEL;
      reg_data(3081)( 8 downto  4)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).DEBUG.TX.DIFF_CTRL;
      reg_data(3121)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).PHY_READ_TIME;
      reg_data(3121)(24)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).ENABLE_PHY_CTRL;
      reg_data(3122)(19 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).PHY_LANE_STABLE;
      reg_data(3123)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).PHY_LANE_ERRORS_TO_RESET;
      reg_data(3124)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(3125)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data( 0)( 0)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ENABLE_UC;
      reg_data( 0)( 1)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ENABLE_PWR;
      reg_data( 0)( 2)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.OVERRIDE_PWR_GOOD;
      reg_data( 0)( 8)  <= DEFAULT_CM_CTRL_t.CM(1).CTRL.ERROR_STATE_RESET;
      reg_data(112)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.COUNT_16X_BAUD;
      reg_data(112)(16)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.ENABLE;
      reg_data(116)( 0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.ERRORS.RESET;
      reg_data(122)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(1).MONITOR.SM_TIMEOUT;
      reg_data(5120)( 5)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).STATUS.INITIALIZE;
      reg_data(5124)(22)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.EYESCAN_RESET;
      reg_data(5124)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.EYESCAN_TRIGGER;
      reg_data(5125)(15 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.PCS_RSV_DIN;
      reg_data(5126)(12)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.BUF_RESET;
      reg_data(5126)(13)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.CDR_HOLD;
      reg_data(5126)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.DFE_LPM_RESET;
      reg_data(5126)(18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.LPM_EN;
      reg_data(5126)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.PCS_RESET;
      reg_data(5126)(24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.PMA_RESET;
      reg_data(5126)(25)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.PRBS_CNT_RST;
      reg_data(5126)(29 downto 26)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.PRBS_SEL;
      reg_data(5127)( 2 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.RX.RATE;
      reg_data(5128)( 7)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.INHIBIT;
      reg_data(5128)(15)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.PCS_RESET;
      reg_data(5128)(16)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.PMA_RESET;
      reg_data(5128)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.POLARITY;
      reg_data(5128)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.POST_CURSOR;
      reg_data(5128)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(5128)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.PRE_CURSOR;
      reg_data(5129)( 3 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.PRBS_SEL;
      reg_data(5129)( 8 downto  4)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).DEBUG.TX.DIFF_CTRL;
      reg_data(5169)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).PHY_READ_TIME;
      reg_data(5169)(24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).ENABLE_PHY_CTRL;
      reg_data(5170)(19 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).PHY_LANE_STABLE;
      reg_data(5171)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).PHY_LANE_ERRORS_TO_RESET;
      reg_data(5172)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(5173)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data(7168)( 5)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).STATUS.INITIALIZE;
      reg_data(7172)(22)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.EYESCAN_RESET;
      reg_data(7172)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.EYESCAN_TRIGGER;
      reg_data(7173)(15 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.PCS_RSV_DIN;
      reg_data(7174)(12)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.BUF_RESET;
      reg_data(7174)(13)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.CDR_HOLD;
      reg_data(7174)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.DFE_LPM_RESET;
      reg_data(7174)(18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.LPM_EN;
      reg_data(7174)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.PCS_RESET;
      reg_data(7174)(24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.PMA_RESET;
      reg_data(7174)(25)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.PRBS_CNT_RST;
      reg_data(7174)(29 downto 26)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.PRBS_SEL;
      reg_data(7175)( 2 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.RX.RATE;
      reg_data(7176)( 7)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.INHIBIT;
      reg_data(7176)(15)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.PCS_RESET;
      reg_data(7176)(16)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.PMA_RESET;
      reg_data(7176)(17)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.POLARITY;
      reg_data(7176)(22 downto 18)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.POST_CURSOR;
      reg_data(7176)(23)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(7176)(31 downto 27)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.PRE_CURSOR;
      reg_data(7177)( 3 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.PRBS_SEL;
      reg_data(7177)( 8 downto  4)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).DEBUG.TX.DIFF_CTRL;
      reg_data(7217)(23 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).PHY_READ_TIME;
      reg_data(7217)(24)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).ENABLE_PHY_CTRL;
      reg_data(7218)(19 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).PHY_LANE_STABLE;
      reg_data(7219)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).PHY_LANE_ERRORS_TO_RESET;
      reg_data(7220)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(7221)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data(4096)( 0)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ENABLE_UC;
      reg_data(4096)( 1)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ENABLE_PWR;
      reg_data(4096)( 2)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.OVERRIDE_PWR_GOOD;
      reg_data(4096)( 8)  <= DEFAULT_CM_CTRL_t.CM(2).CTRL.ERROR_STATE_RESET;
      reg_data(4208)( 7 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.COUNT_16X_BAUD;
      reg_data(4208)(16)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.ENABLE;
      reg_data(4212)( 0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.ERRORS.RESET;
      reg_data(4218)(31 downto  0)  <= DEFAULT_CM_CTRL_t.CM(2).MONITOR.SM_TIMEOUT;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.CM(1).C2C(1).COUNTERS.RESET_COUNTERS <= '0';
      Ctrl.CM(1).C2C(2).COUNTERS.RESET_COUNTERS <= '0';
      Ctrl.CM(2).C2C(1).COUNTERS.RESET_COUNTERS <= '0';
      Ctrl.CM(2).C2C(2).COUNTERS.RESET_COUNTERS <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(12 downto 0))) is
        when 1024 => --0x400
          reg_data(1024)( 5)                         <=  localWrData( 5);                --C2C initialize
        when 1028 => --0x404
          reg_data(1028)(22)                         <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(1028)(23)                         <=  localWrData(23);                --DEBUG eyescan trigger
        when 1029 => --0x405
          reg_data(1029)(15 downto  0)               <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 1030 => --0x406
          reg_data(1030)(12)                         <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(1030)(13)                         <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(1030)(17)                         <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(1030)(18)                         <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(1030)(23)                         <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(1030)(24)                         <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(1030)(25)                         <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(1030)(29 downto 26)               <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 1031 => --0x407
          reg_data(1031)( 2 downto  0)               <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 1032 => --0x408
          reg_data(1032)( 7)                         <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(1032)(15)                         <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(1032)(16)                         <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(1032)(17)                         <=  localWrData(17);                --DEBUG tx polarity
          reg_data(1032)(22 downto 18)               <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(1032)(23)                         <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(1032)(31 downto 27)               <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 1033 => --0x409
          reg_data(1033)( 3 downto  0)               <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(1033)( 8 downto  4)               <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 1048 => --0x418
          Ctrl.CM(1).C2C(1).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 1073 => --0x431
          reg_data(1073)(23 downto  0)               <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(1073)(24)                         <=  localWrData(24);                --phy_lane_control is enabled
        when 1074 => --0x432
          reg_data(1074)(19 downto  0)               <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 1075 => --0x433
          reg_data(1075)( 7 downto  0)               <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 1076 => --0x434
          reg_data(1076)(31 downto  0)               <=  localWrData(31 downto  0);      --Max single bit error rate
        when 1077 => --0x435
          reg_data(1077)(31 downto  0)               <=  localWrData(31 downto  0);      --Max multi  bit error rate
        when 3072 => --0xc00
          reg_data(3072)( 5)                         <=  localWrData( 5);                --C2C initialize
        when 3076 => --0xc04
          reg_data(3076)(22)                         <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(3076)(23)                         <=  localWrData(23);                --DEBUG eyescan trigger
        when 3077 => --0xc05
          reg_data(3077)(15 downto  0)               <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 3078 => --0xc06
          reg_data(3078)(12)                         <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(3078)(13)                         <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(3078)(17)                         <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(3078)(18)                         <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(3078)(23)                         <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(3078)(24)                         <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(3078)(25)                         <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(3078)(29 downto 26)               <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 3079 => --0xc07
          reg_data(3079)( 2 downto  0)               <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 3080 => --0xc08
          reg_data(3080)( 7)                         <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(3080)(15)                         <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(3080)(16)                         <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(3080)(17)                         <=  localWrData(17);                --DEBUG tx polarity
          reg_data(3080)(22 downto 18)               <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(3080)(23)                         <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(3080)(31 downto 27)               <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 3081 => --0xc09
          reg_data(3081)( 3 downto  0)               <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(3081)( 8 downto  4)               <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 3096 => --0xc18
          Ctrl.CM(1).C2C(2).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 3121 => --0xc31
          reg_data(3121)(23 downto  0)               <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(3121)(24)                         <=  localWrData(24);                --phy_lane_control is enabled
        when 3122 => --0xc32
          reg_data(3122)(19 downto  0)               <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 3123 => --0xc33
          reg_data(3123)( 7 downto  0)               <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 3124 => --0xc34
          reg_data(3124)(31 downto  0)               <=  localWrData(31 downto  0);      --Max single bit error rate
        when 3125 => --0xc35
          reg_data(3125)(31 downto  0)               <=  localWrData(31 downto  0);      --Max multi  bit error rate
        when 0 => --0x0
          reg_data( 0)( 0)                           <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data( 0)( 1)                           <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data( 0)( 2)                           <=  localWrData( 2);                --Ignore power good from CM
          reg_data( 0)( 8)                           <=  localWrData( 8);                --CM power is good
        when 112 => --0x70
          reg_data(112)( 7 downto  0)                <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          reg_data(112)(16)                          <=  localWrData(16);                --Enable readout
        when 116 => --0x74
          reg_data(116)( 0)                          <=  localWrData( 0);                --Reset monitoring error counters
        when 122 => --0x7a
          reg_data(122)(31 downto  0)                <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)
        when 5120 => --0x1400
          reg_data(5120)( 5)                         <=  localWrData( 5);                --C2C initialize
        when 5124 => --0x1404
          reg_data(5124)(22)                         <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(5124)(23)                         <=  localWrData(23);                --DEBUG eyescan trigger
        when 5125 => --0x1405
          reg_data(5125)(15 downto  0)               <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 5126 => --0x1406
          reg_data(5126)(12)                         <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(5126)(13)                         <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(5126)(17)                         <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(5126)(18)                         <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(5126)(23)                         <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(5126)(24)                         <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(5126)(25)                         <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(5126)(29 downto 26)               <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 5127 => --0x1407
          reg_data(5127)( 2 downto  0)               <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 5128 => --0x1408
          reg_data(5128)( 7)                         <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(5128)(15)                         <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(5128)(16)                         <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(5128)(17)                         <=  localWrData(17);                --DEBUG tx polarity
          reg_data(5128)(22 downto 18)               <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(5128)(23)                         <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(5128)(31 downto 27)               <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 5129 => --0x1409
          reg_data(5129)( 3 downto  0)               <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(5129)( 8 downto  4)               <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 5144 => --0x1418
          Ctrl.CM(2).C2C(1).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 5169 => --0x1431
          reg_data(5169)(23 downto  0)               <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(5169)(24)                         <=  localWrData(24);                --phy_lane_control is enabled
        when 5170 => --0x1432
          reg_data(5170)(19 downto  0)               <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 5171 => --0x1433
          reg_data(5171)( 7 downto  0)               <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 5172 => --0x1434
          reg_data(5172)(31 downto  0)               <=  localWrData(31 downto  0);      --Max single bit error rate
        when 5173 => --0x1435
          reg_data(5173)(31 downto  0)               <=  localWrData(31 downto  0);      --Max multi  bit error rate
        when 7168 => --0x1c00
          reg_data(7168)( 5)                         <=  localWrData( 5);                --C2C initialize
        when 7172 => --0x1c04
          reg_data(7172)(22)                         <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(7172)(23)                         <=  localWrData(23);                --DEBUG eyescan trigger
        when 7173 => --0x1c05
          reg_data(7173)(15 downto  0)               <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 7174 => --0x1c06
          reg_data(7174)(12)                         <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(7174)(13)                         <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(7174)(17)                         <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(7174)(18)                         <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(7174)(23)                         <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(7174)(24)                         <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(7174)(25)                         <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(7174)(29 downto 26)               <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 7175 => --0x1c07
          reg_data(7175)( 2 downto  0)               <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 7176 => --0x1c08
          reg_data(7176)( 7)                         <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(7176)(15)                         <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(7176)(16)                         <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(7176)(17)                         <=  localWrData(17);                --DEBUG tx polarity
          reg_data(7176)(22 downto 18)               <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(7176)(23)                         <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(7176)(31 downto 27)               <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 7177 => --0x1c09
          reg_data(7177)( 3 downto  0)               <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(7177)( 8 downto  4)               <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 7192 => --0x1c18
          Ctrl.CM(2).C2C(2).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 7217 => --0x1c31
          reg_data(7217)(23 downto  0)               <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(7217)(24)                         <=  localWrData(24);                --phy_lane_control is enabled
        when 7218 => --0x1c32
          reg_data(7218)(19 downto  0)               <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 7219 => --0x1c33
          reg_data(7219)( 7 downto  0)               <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 7220 => --0x1c34
          reg_data(7220)(31 downto  0)               <=  localWrData(31 downto  0);      --Max single bit error rate
        when 7221 => --0x1c35
          reg_data(7221)(31 downto  0)               <=  localWrData(31 downto  0);      --Max multi  bit error rate
        when 4096 => --0x1000
          reg_data(4096)( 0)                         <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data(4096)( 1)                         <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data(4096)( 2)                         <=  localWrData( 2);                --Ignore power good from CM
          reg_data(4096)( 8)                         <=  localWrData( 8);                --CM power is good
        when 4208 => --0x1070
          reg_data(4208)( 7 downto  0)               <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          reg_data(4208)(16)                         <=  localWrData(16);                --Enable readout
        when 4212 => --0x1074
          reg_data(4212)( 0)                         <=  localWrData( 0);                --Reset monitoring error counters
        when 4218 => --0x107a
          reg_data(4218)(31 downto  0)               <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)

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
  
  Ctrl.CM(1).C2C(1).DRP.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.CM(1).C2C(1).DRP.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.CM(1).C2C(1).DRP.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.CM(1).C2C(1).DRP.address   <=  BRAM_MOSI(0).address(10-1 downto 0);
  Ctrl.CM(1).C2C(1).DRP.wr_data   <=  BRAM_MOSI(0).wr_data(16-1 downto 0);

  Ctrl.CM(1).C2C(2).DRP.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.CM(1).C2C(2).DRP.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.CM(1).C2C(2).DRP.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.CM(1).C2C(2).DRP.address   <=  BRAM_MOSI(1).address(10-1 downto 0);
  Ctrl.CM(1).C2C(2).DRP.wr_data   <=  BRAM_MOSI(1).wr_data(16-1 downto 0);

  Ctrl.CM(2).C2C(1).DRP.clk       <=  BRAM_MOSI(2).clk;
  Ctrl.CM(2).C2C(1).DRP.enable    <=  BRAM_MOSI(2).enable;
  Ctrl.CM(2).C2C(1).DRP.wr_enable <=  BRAM_MOSI(2).wr_enable;
  Ctrl.CM(2).C2C(1).DRP.address   <=  BRAM_MOSI(2).address(10-1 downto 0);
  Ctrl.CM(2).C2C(1).DRP.wr_data   <=  BRAM_MOSI(2).wr_data(16-1 downto 0);

  Ctrl.CM(2).C2C(2).DRP.clk       <=  BRAM_MOSI(3).clk;
  Ctrl.CM(2).C2C(2).DRP.enable    <=  BRAM_MOSI(3).enable;
  Ctrl.CM(2).C2C(2).DRP.wr_enable <=  BRAM_MOSI(3).wr_enable;
  Ctrl.CM(2).C2C(2).DRP.address   <=  BRAM_MOSI(3).address(10-1 downto 0);
  Ctrl.CM(2).C2C(2).DRP.wr_data   <=  BRAM_MOSI(3).wr_data(16-1 downto 0);


  BRAM_MISO(0).rd_data(16-1 downto 0) <= Mon.CM(1).C2C(1).DRP.rd_data;
  BRAM_MISO(0).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(0).rd_data_valid <= Mon.CM(1).C2C(1).DRP.rd_data_valid;

  BRAM_MISO(1).rd_data(16-1 downto 0) <= Mon.CM(1).C2C(2).DRP.rd_data;
  BRAM_MISO(1).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(1).rd_data_valid <= Mon.CM(1).C2C(2).DRP.rd_data_valid;

  BRAM_MISO(2).rd_data(16-1 downto 0) <= Mon.CM(2).C2C(1).DRP.rd_data;
  BRAM_MISO(2).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(2).rd_data_valid <= Mon.CM(2).C2C(1).DRP.rd_data_valid;

  BRAM_MISO(3).rd_data(16-1 downto 0) <= Mon.CM(2).C2C(2).DRP.rd_data;
  BRAM_MISO(3).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(3).rd_data_valid <= Mon.CM(2).C2C(2).DRP.rd_data_valid;

    

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