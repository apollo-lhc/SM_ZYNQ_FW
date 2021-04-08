library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

use work.tclink_lpgbt10G_pkg.all;

use work.tcds2_interface_pkg.all;
use work.tcds2_link_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;


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

    -- MGT reference clock input.
    -- NOTE: This should come from an ibufds_gte3/4 compatible with
    -- the connected transceiver.
    clk_320_mgt_ref_i : in std_logic;

    -- LHC bunch clock output.
    -- NOTE: This clock originates from a BUFGCE_DIV and is intended
    -- for use in the FPGA clocking fabric.
    clk_40_o : out std_logic;

    -- LHC bunch clock ODDR outputs.
    -- NOTE: These lines are intended to drive an ODDR1, in order to
    -- extract the bunch clock from the FPGA.
    clk_40_oddr_c_o  : out std_logic;
    clk_40_oddr_d1_o : out std_logic;
    clk_40_oddr_d2_o : out std_logic;
    
    );

  architecture behavioral of TCDS is

    signal Mon              :  TCDS2_Mon_t;
    signal Ctrl             :  TCDS2_Ctrl_t;

    -- Control and status interfaces.
    ctrl_i : in tcds2_interface_ctrl_t;
    stat_o : out tcds2_interface_stat_t;
      
    -- Transceiver control and status signals.
    signal mgt_ctrl : tr_core_to_mgt;
    signal mgt_stat : tr_mgt_to_core;
    
    -- User clock network control and status signals.
    signal mgt_clk_ctrl : tr_clk_to_mgt;
    signal mgt_clk_stat : tr_mgt_to_clk;

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

      clk_40_o => clk_40_o,

      clk_40_oddr_c_o  => clk_40_oddr_c_o,
      clk_40_oddr_d1_o => clk_40_oddr_d1_o,
      clk_40_oddr_d2_o => clk_40_oddr_d2_o,

      orbit_o => orbit_o,

      channel0_ttc2_o => channel0_ttc2_o,
      channel0_tts2_i => channel0_tts2_i,

      channel1_ttc2_o => channel1_ttc2_o,
      channel1_tts2_i => channel1_tts2_i
    );

  ------------------------------------------
  -- The transceiver.
  ------------------------------------------
  mgt : entity work.tcds2_interface_mgt
    generic map (
      G_MGT_TYPE   => MGT_TYPE_GTHE3,
      G_LINK_SPEED => TCDS2_LINK_SPEED_10G
    )
    port map (
      -- Quad.
      gtwiz_reset_clk_freerun_in(0)         => clk_sys_125mhz,
      gtwiz_reset_all_in(0)                 => mgt_ctrl.mgt_reset_all(0),
      gtwiz_reset_tx_pll_and_datapath_in(0) => mgt_ctrl.mgt_reset_tx_pll_and_datapath(0),
      gtwiz_reset_rx_pll_and_datapath_in(0) => mgt_ctrl.mgt_reset_rx_pll_and_datapath(0),
      gtwiz_reset_tx_datapath_in(0)         => std_logic'('0'),
      gtwiz_reset_rx_datapath_in(0)         => std_logic'('0'),
      gtrefclk00_in(0)                      => clk_320_mgt_ref_i,
      gtrefclk01_in(0)                      => clk_320_mgt_ref_i,
      qpll0outclk_out                       => open,
      qpll0outrefclk_out                    => open,
      qpll1outclk_out                       => open,
      qpll1outrefclk_out                    => open,

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


    Mon.TCDS2.csr.status.has_spy_registers         <= stat_o.has_spy_registers;
    Mon.TCDS2.csr.status.is_link_speed_10g         <= stat_o.is_link_speed_10g;
    Mon.TCDS2.csr.status.has_link_test_mode        <= stat_o.has_link_test_mode;
    Mon.TCDS2.csr.status.mgt_power_good            <= stat_o.mgt_powergood;
    Mon.TCDS2.csr.status.mgt_tx_pll_lock           <= stat_o.mgt_txpll_lock;
    Mon.TCDS2.csr.status.mgt_rx_pll_lock           <= stat_o.mgt_rxpll_lock;
    Mon.TCDS2.csr.status.mgt_reset_tx_done         <= stat_o.mgt_reset_tx_done;
    Mon.TCDS2.csr.status.mgt_reset_rx_done         <= stat_o.mgt_reset_rx_done;
    Mon.TCDS2.csr.status.mgt_tx_ready              <= stat_o.mgt_tx_ready;
    Mon.TCDS2.csr.status.mgt_rx_ready              <= stat_o.mgt_rx_ready;
    Mon.TCDS2.csr.status.rx_frame_locked           <= stat_o.rx_frame_locked;
    Mon.TCDS2.csr.status.rx_frame_unlock_counter   <= stat_o.rx_frame_unlock_count;
    Mon.TCDS2.csr.status.prbs_chk_error            <= stat_o.prbschk_error;
    Mon.TCDS2.csr.status.prbs_chk_locked           <= stat_o.prbschk_locked;
    Mon.TCDS2.csr.status.prbs_chk_unlock_counter   <= stat_o.prbschk_unlock_count;
    Mon.TCDS2.csr.status.prbs_gen_o_hint           <= stat_o.prbsgen_o_hint;
    Mon.TCDS2.csr.status.prbs_chk_i_hint           <= stat_o.prbschk_i_hint;
    Mon.TCDS2.csr.status.prbs_chk_o_hint           <= stat_o.prbschk_o_hint;
        
    Mon.TCDS2.spy_frame_tx     
    Mon.TCDS2.spy_frame_rx     
    Mon.TCDS2.spy_ttc2_channel0
    Mon.TCDS2.spy_ttc2_channel1
    Mon.TCDS2.spy_tts2_channel0
    Mon.TCDS2.spy_tts2_channel1
        
    TCDS2_interface_1: entity work.TCDS2_interface
      port map (
        clk_axi         => clk_axi,
        reset_axi_n     => reset_axi_n,
        slave_readMOSI  => slave_readMOSI,
        slave_readMISO  => slave_readMISO,
        slave_writeMOSI => slave_writeMOSI,
        slave_writeMISO => slave_writeMISO,
        Mon             => Mon,
        Ctrl            => Ctrl);

    
  end behavioral;
  
