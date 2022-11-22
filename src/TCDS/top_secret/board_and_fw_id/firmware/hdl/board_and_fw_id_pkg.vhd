--======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package board_and_fw_id_pkg is

  -- Type definitions first.
  subtype tcds2_id is string(1 to 8);
  subtype tcds2_version is natural range 0 to 255;
  subtype tcds2_annotation is string(1 to 8);
  type tcds2_annotation_array is array (integer range <>) of tcds2_annotation;

  --==========

  constant C_ANNOTATION_DUMMY : tcds2_annotation := "DUMMY   ";
  constant C_ANNOTATION_5G : tcds2_annotation := "5G      ";
  constant C_ANNOTATION_10G : tcds2_annotation := "10G     ";

  -- NOTE: The following is _not_ a typo.
  constant C_NO_ANNOTATIONS : tcds2_annotation_array(-1 downto 0) := (others => C_ANNOTATION_DUMMY);

  --==========

  -- Helper functions to convert strings into std_vectors encoded as
  -- series of ASCII characters.
  function id_to_std_logic_vector(s : tcds2_id) return std_logic_vector;

  function annotation_to_std_logic_vector(s : tcds2_annotation) return std_logic_vector;

end board_and_fw_id_pkg;

--======================================================================

package body board_and_fw_id_pkg is

  function id_to_std_logic_vector(s : tcds2_id) return std_logic_vector
  is
    variable r : std_logic_vector(s'length * 8 - 1 downto 0);
  begin
    for i in 1 to s'high loop
      r(i * 8 - 1 downto (i - 1) * 8) :=
        std_logic_vector(to_unsigned(character'pos(s(s'high - i + 1)), 8));
    end loop;
    return r;
  end function;

  function annotation_to_std_logic_vector(s : tcds2_annotation) return std_logic_vector
  is
    variable r : std_logic_vector(s'length * 8 - 1 downto 0);
  begin
    r := id_to_std_logic_vector(s);
    return r;
  end function;

end package body;

--======================================================================
