library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package CM_package is

  --Array C2C_Monitor_t
  type single_C2C_Monitor_t is record    
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

    --debug
    cplllock         : STD_LOGIC;
    dmonitorout      : STD_LOGIC_VECTOR ( 7 downto 0 );
    eyescandataerror : STD_LOGIC;
    rxbufstatus      : STD_LOGIC_VECTOR ( 2 downto 0 );
    rxmonitorout     : STD_LOGIC_VECTOR ( 6 downto 0 );
    rxprbserr        : STD_LOGIC;
    rxresetdone      : STD_LOGIC;
    txbufstatus      : STD_LOGIC_VECTOR ( 1 downto 0 );
    txresetdone      : STD_LOGIC;
  end record single_C2C_Monitor_t;
  type C2C_Monitor_t_ARRAY is array (1 to 2) of single_C2C_Monitor_t;
  type C2C_Monitor_t is record
    CM : C2C_Monitor_t_ARRAY;
  end record C2C_Monitor_t;
  
  --Array C2C_Control_t
  type single_C2C_Control_t is record
    aurora_pma_init_in : std_logic;
    --debug
    eyescanreset     : STD_LOGIC;
    eyescantrigger   : STD_LOGIC;
    rxbufreset       : STD_LOGIC;  
    rxcdrhold        : STD_LOGIC;
    rxdfeagchold     : STD_LOGIC;
    rxdfeagcovrden   : STD_LOGIC;
    rxdfelfhold      : STD_LOGIC;
    rxdfelpmreset    : STD_LOGIC;
    rxlpmen          : STD_LOGIC;
    rxlpmhfovrden    : STD_LOGIC;
    rxlpmlfklovrden  : STD_LOGIC;
    rxmonitorsel     : STD_LOGIC_VECTOR ( 1 downto 0 );
    rxpcsreset       : STD_LOGIC;
    rxpmareset       : STD_LOGIC;
    rxprbscntreset   : STD_LOGIC;
    rxprbssel        : STD_LOGIC_VECTOR ( 2 downto 0 );
    txdiffctrl       : STD_LOGIC_VECTOR ( 3 downto 0 );
    txinhibit        : STD_LOGIC;
    txmaincursor     : STD_LOGIC_VECTOR ( 6 downto 0 );
    txpcsreset       : STD_LOGIC;
    txpmareset       : STD_LOGIC;
    txpolarity       : STD_LOGIC;
    txpostcursor     : STD_LOGIC_VECTOR ( 4 downto 0 );
    txprbsforceerr   : STD_LOGIC;
    txprbssel        : STD_LOGIC_VECTOR ( 2 downto 0 );
    txprecursor      : STD_LOGIC_VECTOR ( 4 downto 0 );
  end record single_C2C_Control_t;
  constant DEFAULT_single_C2C_Control_t : single_C2C_Control_t := (
    aurora_pma_init_in => '0',
    eyescanreset     => '0',
    eyescantrigger   => '0',
    rxbufreset       => '0',
    rxcdrhold        => '0',
    rxdfeagchold     => '0',
    rxdfeagcovrden   => '0',
    rxdfelfhold      => '0',
    rxdfelpmreset    => '0',
    rxlpmen          => '0',
    rxlpmhfovrden    => '0',
    rxlpmlfklovrden  => '0',
    rxmonitorsel     => "00",
    rxpcsreset       => '0',
    rxpmareset       => '0',
    rxprbscntreset   => '0',
    rxprbssel        => "000",
    txdiffctrl       => "0000",
    txinhibit        => '0',
    txmaincursor     => "0000000",
    txpcsreset       => '0',
    txpmareset       => '0',
    txpolarity       => '0',
    txpostcursor     => "00000",
    txprbsforceerr   => '0',
    txprbssel        => "000",
    txprecursor      => "000"
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
