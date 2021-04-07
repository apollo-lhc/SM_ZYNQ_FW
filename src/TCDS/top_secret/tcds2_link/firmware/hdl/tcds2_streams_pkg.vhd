--====================================================================
-- Definitions of VHDL records related to TCDS2 streams (both TTC2 and
-- TTS2).
--
-- Version 0: designed for an lpGBT-like protocol, @10 Gbps, with
-- FEC5.
--====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants_tcds2;

--====================================================================

package tcds2_streams_pkg is

  --==================================================
  -- Link-global constants and types.
  --==================================================

  -- NOTE: The IC, EC, and LM fields are a bit special. These are
  -- shared between the two TCDS2 streams for link-global purposes.
  constant C_TCDS2_IC_WIDTH : integer := 2;
  constant C_TCDS2_EC_WIDTH : integer := 2;
  constant C_TCDS2_LM_WIDTH : integer := 6;

  --==========

  subtype tcds2_ic is std_logic_vector(C_TCDS2_IC_WIDTH - 1 downto 0);
  subtype tcds2_ec is std_logic_vector(C_TCDS2_EC_WIDTH - 1 downto 0);
  subtype tcds2_lm is std_logic_vector(C_TCDS2_LM_WIDTH - 1 downto 0);

  --==========

  constant C_TCDS2_IC_NULL : tcds2_ic := (others => '0');
  constant C_TCDS2_EC_NULL : tcds2_ec := (others => '0');
  constant C_TCDS2_LM_NULL : tcds2_lm := (others => '0');

  --==================================================
  -- TTC2 constants and types.
  --==================================================

  constant C_TCDS2_BIT_NUM_L1A_PHYSICS     : integer := 0;
  constant C_TCDS2_BIT_NUM_L1A_CALIBRATION : integer := 1;
  constant C_TCDS2_BIT_NUM_L1A_RANDOM      : integer := 2;
  constant C_TCDS2_BIT_NUM_L1A_SOFTWARE    : integer := 3;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_4  : integer := 4;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_5  : integer := 5;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_6  : integer := 6;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_7  : integer := 7;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_8  : integer := 8;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_9  : integer := 9;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_10 : integer := 10;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_11 : integer := 11;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_12 : integer := 12;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_13 : integer := 13;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_14 : integer := 14;
  constant C_TCDS2_BIT_NUM_L1A_RESERVED_15 : integer := 15;

  constant C_TCDS2_NUM_L1A_TYPES : integer := 16;

  constant C_TCDS2_L1A_TYPES_WIDTH               : integer := C_TCDS2_NUM_L1A_TYPES;
  constant C_TCDS2_PHYSICS_L1A_SUBTYPE_WIDTH     : integer := 8;
  constant C_TCDS2_BRIL_TRIGGER_DATA_WIDTH       : integer := 16;
  constant C_TCDS2_SYNC_FLAGS_AND_COMMANDS_WIDTH : integer := 49;
  constant C_TCDS2_STATUS_WIDTH                  : integer := 5;
  constant C_TCDS2_TTC2_RESERVED_WIDTH           : integer := 18;

  --==========

  type tcds2_ttc2_l1a_types is record
    l1a_physics     : std_logic;
    l1a_calibration : std_logic;
    l1a_random      : std_logic;
    l1a_software    : std_logic;
    l1a_reserved_4  : std_logic;
    l1a_reserved_5  : std_logic;
    l1a_reserved_6  : std_logic;
    l1a_reserved_7  : std_logic;
    l1a_reserved_8  : std_logic;
    l1a_reserved_9  : std_logic;
    l1a_reserved_10 : std_logic;
    l1a_reserved_11 : std_logic;
    l1a_reserved_12 : std_logic;
    l1a_reserved_13 : std_logic;
    l1a_reserved_14 : std_logic;
    l1a_reserved_15 : std_logic;
  end record;

  subtype tcds2_ttc2_physics_l1a_subtypes is std_logic_vector(C_TCDS2_PHYSICS_L1A_SUBTYPE_WIDTH - 1 downto 0);
  subtype tcds2_ttc2_bril_trigger_data is std_logic_vector(C_TCDS2_BRIL_TRIGGER_DATA_WIDTH - 1 downto 0);
  subtype tcds2_ttc2_sync_flags_and_commands is std_logic_vector(C_TCDS2_SYNC_FLAGS_AND_COMMANDS_WIDTH - 1 downto 0);
  subtype tcds2_ttc2_status is std_logic_vector(C_TCDS2_STATUS_WIDTH - 1 downto 0);
  subtype tcds2_ttc2_reserved is std_logic_vector(C_TCDS2_TTC2_RESERVED_WIDTH - 1 downto 0);

  type tcds2_ttc2 is record
    l1a_types               : tcds2_ttc2_l1a_types;
    physics_l1a_subtypes    : tcds2_ttc2_physics_l1a_subtypes;
    bril_trigger_data       : tcds2_ttc2_bril_trigger_data;
    sync_flags_and_commands : tcds2_ttc2_sync_flags_and_commands;
    status                  : tcds2_ttc2_status;
    reserved                : tcds2_ttc2_reserved;
  end record;

  type tcds2_ttc2_array is array(natural range <>) of tcds2_ttc2;

  --==========

  constant C_TCDS2_TTC2_WIDTH : integer
    := C_TCDS2_L1A_TYPES_WIDTH
    + C_TCDS2_PHYSICS_L1A_SUBTYPE_WIDTH
    + C_TCDS2_BRIL_TRIGGER_DATA_WIDTH
    + C_TCDS2_SYNC_FLAGS_AND_COMMANDS_WIDTH
    + C_TCDS2_STATUS_WIDTH
    + C_TCDS2_TTC2_RESERVED_WIDTH;

  constant C_L1A_TYPES_NULL : tcds2_ttc2_l1a_types
    := (
      l1a_physics     => '0',
      l1a_calibration => '0',
      l1a_random      => '0',
      l1a_software    => '0',
      l1a_reserved_4  => '0',
      l1a_reserved_5  => '0',
      l1a_reserved_6  => '0',
      l1a_reserved_7  => '0',
      l1a_reserved_8  => '0',
      l1a_reserved_9  => '0',
      l1a_reserved_10 => '0',
      l1a_reserved_11 => '0',
      l1a_reserved_12 => '0',
      l1a_reserved_13 => '0',
      l1a_reserved_14 => '0',
      l1a_reserved_15 => '0'
    );

  constant C_PHYSICS_L1A_SUBTYPES_NULL    : tcds2_ttc2_physics_l1a_subtypes := (others => '0');
  constant C_BRIL_TRIGGER_DATA_NULL       : tcds2_ttc2_bril_trigger_data := (others => '0');
  constant C_SYNC_FLAGS_AND_COMMANDS_NULL : tcds2_ttc2_sync_flags_and_commands := (others => '0');
  constant C_STATUS_NULL                  : tcds2_ttc2_status := (others => '0');
  constant C_RESERVED_NULL                : tcds2_ttc2_reserved := (others => '0');

  constant C_TCDS2_TTC2_NULL : tcds2_ttc2
    := (
      l1a_types               => C_L1A_TYPES_NULL,
      physics_l1a_subtypes    => C_PHYSICS_L1A_SUBTYPES_NULL,
      bril_trigger_data       => C_BRIL_TRIGGER_DATA_NULL,
      sync_flags_and_commands => C_SYNC_FLAGS_AND_COMMANDS_NULL,
      status                  => C_STATUS_NULL,
      reserved                => C_RESERVED_NULL
    );

  --==================================================
  -- TTS2 constants and types.
  --==================================================

  constant C_TCDS2_TTS2_VALUE_WIDTH : integer := 8;

  -- For the moment this is based on the number of backplane slots
  -- (i.e., 13) plus the connection to the DTH DAQ FPGA.
  constant C_TCDS2_TTS2_NUM_VALUES : integer := 14;

  constant C_TCDS2_TTS2_VALUES_WIDTH : integer := C_TCDS2_TTS2_NUM_VALUES * C_TCDS2_TTS2_VALUE_WIDTH;

  --==========

  subtype tcds2_tts2_value is integer range 0 to 2 ** C_TCDS2_TTS2_VALUE_WIDTH - 1;

  type tcds2_tts2_value_array is array(natural range <>) of tcds2_tts2_value;

  subtype tcds2_tts2 is tcds2_tts2_value_array(C_TCDS2_TTS2_NUM_VALUES - 1 downto 0);

  type tcds2_tts2_array is array(natural range <>) of tcds2_tts2;

  --==========

  constant C_TCDS2_TTS2_WIDTH : integer
    := C_TCDS2_TTS2_VALUES_WIDTH;

  constant C_TCDS2_TTS2_VALUE_WARNING : tcds2_tts2_value := 16#01#;
  constant C_TCDS2_TTS2_VALUE_BUSY    : tcds2_tts2_value := 16#04#;
  constant C_TCDS2_TTS2_VALUE_READY   : tcds2_tts2_value := 16#08#;
  constant C_TCDS2_TTS2_VALUE_ERROR   : tcds2_tts2_value := 16#0c#;
  constant C_TCDS2_TTS2_VALUE_IGNORED : tcds2_tts2_value := 16#98#;
  constant C_TCDS2_TTS2_VALUE_FAILED  : tcds2_tts2_value := 16#ee#;
  constant C_TCDS2_TTS2_VALUE_INVALID : tcds2_tts2_value := 16#ff#;

  constant C_TCDS2_TTS2_NULL    : tcds2_tts2 := (others => C_TCDS2_TTS2_VALUE_IGNORED);
  constant C_TCDS2_TTS2_READY   : tcds2_tts2 := (others => C_TCDS2_TTS2_VALUE_READY);
  constant C_TCDS2_TTS2_IGNORED : tcds2_tts2 := (others => C_TCDS2_TTS2_VALUE_IGNORED);

  --==================================================
  -- Helper functions to 'flatten' (and 'unflatten') various records
  -- into std_logic_vectors.
  --==================================================

  function flatten_ttc2_l1a_types(l1a_types_i : tcds2_ttc2_l1a_types)
    return std_logic_vector;

  function unflatten_ttc2_l1a_types(l1a_types_flat_i : std_logic_vector(C_TCDS2_L1A_TYPES_WIDTH - 1 downto 0))
    return tcds2_ttc2_l1a_types;

  function flatten_ttc2(stream_i : tcds2_ttc2)
    return std_logic_vector;

  function unflatten_ttc2(stream_flat_i : std_logic_vector(C_TCDS2_TTC2_WIDTH - 1 downto 0))
    return tcds2_ttc2;

  --==========

  function flatten_tts2_values(tts2_values_i : tcds2_tts2_value_array)
    return std_logic_vector;

  function unflatten_tts2(stream_flat_i : std_logic_vector(C_TCDS2_TTS2_WIDTH - 1 downto 0))
    return tcds2_tts2;

  function flatten_tts2(stream_i : tcds2_tts2)
    return std_logic_vector;

  function unflatten_tts2_values(tts2_values_flat_i : std_logic_vector(C_TCDS2_TTS2_VALUES_WIDTH - 1 downto 0))
    return tcds2_tts2_value_array;

end package tcds2_streams_pkg;

--====================================================================

package body tcds2_streams_pkg is

  function flatten_ttc2_l1a_types(l1a_types_i : tcds2_ttc2_l1a_types)
    return std_logic_vector is
    variable l1a_types_flat : std_logic_vector(C_TCDS2_L1A_TYPES_WIDTH - 1 downto 0);
  begin
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_PHYSICS)     := l1a_types_i.l1a_physics;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_CALIBRATION) := l1a_types_i.l1a_calibration;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RANDOM)      := l1a_types_i.l1a_random;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_SOFTWARE)    := l1a_types_i.l1a_software;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_4)  := l1a_types_i.l1a_reserved_4;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_5)  := l1a_types_i.l1a_reserved_5;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_6)  := l1a_types_i.l1a_reserved_6;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_7)  := l1a_types_i.l1a_reserved_7;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_8)  := l1a_types_i.l1a_reserved_8;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_9)  := l1a_types_i.l1a_reserved_9;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_10) := l1a_types_i.l1a_reserved_10;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_11) := l1a_types_i.l1a_reserved_11;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_12) := l1a_types_i.l1a_reserved_12;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_13) := l1a_types_i.l1a_reserved_13;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_14) := l1a_types_i.l1a_reserved_14;
    l1a_types_flat(C_TCDS2_BIT_NUM_L1A_RESERVED_15) := l1a_types_i.l1a_reserved_15;
    return l1a_types_flat;
  end function;

  function unflatten_ttc2_l1a_types(l1a_types_flat_i : std_logic_vector(C_TCDS2_L1A_TYPES_WIDTH - 1 downto 0))
    return tcds2_ttc2_l1a_types is
    variable l1a_types : tcds2_ttc2_l1a_types;
  begin
    l1a_types.l1a_physics     := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_PHYSICS);
    l1a_types.l1a_calibration := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_CALIBRATION);
    l1a_types.l1a_random      := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RANDOM);
    l1a_types.l1a_software    := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_SOFTWARE);
    l1a_types.l1a_reserved_4  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_4);
    l1a_types.l1a_reserved_5  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_5);
    l1a_types.l1a_reserved_6  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_6);
    l1a_types.l1a_reserved_7  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_7);
    l1a_types.l1a_reserved_8  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_8);
    l1a_types.l1a_reserved_9  := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_9);
    l1a_types.l1a_reserved_10 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_10);
    l1a_types.l1a_reserved_11 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_11);
    l1a_types.l1a_reserved_12 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_12);
    l1a_types.l1a_reserved_13 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_13);
    l1a_types.l1a_reserved_14 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_14);
    l1a_types.l1a_reserved_15 := l1a_types_flat_i(C_TCDS2_BIT_NUM_L1A_RESERVED_15);
    return l1a_types;
  end function;

  function flatten_ttc2(stream_i : tcds2_ttc2)
    return std_logic_vector is
    variable stream_flat : std_logic_vector(C_TCDS2_TTC2_WIDTH - 1 downto 0);
  begin
    stream_flat :=
      flatten_ttc2_l1a_types(stream_i.l1a_types)
      & stream_i.physics_l1a_subtypes
      & stream_i.bril_trigger_data
      & stream_i.sync_flags_and_commands
      & stream_i.status
      & stream_i.reserved;
    return stream_flat;
  end function;

  function unflatten_ttc2(stream_flat_i : std_logic_vector(C_TCDS2_TTC2_WIDTH - 1 downto 0))
    return tcds2_ttc2 is
    variable stream : tcds2_ttc2;
    variable hi : integer range 0 to C_TCDS2_TTC2_WIDTH - 1;
    variable lo : integer range 0 to C_TCDS2_TTC2_WIDTH - 1;
  begin
    hi := C_TCDS2_TTC2_WIDTH - 1;
    lo := hi - C_TCDS2_L1A_TYPES_WIDTH + 1;
    stream.l1a_types := unflatten_ttc2_l1a_types(stream_flat_i(hi downto lo));

    hi := lo - 1;
    lo := hi - C_TCDS2_PHYSICS_L1A_SUBTYPE_WIDTH + 1;
    stream.physics_l1a_subtypes := stream_flat_i(hi downto lo);

    hi := lo - 1;
    lo := hi - C_TCDS2_BRIL_TRIGGER_DATA_WIDTH + 1;
    stream.bril_trigger_data := stream_flat_i(hi downto lo);

    hi := lo - 1;
    lo := hi - C_TCDS2_SYNC_FLAGS_AND_COMMANDS_WIDTH + 1;
    stream.sync_flags_and_commands := stream_flat_i(hi downto lo);

    hi := lo - 1;
    lo := hi - C_TCDS2_STATUS_WIDTH + 1;
    stream.status := stream_flat_i(hi downto lo);

    hi := lo - 1;
    lo := hi - C_TCDS2_TTC2_RESERVED_WIDTH + 1;
    stream.reserved := stream_flat_i(hi downto lo);

    return stream;
  end function;

  --==========

  function flatten_tts2_values(tts2_values_i : tcds2_tts2_value_array)
    return std_logic_vector is
    variable values_flat : std_logic_vector(C_TCDS2_TTS2_VALUES_WIDTH - 1 downto 0);
  begin
    for i in 0 to C_TCDS2_TTS2_NUM_VALUES - 1 loop
      values_flat((i + 1) * C_TCDS2_TTS2_VALUE_WIDTH - 1 downto i * C_TCDS2_TTS2_VALUE_WIDTH) := std_logic_vector(to_unsigned(tts2_values_i(i), C_TCDS2_TTS2_VALUE_WIDTH));
    end loop;
    return values_flat;
  end;

  function unflatten_tts2_values(tts2_values_flat_i : std_logic_vector(C_TCDS2_TTS2_VALUES_WIDTH - 1 downto 0))
    return tcds2_tts2_value_array is
    variable values : tcds2_tts2_value_array(C_TCDS2_TTS2_NUM_VALUES - 1 downto 0);
  begin
    for i in 0 to C_TCDS2_TTS2_NUM_VALUES - 1 loop
      values(i) := to_integer(unsigned(tts2_values_flat_i((i + 1) * C_TCDS2_TTS2_VALUE_WIDTH - 1 downto i * C_TCDS2_TTS2_VALUE_WIDTH)));
    end loop;
    return values;
  end function;

  function flatten_tts2(stream_i : tcds2_tts2)
    return std_logic_vector is
    variable stream_flat : std_logic_vector(C_TCDS2_TTS2_WIDTH - 1 downto 0);
  begin
    stream_flat := flatten_tts2_values(stream_i);
    return stream_flat;
  end function;

  function unflatten_tts2(stream_flat_i : std_logic_vector(C_TCDS2_TTS2_WIDTH - 1 downto 0))
    return tcds2_tts2 is
    variable stream : tcds2_tts2;
  begin
    stream := unflatten_tts2_values(stream_flat_i);
    return stream;
  end function;

end package body;

--====================================================================
