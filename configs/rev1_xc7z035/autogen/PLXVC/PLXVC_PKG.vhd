--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package PLXVC_CTRL is
  type PLXVC_XVC_REMOTE_CTRL_t is record
    IP                         :std_logic_vector(31 downto 0);  -- IP of remote connection
    PORT_NUMBER                :std_logic_vector(15 downto 0);  -- port of remote connection
  end record PLXVC_XVC_REMOTE_CTRL_t;


  constant DEFAULT_PLXVC_XVC_REMOTE_CTRL_t : PLXVC_XVC_REMOTE_CTRL_t := (
                                                                         IP => (others => '0'),
                                                                         PORT_NUMBER => (others => '0')
                                                                        );
  type PLXVC_XVC_MON_t is record
    TDO_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data Out (TDO) Capture Vector
    BUSY                       :std_logic;                      -- Cable is operating
  end record PLXVC_XVC_MON_t;
  type PLXVC_XVC_MON_t_ARRAY is array(1 to 2) of PLXVC_XVC_MON_t;

  type PLXVC_XVC_CTRL_t is record
    LENGTH                     :std_logic_vector(31 downto 0);  -- Length of shift operation in bits
    TMS_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Mode Select (TMS) Bit Vector
    TDI_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data In (TDI) Bit Vector
    GO                         :std_logic;                      -- Enable shift operation
    LOCK                       :std_logic_vector(31 downto 0);  -- Lock cable from access
    REMOTE                     :PLXVC_XVC_REMOTE_CTRL_t;      
    PS_RST                     :std_logic;                      -- PS reset
  end record PLXVC_XVC_CTRL_t;
  type PLXVC_XVC_CTRL_t_ARRAY is array(1 to 2) of PLXVC_XVC_CTRL_t;

  constant DEFAULT_PLXVC_XVC_CTRL_t : PLXVC_XVC_CTRL_t := (
                                                           LENGTH => (others => '0'),
                                                           TMS_VECTOR => (others => '0'),
                                                           TDI_VECTOR => (others => '0'),
                                                           GO => '0',
                                                           LOCK => (others => '0'),
                                                           REMOTE => DEFAULT_PLXVC_XVC_REMOTE_CTRL_t,
                                                           PS_RST => '1'
                                                          );
  type PLXVC_MON_t is record
    XVC                        :PLXVC_XVC_MON_t_ARRAY;
  end record PLXVC_MON_t;


  type PLXVC_CTRL_t is record
    XVC                        :PLXVC_XVC_CTRL_t_ARRAY;
  end record PLXVC_CTRL_t;


  constant DEFAULT_PLXVC_CTRL_t : PLXVC_CTRL_t := (
                                                   XVC => (others => DEFAULT_PLXVC_XVC_CTRL_t )
                                                  );


end package PLXVC_CTRL;