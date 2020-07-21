library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;
use work.types.all;
use work.CM_package.all;
use work.CM_Ctrl.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity CM_intf is
  generic (
    CM_COUNT         : integer range 1 to 2 := 1; --Count for how many Command Moduless are present
    COUNTER_COUNT    : integer := 5;               --Count for counters in loop
    CLKFREQ          : integer := 50000000;       --clk frequency in Hz
    ERROR_WAIT_TIME  : integer := 50000000);      --Wait time for error checking states
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    master_readMOSI  : out AXIReadMOSI  := DefaultAXIReadMOSI;
    master_readMISO  : in  AXIReadMISO;
    master_writeMOSI : out AXIWriteMOSI := DefaultAXIWriteMOSI;
    master_writeMISO : in  AXIWriteMISO;
    CM_mon_uart      : in  std_logic := '1';
    enableCM         : out std_logic_vector(1 downto 0);
    enableCM_PWR     : out std_logic_vector(1 downto 0);
    enableCM_IOs     : out std_logic_vector(1 downto 0);
    from_CM          : in from_CM_t;
    to_CM_in         : in to_CM_t; --from SM
    to_CM_out        : out to_CM_t; --from SM, but tristated
    clk_C2C          : in std_logic_vector(1 downto 0);
    CM_C2C_Mon       : in C2C_Monitor_t;
    CM_C2C_Ctrl      : out C2C_Control_t);
end entity CM_intf;

architecture behavioral of CM_intf is

  constant DATA_WIDTH : integer := 32;
  
  signal localAddress      : slv_32_t;
  signal localRdData       : slv_32_t;
  signal localRdData_latch : slv_32_t;
  signal localWrData       : slv_32_t;
  signal localWrEn         : std_logic;
  signal localRdReq        : std_logic;
  signal localRdAck        : std_logic;
  
  signal PWR_good          : slv_2_t;
  signal enableCM_s        : slv_2_t;
  signal enableCM_PWR_s    : slv_2_t;
  signal override_PWRGood  : slv_2_t;
  signal reset_error_state : slv_2_t;
  signal enable_uC         : slv_2_t;
  signal enable_PWR        : slv_2_t;
  signal enable_IOs        : slv_2_t;
  signal CM_seq_state      : slv_8_t;
  signal CM_disable        : std_logic_vector(1 downto 0);
  signal CM_uCIO_disable   : std_logic_vector(1 downto 0);

  --phy_lane_control
  signal phylanelock     : std_logic_vector(1 downto 0);
  signal aurora_init_buf : std_logic_vector(1 downto 0);
  signal phycontrol_en   : std_logic_vector(1 downto 0);
    
  signal reset : std_logic;                     

  signal mon_active : slv_2_t;
  signal mon_errors : slv16_array_t(0 to 1);

  constant INACTIVE_COUNT : slv_32_t := x"03FFFFFF";
  constant PL_MEM_ADDR    : unsigned(31 downto 0) := x"40000000";

  signal debug_history   : slv_32_t;
  signal debug_valid     : slv_4_t;
  signal counter_en      : std_logic_vector(1 downto 0);
  signal C2C_counter     : slv32_array_t(1 to 10);
  signal counter_events  : std_logic_vector(9 downto 0);
  
  signal Mon  : CM_Mon_t;
  signal Ctrl : CM_Ctrl_t;

  
begin
  --reset
  reset <= not reset_axi_n;

  --For signals variable on CM_COUNT
  phycontrol_en(0) <= PWR_good(0) and CTRL.CM(1).CTRL.ENABLE_PHY_CTRL;
  counter_en(0)    <= PWR_good(0);
  CM_CTRL_GENERATE_1: if CM_COUNT = 1 generate
    phycontrol_en(1) <= phylanelock(0) and PWR_good(0) and CTRL.CM(2).CTRL.ENABLE_PHY_CTRL;
    counter_en(1)    <= PWR_good(0);
  end generate CM_CTRL_GENERATE_1;
  CM_CTRL_GENERATE_2: if CM_COUNT = 2 generate
    phycontrol_en(1) <= PWR_good(1) and CTRL.CM(2).CTRL.ENABLE_PHY_CTRL;
    counter_en(1)    <= PWR_good(1);
  end generate CM_CTRL_GENERATE_2;

  --For Power-up Sequences
  Mon.CM(1).CTRL.PWR_GOOD <= PWR_good(0);  

  --For AXI
  CM_interface_1: entity work.CM_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => slave_readMOSI,
      slave_readMISO  => slave_readMISO,
      slave_writeMOSI => slave_writeMOSI,
      slave_writeMISO => slave_writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
  --Signals only relavant to CM1
  Mon.CM(1).MONITOR.ACTIVE         <= mon_active(0);
  Mon.CM(1).MONITOR.HISTORY_VALID  <= debug_valid;
  --Mon.CM(1).MONITOR.ERRORS         <= mon_errors(0);
  Mon.CM(1).MONITOR.HISTORY        <= debug_history;

  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS                => 8,
      INACTIVE_COUNT                 => INACTIVE_COUNT,
      BASE_ADDRESS                   => PL_MEM_ADDR)
    port map (
      clk                            => clk_axi,
      reset                          => reset,
      uart_rx                        => CM_mon_uart,
      baud_16x_count                 => CTRL.CM(1).MONITOR.COUNT_16X_BAUD,
      sm_timeout_value               => CTRL.CM(1).MONITOR.SM_TIMEOUT,
      readMOSI                       => master_readMOSI,
      readMISO                       => master_readMISO,
      writeMOSI                      => master_writeMOSI,
      writeMISO                      => master_writeMISO,
      debug_history                  => debug_history,
      debug_valid                    => debug_valid,
      uart_byte_count                => Mon.CM(1).MONITOR.UART_BYTES,
      error_reset                    => CTRL.CM(1).MONITOR.ERRORS.RESET,
      error_count(0)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BAD_SOF,
      error_count(1)                 => Mon.CM(1).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2,
      error_count(2)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA,
      error_count(3)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA,
      error_count(4)                 => Mon.CM(1).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA,
      error_count(5)                 => Mon.CM(1).MONITOR.ERRORS.CNT_TIMEOUT,
      error_count(6)                 => Mon.CM(1).MONITOR.ERRORS.CNT_UNKNOWN,
      bad_transaction(31 downto 24)  => Mon.CM(1).MONITOR.BAD_TRANS.ERROR_MASK,
      bad_transaction(23 downto  8)  => Mon.CM(1).MONITOR.BAD_TRANS.DATA,
      bad_transaction( 7 downto  0)  => Mon.CM(1).MONITOR.BAD_TRANS.ADDR,
      last_transaction(31 downto 24) => Mon.CM(1).MONITOR.LAST_TRANS.ERROR_MASK,
      last_transaction(23 downto  8) => Mon.CM(1).MONITOR.LAST_TRANS.DATA,
      last_transaction( 7 downto  0) => Mon.CM(1).MONITOR.LAST_TRANS.ADDR,
      channel_active                 => mon_active(0));


  GENERATE_LOOP: for iCM in 1 to 2 generate
    -------------------------------------------------------------------------------
    -- DC data CDC
    -------------------------------------------------------------------------------
    DC_data_CDC_X: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH           => 4)
    port map (
      clk_in               => clk_axi,
      clk_out              => clk_C2C(iCM - 1),
      reset                => reset,
      pass_in(0)           => CTRL.CM(iCM).C2C.RX.PRBS_CNT_RST,
      pass_in(3 downto 1)  => CTRL.CM(iCM).C2C.RX.PRBS_SEL,
      pass_out(0)          => CM_C2C_Ctrl.CM(iCM).rxprbscntreset,
      pass_out(3 downto 1) => CM_C2C_Ctrl.CM(iCM).rxprbssel);

    -------------------------------------------------------------------------------
    -- CM interface
    -------------------------------------------------------------------------------
    CM_UART_BUF_X : OBUFT
      port map (
        T => CM_ucIO_disable(iCM - 1),
        I => to_CM_in.CM(iCM).UART_Tx,
        O => to_CM_out.CM(iCM).UART_Tx);
    CM_TMS_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM - 1),
        I => to_CM_in.CM(iCM).TMS,
        O => to_CM_out.CM(iCM).TMS);
    CM_TDI_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM - 1),
        I => to_CM_in.CM(iCM).TDI,
        O => to_CM_out.CM(iCM).TDI);
    CM_TCK_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM - 1),
        I => to_CM_in.CM(iCM).TCK,
        O => to_CM_out.CM(iCM).TCK);

    -------------------------------------------------------------------------------
    -- Phy_lane_control
    -------------------------------------------------------------------------------
    Phy_lane_control_X: entity work.CM_phy_lane_control
      generic map (
        CLKFREQ          => CLKFREQ,
        DATA_WIDTH       => DATA_WIDTH,
        ERROR_WAIT_TIME => ERROR_WAIT_TIME)
      port map (
        clk              => clk_axi,
        reset            => reset,
        reset_counter    => CTRL.CM(iCM).C2C.CNT.RESET_COUNTERS,
        enable           => phycontrol_en(iCM - 1),
        phy_lane_up      => CM_C2C_Mon.CM(iCM).phy_lane_up(0),
        phy_lane_stable  => CTRL.CM(iCM).CTRL.PHY_LANE_STABLE,
        READ_TIME        => CTRL.CM(iCM).CTRL.PHY_READ_TIME,
        initialize_out   => aurora_init_buf(iCM - 1),
        lock             => phylanelock(iCM - 1),
        state_out        => Mon.CM(iCM).C2C.CNT.PHYLANE_STATE,
        count_error_wait => Mon.CM(iCM).C2C.CNT.PHY_ERRORSTATE_COUNT,
        count_alltime    => Mon.CM(iCM).C2C.CNT.INIT_ALLTIME,
        count_shortterm  => Mon.CM(iCM).C2C.CNT.INIT_SHORTTERM);
    CM_C2C_Ctrl.CM(iCM).aurora_pma_init_in <= (aurora_init_buf(iCM - 1) and CTRL.CM(iCM).CTRL.ENABLE_PHY_CTRL) or (CTRL.CM(iCM).C2C.INITIALIZE and (not CTRL.CM(iCM).CTRL.ENABLE_PHY_CTRL));
    
    ----Chipscope for probing
    --ChipScope_X: entity work.chipscope
    --  port map (
    --    clk       => clk_axi, --maybe C2C clk
    --    probe0(0) => CM_C2C_Mon.CM(iCM).phy_lane_up(0),
    --    probe1(0) => aurora_init_buf(iCM - 1),
    --    probe2(0) => phycontrol_en(iCM - 1),
    --    probe3(0) => '0',
    --    probe4    => Mon.CM(iCM).C2C.CNT.PHYLANE_STATE);
    
    -------------------------------------------------------------------------------
    --Power-up sequences
    -------------------------------------------------------------------------------
    CM_PWR_SEQ_X: entity work.CM_pwr
      generic map (
        COUNT_ERROR_WAIT  => ERROR_WAIT_TIME)
      port map (
        clk               => clk_axi,
        reset_async       => reset,
        reset_sync        => reset_error_state(iCM - 1),
        uc_enabled        => enable_uC(iCM - 1),
        start_PWR         => enableCM_PWR_s(iCM - 1),
        sequence_override => override_PWRGood(iCM -1),
        current_state     => CM_seq_state((iCM * 4) - 1 downto (iCM - 1) * 4),
        enabled_PWR       => enable_PWR(iCM - 1),
        enabled_IOs       => enable_IOs(iCM - 1),
        power_good        => PWR_good(iCM - 1));
    enableCM(iCM - 1)       <= Ctrl.CM(iCM).CTRL.ENABLE_UC;
    PWR_good(iCM - 1)       <= from_CM.CM(iCM).PWR_good;
    enableCM_PWR(iCM - 1)   <= enableCM_PWR_s(iCM - 1);
    enableCM_IOs(iCM - 1)   <= enable_IOs(iCM - 1);
    CM_disable(iCM - 1)     <= not enable_IOs(iCM - 1);
    CM_ucIO_disable(iCM -1) <= not enable_uC(iCM - 1);

    -------------------------------------------------------------------------------
    -- AXI 
    -------------------------------------------------------------------------------
    --CM power/reset signals?
    enable_uc(iCM - 1)            <= Ctrl.CM(iCM).CTRL.ENABLE_UC;         --CM enabled
    enableCM_PWR_s(iCM - 1)       <= Ctrl.CM(iCM).CTRL.ENABLE_PWR;        --CM power eneable
    override_PWRGood(iCM - 1)     <= Ctrl.CM(iCM).CTRL.OVERRIDE_PWR_GOOD; --CM override
    reset_error_state(iCM - 1)    <= Ctrl.CM(iCM).CTRL.ERROR_STATE_RESET; --CM reset error state
    --CM monitor signals
    Mon.CM(iCM).CTRL.STATE             <= CM_seq_state(((iCM*4)-1) downto ((iCM-1)*4));
    Mon.CM(iCM).CTRL.PWR_ENABLED       <= enable_PWR(iCM - 1);
    Mon.CM(iCM).CTRL.IOS_ENABLED       <= enable_IOs(iCM - 1);
    Mon.CM(iCM).C2C.CONFIG_ERROR       <= CM_C2C_Mon.CM(iCM).axi_c2c_config_error_out;
    Mon.CM(iCM).C2C.LINK_ERROR         <= CM_C2C_Mon.CM(iCM).axi_c2c_link_error_out;     
    Mon.CM(iCM).C2C.LINK_GOOD          <= CM_C2C_Mon.CM(iCM).axi_c2c_link_status_out;    
    Mon.CM(iCM).C2C.MB_ERROR           <= CM_C2C_Mon.CM(iCM).axi_c2c_multi_bit_error_out;
    Mon.CM(iCM).C2C.DO_CC              <= CM_C2C_Mon.CM(iCM).aurora_do_cc;
    Mon.CM(iCM).C2C.PHY_RESET          <= CM_C2C_Mon.CM(iCM).phy_link_reset_out;     
    Mon.CM(iCM).C2C.PHY_GT_PLL_LOCK    <= CM_C2C_Mon.CM(iCM).phy_gt_pll_lock;        
    Mon.CM(iCM).C2C.PHY_MMCM_LOL       <= CM_C2C_Mon.CM(iCM).phy_mmcm_not_locked_out;
    Mon.CM(iCM).C2C.PHY_LANE_UP(0)     <= CM_C2C_Mon.CM(iCM).phy_lane_up(0);
    Mon.CM(iCM).C2C.PHY_HARD_ERR       <= CM_C2C_Mon.CM(iCM).phy_hard_err;           
    Mon.CM(iCM).C2C.PHY_SOFT_ERR       <= CM_C2C_Mon.CM(iCM).phy_soft_err;
    Mon.CM(iCM).C2C.CPLL_LOCK          <= CM_C2C_Mon.CM(iCM).cplllock;
    Mon.CM(iCM).C2C.EYESCAN_DATA_ERROR <= CM_C2C_Mon.CM(iCM).eyescandataerror;
    Mon.CM(iCM).C2C.DMONITOR           <= CM_C2C_Mon.CM(iCM).dmonitorout;
    Mon.CM(iCM).C2C.RX.BUF_STATUS      <= CM_C2C_Mon.CM(iCM).rxbufstatus;
    Mon.CM(iCM).C2C.RX.MONITOR         <= CM_C2C_Mon.CM(iCM).rxmonitorout;
    Mon.CM(iCM).C2C.RX.PRBS_ERR        <= CM_C2C_Mon.CM(iCM).rxprbserr;
    Mon.CM(iCM).C2C.RX.RESET_DONE      <= CM_C2C_Mon.CM(iCM).rxresetdone;
    Mon.CM(iCM).C2C.TX.BUF_STATUS      <= CM_C2C_Mon.CM(iCM).txbufstatus;
    Mon.CM(iCM).C2C.TX.RESET_DONE      <= CM_C2C_Mon.CM(iCM).txresetdone;
    --C2C control signals
    --CM_C2C_Ctrl.CM(I).aurora_pma_init_in <= CTRL.CM(I).C2C.INITIALIZE;
    CM_C2C_Ctrl.CM(iCM).eyescanreset       <= CTRL.CM(iCM).C2C.EYESCAN_RESET;
    CM_C2C_Ctrl.CM(iCM).eyescantrigger     <= CTRL.CM(iCM).C2C.EYESCAN_TRIGGER;
    CM_C2C_Ctrl.CM(iCM).rxbufreset         <= CTRL.CM(iCM).C2C.RX.BUF_RESET;
    CM_C2C_Ctrl.CM(iCM).rxcdrhold          <= CTRL.CM(iCM).C2C.RX.CDR_HOLD;   
    CM_C2C_Ctrl.CM(iCM).rxdfeagchold       <= CTRL.CM(iCM).C2C.RX.DFE_AGC_HOLD;
    CM_C2C_Ctrl.CM(iCM).rxdfeagcovrden     <= CTRL.CM(iCM).C2C.RX.DFE_AGC_OVERRIDE;
    CM_C2C_Ctrl.CM(iCM).rxdfelfhold        <= CTRL.CM(iCM).C2C.RX.DFE_LF_HOLD;
    CM_C2C_Ctrl.CM(iCM).rxdfelpmreset      <= CTRL.CM(iCM).C2C.RX.DFE_LPM_RESET;
    CM_C2C_Ctrl.CM(iCM).rxlpmen            <= CTRL.CM(iCM).C2C.RX.LPM_EN;
    CM_C2C_Ctrl.CM(iCM).rxlpmhfovrden      <= CTRL.CM(iCM).C2C.RX.LPM_HF_OVERRIDE;
    CM_C2C_Ctrl.CM(iCM).rxlpmlfklovrden    <= CTRL.CM(iCM).C2C.RX.LPM_LFKL_OVERRIDE;
    CM_C2C_Ctrl.CM(iCM).rxmonitorsel       <= CTRL.CM(iCM).C2C.RX.MON_SEL;
    CM_C2C_Ctrl.CM(iCM).rxpcsreset         <= CTRL.CM(iCM).C2C.RX.PCS_RESET;
    CM_C2C_Ctrl.CM(iCM).rxpmareset         <= CTRL.CM(iCM).C2C.RX.PMA_RESET;
    --CM_C2C_Ctrl.CM(iCM).rxprbscntreset     <= CTRL.CM(iCM).C2C.RX.PRBS_CNT_RST;
    --CM_C2C_Ctrl.CM(iCM).rxprbssel          <= CTRL.CM(iCM).C2C.RX.PRBS_SEL;
    CM_C2C_Ctrl.CM(iCM).txdiffctrl         <= CTRL.CM(iCM).C2C.TX.DIFF_CTRL;
    CM_C2C_Ctrl.CM(iCM).txinhibit          <= CTRL.CM(iCM).C2C.TX.INHIBIT;
    CM_C2C_Ctrl.CM(iCM).txmaincursor       <= CTRL.CM(iCM).C2C.TX.MAIN_CURSOR;
    CM_C2C_Ctrl.CM(iCM).txpcsreset         <= CTRL.CM(iCM).C2C.TX.PCS_RESET;
    CM_C2C_Ctrl.CM(iCM).txpmareset         <= CTRL.CM(iCM).C2C.TX.PMA_RESET;
    CM_C2C_Ctrl.CM(iCM).txpolarity         <= CTRL.CM(iCM).C2C.TX.POLARITY;
    CM_C2C_Ctrl.CM(iCM).txpostcursor       <= CTRL.CM(iCM).C2C.TX.POST_CURSOR;
    CM_C2C_Ctrl.CM(iCM).txprbsforceerr     <= CTRL.CM(iCM).C2C.TX.PRBS_FORCE_ERR;
    CM_C2C_Ctrl.CM(iCM).txprbssel          <= CTRL.CM(iCM).C2C.TX.PRBS_SEL;
    CM_C2C_Ctrl.CM(iCM).txprecursor        <= CTRL.CM(iCM).C2C.TX.PRE_CURSOR;
    -------------------------------------------------------------------------------
    -- COUNTERS
    -------------------------------------------------------------------------------
    GENERATE_COUNTERS_LOOP: for iCNT in 1 to COUNTER_COUNT generate
      Counter_X: entity work.counter
        generic map (
          roll_over   => '0',
          end_value   => x"FFFFFFFF",
          start_value => x"00000000",
          A_RST_CNT   => x"00000000",
          DATA_WIDTH  => 32)
        port map (
          clk         => clk_axi,
          reset_async => reset,
          reset_sync  => CTRL.CM(iCM).C2C.CNT.RESET_COUNTERS,
          enable      => counter_en(iCM - 1),
          event       => counter_events((iCNT - 1) + ((iCM - 1)*COUNTER_COUNT)), --runs 0 to (COUNTER_COUNT - 1)
          count       => C2C_Counter(iCNT + ((iCM - 1)*COUNTER_COUNT)),          --runs 1 to COUNTER_COUNT
          at_max      => open);   
    end generate GENERATE_COUNTERS_LOOP;
    --PATTERN FOR COUNTERS
    --setting events, run 0 to (COUNTER_COUNT - 1)
    counter_events(0 + ((iCM - 1) * COUNTER_COUNT)) <= Mon.CM(iCM).C2C.CONFIG_ERROR;
    counter_events(1 + ((iCM - 1) * COUNTER_COUNT)) <= Mon.CM(iCM).C2C.LINK_ERROR; 
    counter_events(2 + ((iCM - 1) * COUNTER_COUNT)) <= Mon.CM(iCM).C2C.MB_ERROR;
    counter_events(3 + ((iCM - 1) * COUNTER_COUNT)) <= Mon.CM(iCM).C2C.PHY_HARD_ERR;
    counter_events(4 + ((iCM - 1) * COUNTER_COUNT)) <= Mon.CM(iCM).C2C.PHY_SOFT_ERR;
    --setting counters, run 1 to COUNTER_COUNT
    Mon.CM(iCM).C2C.CNT.CONFIG_ERROR_COUNT   <= C2C_Counter(1 + ((iCM - 1) * COUNTER_COUNT));
    Mon.CM(iCM).C2C.CNT.LINK_ERROR_COUNT     <= C2C_Counter(1 + ((iCM - 1) * COUNTER_COUNT));
    Mon.CM(iCM).C2C.CNT.MB_ERROR_COUNT       <= C2C_Counter(1 + ((iCM - 1) * COUNTER_COUNT));
    Mon.CM(iCM).C2C.CNT.PHY_HARD_ERROR_COUNT <= C2C_Counter(1 + ((iCM - 1) * COUNTER_COUNT));
    Mon.CM(iCM).C2C.CNT.PHY_SOFT_ERROR_COUNT <= C2C_Counter(1 + ((iCM - 1) * COUNTER_COUNT));   
  end generate GENERATE_LOOP;
end architecture behavioral;
