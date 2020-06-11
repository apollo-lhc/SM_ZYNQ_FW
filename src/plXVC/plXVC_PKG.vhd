--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package plXVC_CTRL is
  type plXVC_XVC_MON_t is record
    TDO_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data Out (TDO) Capture Vector
    BUSY                       :std_logic;                      -- Cable is operating
  end record plXVC_XVC_MON_t;
  type plXVC_XVC_MON_t_ARRAY is array(1 to 2) of plXVC_XVC_MON_t;

  type plXVC_XVC_CTRL_t is record
    LENGTH                     :std_logic_vector(31 downto 0);  -- Length of shift operation in bits
    TMS_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Mode Select (TMS) Bit Vector
    TDI_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data In (TDI) Bit Vector
    GO                         :std_logic;                      -- Enable shift operation
    LOCK                       :std_logic_vector(31 downto 0);  -- Lock cable from access
  end record plXVC_XVC_CTRL_t;
  type plXVC_XVC_CTRL_t_ARRAY is array(1 to 2) of plXVC_XVC_CTRL_t;

  constant DEFAULT_plXVC_XVC_CTRL_t : plXVC_XVC_CTRL_t := (
                                                           GO => '0',
                                                           LOCK => (others => '0'),
                                                           LENGTH => (others => '0'),
                                                           TDI_VECTOR => (others => '0'),
                                                           TMS_VECTOR => (others => '0')
                                                          );
  type plXVC_MON_t is record
    XVC                        :plXVC_XVC_MON_t_ARRAY;
  end record plXVC_MON_t;


  type plXVC_CTRL_t is record
    XVC                        :plXVC_XVC_CTRL_t_ARRAY;
  end record plXVC_CTRL_t;


  constant DEFAULT_plXVC_CTRL_t : plXVC_CTRL_t := (
                                                   XVC => (others => DEFAULT_plXVC_XVC_CTRL_t )
                                                  );


end package plXVC_CTRL;