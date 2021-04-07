--======================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tcds2_link_pkg.all;
use work.tcds2_streams_pkg.all;

--==================================================

package tcds2_interface_pkg is

  -- Auxiliary type used to specify the transceiver type using the
  -- G_MGT_TYPE generic in tcds2_interface_with_mgt.
  type mgt_type_t is (MGT_TYPE_GTHE3, MGT_TYPE_GTYE3,
                      MGT_TYPE_GTHE4, MGT_TYPE_GTYE4);

  ------------------------------------------

  -- TCDS2 interface control record. Can be used stand-alone or in
  -- combination with the ipbus_tcds2_interface_accessor helper.
  type tcds2_interface_ctrl_t is record
    -- MGT resets.
    mgt_reset_all : std_logic;
    mgt_reset_tx  : std_logic;
    mgt_reset_rx  : std_logic;

    -- Link test mode.
    link_test_mode : std_logic;

    -- PRBS generator and checker resets (for link test mode).
    prbsgen_reset : std_logic;
    prbschk_reset : std_logic;
  end record;

  ------------------------------------------

  -- TCDS2 interface status record. Can be used stand-alone or in
  -- combination with the ipbus_tcds2_interface_accessor helper.
  type tcds2_interface_stat_t is record
    -- Flags representing the implementation choices of the TCDS2
    -- interface.
    is_link_speed_10g  : std_logic;
    has_link_test_mode : std_logic;
    has_spy_registers  : std_logic;

    -- 'Power good' flag for the MGT quad.
    mgt_powergood : std_logic;

    -- PLL lock flags for the MGT quad.
    mgt_txpll_lock : std_logic;
    mgt_rxpll_lock : std_logic;

    -- Reset status flags for the MGT quad.
    mgt_reset_tx_done : std_logic;
    mgt_reset_rx_done : std_logic;

    -- TCLink status.
    mgt_tx_ready    : std_logic;
    mgt_rx_ready    : std_logic;
    rx_frame_locked : std_logic;

    rx_frame_unlock_count : std_logic_vector(31 downto 0);

    prbschk_error  : std_logic;
    prbschk_locked : std_logic;

    prbschk_unlock_count : std_logic_vector(31 downto 0);

    prbsgen_o_hint : std_logic_vector(7 downto 0);
    prbschk_i_hint : std_logic_vector(7 downto 0);
    prbschk_o_hint : std_logic_vector(7 downto 0);

    -- Raw frame data.
    frame_tx : tcds2_frame_t;
    frame_rx : tcds2_frame_t;

    -- TTC2/TTS2 information.
    channel0_ttc2 : tcds2_ttc2;
    channel1_ttc2 : tcds2_ttc2;
    channel0_tts2 : tcds2_tts2;
    channel1_tts2 : tcds2_tts2;
  end record;

end package;

--======================================================================
