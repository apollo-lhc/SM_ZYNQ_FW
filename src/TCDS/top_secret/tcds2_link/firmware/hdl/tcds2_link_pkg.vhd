--====================================================================
-- Definitions related to the TCDS2 link: frame width etc.
--====================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tclink_lpgbt_pkg.all;

use work.tcds2_choice_speed.all;
use work.tcds2_link_medium_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

--====================================================================

package tcds2_link_pkg is

  -- Helper function to initialize 'conditional constants.'
  function if_then_else(b : boolean; x, y : natural) return natural;

  --==========

  -- Helper functions to get frame width and TCLink protocol based on
  -- the TCDS2 link speed.
  function get_tcds2_frame_width(link_speed: tcds2_link_speed_t) return natural;
  -- function get_tcds2_tclink_data_rate(link_speed: tcds2_link_speed_t) return natural;
  function get_tclink_protocol(link_speed : tcds2_link_speed_t) return T_EXAMPLE_PROTOCOL;

  -- Helper function to find out if the link is optical or electrical.
  function is_link_medium_optical(link_medium : tcds2_link_medium_t) return boolean;

  -- Helper function to find out if the link speed given is 10G or not.
  function is_link_speed_10g(link_speed : tcds2_link_speed_t) return boolean;

  --==========

  -- In 5G mode the (data) frame width is 116 bits. (These are the 128
  -- bits of the lpGBT frame minus 2 header bits and 10 FEC bits.)
  constant C_TCDS2_FRAME_WIDTH_5G : natural := 116;
  -- In 10G mode the (data) frame width is 234 bits. (These are the
  -- 256 bits of the lpGBT frame minus 2 header bits and 20 FEC bits.)
  constant C_TCDS2_FRAME_WIDTH_10G : natural := 234;

  constant C_TCDS2_FRAME_WIDTH : natural := get_tcds2_frame_width(C_TCDS2_LINK_SPEED);

  --==========

  subtype tcds2_frame_t is std_logic_vector(C_TCDS2_FRAME_WIDTH - 1 downto 0);
  type tcds2_frame_array is array(natural range <>) of tcds2_frame_t;

  --==========

  constant C_TCDS2_FRAME_NULL : tcds2_frame_t := (others => '0');

end package;

--====================================================================

package body tcds2_link_pkg is

  function if_then_else(b : boolean; x, y : natural) return natural is
  begin
    if (b) then
      return x;
    else
      return y;
    end if;
  end if_then_else;

  function get_tcds2_frame_width(link_speed: tcds2_link_speed_t) return natural is
  begin
    return if_then_else(link_speed = TCDS2_LINK_SPEED_5G,
                        C_TCDS2_FRAME_WIDTH_5G,
                        C_TCDS2_FRAME_WIDTH_10G);
  end get_tcds2_frame_width;

  function get_tclink_protocol(link_speed : tcds2_link_speed_t) return T_EXAMPLE_PROTOCOL is
  begin
    if (link_speed = TCDS2_LINK_SPEED_5G) then
      return SYMMETRIC_5G;
    else
      return SYMMETRIC_10G;
    end if;
  end get_tclink_protocol;

  function is_link_medium_optical(link_medium : tcds2_link_medium_t) return boolean is
  begin
    return link_medium = TCDS2_LINK_MEDIUM_OPTICAL;
  end is_link_medium_optical;

  function is_link_speed_10g(link_speed : tcds2_link_speed_t) return boolean is
  begin
    return link_speed = TCDS2_LINK_SPEED_10G;
  end is_link_speed_10g;

end package body;

--======================================================================
