library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.CM_CTRL.all;

package CM_package is

  type single_C2C_Monitor_t is record
    status             : CM_CM_C2C_STATUS_MON_t;     -- from address table via CM_PKG
    link_debug         : CM_CM_C2C_LINK_DEBUG_MON_t; -- from address table via CM_PKG
  end record single_C2C_Monitor_t;
  type C2C_Monitor_t_ARRAY is array (1 to 2) of single_C2C_Monitor_t;
  type C2C_Monitor_t is record
    CM : C2C_Monitor_t_ARRAY;
  end record C2C_Monitor_t;
  

  type single_C2C_Control_t is record    
    aurora_pma_init_in : std_logic;
    status             : CM_CM_C2C_STATUS_CTRL_t;     -- from address table via CM_PKG
    link_debug         : CM_CM_C2C_LINK_DEBUG_CTRL_t; -- from address table via CM_PKG
  end record single_C2C_Control_t;
  constant DEFAULT_single_C2C_Control_t : single_C2C_Control_t := (
    aurora_pma_init_in => '0',
    status             => DEFAULT_CM_CM_C2C_STATUS_CTRL_t,     -- from address table via CM_PKG
    link_debug         => DEFAULT_CM_CM_C2C_LINK_DEBUG_CTRL_t -- from address table via CM_PKG
    );
  type C2C_Control_t_ARRAY is array (1 to 2) of single_C2C_Control_t;
  type C2C_Control_t is record
    CM : C2C_Control_t_ARRAY;
  end record C2C_Control_t;
  constant DEFAULT_C2C_Control_t : C2C_Control_t := (CM => (others => DEFAULT_single_C2C_Control_t));




  
  --Array to_CM_t
  type single_to_CM_t is record
    UART_Tx : std_logic;
    TMS     : std_logic;
    TDI     : std_logic;
    TCK     : std_logic;
  end record single_to_CM_t;
  type to_CM_t_ARRAY is array (1 to 2) of single_to_CM_t;
  type to_CM_t is record
    CM : to_CM_t_ARRAY;
  end record to_CM_t;
    
  --Array from_CM_t
  type single_from_CM_t is record
    PWR_good : std_logic;
    UART_Rx  : std_logic;
    TDO      : std_logic;
    GPIO     : slv_2_t;
  end record single_from_CM_t;
  type from_CM_t_ARRAY is array (1 to 2) of single_from_CM_t;
  type from_CM_t is record
    CM : from_CM_t_ARRAY;
  end record from_CM_t;
end package CM_package;
