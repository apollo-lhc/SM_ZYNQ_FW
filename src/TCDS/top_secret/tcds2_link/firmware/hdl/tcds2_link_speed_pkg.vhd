--====================================================================
-- Simply the choice of TCDS2 link speed: 10G (production) or 5G
-- (temporary, for prototype back-end support).
-- ====================================================================

package tcds2_link_speed_pkg is

  -- TCDS2 link line rate: 10 Gb/s or 5 Gb/s.
  type tcds2_link_speed_t is (TCDS2_LINK_SPEED_10G, TCDS2_LINK_SPEED_5G);

end package;

--====================================================================
