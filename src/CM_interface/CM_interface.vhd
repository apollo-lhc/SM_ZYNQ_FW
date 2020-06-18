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
    enableCM1        : out std_logic;
    enableCM2        : out std_logic;
    enableCM1_PWR    : out std_logic;
    enableCM2_PWR    : out std_logic;
    enableCM1_IOs    : out std_logic;
    enableCM2_IOs    : out std_logic;
    from_CM1         :  in from_CM_t;
    from_CM2         :  in from_CM_t;
    to_CM1_in        :  in to_CM_t;  --from SM
    to_CM2_in        :  in to_CM_t;  --from SM
    to_CM1_out       : out to_CM_t;  --from SM, but tristated
    to_CM2_out       : out to_CM_t;  --from SM, but tristated
    clk_C2C1         :  in std_logic;
    CM1_C2C_Mon      :  in C2C_Monitor_t;
    CM1_C2C_Ctrl     : out C2C_Control_t;
    clk_C2C2         :  in std_logic;
    CM2_C2C_Mon      :  in C2C_Monitor_t;
    CM2_C2C_Ctrl     : out C2C_Control_t    
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
  signal enableCM         : slv_2_t;
  signal enableCM_PWR     : slv_2_t;
  signal override_PWRGood : slv_2_t;
  signal reset_error_state : slv_2_t;
  signal enable_uC        : slv_2_t;
  signal enable_PWR       : slv_2_t;
  signal enable_IOs       : slv_2_t;
  signal CM_seq_state     : slv_8_t;
  signal CM1_disable      : std_logic;
  signal CM2_disable      : std_logic;

  signal CM1_uCIO_disable      : std_logic;
  signal CM2_uCIO_disable      : std_logic;


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
  --CM1
  CM1_UART_BUF : OBUFT
    port map (
      T => CM1_ucIO_disable,
      I => to_CM1_in.UART_Tx,
      O => to_CM1_out.UART_Tx);
  CM1_TMS_BUF : OBUFT
    port map (
      T => CM1_disable,
      I => to_CM1_in. TMS,
      O => to_CM1_out.TMS);
  CM1_TDI_BUF : OBUFT
    port map (
      T => CM1_disable,
      I => to_CM1_in. TDI,
      O => to_CM1_out.TDI);
  CM1_TCK_BUF : OBUFT
    port map (
      T => CM1_disable,
      I => to_CM1_in. TCK,
      O => to_CM1_out.TCK);
  --CM2
  CM2_UART_BUF : OBUFT
    port map (
      T => CM2_ucIO_disable,
      I => to_CM2_in.UART_Tx,
      O => to_CM2_out.UART_Tx);
  CM2_TMS_BUF : OBUFT
    port map (
      T => CM2_disable,
      I => to_CM2_in. TMS,
      O => to_CM2_out.TMS);
  CM2_TDI_BUF : OBUFT
    port map (
      T => CM2_disable,
      I => to_CM2_in. TDI,
      O => to_CM2_out.TDI);
  CM2_TCK_BUF : OBUFT
    port map (
      T => CM2_disable,
      I => to_CM2_in. TCK,
      O => to_CM2_out.TCK);


  
  -------------------------------------------------------------------------------
  --Power-up sequences
  -------------------------------------------------------------------------------
  enableCM1     <= Ctrl.CM1.CTRL.ENABLE_UC;
  PWR_good(0)           <= from_CM1.PWR_good;
  Mon.CM1.CTRL.PWR_GOOD <= PWR_good(0);  

  enableCM1_PWR <= enable_PWR(0);
  enableCM1_IOs <= enable_IOs(0);
  CM1_disable   <= not enable_IOs(0);
  CM1_ucIO_disable   <= not enable_uc(0);

  PWR_good(1)   <= from_CM2.PWR_good;
  enableCM2     <= enable_uC(1);
  enableCM2_PWR <= enable_PWR(1);
  enableCM2_IOs <= enable_IOs(1);
  CM2_disable   <= not enable_IOs(1);
  CM2_ucIO_disable   <= not enable_uc(1);

  
  
  CM_PWR_SEQ: for iCM in 0 to 1 generate
    CM_pwr_1: entity work.CM_pwr
      generic map (
        COUNT_ERROR_WAIT => 50000000)
      port map (
        clk               => clk_axi,
        reset_async       => reset,
        reset_sync        => reset_error_state(iCM),
        uc_enabled        => enable_uC(iCM),
        start_PWR         => enableCM_PWR(iCM),
        sequence_override => override_PWRGood(iCM),
        current_state     => CM_seq_state((4*iCM) +3 downto 4*iCM),
        enabled_PWR       => enable_PWR(iCM),
        enabled_IOs       => enable_IOs(iCM),
        power_good        => PWR_good(iCM));
  end generate CM_PWR_SEQ;
  
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

  
  enable_uc       (0)      <= Ctrl.CM1.CTRL.ENABLE_UC;         --CM1 enabled
  enableCM_PWR    (0)      <= Ctrl.CM1.CTRL.ENABLE_PWR;        --CM1 power eneable
  override_PWRGood(0)      <= Ctrl.CM1.CTRL.OVERRIDE_PWR_GOOD; --CM1 override
  reset_error_state(0)     <= Ctrl.CM1.CTRL.ERROR_STATE_RESET; --CM1 reset error state

  enable_uc       (1)      <= Ctrl.CM2.CTRL.ENABLE_UC;         --CM2 enabled
  enableCM_PWR    (1)      <= Ctrl.CM2.CTRL.ENABLE_PWR;        --CM2 power eneable
  override_PWRGood(1)      <= Ctrl.CM2.CTRL.OVERRIDE_PWR_GOOD; --CM2 override
  reset_error_state(1)     <= Ctrl.CM2.CTRL.ERROR_STATE_RESET; --CM2 reset error state

  DC_data_CDC_1: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 4)
    port map (
      clk_in               => clk_axi,
      clk_out              => clk_C2C1,
      reset                => reset,
      pass_in(0)           => CTRL.CM1.C2C.RX.PRBS_CNT_RST,
      pass_in(3 downto 1)  => CTRL.CM1.C2C.RX.PRBS_SEL,
      pass_out(0)          => CM1_C2C_Ctrl.rxprbscntreset,
      pass_out(3 downto 1) => CM1_C2C_Ctrl.rxprbssel);

  DC_data_CDC_2: entity work.DC_data_CDC
    generic map (
      DATA_WIDTH => 4)
    port map (
      clk_in               => clk_axi,
      clk_out              => clk_C2C2,
      reset                => reset,
      pass_in(0)           => CTRL.CM2.C2C.RX.PRBS_CNT_RST,
      pass_in(3 downto 1)  => CTRL.CM2.C2C.RX.PRBS_SEL,
      pass_out(0)          => CM2_C2C_Ctrl.rxprbscntreset,
      pass_out(3 downto 1) => CM2_C2C_Ctrl.rxprbssel);

  
  Mon.CM1.CTRL.STATE             <= CM_seq_state(3 downto 0);
  Mon.CM1.CTRL.PWR_ENABLED       <= enable_PWR(0);
  Mon.CM1.CTRL.IOS_ENABLED       <= enable_IOs(0);
  Mon.CM1.C2C.CONFIG_ERROR       <= CM1_C2C_Mon.axi_c2c_config_error_out;
  Mon.CM1.C2C.LINK_ERROR         <= CM1_C2C_Mon.axi_c2c_link_error_out;     
  Mon.CM1.C2C.LINK_GOOD          <= CM1_C2C_Mon.axi_c2c_link_status_out;    
  Mon.CM1.C2C.MB_ERROR           <= CM1_C2C_Mon.axi_c2c_multi_bit_error_out;
  Mon.CM1.C2C.DO_CC              <= CM1_C2C_Mon.aurora_do_cc;
  Mon.CM1.C2C.PHY_RESET          <= CM1_C2C_Mon.phy_link_reset_out;     
  Mon.CM1.C2C.PHY_GT_PLL_LOCK    <= CM1_C2C_Mon.phy_gt_pll_lock;        
  Mon.CM1.C2C.PHY_MMCM_LOL       <= CM1_C2C_Mon.phy_mmcm_not_locked_out;
  Mon.CM1.C2C.PHY_LANE_UP(0)     <= CM1_C2C_Mon.phy_lane_up(0);
  Mon.CM1.C2C.PHY_HARD_ERR       <= CM1_C2C_Mon.phy_hard_err;           
  Mon.CM1.C2C.PHY_SOFT_ERR       <= CM1_C2C_Mon.phy_soft_err;
  Mon.CM1.C2C.CPLL_LOCK          <= CM1_C2C_Mon.cplllock;
  Mon.CM1.C2C.EYESCAN_DATA_ERROR <= CM1_C2C_Mon.eyescandataerror;
  Mon.CM1.C2C.DMONITOR           <= CM1_C2C_Mon.dmonitorout;
  Mon.CM1.C2C.RX.BUF_STATUS      <= CM1_C2C_Mon.rxbufstatus;
  Mon.CM1.C2C.RX.MONITOR         <= CM1_C2C_Mon.rxmonitorout;
  Mon.CM1.C2C.RX.PRBS_ERR        <= CM1_C2C_Mon.rxprbserr;
  Mon.CM1.C2C.RX.RESET_DONE      <= CM1_C2C_Mon.rxresetdone;
  Mon.CM1.C2C.TX.BUF_STATUS      <= CM1_C2C_Mon.txbufstatus;
  Mon.CM1.C2C.TX.RESET_DONE      <= CM1_C2C_Mon.txresetdone;
  Mon.CM1.MONITOR.ACTIVE         <= mon_active(0);
  Mon.CM1.MONITOR.HISTORY_VALID  <= debug_valid;
--           <= mon_errors(0);
  Mon.CM1.MONITOR.HISTORY        <= debug_history;

  
  Mon.CM2.CTRL.STATE       <= CM_seq_state(7 downto 4);
  Mon.CM2.CTRL.PWR_ENABLED <= enable_PWR(1);
  Mon.CM2.CTRL.IOS_ENABLED <= enable_IOs(1);
  Mon.CM2.C2C.CONFIG_ERROR       <= CM2_C2C_Mon.axi_c2c_config_error_out;
  Mon.CM2.C2C.LINK_ERROR         <= CM2_C2C_Mon.axi_c2c_link_error_out;     
  Mon.CM2.C2C.LINK_GOOD          <= CM2_C2C_Mon.axi_c2c_link_status_out;    
  Mon.CM2.C2C.MB_ERROR           <= CM2_C2C_Mon.axi_c2c_multi_bit_error_out;
  Mon.CM2.C2C.DO_CC              <= CM2_C2C_Mon.aurora_do_cc;
  Mon.CM2.C2C.PHY_RESET          <= CM2_C2C_Mon.phy_link_reset_out;     
  Mon.CM2.C2C.PHY_GT_PLL_LOCK    <= CM2_C2C_Mon.phy_gt_pll_lock;        
  Mon.CM2.C2C.PHY_MMCM_LOL       <= CM2_C2C_Mon.phy_mmcm_not_locked_out;
  Mon.CM2.C2C.PHY_LANE_UP(0)     <= CM2_C2C_Mon.phy_lane_up(0);
  Mon.CM2.C2C.PHY_HARD_ERR       <= CM2_C2C_Mon.phy_hard_err;           
  Mon.CM2.C2C.PHY_SOFT_ERR       <= CM2_C2C_Mon.phy_soft_err;
  Mon.CM2.C2C.CPLL_LOCK          <= CM2_C2C_Mon.cplllock;
  Mon.CM2.C2C.EYESCAN_DATA_ERROR <= CM2_C2C_Mon.eyescandataerror;
  Mon.CM2.C2C.DMONITOR           <= CM2_C2C_Mon.dmonitorout;
  Mon.CM2.C2C.RX.BUF_STATUS      <= CM2_C2C_Mon.rxbufstatus;
  Mon.CM2.C2C.RX.MONITOR         <= CM2_C2C_Mon.rxmonitorout;
  Mon.CM2.C2C.RX.PRBS_ERR        <= CM2_C2C_Mon.rxprbserr;
  Mon.CM2.C2C.RX.RESET_DONE      <= CM2_C2C_Mon.rxresetdone;
  Mon.CM2.C2C.TX.BUF_STATUS      <= CM2_C2C_Mon.txbufstatus;
  Mon.CM2.C2C.TX.RESET_DONE      <= CM2_C2C_Mon.txresetdone;



  CM1_C2C_Ctrl.aurora_pma_init_in <= CTRL.CM1.C2C.INITIALIZE;
  CM1_C2C_Ctrl.eyescanreset       <= CTRL.CM1.C2C.EYESCAN_RESET;
  CM1_C2C_Ctrl.eyescantrigger     <= CTRL.CM1.C2C.EYESCAN_TRIGGER;
  CM1_C2C_Ctrl.rxbufreset         <= CTRL.CM1.C2C.RX.BUF_RESET;
  CM1_C2C_Ctrl.rxcdrhold          <= CTRL.CM1.C2C.RX.CDR_HOLD;   
  CM1_C2C_Ctrl.rxdfeagchold       <= CTRL.CM1.C2C.RX.DFE_AGC_HOLD;
  CM1_C2C_Ctrl.rxdfeagcovrden     <= CTRL.CM1.C2C.RX.DFE_AGC_OVERRIDE;
  CM1_C2C_Ctrl.rxdfelfhold        <= CTRL.CM1.C2C.RX.DFE_LF_HOLD;
  CM1_C2C_Ctrl.rxdfelpmreset      <= CTRL.CM1.C2C.RX.DFE_LPM_RESET;
  CM1_C2C_Ctrl.rxlpmen            <= CTRL.CM1.C2C.RX.LPM_EN;
  CM1_C2C_Ctrl.rxlpmhfovrden      <= CTRL.CM1.C2C.RX.LPM_HF_OVERRIDE;
  CM1_C2C_Ctrl.rxlpmlfklovrden    <= CTRL.CM1.C2C.RX.LPM_LFKL_OVERRIDE;
  CM1_C2C_Ctrl.rxmonitorsel       <= CTRL.CM1.C2C.RX.MON_SEL;
  CM1_C2C_Ctrl.rxpcsreset         <= CTRL.CM1.C2C.RX.PCS_RESET;
  CM1_C2C_Ctrl.rxpmareset         <= CTRL.CM1.C2C.RX.PMA_RESET;
  CM1_C2C_Ctrl.txdiffctrl         <= CTRL.CM1.C2C.TX.DIFF_CTRL;
  CM1_C2C_Ctrl.txinhibit          <= CTRL.CM1.C2C.TX.INHIBIT;
  CM1_C2C_Ctrl.txmaincursor       <= CTRL.CM1.C2C.TX.MAIN_CURSOR;
  CM1_C2C_Ctrl.txpcsreset         <= CTRL.CM1.C2C.TX.PCS_RESET;
  CM1_C2C_Ctrl.txpmareset         <= CTRL.CM1.C2C.TX.PMA_RESET;
  CM1_C2C_Ctrl.txpolarity         <= CTRL.CM1.C2C.TX.POLARITY;
  CM1_C2C_Ctrl.txpostcursor       <= CTRL.CM1.C2C.TX.POST_CURSOR;
  CM1_C2C_Ctrl.txprbsforceerr     <= CTRL.CM1.C2C.TX.PRBS_FORCE_ERR;
  CM1_C2C_Ctrl.txprbssel          <= CTRL.CM1.C2C.TX.PRBS_SEL;
  CM1_C2C_Ctrl.txprecursor        <= CTRL.CM1.C2C.TX.PRE_CURSOR;

  CM2_C2C_Ctrl.aurora_pma_init_in <= CTRL.CM2.C2C.INITIALIZE;
  CM2_C2C_Ctrl.eyescanreset       <= CTRL.CM2.C2C.EYESCAN_RESET;
  CM2_C2C_Ctrl.eyescantrigger     <= CTRL.CM2.C2C.EYESCAN_TRIGGER;
  CM2_C2C_Ctrl.rxbufreset         <= CTRL.CM2.C2C.RX.BUF_RESET;
  CM2_C2C_Ctrl.rxcdrhold          <= CTRL.CM2.C2C.RX.CDR_HOLD;   
  CM2_C2C_Ctrl.rxdfeagchold       <= CTRL.CM2.C2C.RX.DFE_AGC_HOLD;
  CM2_C2C_Ctrl.rxdfeagcovrden     <= CTRL.CM2.C2C.RX.DFE_AGC_OVERRIDE;
  CM2_C2C_Ctrl.rxdfelfhold        <= CTRL.CM2.C2C.RX.DFE_LF_HOLD;
  CM2_C2C_Ctrl.rxdfelpmreset      <= CTRL.CM2.C2C.RX.DFE_LPM_RESET;
  CM2_C2C_Ctrl.rxlpmen            <= CTRL.CM2.C2C.RX.LPM_EN;
  CM2_C2C_Ctrl.rxlpmhfovrden      <= CTRL.CM2.C2C.RX.LPM_HF_OVERRIDE;
  CM2_C2C_Ctrl.rxlpmlfklovrden    <= CTRL.CM2.C2C.RX.LPM_LFKL_OVERRIDE;
  CM2_C2C_Ctrl.rxmonitorsel       <= CTRL.CM2.C2C.RX.MON_SEL;
  CM2_C2C_Ctrl.rxpcsreset         <= CTRL.CM2.C2C.RX.PCS_RESET;
  CM2_C2C_Ctrl.rxpmareset         <= CTRL.CM2.C2C.RX.PMA_RESET;
  CM2_C2C_Ctrl.txdiffctrl         <= CTRL.CM2.C2C.TX.DIFF_CTRL;
  CM2_C2C_Ctrl.txinhibit          <= CTRL.CM2.C2C.TX.INHIBIT;
  CM2_C2C_Ctrl.txmaincursor       <= CTRL.CM2.C2C.TX.MAIN_CURSOR;
  CM2_C2C_Ctrl.txpcsreset         <= CTRL.CM2.C2C.TX.PCS_RESET;
  CM2_C2C_Ctrl.txpmareset         <= CTRL.CM2.C2C.TX.PMA_RESET;
  CM2_C2C_Ctrl.txpolarity         <= CTRL.CM2.C2C.TX.POLARITY;
  CM2_C2C_Ctrl.txpostcursor       <= CTRL.CM2.C2C.TX.POST_CURSOR;
  CM2_C2C_Ctrl.txprbsforceerr     <= CTRL.CM2.C2C.TX.PRBS_FORCE_ERR;
  CM2_C2C_Ctrl.txprbssel          <= CTRL.CM2.C2C.TX.PRBS_SEL;
  CM2_C2C_Ctrl.txprecursor        <= CTRL.CM2.C2C.TX.PRE_CURSOR;
  -------------------------------------------------------------------------------

  CM_Monitoring_1: entity work.CM_Monitoring
    generic map (
      BAUD_COUNT_BITS => 8,
      INACTIVE_COUNT  => INACTIVE_COUNT,
      BASE_ADDRESS    => PL_MEM_ADDR)
    port map (
      clk                            => clk_axi,
      reset                          => reset,
      uart_rx                        => CM_mon_uart,
      baud_16x_count                 => CTRL.CM1.MONITOR.COUNT_16X_BAUD,
      readMOSI                       => master_readMOSI,
      readMISO                       => master_readMISO,
      writeMOSI                      => master_writeMOSI,
      writeMISO                      => master_writeMISO,
      debug_history                  => debug_history,
      debug_valid                    => debug_valid,
      uart_byte_count                => Mon.CM1.MONITOR.UART_BYTES,
      error_reset                    => CTRL.CM1.MONITOR.ERRORS.RESET,
      error_count(0)                 => Mon.CM1.MONITOR.ERRORS.CNT_BAD_SOF,
      error_count(1)                 => Mon.CM1.MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2,
      error_count(2)                 => Mon.CM1.MONITOR.ERRORS.CNT_BYTE2_NOT_DATA,
      error_count(3)                 => Mon.CM1.MONITOR.ERRORS.CNT_BYTE3_NOT_DATA,
      error_count(4)                 => Mon.CM1.MONITOR.ERRORS.CNT_BYTE4_NOT_DATA,
      error_count(5)                 => Mon.CM1.MONITOR.ERRORS.CNT_UNKNOWN,
      bad_transaction(31 downto 24)  => Mon.CM1.MONITOR.BAD_TRANS.ERROR_MASK,
      bad_transaction(23 downto  8)  => Mon.CM1.MONITOR.BAD_TRANS.DATA,
      bad_transaction( 7 downto  0)  => Mon.CM1.MONITOR.BAD_TRANS.ADDR,
      last_transaction(31 downto 24) => Mon.CM1.MONITOR.LAST_TRANS.ERROR_MASK,
      last_transaction(23 downto  8) => Mon.CM1.MONITOR.LAST_TRANS.DATA,
      last_transaction( 7 downto  0) => Mon.CM1.MONITOR.LAST_TRANS.ADDR,
      channel_active => mon_active(0));
  

  
end architecture behavioral;
