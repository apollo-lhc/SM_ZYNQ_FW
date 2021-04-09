--======================================================================
-- The main TCDS2 interface from the back-end point of view.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.tclink_lpgbt_pkg.all;

use work.tcds2_interface_pkg.all;
use work.tcds2_link_pkg.all;
use work.tcds2_link_medium_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

--==================================================

entity tcds2_interface is
  generic (
    -- Choice of link medium:
    -- - TCDS2_LINK_MEDIUM_ELECTRICAL for optical links.
    -- - TCDS2_LINK_MEDIUM_OPTICAL for electrical (e.g., backplane)
    --   links.
    G_LINK_MEDIUM : tcds2_link_medium_t := TCDS2_LINK_MEDIUM_ELECTRICAL;

    -- Choice of link line rate:
    -- - TCDS2_LINK_SPEED_10G for 10 Gb/s (i.e., the production
    --   version).
    -- - TCDS2_LINK_SPEED_5G for 5 Gb/s (i.e., the 'compatibility'
    --   version for back-end prototyping with intermediate FPGAs).
    G_LINK_SPEED : tcds2_link_speed_t := TCDS2_LINK_SPEED_10G;

    -- Choice to include/exclude PRBS generator and checker for link
    -- tests.
    G_INCLUDE_PRBS_LINK_TEST : boolean := true
  );
  port (
    -- Control and status interfaces.
    ctrl_i : in tcds2_interface_ctrl_t;
    stat_o : out tcds2_interface_stat_t;

    -- System clock at 125 MHz.
    clk_sys_125mhz : in std_logic;

    -- Transceiver control and status signals (i.e., straight to/from
    -- the transceiver).
    mgt_ctrl_o     : out tr_core_to_mgt;
    mgt_stat_i     : in tr_mgt_to_core;
    mgt_clk_ctrl_o : out tr_clk_to_mgt;
    mgt_clk_stat_i : in tr_mgt_to_clk;

    -- LHC bunch clock output.
    -- NOTE: This clock originates from a BUFGCE_DIV and is intended
    -- for use in the FPGA logic.
    clk_40_o : out std_logic;

    -- LHC bunch clock ODDR outputs.
    -- NOTE: These lines are intended to drive an ODDR1, in order to
    -- extract the bunch clock from the FPGA.
    clk_40_oddr_c_o  : out std_logic;
    clk_40_oddr_d1_o : out std_logic;
    clk_40_oddr_d2_o : out std_logic;

    -- LHC orbit pulse output.
    orbit_o : out std_logic;

    -- TCDS2 channel 0 interface.
    channel0_ttc2_o : out tcds2_ttc2;
    channel0_tts2_i : in tcds2_tts2_value_array(0 downto 0);

    -- TCDS2 channel 1 interface.
    channel1_ttc2_o : out tcds2_ttc2;
    channel1_tts2_i : in tcds2_tts2_value_array(0 downto 0)
  );
end tcds2_interface;

--==================================================

architecture arch of tcds2_interface is

  -- Clock signals.
  signal clk_40 : std_logic;
  signal clk_320 : std_logic;
  -- signal clk_40_tx : std_logic;
  -- signal clk_320_tx : std_logic;

  signal clk_40_oddr_d : std_logic;

  signal txusrclk : std_logic;
  signal rxusrclk : std_logic;

  signal mgt_txoutclk : std_logic;
  signal mgt_rxoutclk : std_logic;

  -- TCLink control and status signals.
  signal core_ctrl   : tr_core_control;
  signal core_stat   : tr_core_status;
  signal tclink_ctrl : tr_tclink_control;
  signal tclink_stat : tr_tclink_status;

  -- TCDS2 TTC2/TTS2 frame signals.
  signal frame_ttc2 : tcds2_frame_t;
  signal frame_tts2 : tcds2_frame_t;

  signal frame_tx : tcds2_frame_t;
  signal frame_rx : tcds2_frame_t;

  -- TCDS2 TTC2/TTS2 signals.
  signal channel0_ttc2 : tcds2_ttc2;
  signal channel0_tts2 : tcds2_tts2;

  signal channel1_ttc2 : tcds2_ttc2;
  signal channel1_tts2 : tcds2_tts2;

  -- Misc.
  signal rx_frame_unlock_count : std_logic_vector(31 downto 0);
  signal rx_frame_locked_320 : std_logic;
  signal not_rx_frame_locked_320 : std_logic;

  -- The tcds2_interface is a follower, not a leader.
  constant C_IS_LINK_LEADER : boolean := false;

  -- The MGT connected to the tcds2_interface is expected to be in
  -- control of its QUAD.
  constant C_IS_QUAD_LEADER : boolean := true;

  constant C_IS_LINK_MEDIUM_OPTICAL : boolean := is_link_medium_optical(G_LINK_MEDIUM);
  constant C_IS_LINK_SPEED_10G : boolean := is_link_speed_10g(G_LINK_SPEED);

  constant C_HAS_LINK_TEST_MODE : boolean := G_INCLUDE_PRBS_LINK_TEST;
  signal is_link_test_mode : boolean;
  signal is_link_test_mode_tmp : std_logic;

  ------------------------------------------
  -- PRBS-related settings and signals.
  ------------------------------------------

  constant C_TCDS2_INTERFACE_FRAME_WIDTH : natural
    := fcn_protocol_tx_width(get_tclink_protocol(G_LINK_SPEED));

  constant C_PRBS_FRAME_WIDTH : natural := C_TCDS2_INTERFACE_FRAME_WIDTH;
  subtype prbs_frame is std_logic_vector(C_PRBS_FRAME_WIDTH - 1 downto 0);

  -- The PRBS polynomial. Notation: x^23 + x^18 + 1 (PRBS-23).
  constant C_PRBS_POLYNOMIAL : std_logic_vector(23 downto 0) := "100001000000000000000001";

   -- PRBS generator polynomial seed.
  constant C_PRBS_SEED : std_logic_vector(C_PRBS_POLYNOMIAL'length - 2 downto 0) := (others => '1');

  -- Number of correct received frames for PRBS checker to lock.
  constant C_PRBS_GOOD_FRAME_TO_LOCK : integer := 15;

  -- Number of incorrect received frames for PRBS checker to unlock.
  constant C_PRBS_BAD_FRAME_TO_UNLOCK : integer := 5;

  -- PRBS generator signals.
  signal prbsgen_reset : std_logic;
  signal prbsgen_reset_manual : std_logic;
  -- PRBS generator output data.
  signal prbsgen_frame : prbs_frame;

  -- PRBS checker signals.
  signal prbschk_reset : std_logic;
  signal prbschk_reset_manual : std_logic;
  -- PRBS checker input data.
  signal prbschk_frame : prbs_frame;
  -- PRBS checker output data.
  signal prbschk_gen : prbs_frame;
  signal prbschk_error : std_logic;
  signal prbschk_locked : std_logic;
  signal prbschk_unlock_count : std_logic_vector(31 downto 0);

begin

  ------------------------------------------
  -- Control and status mapping.
  ------------------------------------------

  core_ctrl   <= ctrl_i.link_control.tclink_core_control;
  tclink_ctrl <= ctrl_i.link_control.tclink_control;

  is_link_test_mode_tmp <= ctrl_i.link_test_mode;

  prbsgen_reset_manual <= ctrl_i.prbsgen_reset;
  prbschk_reset_manual <= ctrl_i.prbschk_reset;

  ----------

  stat_o.has_link_test_mode <= '1' when C_HAS_LINK_TEST_MODE
                               else '0';

  stat_o.link_status.is_link_medium_optical <= '1' when C_IS_LINK_MEDIUM_OPTICAL
                                               else '0';
  stat_o.link_status.is_link_speed_10g <= '1' when C_IS_LINK_SPEED_10G
                                          else '0';
  stat_o.link_status.is_leader <= '1' when C_IS_LINK_LEADER
                                  else '0';
  stat_o.link_status.is_quad_leader <= '1' when C_IS_QUAD_LEADER
                                          else '0';
  stat_o.link_status.is_mgt_mode_lpm <= core_ctrl.mgt_rxeq_rxlpmen;

  stat_o.link_status.tclink_core_status <= core_stat;
  stat_o.link_status.tclink_status      <= tclink_stat;

  stat_o.link_status.channel_unlock_count <= rx_frame_unlock_count;

  stat_o.prbschk_error  <= prbschk_error when C_HAS_LINK_TEST_MODE
                           else '0';
  stat_o.prbschk_locked <= prbschk_locked when C_HAS_LINK_TEST_MODE
                           else '0';

  stat_o.prbschk_unlock_count <= prbschk_unlock_count when C_HAS_LINK_TEST_MODE
                                 else (others => '0');

  stat_o.prbsgen_o_hint <= prbsgen_frame(stat_o.prbsgen_o_hint'range) when C_HAS_LINK_TEST_MODE
                           else (others => '0');
  stat_o.prbschk_i_hint <= prbschk_frame(stat_o.prbschk_i_hint'range) when C_HAS_LINK_TEST_MODE
                           else (others => '0');
  stat_o.prbschk_o_hint <= prbschk_gen(stat_o.prbschk_o_hint'range) when C_HAS_LINK_TEST_MODE
                           else (others => '0');

  stat_o.frame_tx <= frame_tx;
  stat_o.frame_rx <= frame_rx;

  stat_o.channel0_ttc2 <= channel0_ttc2;
  stat_o.channel1_ttc2 <= channel1_ttc2;
  stat_o.channel0_tts2 <= channel0_tts2;
  stat_o.channel1_tts2 <= channel1_tts2;

  ----------

  is_link_test_mode <= true when C_HAS_LINK_TEST_MODE and is_link_test_mode_tmp = '1'
                       else false;

  ------------------------------------------
  -- Transceiver user clock network.
  ------------------------------------------

  mgt_user_clock : entity work.mgt_user_clock
    generic map (
      g_NUMBER_CHANNELS => 1
    )
    port map (
      txusrclk_o(0) => txusrclk,
      rxusrclk_o(0) => rxusrclk,

      mgt_txoutclk_i(0) => mgt_txoutclk,
      mgt_rxoutclk_i(0) => mgt_rxoutclk
    );

  mgt_clk_ctrl_o.txusrclk <= txusrclk;
  mgt_clk_ctrl_o.rxusrclk <= rxusrclk;

  mgt_txoutclk <= mgt_clk_stat_i.txoutclk;
  mgt_rxoutclk <= mgt_clk_stat_i.rxoutclk;

  ------------------------------------------
  -- TCLink cores.
  ------------------------------------------

  -- The TCLink.
  tclink : entity work.tclink_lpgbt
    generic map (
      -- The tcds2_interface is always on the receiving end of a TCDS2
      -- link.
      G_MASTER_NSLAVE               => C_IS_LINK_LEADER,
      G_QUAD_LEADER                 => C_IS_QUAD_LEADER,
      G_MASTER_TCLINK_TESTER_ENABLE => false,
      G_PROTOCOL                    => get_tclink_protocol(G_LINK_SPEED)
    )
    port map (
      -- System clock/resets.
      clk_sys_i   => clk_sys_125mhz,

      -- Core control/status. (Synchronous to clk_sys_i.)
      core_ctrl_i => core_ctrl,
      core_stat_o => core_stat,

      -- TCLink business.
      master_tclink_clk_offset_i => '0',
      master_tclink_ctrl_i       => tclink_ctrl,
      master_tclink_stat_o       => tclink_stat,

      -- Recovered clock.
      slave_clk40_oddr_o => clk_40_oddr_d,

      -- MMCM status (which only exists for the master).
      mmcm_locked_i => '0',

      -- User data.
      tx_clk40_i        => clk_40,
      tx_clk40_stable_i => '1',
      tx_data_i         => frame_tx,

      rx_clk40_i        => clk_40,
      rx_clk40_stable_i => '1',
      rx_data_o         => frame_rx,

      -- MGT interface.
      mgt_txclk_i => txusrclk,
      mgt_rxclk_i => rxusrclk,
      mgt_ctrl_o  => mgt_ctrl_o,
      mgt_stat_i  => mgt_stat_i
    );

  ------------------------------------------
  -- Clock divider to derive the 40 MHz bunch clock from the 320 MHz
  -- MGT RX clock.
  ------------------------------------------

  -- BUG BUG BUG
  -- What about the relative phase between these two clocks in this
  -- configuration?
  -- BUG BUG BUG end

  rx_frame_locked_bit_sync_320 : entity work.bit_synchronizer
    port map (
      clk_in => clk_320,
      i_in   => core_stat.rx_frame_locked,
      o_out  => rx_frame_locked_320
    );
  not_rx_frame_locked_320 <= not rx_frame_locked_320;

  bufgce_clk_40_rx : bufgce_div
    generic map (
      BUFGCE_DIVIDE => 8
    )
    port map (
      i   => clk_320,
      o   => clk_40,
      ce  => '1', --rx_frame_locked_320,
      clr => not_rx_frame_locked_320
    );

  -- Clock mapping.
  clk_320  <= rxusrclk;
  -- BUG BUG BUG
  -- clk_40_o <= clk_40;
  clk_40_o <= clk_40_oddr_d;
  -- BUG BUG BUG end

  clk_40_oddr_c_o  <= clk_320;
  clk_40_oddr_d1_o <= clk_40_oddr_d;
  clk_40_oddr_d2_o <= clk_40_oddr_d;

  ------------------------------------------
  -- Frame (i.e., link) unlock counter.
  ------------------------------------------

  rx_frame_unlock_cnt : entity work.unlock_counter
    generic map (
      G_WIDTH => rx_frame_unlock_count'length
    )
    port map (
      clk          => clk_sys_125mhz,
      rst          => core_ctrl.mgt_reset_rx_datapath,
      locked       => core_stat.rx_frame_locked,
      unlock_count => rx_frame_unlock_count
    );

  ------------------------------------------
  -- Optional: PRBS generator and checker (and unlock counter).
  ------------------------------------------

  if_include_link_test_hw : if G_INCLUDE_PRBS_LINK_TEST generate
    -- PRBS generator.
    prbs_generator : entity work.prbs_gen
      generic map (
        G_PARAL_FACTOR    => C_PRBS_FRAME_WIDTH,
        G_PRBS_POLYNOMIAL => C_PRBS_POLYNOMIAL
      )
      port map (
        clk_i        => clk_40,
        reset_i      => prbsgen_reset,
        en_i         => '1',
        seed_i       => C_PRBS_SEED,
        load_i       => '0',
        data_o       => prbsgen_frame,
        data_valid_o => open
      );

    -- PRBS checker.
    prbs_checker : entity work.prbs_chk
      generic map (
        G_PARAL_FACTOR        => C_PRBS_FRAME_WIDTH,
        G_PRBS_POLYNOMIAL     => C_PRBS_POLYNOMIAL,
        G_GOOD_FRAME_TO_LOCK  => C_PRBS_GOOD_FRAME_TO_LOCK,
        G_BAD_FRAME_TO_UNLOCK => C_PRBS_BAD_FRAME_TO_UNLOCK
      )
      port map (
        clk_i    => clk_40,
        reset_i  => prbschk_reset,
        en_i     => '1',
        data_i   => prbschk_frame,
        data_o   => prbschk_gen,
        error_o  => prbschk_error,
        locked_o => prbschk_locked
      );

    -- PRBS checker unlock counter.
    prbs_chk_unlock_cnt : entity work.unlock_counter
      generic map (
        G_WIDTH => prbschk_unlock_count'length
      )
      port map (
        clk          => clk_40,
        rst          => prbschk_reset,
        locked       => prbschk_locked,
        unlock_count => prbschk_unlock_count
      );

    -- In normal operation the PRBS generator and checker are kept
    -- under reset. In link test mode they can be manually reset if
    -- needed.
    prbsgen_reset <= prbsgen_reset_manual when is_link_test_mode else '1';
    prbschk_reset <= prbschk_reset_manual when is_link_test_mode else '1';
  end generate;

  ------------------------------------------
  -- TTC2 frame splitter.
  ------------------------------------------

  ttc2_frame_splitter : entity work.ttc2_frame_splitter
    generic map (
      G_LINK_SPEED => G_LINK_SPEED
    )
    port map (
      frame_i => frame_ttc2,

      stream0_o => channel0_ttc2,
      stream1_o => channel1_ttc2,

      ic_o => open,
      ec_o => open,
      lm_o => open
    );

  ------------------------------------------
  -- TTS2 frame builder.
  ------------------------------------------

  tts2_frame_builder : entity work.tts2_frame_builder
    generic map (
      G_LINK_SPEED => G_LINK_SPEED
    )
    port map (
      stream0_i => channel0_tts2,
      stream1_i => channel1_tts2,

      ic_i => C_TCDS2_IC_NULL,
      ec_i => C_TCDS2_EC_NULL,
      lm_i => C_TCDS2_LM_NULL,

      frame_o => frame_tts2
  );

  ------------------------------------------
  -- Frame routing for normal and link test modes.
  ------------------------------------------

  -- TTC2.
  frame_ttc2    <= frame_rx when not is_link_test_mode else C_TCDS2_FRAME_NULL;
  prbschk_frame <= frame_rx when is_link_test_mode else (others => '0');

  -- TTS2.
  frame_tx <= prbsgen_frame when is_link_test_mode else frame_tts2;

  ------------------------------------------
  -- Channel assignments.
  ------------------------------------------

  channel0_ttc2_o <= channel0_ttc2;
  channel0_tts2   <= (0 => channel0_tts2_i(0),
                      others => C_TCDS2_TTS2_VALUE_IGNORED);

  channel1_ttc2_o <= channel1_ttc2;
  channel1_tts2   <= (0 => channel1_tts2_i(0),
                      others => C_TCDS2_TTS2_VALUE_IGNORED);

  -- ------------------------------------------
  -- -- Various monitoring.
  -- ------------------------------------------

  -- orbit_mon : entity work.orbit_monitor
  --   port map (
  --     reset_i                  => reset_all,
  --     bunch_clock_i            => clk_40,
  --     orbit_strobe_i           => orbit_strobe,

  --     first_strobe_detected_o  => first_orbit_detected,
  --     missed_strobe_detected_o => missed_orbit_detected,
  --     early_strobe_detected_o  => early_orbit_detected,
  --     missed_strobe_count_o    => missed_orbit_count,
  --     early_strobe_count_o     => early_orbit_count
  --   );

end arch;

--======================================================================
