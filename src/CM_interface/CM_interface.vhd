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
    CLKFREQ          : integer :=  50000000); --clk frequency in Hz
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
    CM_C2C_Mon       : in C2C_Monitor_t;
    CM_C2C_Ctrl      : out C2C_Control_t
    );
end entity CM_intf;

architecture behavioral of CM_intf is
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  
  signal PWR_good         : slv_2_t;
  signal enableCM_s       : slv_2_t;
  signal enableCM_PWR_s   : slv_2_t;
  signal override_PWRGood : slv_2_t;
  signal reset_error_state : slv_2_t;
  signal enable_uC        : slv_2_t;
  signal enable_PWR       : slv_2_t;
  signal enable_IOs       : slv_2_t;
  signal CM_seq_state     : slv_8_t;
  signal CM_disable     : std_logic_vector(1 downto 0);
  signal CM_uCIO_disable : std_logic_vector(1 downto 0);

  signal phylanelock : std_logic;
  
  signal reset             : std_logic;                     

  signal mon_active : slv_2_t;
  signal mon_errors : slv16_array_t(0 to 1);

  constant INACTIVE_COUNT : slv_32_t := x"03FFFFFF";
  constant PL_MEM_ADDR : unsigned(31 downto 0) := x"40000000";

  signal debug_history   : slv_32_t;
  signal debug_valid     : slv_4_t;

  signal Mon              : CM_Mon_t;
  signal Ctrl             : CM_Ctrl_t;

  
begin  -- architecture behavioral

  reset <= not reset_axi_n;
  
  -------------------------------------------------------------------------------
  -- CM interface
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------  
  --Generate loop for buffers
  GENERATE_BUF: for I in 1 to 2 generate
    CM_UART_BUF_X : OBUFT
      port map (
        T => CM_ucIO_disable(I - 1),
        I => to_CM_in.CM(I).UART_Tx,
        O => to_CM_out.CM(I).UART_Tx);
    CM_TMS_BUF_X : OBUFT
      port map (
        T => CM_disable(I - 1),
        I => to_CM_in.CM(I).TMS,
        O => to_CM_out.CM(I).TMS);
    CM_TDI_BUF_X : OBUFT
      port map (
        T => CM_disable(I - 1),
        I => to_CM_in.CM(I).TDI,
        O => to_CM_out.CM(I).TDI);
    CM_TCK_BUF_X : OBUFT
      port map (
        T => CM_disable(I - 1),
        I => to_CM_in.CM(I).TCK,
        O => to_CM_out.CM(I).TCK);
  end generate GENERATE_BUF;
  
  -------------------------------------------------------------------------------
  --Power-up sequences
  -------------------------------------------------------------------------------
  CM_PWR_SEQ: for iCM in 0 to 1 generate
    CM_pwr_1: entity work.CM_pwr
      generic map (
        COUNT_ERROR_WAIT => 50000000)
      port map (
        clk               => clk_axi,
        reset_async       => reset,
        reset_sync        => reset_error_state(iCM),
        uc_enabled        => enable_uC(iCM),
        start_PWR         => enableCM_PWR_s(iCM),
        sequence_override => override_PWRGood(iCM),
        current_state     => CM_seq_state((4*iCM) +3 downto 4*iCM),
        enabled_PWR       => enable_PWR(iCM),
        enabled_IOs       => enable_IOs(iCM),
        power_good        => PWR_good(iCM));

    enableCM(iCM) <= Ctrl.CM(iCM + 1).CTRL.ENABLE_UC;
    PWR_good(iCM) <= from_CM.CM(iCM + 1).PWR_good;
    enableCM_PWR(iCM) <= enableCM_PWR_s(iCM);
    enableCM_IOs(iCM) <= enable_IOs(iCM);
    CM_disable(iCM) <= not enable_IOs(iCM);
    CM_ucIO_disable(iCM) <= not enable_uc(iCM);
    
  end generate CM_PWR_SEQ;

  Mon.CM(1).CTRL.PWR_GOOD <= PWR_good(0);  

  
  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
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

  GENERATE_CTRL_MON: for I in 1 to 2 generate
    --CM power/reset signals?
    enable_uc(I - 1)            <= Ctrl.CM(I).CTRL.ENABLE_UC;         --CM enabled
    enableCM_PWR_s(I - 1)       <= Ctrl.CM(I).CTRL.ENABLE_PWR;        --CM power eneable
    override_PWRGood(I - 1)     <= Ctrl.CM(I).CTRL.OVERRIDE_PWR_GOOD; --CM override
    reset_error_state(I - 1)    <= Ctrl.CM(I).CTRL.ERROR_STATE_RESET; --CM reset error state
    --CM monitor signals
    Mon.CM(I).CTRL.STATE             <= CM_seq_state(((I*4)-1) downto ((I - 1)*4));
    Mon.CM(I).CTRL.PWR_ENABLED       <= enable_PWR(I - 1);
    Mon.CM(I).CTRL.IOS_ENABLED       <= enable_IOs(I - 1);
    Mon.CM(I).C2C.CONFIG_ERROR       <= CM_C2C_Mon.CM(I).axi_c2c_config_error_out;
    Mon.CM(I).C2C.LINK_ERROR         <= CM_C2C_Mon.CM(I).axi_c2c_link_error_out;     
    Mon.CM(I).C2C.LINK_GOOD          <= CM_C2C_Mon.CM(I).axi_c2c_link_status_out;    
    Mon.CM(I).C2C.MB_ERROR           <= CM_C2C_Mon.CM(I).axi_c2c_multi_bit_error_out;
    Mon.CM(I).C2C.DO_CC              <= CM_C2C_Mon.CM(I).aurora_do_cc;
    Mon.CM(I).C2C.PHY_RESET          <= CM_C2C_Mon.CM(I).phy_link_reset_out;     
    Mon.CM(I).C2C.PHY_GT_PLL_LOCK    <= CM_C2C_Mon.CM(I).phy_gt_pll_lock;        
    Mon.CM(I).C2C.PHY_MMCM_LOL       <= CM_C2C_Mon.CM(I).phy_mmcm_not_locked_out;
    Mon.CM(I).C2C.PHY_LANE_UP(0)     <= CM_C2C_Mon.CM(I).phy_lane_up(0);
    Mon.CM(I).C2C.PHY_HARD_ERR       <= CM_C2C_Mon.CM(I).phy_hard_err;           
    Mon.CM(I).C2C.PHY_SOFT_ERR       <= CM_C2C_Mon.CM(I).phy_soft_err;
    Mon.CM(I).C2C.CPLL_LOCK          <= CM_C2C_Mon.CM(I).cplllock;
    Mon.CM(I).C2C.EYESCAN_DATA_ERROR <= CM_C2C_Mon.CM(I).eyescandataerror;
    Mon.CM(I).C2C.DMONITOR           <= CM_C2C_Mon.CM(I).dmonitorout;
    Mon.CM(I).C2C.RX.BUF_STATUS      <= CM_C2C_Mon.CM(I).rxbufstatus;
    Mon.CM(I).C2C.RX.MONITOR         <= CM_C2C_Mon.CM(I).rxmonitorout;
    Mon.CM(I).C2C.RX.PRBS_ERR        <= CM_C2C_Mon.CM(I).rxprbserr;
    Mon.CM(I).C2C.RX.RESET_DONE      <= CM_C2C_Mon.CM(I).rxresetdone;
    Mon.CM(I).C2C.TX.BUF_STATUS      <= CM_C2C_Mon.CM(I).txbufstatus;
    Mon.CM(I).C2C.TX.RESET_DONE      <= CM_C2C_Mon.CM(I).txresetdone;
    --C2C control signals
    --CM_C2C_Ctrl.CM(I).aurora_pma_init_in <= CTRL.CM(I).C2C.INITIALIZE;
    CM_C2C_Ctrl.CM(I).eyescanreset       <= CTRL.CM(I).C2C.EYESCAN_RESET;
    CM_C2C_Ctrl.CM(I).eyescantrigger     <= CTRL.CM(I).C2C.EYESCAN_TRIGGER;
    CM_C2C_Ctrl.CM(I).rxbufreset         <= CTRL.CM(I).C2C.RX.BUF_RESET;
    CM_C2C_Ctrl.CM(I).rxcdrhold          <= CTRL.CM(I).C2C.RX.CDR_HOLD;   
    CM_C2C_Ctrl.CM(I).rxdfeagchold       <= CTRL.CM(I).C2C.RX.DFE_AGC_HOLD;
    CM_C2C_Ctrl.CM(I).rxdfeagcovrden     <= CTRL.CM(I).C2C.RX.DFE_AGC_OVERRIDE;
    CM_C2C_Ctrl.CM(I).rxdfelfhold        <= CTRL.CM(I).C2C.RX.DFE_LF_HOLD;
    CM_C2C_Ctrl.CM(I).rxdfelpmreset      <= CTRL.CM(I).C2C.RX.DFE_LPM_RESET;
    CM_C2C_Ctrl.CM(I).rxlpmen            <= CTRL.CM(I).C2C.RX.LPM_EN;
    CM_C2C_Ctrl.CM(I).rxlpmhfovrden      <= CTRL.CM(I).C2C.RX.LPM_HF_OVERRIDE;
    CM_C2C_Ctrl.CM(I).rxlpmlfklovrden    <= CTRL.CM(I).C2C.RX.LPM_LFKL_OVERRIDE;
    CM_C2C_Ctrl.CM(I).rxmonitorsel       <= CTRL.CM(I).C2C.RX.MON_SEL;
    CM_C2C_Ctrl.CM(I).rxpcsreset         <= CTRL.CM(I).C2C.RX.PCS_RESET;
    CM_C2C_Ctrl.CM(I).rxpmareset         <= CTRL.CM(I).C2C.RX.PMA_RESET;
    CM_C2C_Ctrl.CM(I).rxprbscntreset     <= CTRL.CM(I).C2C.RX.PRBS_CNT_RST;
    CM_C2C_Ctrl.CM(I).rxprbssel          <= CTRL.CM(I).C2C.RX.PRBS_SEL;
    CM_C2C_Ctrl.CM(I).txdiffctrl         <= CTRL.CM(I).C2C.TX.DIFF_CTRL;
    CM_C2C_Ctrl.CM(I).txinhibit          <= CTRL.CM(I).C2C.TX.INHIBIT;
    CM_C2C_Ctrl.CM(I).txmaincursor       <= CTRL.CM(I).C2C.TX.MAIN_CURSOR;
    CM_C2C_Ctrl.CM(I).txpcsreset         <= CTRL.CM(I).C2C.TX.PCS_RESET;
    CM_C2C_Ctrl.CM(I).txpmareset         <= CTRL.CM(I).C2C.TX.PMA_RESET;
    CM_C2C_Ctrl.CM(I).txpolarity         <= CTRL.CM(I).C2C.TX.POLARITY;
    CM_C2C_Ctrl.CM(I).txpostcursor       <= CTRL.CM(I).C2C.TX.POST_CURSOR;
    CM_C2C_Ctrl.CM(I).txprbsforceerr     <= CTRL.CM(I).C2C.TX.PRBS_FORCE_ERR;
    CM_C2C_Ctrl.CM(I).txprbssel          <= CTRL.CM(I).C2C.TX.PRBS_SEL;
    CM_C2C_Ctrl.CM(I).txprecursor        <= CTRL.CM(I).C2C.TX.PRE_CURSOR;
    
  end generate GENERATE_CTRL_MON;

  --Signals only relavant to CM1
  Mon.CM(1).MONITOR.ACTIVE         <= mon_active(0);
  Mon.CM(1).MONITOR.HISTORY_VALID  <= debug_valid;
  Mon.CM(1).MONITOR.ERRORS         <= mon_errors(0);
  Mon.CM(1).MONITOR.HISTORY        <= debug_history;

  Phy_Lane_Control_1: entity work.phy_lane_control
    generic map (
      CLKFREQ => CLKFREQ)
    port map (
      clk => clk_axi,
      reset => reset,
      enable => '1',
      initialize_in => CTRL.CM(1).C2C.INITIALIZE,
      phy_lane_ => CM_C2C_Mon.CM(1).phy_lane_up(0),
      initialize_out => CM_C2C_Ctrl.CM(1).aurora_pma_init_in,
      lock => phylanelock);

    Phy_Lane_Control_2: entity work.phy_lane_control
    generic map (
      CLKFREQ => CLKFREQ)
    port map (
      clk => clk_axi,
      reset => reset,
      enable => phylanelock,
      initialize_in => CTRL.CM(2).C2C.INITIALIZE,
      phy_lane_ => CM_C2C_Mon.CM(2).phy_lane_up(0),
      initialize_out => CM_C2C_Ctrl.CM(2).aurora_pma_init_in,
      lock => open);

  
  
  -------------------------------------------------------------------------------

  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS => 8,
      INACTIVE_COUNT  => INACTIVE_COUNT,
      BASE_ADDRESS    => PL_MEM_ADDR)
    port map (
      clk            => clk_axi,
      reset          => reset,
      uart_rx        => CM_mon_uart,
      baud_16x_count => CTRL.CM(1).MONITOR.COUNT_16X_BAUD,
      readMOSI       => master_readMOSI,
      readMISO       => master_readMISO,
      writeMOSI      => master_writeMOSI,
      writeMISO      => master_writeMISO,
      debug_history  => debug_history,
      debug_valid    => debug_valid,
      error_count    => mon_errors(0),
      channel_active => mon_active(0));
  
end architecture behavioral;
