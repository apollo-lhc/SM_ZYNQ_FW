--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package plXVC_CTRL is
  type plXVC_MON_t is record
    BUSY                       : std_logic;                       -- Cable is operating
    TDO_VECTOR                 : std_logic_vector(31 downto  0);  -- Test Data Out (TDO) Capture Vector
  end record plXVC_MON_t;

  type plXVC_CTRL_t is record
    GO                         : std_logic;                       -- Enable shift operation
    LENGTH                     : std_logic_vector(31 downto  0);  -- Length of shift operation in bits
    TDI_VECTOR                 : std_logic_vector(31 downto  0);  -- Test Data In (TDI) Bit Vector
    TMS_VECTOR                 : std_logic_vector(31 downto  0);  -- Test Mode Select (TMS) Bit Vector
  end record plXVC_CTRL_t;

  constant DEFAULT_plXVC_CTRL_t : plXVC_CTRL_t := (
                                                   GO => '0',
                                                   LENGTH => (others => '0'),
                                                   TDI_VECTOR => (others => '0'),
                                                   TMS_VECTOR => (others => '0')
                                                  );


end package plXVC_CTRL;