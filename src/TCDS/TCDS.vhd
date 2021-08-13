library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.AXIRegPkg.all; --for AXIReadMOSI, AXIReadMISO, AXIWriteMOSI, and AXIWriteMISO

--use work.tclink_lpgbt10G_pkg.all;

use work.tcds2_interface_pkg.all;
use work.tcds2_link_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

use work.TCDS_2_Ctrl.all;

use work.tclink_lpgbt_pkg.all;

entity TCDS is
  port (
    -- AXI interface
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;


    -- System clock at 125 MHz.
    clk_sys_125mhz : in std_logic;

    -- MGT data interface.
    mgt_tx_p_o : out std_logic;
    mgt_tx_n_o : out std_logic;
    mgt_rx_p_i : in std_logic;
    mgt_rx_n_i : in std_logic;

    clk_TCDS_REC_in_p  : in  std_logic;
    clk_TCDS_REC_in_n  : in  std_logic;
    clk_TCDS_320_in_p  : in  std_logic;
    clk_TCDS_320_in_n  : in  std_logic;

    clk_TCDS_REC_out_p : out std_logic;
    clk_TCDS_REC_out_n : out std_logic;
    -- LHC bunch clock output.
    -- NOTE: This clock originates from a BUFGCE_DIV and is intended
    -- for use in the FPGA clocking fabric.
    clk_TCDS : out std_logic;

    LTTC_P   : out std_logic_vector(1 downto 0);
    LTTC_N   : out std_logic_vector(1 downto 0);

    LTTS_P   : in  std_logic_vector(1 downto 0);
    LTTS_N   : in  std_logic_vector(1 downto 0)

    );
end entity TCDS;

architecture behavioral of TCDS is

  signal Mon              :  TCDS_2_Mon_t;
  signal Ctrl             :  TCDS_2_Ctrl_t;

  -- Control and status interfaces.
  signal ctrl_i : tcds2_interface_ctrl_t;
  signal stat_o : tcds2_interface_stat_t;
  
  -- Transceiver control and status signals.
  signal mgt_ctrl : tr_core_to_mgt;
  signal mgt_stat : tr_mgt_to_core;
  
  -- User clock network control and status signals.
  signal mgt_clk_ctrl : tr_clk_to_mgt;
  signal mgt_clk_stat : tr_mgt_to_clk;

  -- LHC bunch clock ODDR outputs.
  -- NOTE: These lines are intended to drive an ODDR1, in order to
  -- extract the bunch clock from the FPGA.
  signal clk_40_oddr_c  : std_logic;
  signal clk_40_oddr_d1 : std_logic;
  signal clk_40_oddr_d2 : std_logic;
  signal clk_40_out     : std_logic;

  signal clk_TCDS_320   : std_logic;
  signal clk_TCDS_REC   : std_logic;

  -- TCDS2 channel 0 interface.
  signal channel0_ttc2_o : tcds2_ttc2;
  signal channel0_tts2_i : tcds2_tts2_value_array(0 downto 0);

  -- TCDS2 channel 1 interface.
  signal channel1_ttc2_o : tcds2_ttc2;
  signal channel1_tts2_i : tcds2_tts2_value_array(0 downto 0);

  constant zero : std_logic := '0';

  signal local_TCDS_clk1 : std_logic;
  signal local_TCDS_clk2 : std_logic;
  signal local_TCDS_refclk1 : std_logic;
  signal local_TCDS_refclk2 : std_logic;

  signal ttc_data : slv_32_t;
  signal tts_data : slv32_array_t(1 downto 0);
  
begin

  

  ------------------------------------------
  -- The core TCDS2 interface.
  ------------------------------------------

  tcds2_interface : entity work.tcds2_interface
    generic map (
      G_LINK_SPEED             => TCDS2_LINK_SPEED_10G,
      G_INCLUDE_PRBS_LINK_TEST => true
      )
    port map (
      ctrl_i => ctrl_i,
      stat_o => stat_o,

      clk_sys_125mhz => clk_sys_125mhz,

      mgt_ctrl_o     => mgt_ctrl,
      mgt_stat_i     => mgt_stat,
      mgt_clk_ctrl_o => mgt_clk_ctrl,
      mgt_clk_stat_i => mgt_clk_stat,

      clk_40_o => clk_TCDS,

      clk_40_oddr_c_o  => clk_40_oddr_c,
      clk_40_oddr_d1_o => clk_40_oddr_d1,
      clk_40_oddr_d2_o => clk_40_oddr_d2,

      orbit_o => open,

      channel0_ttc2_o => channel0_ttc2_o,
      channel0_tts2_i => channel0_tts2_i,

      channel1_ttc2_o => channel1_ttc2_o,
      channel1_tts2_i => channel1_tts2_i
      );

  ------------------------------------------
  -- The transceiver.
  ------------------------------------------
  TCDS_320 : ibufds_gte4
    port map (
      i   => clk_TCDS_320_in_p,
      ib  => clk_TCDS_320_in_n,
      o   => clk_TCDS_320,
      ceb => zero--'0'
      );
  TCDS_REC : ibufds_gte4
    port map (
      i   => clk_TCDS_REC_in_p,
      ib  => clk_TCDS_REC_in_n,
      o   => clk_TCDS_REC,
      ceb => zero--'0'
      );
  
  

  mgt : entity work.tcds2_interface_mgt
    generic map (
      G_MGT_TYPE   => MGT_TYPE_GTHE3,
      G_LINK_SPEED => TCDS2_LINK_SPEED_10G
      )
    port map (
      -- Quad.
      gtwiz_reset_clk_freerun_in(0)         => clk_sys_125mhz,
      gtwiz_reset_all_in                    => mgt_ctrl.gtwiz_reset_all_in,   
      gtwiz_reset_tx_pll_and_datapath_in    => mgt_ctrl.gtwiz_reset_tx_pll_and_datapath_in,
      gtwiz_reset_rx_pll_and_datapath_in    => mgt_ctrl.gtwiz_reset_rx_pll_and_datapath_in,
      gtwiz_reset_tx_datapath_in            => mgt_ctrl.gtwiz_reset_tx_datapath_in,
      gtwiz_reset_rx_datapath_in            => mgt_ctrl.gtwiz_reset_rx_datapath_in,


      gtrefclk00_in(0)                      => clk_TCDS_320,
      gtrefclk01_in(0)                      => clk_TCDS_REC,
      qpll0outclk_out(0)                    => local_TCDS_clk1,
      qpll0outrefclk_out(0)                 => local_TCDS_refclk1,
      qpll1outclk_out(0)                    => local_TCDS_clk2,
      qpll1outrefclk_out(0)                 => local_TCDS_refclk2,

      -- User clocking.
      txusrclk_in(0)                        => mgt_clk_ctrl.txusrclk,
      txusrclk2_in(0)                       => mgt_clk_ctrl.txusrclk,
      rxusrclk_in(0)                        => mgt_clk_ctrl.rxusrclk,
      rxusrclk2_in(0)                       => mgt_clk_ctrl.rxusrclk,
      txoutclk_out(0)                       => mgt_clk_stat.txoutclk,
      rxoutclk_out(0)                       => mgt_clk_stat.rxoutclk,

      -- Channel.
      gtwiz_userclk_tx_active_in            => mgt_ctrl.gtwiz_userclk_tx_active_in,
      gtwiz_userclk_rx_active_in            => mgt_ctrl.gtwiz_userclk_rx_active_in,
      gtwiz_buffbypass_rx_reset_in          => mgt_ctrl.gtwiz_buffbypass_rx_reset_in,
      gtwiz_buffbypass_rx_start_user_in     => mgt_ctrl.gtwiz_buffbypass_rx_start_user_in,
      gtwiz_buffbypass_rx_done_out          => mgt_stat.gtwiz_buffbypass_rx_done_out,
      gtwiz_buffbypass_rx_error_out         => mgt_stat.gtwiz_buffbypass_rx_error_out,
      gtwiz_reset_rx_cdr_stable_out         => mgt_stat.gtwiz_reset_rx_cdr_stable_out,
      gtwiz_reset_tx_done_out               => mgt_stat.gtwiz_reset_tx_done_out,
      gtwiz_reset_rx_done_out               => mgt_stat.gtwiz_reset_rx_done_out,
      qpll0lock_out                         => mgt_stat.txplllock_out,
      qpll1lock_out                         => mgt_stat.rxplllock_out,
      loopback_in                           => mgt_ctrl.loopback_in,
      rxdfeagcovrden_in                     => mgt_ctrl.rxdfeagcovrden_in,
      rxdfelfovrden_in                      => mgt_ctrl.rxdfelfovrden_in,
      rxdfelpmreset_in                      => mgt_ctrl.rxdfelpmreset_in,
      rxdfeutovrden_in                      => mgt_ctrl.rxdfeutovrden_in,
      rxdfevpovrden_in                      => mgt_ctrl.rxdfevpovrden_in,
      rxlpmen_in                            => mgt_ctrl.rxlpmen_in,
      rxosovrden_in                         => mgt_ctrl.rxosovrden_in,
      rxlpmgcovrden_in                      => mgt_ctrl.rxlpmgcovrden_in,
      rxlpmhfovrden_in                      => mgt_ctrl.rxlpmhfovrden_in,
      rxlpmlfklovrden_in                    => mgt_ctrl.rxlpmlfklovrden_in,
      rxlpmosovrden_in                      => mgt_ctrl.rxlpmosovrden_in,
      rxslide_in                            => mgt_ctrl.rxslide_in,
      dmonitorclk_in                        => mgt_ctrl.dmonitorclk_in,
      drpaddr_in                            => mgt_ctrl.drpaddr_in,
      drpclk_in                             => mgt_ctrl.drpclk_in,
      drpdi_in                              => mgt_ctrl.drpdi_in,
      drpen_in                              => mgt_ctrl.drpen_in,
      drpwe_in                              => mgt_ctrl.drpwe_in,
      rxpolarity_in                         => mgt_ctrl.rxpolarity_in,
      rxprbscntreset_in                     => mgt_ctrl.rxprbscntreset_in,
      rxprbssel_in                          => mgt_ctrl.rxprbssel_in,
      txpippmen_in                          => mgt_ctrl.txpippmen_in,
      txpippmovrden_in                      => mgt_ctrl.txpippmovrden_in,
      txpippmpd_in                          => mgt_ctrl.txpippmpd_in,
      txpippmsel_in                         => mgt_ctrl.txpippmsel_in,
      txpippmstepsize_in                    => mgt_ctrl.txpippmstepsize_in,
      txpolarity_in                         => mgt_ctrl.txpolarity_in,
      txprbsforceerr_in                     => mgt_ctrl.txprbsforceerr_in,
      txprbssel_in                          => mgt_ctrl.txprbssel_in,
      dmonitorout_out                       => mgt_stat.dmonitorout_out,
      drpdo_out                             => mgt_stat.drpdo_out,
      drprdy_out                            => mgt_stat.drprdy_out,
      rxprbserr_out                         => mgt_stat.rxprbserr_out,
      rxprbslocked_out                      => mgt_stat.rxprbslocked_out,
      txbufstatus_out                       => mgt_stat.txbufstatus_out,
      txpmaresetdone_out                    => mgt_stat.txpmaresetdone_out,
      rxpmaresetdone_out                    => mgt_stat.rxpmaresetdone_out,
      gtpowergood_out                       => mgt_stat.gtpowergood_out,
      gtwiz_userdata_tx_in                  => mgt_ctrl.txdata_in,
      gtwiz_userdata_rx_out                 => mgt_stat.rxdata_out,
      txp_out(0)                            => mgt_tx_p_o,
      txn_out(0)                            => mgt_tx_n_o,
      rxn_in(0)                             => mgt_rx_p_i,
      rxp_in(0)                             => mgt_rx_n_i
      );


  -------------------------------------------------------------------------------
  -- Recovered TCDS out
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  --Output LHC 40Mhz clock for Si chip input
  --d1 & d2 for fancy phase work? 
  oddr1_clk_40_out_pri : oddre1
    generic map (
      is_c_inverted  => zero,--'0',
      is_d1_inverted => zero,--'0',
      is_d2_inverted => zero,--'0',
      srval          => zero--'0'
      )
    port map (
      sr => zero,--'0',
      c  => clk_40_oddr_c,
      d1 => clk_40_oddr_d1,
      d2 => clk_40_oddr_d2,
      q  => clk_40_out
      );
  obufds_clk_rec_out : obufds
    port map (
      I => clk_40_out,
      O => clk_TCDS_REC_out_p,
      OB => clk_TCDS_REC_out_n
      );



  
  -------------------------------------------------------------------------------
  -- AXI slave interface
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  TCDS_2_map_1: entity work.TCDS_2_map
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => slave_readMOSI,
      slave_readMISO  => slave_readMISO,
      slave_writeMOSI => slave_writeMOSI,
      slave_writeMISO => slave_writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);



  --


  Mon.TCDS_2.hw_cfg.has_spy_registers                  <= stat_o.has_spy_registers;
  Mon.TCDS_2.hw_cfg.has_link_test_mode                 <= stat_o.has_link_test_mode;
  Mon.TCDS_2.link_test.status.prbs_chk_error           <= stat_o.prbschk_error;
  Mon.TCDS_2.link_test.status.prbs_chk_locked          <= stat_o.prbschk_locked;
  Mon.TCDS_2.link_test.status.prbs_chk_unlock_counter  <= stat_o.prbschk_unlock_count;
  Mon.TCDS_2.link_test.status.prbs_gen_o_hint          <= stat_o.prbsgen_o_hint;
  Mon.TCDS_2.link_test.status.prbs_chk_i_hint          <= stat_o.prbschk_i_hint;
  Mon.TCDS_2.link_test.status.prbs_chk_o_hint          <= stat_o.prbschk_o_hint;

  
  Mon.TCDS_2.csr.status.is_link_optical                <= stat_o.link_status.is_link_medium_optical;
  Mon.TCDS_2.csr.status.is_link_speed_10g              <= stat_o.link_status.is_link_speed_10g;
  Mon.TCDS_2.csr.status.is_leader                      <= stat_o.link_status.is_leader;
  Mon.TCDS_2.csr.status.is_quad_leader                 <= stat_o.link_status.is_quad_leader;
  Mon.TCDS_2.csr.status.is_mgt_rx_mode_lpm             <= stat_o.link_status.is_mgt_mode_lpm;
  Mon.TCDS_2.csr.status.mmcm_locked                    <= stat_o.link_status.tclink_core_status.mmcm_locked;
  Mon.TCDS_2.csr.status.mgt_power_good                 <= stat_o.link_status.tclink_core_status.mgt_powergood;
  Mon.TCDS_2.csr.status.mgt_tx_pll_locked              <= stat_o.link_status.tclink_core_status.mgt_txpll_lock;
  Mon.TCDS_2.csr.status.mgt_rx_pll_locked              <= stat_o.link_status.tclink_core_status.mgt_rxpll_lock;
  Mon.TCDS_2.csr.status.mgt_reset_tx_done              <= stat_o.link_status.tclink_core_status.mgt_reset_tx_done;
  Mon.TCDS_2.csr.status.mgt_reset_rx_done              <= stat_o.link_status.tclink_core_status.mgt_reset_rx_done;
  Mon.TCDS_2.csr.status.mgt_tx_ready                   <= stat_o.link_status.tclink_core_status.mgt_tx_ready;
  Mon.TCDS_2.csr.status.mgt_rx_ready                   <= stat_o.link_status.tclink_core_status.mgt_rx_ready;
  Mon.TCDS_2.csr.status.cdc40_tx_ready                 <= stat_o.link_status.tclink_core_status.cdc_40_tx_ready;
  Mon.TCDS_2.csr.status.cdc40_rx_ready                 <= stat_o.link_status.tclink_core_status.cdc_40_rx_ready;
  Mon.TCDS_2.csr.status.rx_data_not_idle               <= stat_o.link_status.tclink_core_status.rx_data_not_idle;
  Mon.TCDS_2.csr.status.rx_frame_locked                <= stat_o.link_status.tclink_core_status.rx_frame_locked;
  Mon.TCDS_2.csr.status.tx_user_data_ready             <= stat_o.link_status.tclink_core_status.tx_user_data_ready;
  Mon.TCDS_2.csr.status.rx_user_data_ready             <= stat_o.link_status.tclink_core_status.rx_user_data_ready;
  Mon.TCDS_2.csr.status.tclink_ready                   <= stat_o.link_status.tclink_core_status.channel_ready;
  Mon.TCDS_2.csr.status.initializer_fsm_state(16 downto 0 ) <= stat_o.link_status.tclink_core_status.channel_controller_state;
  Mon.TCDS_2.csr.status.initializer_fsm_state(30 downto 17) <= (others  => '0');
  Mon.TCDS_2.csr.status.initializer_fsm_running        <= stat_o.link_status.tclink_core_status.channel_controller_running;
  Mon.TCDS_2.csr.status.rx_frame_unlock_counter        <= stat_o.link_status.channel_unlock_count;
  Mon.TCDS_2.csr.status.phase_cdc40_tx_measured        <= stat_o.link_status.tclink_core_status.phase_cdc40_tx;
  Mon.TCDS_2.csr.status.phase_cdc40_rx_measured        <= stat_o.link_status.tclink_core_status.phase_cdc40_rx;
  Mon.TCDS_2.csr.status.phase_pi_tx_measured           <= stat_o.link_status.tclink_core_status.mgt_hptd_tx_pi_phase;
  Mon.TCDS_2.csr.status.fec_correction_applied         <= stat_o.link_status.tclink_core_status.rx_fec_corrected_latched;
  Mon.TCDS_2.csr.status.tclink_loop_closed             <= stat_o.link_status.tclink_status.tclink_loop_closed;
  Mon.TCDS_2.csr.status.tclink_operation_error         <= stat_o.link_status.tclink_status.tclink_operation_error;
  Mon.TCDS_2.csr.status.tclink_phase_measured          <= stat_o.link_status.tclink_status.tclink_phase_detector;
  Mon.TCDS_2.csr.status.tclink_phase_error.lo          <= stat_o.link_status.tclink_status.tclink_error_controller(31 downto  0);
  Mon.TCDS_2.csr.status.tclink_phase_error.hi          <= stat_o.link_status.tclink_status.tclink_error_controller(47 downto 32);
  Mon.TCDS_2.spy_frame_tx.word0                        <= stat_o.frame_tx( 31 downto    0);
  Mon.TCDS_2.spy_frame_tx.word1                        <= stat_o.frame_tx( 63 downto   32);
  Mon.TCDS_2.spy_frame_tx.word2                        <= stat_o.frame_tx( 95 downto   64);
  Mon.TCDS_2.spy_frame_tx.word3                        <= stat_o.frame_tx(127 downto   96);
  Mon.TCDS_2.spy_frame_tx.word4                        <= stat_o.frame_tx(159 downto  128);
  Mon.TCDS_2.spy_frame_tx.word5                        <= stat_o.frame_tx(191 downto  160);
  Mon.TCDS_2.spy_frame_tx.word6                        <= stat_o.frame_tx(223 downto  192);
  Mon.TCDS_2.spy_frame_tx.word7                        <= stat_o.frame_tx(233 downto  224);
  Mon.TCDS_2.spy_frame_rx.word0                        <= stat_o.frame_rx( 31 downto    0);
  Mon.TCDS_2.spy_frame_rx.word1                        <= stat_o.frame_rx( 63 downto   32);
  Mon.TCDS_2.spy_frame_rx.word2                        <= stat_o.frame_rx( 95 downto   64);
  Mon.TCDS_2.spy_frame_rx.word3                        <= stat_o.frame_rx(127 downto   96);
  Mon.TCDS_2.spy_frame_rx.word4                        <= stat_o.frame_rx(159 downto  128);
  Mon.TCDS_2.spy_frame_rx.word5                        <= stat_o.frame_rx(191 downto  160);
  Mon.TCDS_2.spy_frame_rx.word6                        <= stat_o.frame_rx(223 downto  192);
  Mon.TCDS_2.spy_frame_rx.word7                        <= stat_o.frame_rx(233 downto  224);
  

  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.physics        <= stat_o.channel0_ttc2.l1a_types.l1a_physics ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.calibration    <= stat_o.channel0_ttc2.l1a_types.l1a_calibration ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.random         <= stat_o.channel0_ttc2.l1a_types.l1a_random ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.software       <= stat_o.channel0_ttc2.l1a_types.l1a_software ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_4     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_4 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_5     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_5 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_6     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_6 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_7     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_7 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_8     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_8 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_9     <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_9 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_10    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_10 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_11    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_11 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_12    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_12 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_13    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_13 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_14    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_14 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.reserved_15    <= stat_o.channel0_ttc2.l1a_types.l1a_reserved_15 ;
  Mon.TCDS_2.spy_ttc2_channel0.l1a_info.physics_subtype<= stat_o.channel0_ttc2.physics_l1a_subtypes;        
  Mon.TCDS_2.spy_ttc2_channel0.bril_trigger_info       <= stat_o.channel0_ttc2.bril_trigger_data;   
  Mon.TCDS_2.spy_ttc2_channel0.timing_and_sync_info.lo <= stat_o.channel0_ttc2.sync_flags_and_commands(31 downto  0);
  Mon.TCDS_2.spy_ttc2_channel0.timing_and_sync_info.hi <= stat_o.channel0_ttc2.sync_flags_and_commands(48 downto 32);
  Mon.TCDS_2.spy_ttc2_channel0.status_info             <= stat_o.channel0_ttc2.status;
  Mon.TCDS_2.spy_ttc2_channel0.reserved                <= stat_o.channel0_ttc2.reserved;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.physics        <= stat_o.channel1_ttc2.l1a_types.l1a_physics ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.calibration    <= stat_o.channel1_ttc2.l1a_types.l1a_calibration ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.random         <= stat_o.channel1_ttc2.l1a_types.l1a_random ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.software       <= stat_o.channel1_ttc2.l1a_types.l1a_software ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_4     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_4 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_5     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_5 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_6     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_6 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_7     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_7 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_8     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_8 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_9     <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_9 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_10    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_10 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_11    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_11 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_12    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_12 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_13    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_13 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_14    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_14 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.reserved_15    <= stat_o.channel1_ttc2.l1a_types.l1a_reserved_15 ;
  Mon.TCDS_2.spy_ttc2_channel1.l1a_info.physics_subtype<= stat_o.channel1_ttc2.physics_l1a_subtypes;        
  Mon.TCDS_2.spy_ttc2_channel1.bril_trigger_info       <= stat_o.channel1_ttc2.bril_trigger_data;   
  Mon.TCDS_2.spy_ttc2_channel1.timing_and_sync_info.lo <= stat_o.channel1_ttc2.sync_flags_and_commands(31 downto  0);
  Mon.TCDS_2.spy_ttc2_channel1.timing_and_sync_info.hi <= stat_o.channel1_ttc2.sync_flags_and_commands(48 downto 32);
  Mon.TCDS_2.spy_ttc2_channel1.status_info             <= stat_o.channel1_ttc2.status;
  Mon.TCDS_2.spy_ttc2_channel1.reserved                <= stat_o.channel1_ttc2.reserved;
  
  Mon.TCDS_2.spy_tts2_channel0.value_0                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(0) ,8));  
  Mon.TCDS_2.spy_tts2_channel0.value_1                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(1) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_2                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(2) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_3                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(3) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_4                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(4) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_5                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(5) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_6                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(6) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_7                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(7) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_8                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(8) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_9                 <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(9) ,8));
  Mon.TCDS_2.spy_tts2_channel0.value_10                <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(10),8));
  Mon.TCDS_2.spy_tts2_channel0.value_11                <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(11),8));
  Mon.TCDS_2.spy_tts2_channel0.value_12                <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(12),8));
  Mon.TCDS_2.spy_tts2_channel0.value_13                <= std_logic_vector(to_unsigned(stat_o.channel0_tts2(13),8));

  Mon.TCDS_2.spy_tts2_channel1.value_0                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(0) ,8));  
  Mon.TCDS_2.spy_tts2_channel1.value_1                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(1) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_2                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(2) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_3                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(3) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_4                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(4) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_5                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(5) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_6                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(6) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_7                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(7) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_8                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(8) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_9                 <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(9) ,8));
  Mon.TCDS_2.spy_tts2_channel1.value_10                <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(10),8));
  Mon.TCDS_2.spy_tts2_channel1.value_11                <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(11),8));
  Mon.TCDS_2.spy_tts2_channel1.value_12                <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(12),8));
  Mon.TCDS_2.spy_tts2_channel1.value_13                <= std_logic_vector(to_unsigned(stat_o.channel1_tts2(13),8));


  ctrl_i.link_test_mode  <=  Ctrl.TCDS_2.link_test.control.link_test_mode;
  ctrl_i.prbsgen_reset   <=  Ctrl.TCDS_2.link_test.control.prbs_gen_reset;
  ctrl_i.prbschk_reset   <=  Ctrl.TCDS_2.link_test.control.prbs_chk_reset;


  ctrl_i.link_control.tclink_core_control.reset_all                             <= Ctrl.TCDS_2.csr.control.reset_all;
  ctrl_i.link_control.tclink_core_control.mgt_reset_all                         <= Ctrl.TCDS_2.csr.control.mgt_reset_all ;
  ctrl_i.link_control.tclink_core_control.mgt_reset_tx_pll_and_datapath         <= Ctrl.TCDS_2.csr.control.mgt_reset_tx_pll_and_datapath ;
  ctrl_i.link_control.tclink_core_control.mgt_reset_tx_datapath                 <= Ctrl.TCDS_2.csr.control.mgt_reset_tx_datapath ;
  ctrl_i.link_control.tclink_core_control.mgt_reset_rx_pll_and_datapath         <= Ctrl.TCDS_2.csr.control.mgt_reset_rx_pll_and_datapath ;
  ctrl_i.link_control.tclink_core_control.mgt_reset_rx_datapath                 <= Ctrl.TCDS_2.csr.control.mgt_reset_rx_datapath ;
  ctrl_i.link_control.tclink_core_control.channel_controller_reset              <= Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_reset ;
  ctrl_i.link_control.tclink_core_control.channel_controller_enable             <= Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_enable ;
  ctrl_i.link_control.tclink_core_control.channel_controller_gentle             <= Ctrl.TCDS_2.csr.control.tclink_channel_ctrl_gentle ;
  ctrl_i.link_control.tclink_control.tclink_close_loop                          <= Ctrl.TCDS_2.csr.control.tclink_close_loop ;
  ctrl_i.link_control.tclink_control.tclink_offset_error(31 downto  0)          <= Ctrl.TCDS_2.csr.control.tclink_phase_offset.lo ;
  ctrl_i.link_control.tclink_control.tclink_offset_error(47 downto 32)          <= Ctrl.TCDS_2.csr.control.tclink_phase_offset.hi ;
  ctrl_i.link_control.tclink_core_control.phase_cdc40_tx_calib                 <= Ctrl.TCDS_2.csr.control.phase_cdc40_tx_calib ;
  ctrl_i.link_control.tclink_core_control.phase_cdc40_tx_force                 <= Ctrl.TCDS_2.csr.control.phase_cdc40_tx_force ;
  ctrl_i.link_control.tclink_core_control.phase_cdc40_rx_calib                 <= Ctrl.TCDS_2.csr.control.phase_cdc40_rx_calib ;
  ctrl_i.link_control.tclink_core_control.phase_cdc40_rx_force                 <= Ctrl.TCDS_2.csr.control.phase_cdc40_rx_force ;
  ctrl_i.link_control.tclink_core_control.mgt_hptd_tx_pi_phase_calib            <= Ctrl.TCDS_2.csr.control.phase_pi_tx_calib ;
  ctrl_i.link_control.tclink_core_control.mgt_hptd_tx_ui_align_calib            <= Ctrl.TCDS_2.csr.control.phase_pi_tx_force ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxlpmen                           <= Ctrl.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm ;
  ctrl_i.link_control.tclink_core_control.mgt_rxprbscntreset                    <= Ctrl.TCDS_2.csr.control.mgt_rx_dfe_vs_lpm_reset ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxlpmgcovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmgcovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxlpmhfovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmhfovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxlpmlfklovrden              <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmlfklovrden;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxlpmosovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.lpm.rxlpmosovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxosovrden                   <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxosovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxdfeagcovrden               <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeagcovrden;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxdfelfovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfelfovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxdfeutovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfeutovrden ;
  ctrl_i.link_control.tclink_core_control.mgt_rxeq_rxdfevpovrden                <= Ctrl.TCDS_2.csr.control.mgt_rxeq_params.dfe.rxdfevpovrden ;
  ctrl_i.link_control.tclink_core_control.rx_fec_corrected_clear                <= Ctrl.TCDS_2.csr.control.fec_monitor_reset ;
  ctrl_i.link_control.tclink_control.tclink_metastability_deglitch              <= Ctrl.TCDS_2.csr.control.tclink_param_metastability_deglitch ;
  ctrl_i.link_control.tclink_control.tclink_phase_detector_navg                 <= Ctrl.TCDS_2.csr.control.tclink_param_phase_detector_navg ;
  ctrl_i.link_control.tclink_control.tclink_modulo_carrier_period(31 downto  0) <= Ctrl.TCDS_2.csr.control.tclink_param_modulo_carrier_period.lo ;
  ctrl_i.link_control.tclink_control.tclink_modulo_carrier_period(47 downto 32) <= Ctrl.TCDS_2.csr.control.tclink_param_modulo_carrier_period.hi ;
  ctrl_i.link_control.tclink_control.tclink_master_rx_ui_period(31 downto  0)   <= Ctrl.TCDS_2.csr.control.tclink_param_master_rx_ui_period.lo ;
  ctrl_i.link_control.tclink_control.tclink_master_rx_ui_period(47 downto 32)   <= Ctrl.TCDS_2.csr.control.tclink_param_master_rx_ui_period.hi ;
  ctrl_i.link_control.tclink_control.tclink_aie                                 <= Ctrl.TCDS_2.csr.control.tclink_param_aie ;
  ctrl_i.link_control.tclink_control.tclink_aie_enable                          <= Ctrl.TCDS_2.csr.control.tclink_param_aie_enable ;
  ctrl_i.link_control.tclink_control.tclink_ape                                 <= Ctrl.TCDS_2.csr.control.tclink_param_ape ;
  ctrl_i.link_control.tclink_control.tclink_sigma_delta_clk_div                 <= Ctrl.TCDS_2.csr.control.tclink_param_sigma_delta_clk_div ;
  ctrl_i.link_control.tclink_control.tclink_enable_mirror                       <= Ctrl.TCDS_2.csr.control.tclink_param_enable_mirror ;
  ctrl_i.link_control.tclink_control.tclink_adco(31 downto  0)                  <= Ctrl.TCDS_2.csr.control.tclink_param_adco.lo ;
  ctrl_i.link_control.tclink_control.tclink_adco(47 downto 32)                  <= Ctrl.TCDS_2.csr.control.tclink_param_adco.hi ;










  ttc_data( 0) <= channel0_ttc2_o.l1a_types.l1a_physics;
  ttc_data( 1) <= channel0_ttc2_o.l1a_types.l1a_calibration;
  ttc_data( 2) <= channel0_ttc2_o.l1a_types.l1a_random;     
  ttc_data( 3) <= channel0_ttc2_o.l1a_types.l1a_software;   
  ttc_data( 4) <= channel0_ttc2_o.l1a_types.l1a_reserved_4; 
  ttc_data( 5) <= channel0_ttc2_o.l1a_types.l1a_reserved_5; 
  ttc_data( 6) <= channel0_ttc2_o.l1a_types.l1a_reserved_6; 
  ttc_data( 7) <= channel0_ttc2_o.l1a_types.l1a_reserved_7; 
  ttc_data( 8) <= channel0_ttc2_o.l1a_types.l1a_reserved_8; 
  ttc_data( 9) <= channel0_ttc2_o.l1a_types.l1a_reserved_9; 
  ttc_data(10) <= channel0_ttc2_o.l1a_types.l1a_reserved_10;
  ttc_data(11) <= channel0_ttc2_o.l1a_types.l1a_reserved_11;
  ttc_data(12) <= channel0_ttc2_o.l1a_types.l1a_reserved_12;
  ttc_data(13) <= channel0_ttc2_o.l1a_types.l1a_reserved_13;
  ttc_data(14) <= channel0_ttc2_o.l1a_types.l1a_reserved_14;
  ttc_data(15) <= channel0_ttc2_o.l1a_types.l1a_reserved_15;
  ttc_data(26 downto 16) <= channel0_ttc2_o.sync_flags_and_commands(10 downto 0);
  ttc_data(31 downto 27) <= channel0_ttc2_o.status;


  channel0_tts2_i(0) <=
      to_integer(unsigned(tts_data(0)(6 downto 0) or
                          tts_data(1)(6 downto 0)));

  
  local_TCDS: for iCM in 1 to 2 generate

    local_TCDS_MGBT_1: entity work.LOCAL_TCDS2
    port map (
      gtwiz_userclk_tx_reset_in(0)          => Ctrl.LTCDS(iCM).RESET.USERCLK_TX,
      gtwiz_userclk_tx_srcclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk2_out(0)       => open,
      gtwiz_userclk_tx_active_out(0)        => Mon.LTCDS(iCM).STATUS.userclk_tx_active,
      gtwiz_userclk_rx_reset_in(0)          => Ctrl.LTCDS(iCM).RESET.USERCLK_RX,
      gtwiz_userclk_rx_srcclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk2_out(0)       => open,
      gtwiz_userclk_rx_active_out(0)        => Mon.LTCDS(iCM).STATUS.userclk_rx_active,
      gtwiz_reset_clk_freerun_in(0)         => '0',
      gtwiz_reset_all_in(0)                 => Ctrl.LTCDS(iCM).RESET.RESET_ALL,
      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl.LTCDS(iCM).RESET.TX_PLL_AND_DATAPATH,
      gtwiz_reset_tx_datapath_in(0)         => Ctrl.LTCDS(iCM).RESET.TX_DATAPATH,
      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl.LTCDS(iCM).RESET.RX_PLL_AND_DATAPATH,
      gtwiz_reset_rx_datapath_in(0)         => Ctrl.LTCDS(iCM).RESET.RX_DATAPATH,
      gtwiz_reset_qpll0lock_in(0)           => mgt_stat.txplllock_out(0),
      gtwiz_reset_rx_cdr_stable_out(0)      => Mon.LTCDS(iCM).STATUS.reset_rx_cdr_stable,
      gtwiz_reset_tx_done_out(0)            => Mon.LTCDS(iCM).STATUS.reset_tx_done,
      gtwiz_reset_rx_done_out(0)            => Mon.LTCDS(iCM).STATUS.reset_rx_done,
      gtwiz_reset_qpll0reset_out(0)         => open,
      gtwiz_userdata_tx_in                  => ttc_data,
      gtwiz_userdata_rx_out                 => tts_data(iCM-1),
      qpll0clk_in(0)                        => local_TCDS_clk1,   
      qpll0refclk_in(0)                     => local_TCDS_refclk1,
      qpll1clk_in(0)                        => local_TCDS_clk2,   
      qpll1refclk_in(0)                     => local_TCDS_refclk2,
      gthrxn_in(0)                          => LTTS_N(iCM-1),
      gthrxp_in(0)                          => LTTS_P(iCM-1),
      rx8b10ben_in(0)                       => '1',
      rxcommadeten_in(0)                    => '1',
      rxmcommaalignen_in(0)                 => '1',
      rxpcommaalignen_in(0)                 => '1',
      tx8b10ben_in(0)                       => '1',
      txctrl0_in                            => Ctrl.LTCDS(iCM).tx.ctrl0,
      txctrl1_in                            => Ctrl.LTCDS(iCM).tx.ctrl1,
      txctrl2_in                            => Ctrl.LTCDS(iCM).tx.ctrl2,
      gthtxn_out(0)                         => LTTC_N(iCM-1),
      gthtxp_out(0)                         => LTTC_P(iCM-1),
      gtpowergood_out(0)                    => Mon.LTCDS(iCM).STATUS.gt_power_good,
      rxbyteisaligned_out(0)                => Mon.LTCDS(iCM).STATUS.rx_byte_isaligned,
      rxbyterealign_out(0)                  => Mon.LTCDS(iCM).STATUS.rx_byte_realign,
      rxcommadet_out(0)                     => Mon.LTCDS(iCM).STATUS.rx_commadet,
      rxctrl0_out                           => Mon.LTCDS(iCM).RX.ctrl0,
      rxctrl1_out                           => Mon.LTCDS(iCM).RX.ctrl1,
      rxctrl2_out                           => Mon.LTCDS(iCM).RX.ctrl2,
      rxctrl3_out                           => Mon.LTCDS(iCM).RX.ctrl3,
      rxpmaresetdone_out(0)                 => Mon.LTCDS(iCM).STATUS.rx_pma_reset_done,
      txpmaresetdone_out(0)                 => Mon.LTCDS(iCM).STATUS.tx_pma_reset_done);
  end generate local_TCDS;





  
  
  
end behavioral;

