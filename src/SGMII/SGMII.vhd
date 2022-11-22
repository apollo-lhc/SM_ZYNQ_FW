library ieee;
use ieee.std_logic_1164.all;

use work.SGMII_MONITOR.all;


entity SGMII is
  
  port (
    sys_clk           : in    std_logic;
    refclk_125Mhz_P   : in    std_logic; 
    refclk_125Mhz_N   : in    std_logic; 

    sgmii_tx_P        : out   std_logic; 
    sgmii_tx_N        : out   std_logic; 
    sgmii_rx_P        : in    std_logic; 
    sgmii_rx_N        : in    std_logic;

    QPLL_CLK             : out std_logic;
    QPLL_REF_CLK         : out std_logic;

    ENET1_EXT_INTIN_0     : out STD_LOGIC;
    GMII_ETHERNET_col     : out STD_LOGIC;
    GMII_ETHERNET_crs     : out STD_LOGIC;
    GMII_ETHERNET_rx_clk  : out STD_LOGIC;
    GMII_ETHERNET_rx_dv   : out STD_LOGIC;
    GMII_ETHERNET_rx_er   : out STD_LOGIC;
    GMII_ETHERNET_rxd     : out STD_LOGIC_VECTOR ( 7 downto 0 );
    GMII_ETHERNET_tx_clk  : out STD_LOGIC;
    GMII_ETHERNET_tx_en   : in  STD_LOGIC_VECTOR ( 0 to 0 );
    GMII_ETHERNET_tx_er   : in  STD_LOGIC_VECTOR ( 0 to 0 );
    GMII_ETHERNET_txd     : in  STD_LOGIC_VECTOR ( 7 downto 0 );
    MDIO_ETHERNET_mdc     : in  std_logic;
    MDIO_ETHERNET_mdio_i  : out std_logic;
    MDIO_ETHERNET_mdio_o  : in  std_logic;
    SGMII_MON  : out SGMII_Monitor_t;
    SGMII_CTRL : in  SGMII_Control_t);

end entity SGMII;

architecture behavioral of SGMII is
  component SGMII_INTF is
    port (
      gtrefclk_bufg          : IN  STD_LOGIC;
      gtrefclk               : IN  STD_LOGIC;
      txn                    : OUT STD_LOGIC;
      txp                    : OUT STD_LOGIC;
      rxn                    : IN  STD_LOGIC;
      rxp                    : IN  STD_LOGIC;
      independent_clock_bufg : IN  STD_LOGIC;
      txoutclk               : OUT STD_LOGIC;
      rxoutclk               : OUT STD_LOGIC;
      resetdone              : OUT STD_LOGIC;
      cplllock               : OUT STD_LOGIC;
      mmcm_reset             : OUT STD_LOGIC;
      userclk                : IN  STD_LOGIC;
      userclk2               : IN  STD_LOGIC;
      pma_reset              : IN  STD_LOGIC;
      mmcm_locked            : IN  STD_LOGIC;
      rxuserclk              : IN  STD_LOGIC;
      rxuserclk2             : IN  STD_LOGIC;
      sgmii_clk_r            : OUT STD_LOGIC;
      sgmii_clk_f            : OUT STD_LOGIC;
      gmii_txclk             : OUT STD_LOGIC;
      gmii_rxclk             : OUT STD_LOGIC;
      gmii_txd               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      gmii_tx_en             : IN  STD_LOGIC;
      gmii_tx_er             : IN  STD_LOGIC;
      gmii_rxd               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gmii_rx_dv             : OUT STD_LOGIC;
      gmii_rx_er             : OUT STD_LOGIC;
      gmii_isolate           : OUT STD_LOGIC;
      mdc                    : IN  STD_LOGIC;
      mdio_i                 : IN  STD_LOGIC;
      mdio_o                 : OUT STD_LOGIC;
      mdio_t                 : OUT STD_LOGIC;
      phyaddr                : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      configuration_vector   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      configuration_valid    : IN  STD_LOGIC;
      an_interrupt           : OUT STD_LOGIC;
      an_adv_config_vector   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      an_adv_config_val      : IN  STD_LOGIC;
      an_restart_config      : IN  STD_LOGIC;
      status_vector          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      reset                  : IN  STD_LOGIC;
      signal_detect          : IN  STD_LOGIC;
      gt0_qplloutclk_in      : IN  STD_LOGIC;
      gt0_qplloutrefclk_in   : IN  STD_LOGIC);
  end component SGMII_INTF;

  --SGMII interface
  signal clk_SGMII_tx          :  std_logic;
  signal clk_SGMII_rx          :  std_logic;
  signal reset_MMCM            :  std_logic;
  signal reset_SGMII_MMCM      :  std_logic;
  signal reset_pma_SGMII       :  std_logic;
  signal locked_sgmii_mmcm     :  std_logic;
  signal refclk_125Mhz_IBUFG   :  std_logic;
  signal clk_125Mhz            :  std_logic;
  signal clk_user_SGMII        :  std_logic;
  signal clk_user2_SGMII       :  std_logic;
  signal clk_rxuser_SGMII      :  std_logic;
  signal clk_rxuser2_SGMII     :  std_logic; 

  signal clk_gt_qpllout : std_logic;
  signal refclk_gt_qpllout : std_logic;
  signal reset_MGBT2 : std_logic;
  
begin  -- architecture behavioral

 MGBT2_common_reset_1: entity work.MGBT2_common_reset 
   generic map (
     STABLE_CLOCK_PERIOD => 16) 
   port map ( 
     STABLE_CLOCK => sys_clk, 
     SOFT_RESET => '0', 
     COMMON_RESET => reset_MGBT2);
 MGBT2_common_1: entity work.MGBT2_common 
   port map ( 
     QPLLREFCLKSEL_IN => "001",
     GTREFCLK1_IN => '0', 
     GTREFCLK0_IN => refclk_125Mhz_IBUFG, 
     QPLLLOCK_OUT => open,
     QPLLLOCKDETCLK_IN=> sys_clk, 
     QPLLOUTCLK_OUT   => clk_gt_qpllout, 
     QPLLOUTREFCLK_OUT=> refclk_gt_qpllout, 
     QPLLREFCLKLOST_OUT => open,
     QPLLRESET_IN => reset_MGBT2);

 QPLL_CLK      <= clk_gt_qpllout;
 QPLL_REF_CLK  <= refclk_gt_qpllout;

 
 
  SGMII_MON.mmcm_reset <= reset_SGMII_MMCM;
  SGMII_MON.mmcm_locked <= locked_SGMII_MMCM;
  SGMII_INTF_clocking_1 : entity work.SGMII_INTF_clocking
    port map(
      gtrefclk_p                 => refclk_125Mhz_P,
      gtrefclk_n                 => refclk_125Mhz_N,
      txoutclk                   => clk_SGMII_tx,
      rxoutclk                   => clk_SGMII_rx,
      mmcm_reset                 => reset_SGMII_MMCM,
      gtrefclk                   => refclk_125Mhz_IBUFG,
      gtrefclk_bufg              => clk_125Mhz, --refclk_125Mhz via BUFG
      mmcm_locked                => locked_SGMII_MMCM,
      userclk                    => clk_user_SGMII,
      userclk2                   => clk_user2_SGMII,
      rxuserclk                  => clk_rxuser_SGMII,
      rxuserclk2                 => clk_rxuser2_SGMII
      );

  SGMII_MON.reset <= SGMII_CTRL.reset;
  SGMII_MON.pma_reset <= reset_pma_SGMII;
  core_resets_i : entity work.SGMII_INTF_resets
    port map (
      reset                     => SGMII_CTRL.reset, 
      independent_clock_bufg    => sys_clk,
      pma_reset                 => reset_pma_SGMII
      );
  
  SGMII_INTF_1: entity work.SGMII_INTF
    port map (
      gtrefclk               => refclk_125Mhz_IBUFG,
      gtrefclk_bufg          => clk_125Mhz,
      txp                    => sgmii_tx_P,
      txn                    => sgmii_tx_N,
      rxp                    => sgmii_rx_P,
      rxn                    => sgmii_rx_N,
      resetdone              => SGMII_MON.reset_done,--open, --monitor?
      cplllock               => SGMII_MON.cpll_lock,--open, --monitor?
      mmcm_reset             => reset_SGMII_MMCM,
      txoutclk               => clk_SGMII_tx,
      rxoutclk               => clk_SGMII_rx,
      userclk                => clk_user_SGMII,
      userclk2               => clk_user2_SGMII,
      rxuserclk              => clk_rxuser_SGMII,
      rxuserclk2             => clk_rxuser2_SGMII,
      pma_reset              => reset_pma_SGMII,
      mmcm_locked            => locked_SGMII_MMCM,--reset_SGMII_MMCM,
      independent_clock_bufg => sys_clk,
      sgmii_clk_r            => open,   -- from example
      sgmii_clk_f            => open,   -- from example
      gmii_txclk             => GMII_ETHERNET_tx_clk,
      gmii_rxclk             => GMII_ETHERNET_rx_clk,
      gmii_txd               => GMII_ETHERNET_txd,
      gmii_tx_en             => GMII_ETHERNET_tx_en(0),
      gmii_tx_er             => GMII_ETHERNET_tx_er(0),
      gmii_rxd               => GMII_ETHERNET_rxd,
      gmii_rx_dv             => GMII_ETHERNET_rx_dv,
      gmii_rx_er             => GMII_ETHERNET_rx_er,
      gmii_isolate           => open,
      mdc                    => MDIO_ETHERNET_mdc,
      mdio_i                 => MDIO_ETHERNET_mdio_o, --swap for zynq
      mdio_o                 => MDIO_ETHERNET_mdio_i, --swap for zynq
      mdio_t                 => open,
      phyaddr                => "01001", -- from example
      configuration_vector   => "00000", -- from example
      configuration_valid    => '0',     -- from example
      an_interrupt           => open,    -- from example
      an_adv_config_vector   => x"D801", -- from example
      an_adv_config_val      => '0',     -- from example
      an_restart_config      => '0',     -- from example
      status_vector          => SGMII_MON.status_vector,--open,
      reset                  => '0',     -- from example
      signal_detect          => '1',     -- from example
      gt0_qplloutclk_in      => clk_gt_qpllout,
      gt0_qplloutrefclk_in   => refclk_gt_qpllout);

  

end architecture behavioral;
