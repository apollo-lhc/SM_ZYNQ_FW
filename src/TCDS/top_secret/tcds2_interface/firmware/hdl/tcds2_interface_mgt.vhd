--======================================================================
-- Simple wrapper to keep all the 'if ... generate' statements a bit
-- out of the way.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tcds2_interface_pkg.all;
use work.tcds2_link_speed_pkg.all;

--==================================================

entity tcds2_interface_mgt is
  generic (
    -- Choice of transceiver (US or USP, and GTH or GTY).
    G_MGT_TYPE : mgt_type_t;

    -- Choice of link line rate:
    -- - TCDS2_LINK_SPEED_10G for 10 Gb/s (i.e., the production
    --   version).
    -- - TCDS2_LINK_SPEED_5G for 5 Gb/s (i.e., the 'compatibility'
    --   version for back-end prototyping with intermediate FPGAs).
    G_LINK_SPEED : tcds2_link_speed_t := TCDS2_LINK_SPEED_10G
  );
  port (
    -- Quad.
    gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
    gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
    gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
    gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
    gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
    gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
    gtrefclk00_in                      : in  std_logic_vector(0 downto 0);
    gtrefclk01_in                      : in  std_logic_vector(0 downto 0);
    qpll0outclk_out                    : out std_logic_vector(0 downto 0);
    qpll0outrefclk_out                 : out std_logic_vector(0 downto 0);
    qpll1outclk_out                    : out std_logic_vector(0 downto 0);
    qpll1outrefclk_out                 : out std_logic_vector(0 downto 0);

    -- User clocking.
    txusrclk_in                        : in  std_logic_vector(0 downto 0);
    txusrclk2_in                       : in  std_logic_vector(0 downto 0);
    rxusrclk_in                        : in  std_logic_vector(0 downto 0);
    rxusrclk2_in                       : in  std_logic_vector(0 downto 0);
    txoutclk_out                       : out std_logic_vector(0 downto 0);
    rxoutclk_out                       : out std_logic_vector(0 downto 0);

    -- Channel.
    gtwiz_userclk_tx_active_in         : in  std_logic_vector(0 downto 0);
    gtwiz_userclk_rx_active_in         : in  std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_reset_in       : in  std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_start_user_in  : in  std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
    gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
    gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
    gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
    qpll0lock_out                      : out std_logic_vector(0 downto 0);
    qpll1lock_out                      : out std_logic_vector(0 downto 0);
    loopback_in                        : in  std_logic_vector(2 downto 0);
    rxdfeagcovrden_in                  : in  std_logic_vector(0 downto 0);
    rxdfelfovrden_in                   : in  std_logic_vector(0 downto 0);
    rxdfelpmreset_in                   : in  std_logic_vector(0 downto 0);
    rxdfeutovrden_in                   : in  std_logic_vector(0 downto 0);
    rxdfevpovrden_in                   : in  std_logic_vector(0 downto 0);
    rxlpmen_in                         : in  std_logic_vector(0 downto 0);
    rxosovrden_in                      : in  std_logic_vector(0 downto 0);
    rxlpmgcovrden_in                   : in  std_logic_vector(0 downto 0);
    rxlpmhfovrden_in                   : in  std_logic_vector(0 downto 0);
    rxlpmlfklovrden_in                 : in  std_logic_vector(0 downto 0);
    rxlpmosovrden_in                   : in  std_logic_vector(0 downto 0);
    rxslide_in                         : in  std_logic_vector(0 downto 0);
    dmonitorclk_in                     : in  std_logic_vector(0 downto 0);
    drpaddr_in                         : in  std_logic_vector(9 downto 0);
    drpclk_in                          : in  std_logic_vector(0 downto 0);
    drpdi_in                           : in  std_logic_vector(15 downto 0);
    drpen_in                           : in  std_logic_vector(0 downto 0);
    drpwe_in                           : in  std_logic_vector(0 downto 0);
    rxpolarity_in                      : in  std_logic_vector(0 downto 0);
    rxprbscntreset_in                  : in  std_logic_vector(0 downto 0);
    rxprbssel_in                       : in  std_logic_vector(3 downto 0);
    txpippmen_in                       : in  std_logic_vector(0 downto 0);
    txpippmovrden_in                   : in  std_logic_vector(0 downto 0);
    txpippmpd_in                       : in  std_logic_vector(0 downto 0);
    txpippmsel_in                      : in  std_logic_vector(0 downto 0);
    txpippmstepsize_in                 : in  std_logic_vector(4 downto 0);
    txpolarity_in                      : in  std_logic_vector(0 downto 0);
    txprbsforceerr_in                  : in  std_logic_vector(0 downto 0);
    txprbssel_in                       : in  std_logic_vector(3 downto 0);
    dmonitorout_out                    : out std_logic_vector(15 downto 0);
    drpdo_out                          : out std_logic_vector(15 downto 0);
    drprdy_out                         : out std_logic_vector(0 downto 0);
    rxprbserr_out                      : out std_logic_vector(0 downto 0);
    rxprbslocked_out                   : out std_logic_vector(0 downto 0);
    txbufstatus_out                    : out std_logic_vector(1 downto 0);
    rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
    txpmaresetdone_out                 : out std_logic_vector(0 downto 0);
    gtpowergood_out                    : out std_logic_vector(0 downto 0);
    gtwiz_userdata_tx_in               : in  std_logic_vector(31 downto 0);
    gtwiz_userdata_rx_out              : out std_logic_vector(31 downto 0);
    txp_out                            : out std_logic_vector(0 downto 0);
    txn_out                            : out std_logic_vector(0 downto 0);
    rxp_in                             : in  std_logic_vector(0 downto 0);
    rxn_in                             : in  std_logic_vector(0 downto 0)
  );
end tcds2_interface_mgt;

--==================================================

architecture arch of tcds2_interface_mgt is
begin
  -- UltraScale GTH.
  if_us_gth : if G_MGT_TYPE = MGT_TYPE_GTHE3 generate
    if_5g : if G_LINK_SPEED = TCDS2_LINK_SPEED_5G generate
      mgt : entity work.gthe3_slave_timing_5g
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in(15 downto 0),
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out(15 downto 0),
          gthtxp_out                        => txp_out,
          gthtxn_out                        => txn_out,
          gthrxp_in                         => rxp_in,
          gthrxn_in                         => rxn_in
        );
    end generate;

    if_10g : if G_LINK_SPEED = TCDS2_LINK_SPEED_10G generate
      mgt : entity work.gthe3_slave_timing
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in,
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out,
          gthtxp_out                        => txp_out,
          gthtxn_out                        => txn_out,
          gthrxp_in                         => rxp_in,
          gthrxn_in                         => rxn_in
        );
    end generate;
  end generate;

  ----------

  -- UltraScale GTY.
  if_us_gty : if G_MGT_TYPE = MGT_TYPE_GTYE3 generate
    if_5g : if G_LINK_SPEED = TCDS2_LINK_SPEED_5G generate
      mgt : entity work.gtye3_slave_timing_5g
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in(15 downto 0),
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out(15 downto 0),
          gtytxp_out                        => txp_out,
          gtytxn_out                        => txn_out,
          gtyrxp_in                         => rxp_in,
          gtyrxn_in                         => rxn_in
        );
    end generate;

    if_10g : if G_LINK_SPEED = TCDS2_LINK_SPEED_10G generate
      mgt : entity work.gtye3_slave_timing
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in,
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out,
          gtytxp_out                        => txp_out,
          gtytxn_out                        => txn_out,
          gtyrxp_in                         => rxp_in,
          gtyrxn_in                         => rxn_in
        );
    end generate;
  end generate;

  ----------

  -- UltraScale+ GTH.
  if_usp_gth : if G_MGT_TYPE = MGT_TYPE_GTHE4 generate
    if_5g : if G_LINK_SPEED = TCDS2_LINK_SPEED_5G generate
      mgt : entity work.gthe4_slave_timing_5g
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in(15 downto 0),
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out(15 downto 0),
          gthtxp_out                        => txp_out,
          gthtxn_out                        => txn_out,
          gthrxp_in                         => rxp_in,
          gthrxn_in                         => rxn_in
        );
    end generate;

    if_10g : if G_LINK_SPEED = TCDS2_LINK_SPEED_10G generate
      mgt : entity work.gthe4_slave_timing
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in,
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out,
          gthtxp_out                        => txp_out,
          gthtxn_out                        => txn_out,
          gthrxp_in                         => rxp_in,
          gthrxn_in                         => rxn_in
        );
    end generate;
  end generate;

  ----------

  -- UltraScale+ GTY.
  if_usp_gty : if G_MGT_TYPE = MGT_TYPE_GTYE4 generate
    if_5g : if G_LINK_SPEED = TCDS2_LINK_SPEED_5G generate
      mgt : entity work.gtye4_slave_timing_5g
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in(15 downto 0),
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out(15 downto 0),
          gtytxp_out                        => txp_out,
          gtytxn_out                        => txn_out,
          gtyrxp_in                         => rxp_in,
          gtyrxn_in                         => rxn_in
        );
    end generate;

    if_10g : if G_LINK_SPEED = TCDS2_LINK_SPEED_10G generate
      mgt : entity work.gtye4_slave_timing
        port map (
          -- Quad.
          gtwiz_reset_clk_freerun_in         => gtwiz_reset_clk_freerun_in,
          gtwiz_reset_all_in                 => gtwiz_reset_all_in,
          gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
          gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
          gtwiz_reset_tx_datapath_in         => gtwiz_reset_tx_datapath_in,
          gtwiz_reset_rx_datapath_in         => gtwiz_reset_rx_datapath_in,
          gtrefclk00_in                      => gtrefclk00_in,
          gtrefclk01_in                      => gtrefclk01_in,
          qpll0outclk_out                    => qpll0outclk_out,
          qpll0outrefclk_out                 => qpll0outrefclk_out,
          qpll1outclk_out                    => qpll1outclk_out,
          qpll1outrefclk_out                 => qpll1outrefclk_out,

          -- User clocking.
          txusrclk_in  => txusrclk_in,
          txusrclk2_in => txusrclk2_in,
          rxusrclk_in  => rxusrclk_in,
          rxusrclk2_in => rxusrclk2_in,
          txoutclk_out => txoutclk_out,
          rxoutclk_out => rxoutclk_out,

          -- Channel.
          gtwiz_userclk_tx_active_in        => gtwiz_userclk_tx_active_in,
          gtwiz_userclk_rx_active_in        => gtwiz_userclk_rx_active_in,
          gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
          gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
          gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
          gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
          gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
          gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
          gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
          qpll0lock_out                     => qpll0lock_out,
          qpll1lock_out                     => qpll1lock_out,
          loopback_in                       => loopback_in,
          rxdfeagcovrden_in                 => rxdfeagcovrden_in,
          rxdfelfovrden_in                  => rxdfelfovrden_in,
          rxdfelpmreset_in                  => rxdfelpmreset_in,
          rxdfeutovrden_in                  => rxdfeutovrden_in,
          rxdfevpovrden_in                  => rxdfevpovrden_in,
          rxlpmen_in                        => rxlpmen_in,
          rxosovrden_in                     => rxosovrden_in,
          rxlpmgcovrden_in                  => rxlpmgcovrden_in,
          rxlpmhfovrden_in                  => rxlpmhfovrden_in,
          rxlpmlfklovrden_in                => rxlpmlfklovrden_in,
          rxlpmosovrden_in                  => rxlpmosovrden_in,
          rxslide_in                        => rxslide_in,
          dmonitorclk_in                    => dmonitorclk_in,
          drpaddr_in                        => drpaddr_in,
          drpclk_in                         => drpclk_in,
          drpdi_in                          => drpdi_in,
          drpen_in                          => drpen_in,
          drpwe_in                          => drpwe_in,
          rxpolarity_in                     => rxpolarity_in,
          rxprbscntreset_in                 => rxprbscntreset_in,
          rxprbssel_in                      => rxprbssel_in,
          txpippmen_in                      => txpippmen_in,
          txpippmovrden_in                  => txpippmovrden_in,
          txpippmpd_in                      => txpippmpd_in,
          txpippmsel_in                     => txpippmsel_in,
          txpippmstepsize_in                => txpippmstepsize_in,
          txpolarity_in                     => txpolarity_in,
          txprbsforceerr_in                 => txprbsforceerr_in,
          txprbssel_in                      => txprbssel_in,
          dmonitorout_out                   => dmonitorout_out,
          drpdo_out                         => drpdo_out,
          drprdy_out                        => drprdy_out,
          rxprbserr_out                     => rxprbserr_out,
          rxprbslocked_out                  => rxprbslocked_out,
          txbufstatus_out                   => txbufstatus_out,
          txpmaresetdone_out                => txpmaresetdone_out,
          rxpmaresetdone_out                => rxpmaresetdone_out,
          gtpowergood_out                   => gtpowergood_out,
          gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in,
          gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out,
          gtytxp_out                        => txp_out,
          gtytxn_out                        => txn_out,
          gtyrxp_in                         => rxp_in,
          gtyrxn_in                         => rxn_in
        );
    end generate;
  end generate;

end arch;
