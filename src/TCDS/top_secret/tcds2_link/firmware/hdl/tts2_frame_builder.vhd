--====================================================================
-- 'Packer' to build a TCDS2 data frame from two TTS2 streams and the
-- auxiliary IC, EC, and LM fields.
--====================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.tcds2_link_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

entity tts2_frame_builder is
  generic (
    G_LINK_SPEED : tcds2_link_speed_t := tcds2_link_speed_10G
  );
  port (
    -- The two TTS2 streams.
    stream0_i : in tcds2_tts2;
    stream1_i : in tcds2_tts2;

    -- The IC field.
    ic_i : in tcds2_ic;

    -- The EC field.
    ec_i : in tcds2_ec;

    -- The LM field.
    lm_i : in tcds2_lm;

    -- The resulting output frame.
    frame_o : out tcds2_frame_t
  );
end tts2_frame_builder;

--==========

-- This is version 0 of the TCDS2 downstream frame format.
architecture v0 of tts2_frame_builder is
begin

  if_5g : if G_LINK_SPEED = tcds2_link_speed_5G generate
    frame_o <= ic_i & ec_i & flatten_tts2(stream0_i);
  end generate;

  if_10g : if G_LINK_SPEED = tcds2_link_speed_10G generate
    frame_o <= ic_i & ec_i & flatten_tts2(stream1_i) & flatten_tts2(stream0_i) & lm_i;
  end generate;

end v0;

--====================================================================
