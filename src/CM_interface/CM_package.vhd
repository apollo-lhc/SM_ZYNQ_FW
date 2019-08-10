library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package CM_package is

  type C2C_Monitor_t is record    
    axi_c2c_config_error_out    : STD_LOGIC;
    axi_c2c_link_error_out      : STD_LOGIC;
    axi_c2c_link_status_out     : STD_LOGIC;
    axi_c2c_multi_bit_error_out : STD_LOGIC;
    aurora_do_cc                : STD_LOGIC;
    phy_gt_pll_lock             : STD_LOGIC;
    phy_hard_err                : STD_LOGIC;
    phy_lane_up                 : STD_LOGIC_VECTOR ( 0 to 0 );
    phy_link_reset_out          : STD_LOGIC;
    phy_mmcm_not_locked_out     : STD_LOGIC;
    phy_soft_err                : STD_LOGIC;
  end record C2C_Monitor_t;

  type C2C_Control_t is record
    aurora_pma_init_in : std_logic;
  end record C2C_Control_t;
  constant DEFAULT_C2C_Control_t : C2C_Control_t := (aurora_pma_init_in => '0');
  
  
  type to_CM_t is record
    UART_Tx : std_logic;
    TMS     : std_logic;
    TDI     : std_logic;
    TCK     : std_logic;
  end record to_CM_t;

  type from_CM_t is record
    PWR_good : std_logic;
    UART_Rx  : std_logic;
    TDO      : std_logic;
    GPIO     : slv_2_t;
  end record from_CM_t;

end package CM_package;
