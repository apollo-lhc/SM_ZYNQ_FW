--====================================================================
-- 'Unpacker' to split a TCDS2 data frame into two TTC2 streams and
-- the auxiliary IC, EC, and LM fields.
-- ====================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tcds2_link_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

entity ttc2_frame_splitter is
  generic (
    G_LINK_SPEED : tcds2_link_speed_t := tcds2_link_speed_10G
  );
  port (
    -- The input frame.
    frame_i : in tcds2_frame_t;

    -- The two TTC2 streams.
    stream0_o : out tcds2_ttc2;
    stream1_o : out tcds2_ttc2;

    -- The IC field.
    ic_o : out tcds2_ic;

    -- The EC field.
    ec_o : out tcds2_ec;

    -- The LM field.
    lm_o : out tcds2_lm
  );
end ttc2_frame_splitter;

--==========

-- This is version 0 of the TCDS2 frame format.
architecture V0 of ttc2_frame_splitter is

  constant C_TCDS2_TTC2_FRAME_WIDTH : natural
    := C_TCDS2_IC_WIDTH + C_TCDS2_EC_WIDTH + 2 * C_TCDS2_TTC2_WIDTH + C_TCDS2_LM_WIDTH;

  -- 5G link variant.
  constant lo_stream0_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := 0;
  constant hi_stream0_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_stream0_5g + C_TCDS2_TTC2_WIDTH - 1;

  constant lo_ec_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_stream0_5g + 1;
  constant hi_ec_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_ec_5g + C_TCDS2_EC_WIDTH - 1;

  constant lo_ic_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_ec_5g + 1;
  constant hi_ic_5g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_ic_5g + C_TCDS2_IC_WIDTH - 1;

  -- 10G link variant.
  constant lo_lm_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := 0;
  constant hi_lm_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_lm_10g + C_TCDS2_LM_WIDTH - 1;

  constant lo_stream0_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_lm_10g + 1;
  constant hi_stream0_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_stream0_10g + C_TCDS2_TTC2_WIDTH - 1;

  constant lo_stream1_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_stream0_10g + 1;
  constant hi_stream1_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_stream1_10g + C_TCDS2_TTC2_WIDTH - 1;

  constant lo_ec_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_stream1_10g + 1;
  constant hi_ec_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_ec_10g + C_TCDS2_EC_WIDTH - 1;

  constant lo_ic_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := hi_ec_10g + 1;
  constant hi_ic_10g : natural range 0 to C_TCDS2_TTC2_FRAME_WIDTH - 1 := lo_ic_10g + C_TCDS2_IC_WIDTH - 1;

begin

  -- 5G link variant.
  if_5g : if G_LINK_SPEED = tcds2_link_speed_5G generate
    ic_o      <= frame_i(hi_ic_5g downto lo_ic_5g);
    ec_o      <= frame_i(hi_ec_5g downto lo_ec_5g);
    stream0_o <= unflatten_ttc2(frame_i(hi_stream0_5g downto lo_stream0_5g));
  end generate;

  -- 10G link variant.
  if_10g : if G_LINK_SPEED = tcds2_link_speed_10G generate
    ic_o      <= frame_i(hi_ic_10g downto lo_ic_10g);
    ec_o      <= frame_i(hi_ec_10g downto lo_ec_10g);
    stream1_o <= unflatten_ttc2(frame_i(hi_stream1_10g downto lo_stream1_10g));
    stream0_o <= unflatten_ttc2(frame_i(hi_stream0_10g downto lo_stream0_10g));
    lm_o      <= frame_i(hi_lm_10g downto lo_lm_10g);
  end generate;

end V0;

--====================================================================
