--====================================================================
-- Definitions related to the TCDS2 link CSR.
--====================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tclink_lpgbt_pkg.all;

-- use work.tcds2_choice_speed.all;
-- use work.tcds2_link_speed_pkg.all;
-- use work.tcds2_streams_pkg.all;

--====================================================================

package tcds2_link_csr_pkg is

  type tcds2_link_ctrl_t is record

    -- These two go 'straight to' the TCLink core.
    tclink_core_control : tr_core_control;
    tclink_control : tr_tclink_control;

  end record;

  --==========

  type tcds2_link_stat_t is record

    -- Link medium flag (optical or electrical).
    is_link_medium_optical : std_logic;
    -- Link speed indicator.
    is_link_speed_10g : std_logic;
    -- Leader/follower flag.
    is_leader : std_logic;
    -- Quad leader flag.
    is_quad_leader : std_logic;
    -- MGT RX mode flag (DFE/LPM).
    is_mgt_mode_lpm : std_logic;

    -- These two come 'straight from' the TCLink core.
    tclink_core_status : tr_core_status;
    tclink_status : tr_tclink_status;

    -- Some additional channel monitoring info.
    channel_unlock_count : std_logic_vector(31 downto 0);

  end record;

  --==========

  type tcds2_link_ctrl_array is array(natural range <>) of tcds2_link_ctrl_t;
  type tcds2_link_stat_array is array(natural range <>) of tcds2_link_stat_t;

end package;

--====================================================================
