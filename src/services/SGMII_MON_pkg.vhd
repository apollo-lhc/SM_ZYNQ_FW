library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package SGMII_MONITOR is

  type SGMII_MONITOR_t is record
    reset_done    : std_logic;
    cpll_lock     : std_logic;
    mmcm_reset    : std_logic;
    pma_reset     : std_logic;
    mmcm_locked   : std_logic;
    status_vector : slv_16_t;
    reset         : std_logic;
  end record SGMII_MONITOR_t;

  type SGMII_CONTROL_t is record
    reset : std_logic;
  end record SGMII_CONTROL_t;
  constant SGMII_CONTROL_DEFAULT : SGMII_CONTROL_t := (
    reset => '0');
  
  

end package SGMII_MONITOR;
