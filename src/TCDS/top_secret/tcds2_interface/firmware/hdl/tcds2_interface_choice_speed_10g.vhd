--======================================================================
-- This may all look a bit cumbersome but in the context of ipbb and
-- friends it all works out quite well.
--======================================================================

use work.tcds2_link_speed_pkg.all;

package tcds2_interface_choice_speed is

  constant C_TCDS2_BACKEND_LINK_SPEED : tcds2_link_speed_t := TCDS2_LINK_SPEED_10G;

end package;

--======================================================================
