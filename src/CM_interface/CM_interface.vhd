library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.CM_package.all;
use work.CM_Ctrl.all;
use work.AXISlaveAddrPkg.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity CM_intf is
  generic (
    CM_COUNT         : integer range 1 to 2 := 1; --Count for how many Command Moduless are present
    CM1_LANES        : std_logic_vector(2 downto 1) := "01"; -- active links on
                                                             -- CM1 
    CM2_LANES        : std_logic_vector(2 downto 1) := "01"; -- active links on
                                                             -- CM1 
    COUNTER_COUNT    : integer := 5;               --Count for counters in loop
    CLKFREQ          : integer := 50000000;       --clk frequency in Hz
    ERROR_WAIT_TIME  : integer := 50000000);      --Wait time for error checking states
  port (
    clk_axi           : in  std_logic;
    reset_axi_n       : in  std_logic;
    slave_readMOSI    : in  AXIReadMOSI;
    slave_readMISO    : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI   : in  AXIWriteMOSI;
    slave_writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    master_readMOSI   : out AXIReadMOSI  := DefaultAXIReadMOSI;
    master_readMISO   : in  AXIReadMISO;
    master_writeMOSI  : out AXIWriteMOSI := DefaultAXIWriteMOSI;
    master_writeMISO  : in  AXIWriteMISO;
    CM_mon_uart       : in  std_logic := '1';
    enableCM          : out std_logic_vector(2 downto 1);
    enableCM_PWR      : out std_logic_vector(2 downto 1);
    enableCM_IOs      : out std_logic_vector(2 downto 1);
    from_CM           : in  from_CM_t;
    to_CM_in          : in  to_CM_t; --from SM
    to_CM_out         : out to_CM_t; --from SM, but tristated
    clk_C2C           : in  std_logic_vector(4 downto 1);
    CM_C2C_Mon        : in  C2C_Monitor_t;
    CM_C2C_Ctrl       : out C2C_Control_t);
end entity CM_intf;

architecture behavioral of CM_intf is
  constant HW_CM_COUNT : integer := 2;
  constant HW_LINK_PER_CM_COUNT : integer := 2;
  constant HW_LINK_COUNT : integer := HW_CM_COUNT * HW_LINK_PER_CM_COUNT;
  
  constant DATA_WIDTH : integer := 32;
  
  signal localAddress      : slv_32_t;
  signal localRdData       : slv_32_t;
  signal localRdData_latch : slv_32_t;
  signal localWrData       : slv_32_t;
  signal localWrEn         : std_logic;
  signal localRdReq        : std_logic;
  signal localRdAck        : std_logic;
  
  signal PWR_good          : std_logic_vector(2 downto 1);
  signal enable_PWR_out    : std_logic_vector(2 downto 1);
  signal enable_IOs_out    : std_logic_vector(2 downto 1);
  signal CM_disable        : std_logic_vector(2 downto 1);
  signal CM_uCIO_disable   : std_logic_vector(2 downto 1);

  --phy_lane_control
  signal phylanelock     : std_logic_vector(4 downto 1);
  signal aurora_init_buf : std_logic_vector(4 downto 1);
  signal phycontrol_en   : std_logic_vector(4 downto 1);
    
  signal reset : std_logic;                     

  signal mon_active : std_logic_vector(2 downto 1);
  signal mon_errors : slv16_array_t(1 to 2);

  constant INACTIVE_COUNT : slv_32_t := x"03FFFFFF";
 
  signal debug_history   : slv32_array_t(1 to 2);
  signal debug_valid     : slv4_array_t(1 to 2);
  signal counter_en      : std_logic_vector(4 downto 1);
  signal C2C_counter     : slv32_array_t(0 to (2*2*COUNTER_COUNT)-1);
  signal counter_events  : std_logic_vector(  (2*2*COUNTER_COUNT)-1 downto 0);
  
  signal Mon  : CM_Mon_t;
  signal Ctrl : CM_Ctrl_t;

  constant CDC_PRBS_SEL_LENGTH : integer := CM_C2C_Ctrl.Link(1).LINK_DEBUG.RX.PRBS_SEL'length;
  type CDC_PASSTHROUGH_t is array (1 to 2*2) of std_logic_vector(CDC_PRBS_SEL_LENGTH -1 + 1 downto 0);
  signal CDC_PASSTHROUGH : CDC_PASSTHROUGH_t;
  
begin
  --reset
  reset <= not reset_axi_n;

  --For signals variable on CM_COUNT
  phycontrol_en(1) <=                    from_CM.CM(1).PWR_good and CTRL.CM(1).C2C(1).ENABLE_PHY_CTRL;
  counter_en(1)    <= from_CM.CM(1).PWR_good;
  
  phycontrol_en(2) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(1).C2C(2).ENABLE_PHY_CTRL;
  counter_en(2)    <= from_CM.CM(1).PWR_good;

  CM_CTRL_GENERATE_1: if CM_COUNT = 1 generate
    phycontrol_en(3) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(2).C2C(1).ENABLE_PHY_CTRL;
    counter_en(3)    <= from_CM.CM(1).PWR_good;
    phycontrol_en(4) <= phylanelock(1) and from_CM.CM(1).PWR_good and CTRL.CM(2).C2C(2).ENABLE_PHY_CTRL;
    counter_en(4)    <= from_CM.CM(1).PWR_good;
  end generate CM_CTRL_GENERATE_1;
  CM_CTRL_GENERATE_2: if CM_COUNT = 2 generate
    phycontrol_en(3) <=                    from_CM.CM(2).PWR_good and CTRL.CM(2).C2C(1).ENABLE_PHY_CTRL;
    counter_en(3)    <= from_CM.CM(2).PWR_good;
    phycontrol_en(4) <= phylanelock(3) and from_CM.CM(2).PWR_good and CTRL.CM(2).C2C(2).ENABLE_PHY_CTRL;
    counter_en(4)    <= from_CM.CM(2).PWR_good;
  end generate CM_CTRL_GENERATE_2;


  --For AXI
  CM_interface_1: entity work.CM_map
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
  Mon.CM(1).MONITOR.ACTIVE         <= mon_active(1);
  Mon.CM(1).MONITOR.HISTORY_VALID  <= debug_valid(1);
  --Mon.CM(1).MONITOR.ERRORS         <= mon_errors(0);
  Mon.CM(1).MONITOR.HISTORY        <= debug_history(1);
  
  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS                => 8,
      INACTIVE_COUNT                 => INACTIVE_COUNT,
      BASE_ADDRESS                   => AXI_ADDR_PL_MEM)
    port map (
      clk                            => clk_axi,
      reset                          => reset,
      enable_axi_writes              => CTRL.CM(1).MONITOR.ENABLE,
      uart_rx                        => CM_mon_uart,
      baud_16x_count                 => CTRL.CM(1).MONITOR.COUNT_16X_BAUD,
      sm_timeout_value               => CTRL.CM(1).MONITOR.SM_TIMEOUT,
      readMOSI                       => master_readMOSI,
      readMISO                       => master_readMISO,
      writeMOSI                      => master_writeMOSI,
      writeMISO                      => master_writeMISO,
      debug_history                  => debug_history(1),
      debug_valid                    => debug_valid(1),
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
      channel_active                 => mon_active(1));


  GENERATE_LOOP: for iCM in 1 to 2 generate

    -------------------------------------------------------------------------------
    -- CM interface
    -------------------------------------------------------------------------------
    CM_UART_BUF_X : OBUFT
      port map (
        T => CM_ucIO_disable(iCM),
        I => to_CM_in.CM(iCM).UART_Tx,
        O => to_CM_out.CM(iCM).UART_Tx);
    CM_TMS_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TMS,
        O => to_CM_out.CM(iCM).TMS);
    CM_TDI_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TDI,
        O => to_CM_out.CM(iCM).TDI);
    CM_TCK_BUF_X : OBUFT
      port map (
        T => CM_disable(iCM),
        I => to_CM_in.CM(iCM).TCK,
        O => to_CM_out.CM(iCM).TCK);

    -------------------------------------------------------------------------------
    --Power-up sequences
    -------------------------------------------------------------------------------
    CM_PWR_SEQ_X: entity work.CM_pwr
      generic map (
        COUNT_ERROR_WAIT  => ERROR_WAIT_TIME)
      port map (
        clk               => clk_axi,
        reset_async       => reset,
        reset_sync        => Ctrl.CM(iCM).CTRL.ERROR_STATE_RESET,
        uc_enabled        => Ctrl.CM(iCM).CTRL.ENABLE_UC,
        start_PWR         => Ctrl.CM(iCM).CTRL.ENABLE_PWR,
        sequence_override => Ctrl.CM(iCM).CTRL.OVERRIDE_PWR_GOOD,
        current_state     => Mon.CM(iCM).CTRL.STATE,
        enabled_PWR       => enable_PWR_out(iCM),
        enabled_IOs       => enable_IOs_out(iCM),
        power_good        => from_CM.CM(iCM).PWR_good);
    --For Power-up Sequences

    enableCM(iCM)           <= Ctrl.CM(iCM).CTRL.ENABLE_UC;
    enableCM_PWR(iCM)       <= enable_PWR_out(iCM);
    enableCM_IOs(iCM)       <= enable_IOs_out(iCM);
    CM_disable(iCM)         <= not enable_IOs_out(iCM);
    CM_ucIO_disable(iCM)    <= not Ctrl.CM(iCM).CTRL.ENABLE_UC;
    
    Mon.CM(iCM).CTRL.PWR_GOOD <= from_CM.CM(iCM).PWR_good;  
    Mon.CM(iCM).CTRL.PWR_ENABLED       <= enable_PWR_out(iCM);
    Mon.CM(iCM).CTRL.IOS_ENABLED       <= enable_IOs_out(iCM);

    -------------------------------------------------------------------------------
    -- AXI 
    -------------------------------------------------------------------------------


    GENERATE_LANE_LOOP: for iLane in 1 to 2 generate
      signal linkID : integer := 2*(iCM-1) + (iLane);
    begin
      Mon.CM(iCM).C2C(iLane).LINK_DEBUG         <= CM_C2C_Mon.Link(linkID).LINK_DEBUG;
      Mon.CM(iCM).C2C(iLane).STATUS             <= CM_C2C_Mon.Link(linkID).STATUS;
      Mon.CM(iCM).C2C(iLane).CNT.USER_CLK_FREQ  <= CM_C2C_Mon.Link(linkID).user_clk_freq;
      --C2C control signals
      --CM_C2C_Ctrl.Link(I).aurora_pma_init_in <= CTRL.CM(I).C2C.INITIALIZE;
    
      -------------------------------------------------------------------------------
      -- DC data CDC
      -------------------------------------------------------------------------------
      
      --The following code is ugly, but it is being used to pass two signals from
      --a record assignment through a CDC
      --The signals aren't listed explicityly since we want the fundamental
      --record type to be unexposed since this record will change between 7series
      --and USP
      DC_data_CDC_X: entity work.DC_data_CDC
        generic map (
          DATA_WIDTH           => 1 + CDC_PRBS_SEL_LENGTH)
        port map (
          clk_in               => clk_axi,
          clk_out              => clk_C2C(linkID),
          reset                => reset,
          pass_in(0)                                      => CTRL.CM(iCM).C2C(iLane).LINK_DEBUG.RX.PRBS_CNT_RST,
          pass_in( (CDC_PRBS_SEL_LENGTH -1) + 1 downto 1) => CTRL.CM(iCM).C2C(iLane).LINK_DEBUG.RX.PRBS_SEL,
          pass_out(0)                                     => CDC_PASSTHROUGH(linkID)(0),               
          pass_out((CDC_PRBS_SEL_LENGTH -1) + 1 downto 1) => CDC_PASSTHROUGH(linkID)((CDC_PRBS_SEL_LENGTH - 1) + 1 downto 1));

      partial_assignment: process (clk_axi) is
      begin  -- process partial_assignment
        if clk_axi'event and clk_axi = '1' then  -- rising clock edge
          --assign everything
          CM_C2C_Ctrl.Link(linkID).link_debug                 <= CTRL.CM(iCM).C2C(iLane).LINK_DEBUG;
          CM_C2C_Ctrl.Link(linkID).status                     <= CTRL.CM(iCM).C2C(iLane).status;
          --override these signals with the CDC versions
          CM_C2C_Ctrl.Link(linkID).LINK_DEBUG.RX.PRBS_CNT_RST <= CDC_PASSTHROUGH(linkID)(0);
          CM_C2C_Ctrl.Link(linkID).LINK_DEBUG.RX.PRBS_SEL     <= CDC_PASSTHROUGH(linkID)((CDC_PRBS_SEL_LENGTH -1) + 1 downto 1);        
        end if;
      end process partial_assignment;
    

      -------------------------------------------------------------------------------
      -- Phy_lane_control
      -------------------------------------------------------------------------------
      Phy_lane_control_X: entity work.CM_phy_lane_control
        generic map (
          CLKFREQ          => CLKFREQ,
          DATA_WIDTH       => DATA_WIDTH,
          ERROR_WAIT_TIME  => ERROR_WAIT_TIME)
        port map (
          clk              => clk_axi,
          reset            => reset,
          reset_counter    => CTRL.CM(iCM).C2C(iLane).CNT.RESET_COUNTERS,
          enable           => phycontrol_en(linkID),
          phy_lane_up      => CM_C2C_Mon.Link(linkID).status.phy_lane_up(0),
          phy_lane_stable  => CTRL.CM(iCM).C2C(iLane).PHY_LANE_STABLE,
          READ_TIME        => CTRL.CM(iCM).C2C(iLane).PHY_READ_TIME,
          initialize_out   => aurora_init_buf(linkID),
          lock             => phylanelock(linkID),
          state_out        => Mon.CM(iCM).C2C(iLane).CNT.PHYLANE_STATE,
          count_error_wait => Mon.CM(iCM).C2C(iLane).CNT.PHY_ERRORSTATE_COUNT,
          count_alltime    => Mon.CM(iCM).C2C(iLane).CNT.INIT_ALLTIME,
          count_shortterm  => Mon.CM(iCM).C2C(iLane).CNT.INIT_SHORTTERM);
      CM_C2C_Ctrl.Link(linkID).aurora_pma_init_in <= (aurora_init_buf(linkID) and CTRL.CM(iCM).C2C(iLane).ENABLE_PHY_CTRL) or
                                                     (CTRL.CM(iCM).C2C(iLane).STATUS.INITIALIZE and (not CTRL.CM(iCM).C2C(iLane).ENABLE_PHY_CTRL));
    

      -------------------------------------------------------------------------------
      -- COUNTERS
      -------------------------------------------------------------------------------
      GENERATE_COUNTERS_LOOP: for iCNT in 0 to COUNTER_COUNT -1 generate --....counter_count
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
            reset_sync  => CTRL.CM(iCM).C2C(iLane).CNT.RESET_COUNTERS,
            enable      => counter_en(linkID),
            event       => counter_events((linkID-1)*COUNTER_COUNT + iCNT ),
            count       => C2C_Counter((LinkID-1)*COUNTER_COUNT + iCNT),          --runs 1 to COUNTER_COUNT
            at_max      => open);   
      end generate GENERATE_COUNTERS_LOOP;
      --PATTERN FOR COUNTERS
      --setting events, run 0 to (COUNTER_COUNT - 1)
      counter_events((LinkID-1)*COUNTER_COUNT + 0) <= Mon.CM(iCM).C2C(iLane).STATUS.CONFIG_ERROR;
      counter_events((LinkID-1)*COUNTER_COUNT + 1) <= Mon.CM(iCM).C2C(iLane).STATUS.LINK_ERROR; 
      counter_events((LinkID-1)*COUNTER_COUNT + 2) <= Mon.CM(iCM).C2C(iLane).STATUS.MB_ERROR;
      counter_events((LinkID-1)*COUNTER_COUNT + 3) <= Mon.CM(iCM).C2C(iLane).STATUS.PHY_HARD_ERR;
      counter_events((LinkID-1)*COUNTER_COUNT + 4) <= Mon.CM(iCM).C2C(iLane).STATUS.PHY_SOFT_ERR;
      --setting counters, run 1 to COUNTER_COUNT
      Mon.CM(iCM).C2C(iLane).CNT.CONFIG_ERROR_COUNT   <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 0);
      Mon.CM(iCM).C2C(iLane).CNT.LINK_ERROR_COUNT     <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 1);
      Mon.CM(iCM).C2C(iLane).CNT.MB_ERROR_COUNT       <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 2);
      Mon.CM(iCM).C2C(iLane).CNT.PHY_HARD_ERROR_COUNT <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 3);
      Mon.CM(iCM).C2C(iLane).CNT.PHY_SOFT_ERROR_COUNT <= C2C_Counter((LinkID-1)*COUNTER_COUNT + 4);   
    end generate GENERATE_LANE_LOOP;
  end generate GENERATE_LOOP;
end architecture behavioral;
