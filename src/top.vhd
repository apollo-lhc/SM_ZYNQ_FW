library ieee;
use ieee.std_logic_1164.all;

use work.AXIRegPKG.all;

entity top is
  port (
    DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n         : inout STD_LOGIC;
    DDR_ck_n          : inout STD_LOGIC;
    DDR_ck_p          : inout STD_LOGIC;
    DDR_cke           : inout STD_LOGIC;
    DDR_cs_n          : inout STD_LOGIC;
    DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt           : inout STD_LOGIC;
    DDR_ras_n         : inout STD_LOGIC;
    DDR_reset_n       : inout STD_LOGIC;
    DDR_we_n          : inout STD_LOGIC;
    FIXED_IO_ddr_vrn  : inout STD_LOGIC;
    FIXED_IO_ddr_vrp  : inout STD_LOGIC;
    FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk   : inout STD_LOGIC;
    FIXED_IO_ps_porb  : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    clk_in            : in    std_logic;
    XVC0_tck          : out   STD_LOGIC;
    XVC0_tdi          : out   STD_LOGIC;
    XVC0_tdo          : in    STD_LOGIC;
    XVC0_tms          : out   STD_LOGIC;
    XVC1_tck          : out   STD_LOGIC;
    XVC1_tdi          : out   STD_LOGIC;
    XVC1_tdo          : in    STD_LOGIC;
    XVC1_tms          : out   STD_LOGIC;

    -------------------------------------------------------------------------------------------
    -- MGBT 1
    -------------------------------------------------------------------------------------------
    AXI_C2C_Rx_P      : in    std_logic_vector(0 downto 0);
    AXI_C2C_Rx_N      : in    std_logic_vector(0 downto 0);
    AXI_C2C_Tx_P      : out   std_logic_vector(0 downto 0);
    AXI_C2C_Tx_N      : out   std_logic_vector(0 downto 0);

    refclk_C2C_P      : in    std_logic_vector(0 downto 0);
    refclk_C2C_N      : in    std_logic_vector(0 downto 0);

    
    -------------------------------------------------------------------------------------------
    -- MGBT 2
    -------------------------------------------------------------------------------------------
    refclk_125Mhz_P   : in    std_logic; 
    refclk_125Mhz_N   : in    std_logic; 
    refclk_TCDS_P     : in    std_logic; 
    refclk_TCDS_N     : in    std_logic; 
                              
    sgmii_tx_P        : out   std_logic; 
    sgmii_tx_N        : out   std_logic; 
    sgmii_rx_P        : in    std_logic; 
    sgmii_rx_N        : in    std_logic; 
                              
    tts_P             : out   std_logic; 
    tts_N             : out   std_logic; 
    ttc_P             : in    std_logic; 
    ttc_N             : in    std_logic; 
                              
    fake_ttc_P        : out   std_logic; 
    fake_ttc_N        : out   std_logic; 
    m1_tts_P          : in    std_logic; 
    m1_tts_N          : in    std_logic;                       
    m2_tts_P          : in    std_logic; 
    m2_tts_N          : in    std_logic


    );    
end entity top;

architecture structure of top is

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

  signal pl_clk : std_logic;
  signal axi_reset_n : std_logic;
  signal axi_reset : std_logic;
  signal readMOSI  : AXIReadMOSI;
  signal readMISO  : AXIReadMISO;
  signal writeMOSI : AXIWriteMOSI;
  signal writeMISO : AXIWriteMISO;

  signal pl_reset_n : std_logic;
  
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
  
  signal ENET1_EXT_INTIN_0     :  STD_LOGIC;
  signal GMII_ETHERNET_col     :  STD_LOGIC;
  signal GMII_ETHERNET_crs     :  STD_LOGIC;
  signal GMII_ETHERNET_rx_clk  :  STD_LOGIC;
  signal GMII_ETHERNET_rx_dv   :  STD_LOGIC;
  signal GMII_ETHERNET_rx_er   :  STD_LOGIC;
  signal GMII_ETHERNET_rxd     :  STD_LOGIC_VECTOR ( 7 downto 0 );
  signal GMII_ETHERNET_tx_clk  :  STD_LOGIC;
  signal GMII_ETHERNET_tx_en   :  STD_LOGIC_VECTOR ( 0 to 0 );
  signal GMII_ETHERNET_tx_er   :  STD_LOGIC_VECTOR ( 0 to 0 );
  signal GMII_ETHERNET_txd     :  STD_LOGIC_VECTOR ( 7 downto 0 );
  signal MDIO_ETHERNET_mdc     :  std_logic;
  signal MDIO_ETHERNET_mdio_i  :  std_logic;
  signal MDIO_ETHERNET_mdio_o  :  std_logic;



----- TCDS
  signal reset_MGBT2 : std_logic;
  signal clk_gt_qpllout : std_logic;
  signal refclk_gt_qpllout : std_logic;

  signal refclk_TCDS : std_logic;
  signal ttc_data : std_logic_vector(35 downto 0); 
  signal tts_data : std_logic_vector(35 downto 0); 
  signal fake_ttc_data : std_logic_vector(35 downto 0);
  signal m1_tts_data : std_logic_vector(35 downto 0);
  signal m2_tts_data : std_logic_vector(35 downto 0);
  signal ttc_dv : std_logic; 
  signal tts_dv : std_logic; 
  signal fake_ttc_dv : std_logic;
  signal m1_tts_dv : std_logic;
  signal m2_tts_dv : std_logic;


  -- AXI C2C
  signal AXI_C2CM1_RX_data              : STD_LOGIC_VECTOR (63 downto 0 );
  signal AXI_C2CM1_RX_dv                : STD_LOGIC;                          
  signal AXI_C2CM1_TX_data              : STD_LOGIC_VECTOR (63 downto 0 );
  signal AXI_C2CM1_TX_ready             : STD_LOGIC;                       
  signal AXI_C2CM1_TX_dv                : STD_LOGIC;                         
  signal AXI_C2C_aurora_init_clk        : STD_LOGIC;                  
  signal AXI_C2C_aurora_mmcm_not_locked : STD_LOGIC;           
  signal AXI_C2C_aurora_pma_init_out    : STD_LOGIC;             
  signal AXI_C2C_reset                  : STD_LOGIC;                           
  signal AXI_C2CM1_channel_up           : STD_LOGIC;                     
  signal AXI_C2CM1_phy_clk              : STD_LOGIC;                        
  signal AXI_C2CM1_phy_clk_raw          : std_logic;
  
  signal refclk_C2C        : std_logic;
  
  signal AXI_C2C_ReadMOSI  : AXIReadMOSI_array_t(0 to 0);
  signal AXI_C2C_ReadMISO  : AXIReadMISO_array_t(0 to 0);
  signal AXI_C2C_WriteMOSI : AXIWriteMOSI_array_t(0 to 0);
  signal AXI_C2C_WriteMISO : AXIWriteMISO_array_t(0 to 0);
  
  

  
begin  -- architecture structure

  pl_reset_n <= axi_reset_n ;
  zynq_bd_wrapper_1: entity work.zynq_bd_wrapper
    port map (
      AXI_RST_N(0)         => axi_reset_n,
      AXI_CLK              => pl_clk,
      DDR_addr             => DDR_addr,
      DDR_ba               => DDR_ba,
      DDR_cas_n            => DDR_cas_n,
      DDR_ck_n             => DDR_ck_n,
      DDR_ck_p             => DDR_ck_p,
      DDR_cke              => DDR_cke,
      DDR_cs_n             => DDR_cs_n,
      DDR_dm               => DDR_dm,
      DDR_dq               => DDR_dq,
      DDR_dqs_n            => DDR_dqs_n,
      DDR_dqs_p            => DDR_dqs_p,
      DDR_odt              => DDR_odt,
      DDR_ras_n            => DDR_ras_n,
      DDR_reset_n          => DDR_reset_n,
      DDR_we_n             => DDR_we_n,
      FIXED_IO_ddr_vrn     => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp     => FIXED_IO_ddr_vrp,
      FIXED_IO_mio         => FIXED_IO_mio,
      FIXED_IO_ps_clk      => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb     => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb    => FIXED_IO_ps_srstb,
      ENET1_EXT_INTIN_0         => ENET1_EXT_INTIN_0         ,
      GMII_ETHERNET_1_0_col     => GMII_ETHERNET_col     ,
      GMII_ETHERNET_1_0_crs     => GMII_ETHERNET_crs     ,
      GMII_ETHERNET_1_0_rx_clk  => GMII_ETHERNET_rx_clk  ,
      GMII_ETHERNET_1_0_rx_dv   => GMII_ETHERNET_rx_dv   ,
      GMII_ETHERNET_1_0_rx_er   => GMII_ETHERNET_rx_er   ,
      GMII_ETHERNET_1_0_rxd     => GMII_ETHERNET_rxd     ,
      GMII_ETHERNET_1_0_tx_clk  => GMII_ETHERNET_tx_clk  ,
      GMII_ETHERNET_1_0_tx_en   => GMII_ETHERNET_tx_en   ,
      GMII_ETHERNET_1_0_tx_er   => GMII_ETHERNET_tx_er   ,
      GMII_ETHERNET_1_0_txd     => GMII_ETHERNET_txd     ,
      ENET1_MDIO_MDC_0          => MDIO_ETHERNET_mdc     ,
      ENET1_MDIO_I_0            => MDIO_ETHERNET_mdio_i  ,
      ENET1_MDIO_O_0            => MDIO_ETHERNET_mdio_o  ,
--      PL_CLK                    => pl_clk,
--      PL_RESET_N                => pl_reset_n,
      tap_tck_0                 => XVC0_tck,
      tap_tdi_0                 => XVC0_tdi,
      tap_tdo_0                 => XVC0_tdo,
      tap_tms_0                 => XVC0_tms,
      tap_tck_1                 => XVC1_tck,
      tap_tdi_1                 => XVC1_tdi,
      tap_tdo_1                 => XVC1_tdo,
      tap_tms_1                 => XVC1_tms,

      AXIS_RX_0_tdata             => AXI_C2CM1_RX_data(63 downto 0),
      AXIS_RX_0_tvalid            => AXI_C2CM1_RX_dv,
      AXIS_TX_0_tdata             => AXI_C2CM1_TX_data(63 downto 0),
      AXIS_TX_0_tready            => AXI_C2CM1_TX_ready,
      AXIS_TX_0_tvalid            => AXI_C2CM1_TX_dv,
      aurora_init_clk_0           => AXI_C2C_aurora_init_clk,
      aurora_mmcm_not_locked_0    => AXI_C2C_aurora_mmcm_not_locked,
      aurora_pma_init_out_0       => AXI_C2C_aurora_pma_init_out,
      aurora_reset_pb_0           => AXI_C2C_reset,
      axi_c2c_aurora_channel_up_0 => AXI_C2CM1_channel_up,
      axi_c2c_phy_clk_0           => AXI_C2CM1_phy_clk,
      PL_CLK                      => pl_clk,
      PL_RESET_N                  => pl_reset_n,
      C2C1_GT_awaddr              => AXI_C2C_WriteMOSI(0).address,
      C2C1_GT_rresp               => AXI_C2C_ReadMISO(0).response,
      C2C1_GT_bresp               => AXI_C2C_WriteMISO(0).response,
      C2C1_GT_wstrb               => AXI_C2C_WriteMOSI(0).data_write_strobe,
      C2C1_GT_wdata               => AXI_C2C_WriteMOSI(0).data,
      C2C1_GT_araddr              => AXI_C2C_ReadMOSI(0).address,
      C2C1_GT_rdata               => AXI_C2C_ReadMISO(0).data,
      C2C1_GT_bready              => AXI_C2C_WriteMOSI(0).ready_for_response,
      C2C1_GT_awvalid             => AXI_C2C_WriteMOSI(0).address_valid,
      C2C1_GT_awready             => AXI_C2C_WriteMISO(0).ready_for_address,
      C2C1_GT_wvalid              => AXI_C2C_WriteMOSI(0).data_valid,
      C2C1_GT_wready              => AXI_C2C_WriteMISO(0).ready_for_data,
      C2C1_GT_bvalid              => AXI_C2C_WriteMISO(0).response_valid,
      C2C1_GT_arvalid             => AXI_C2C_ReadMOSI(0).address_valid,
      C2C1_GT_arready             => AXI_C2C_ReadMISO(0).ready_for_address,
      C2C1_GT_rvalid              => AXI_C2C_ReadMISO(0).data_valid,
      C2C1_GT_rready              => AXI_C2C_ReadMOSI(0).ready_for_data
      );


  
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

   core_resets_i : entity work.SGMII_INTF_resets
   port map (
      reset                     => '0', 
      independent_clock_bufg    => pl_clk,
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
      resetdone              => open, --monitor?
      cplllock               => open, --monitor?
      mmcm_reset             => reset_SGMII_MMCM,
      txoutclk               => clk_SGMII_tx,
      rxoutclk               => clk_SGMII_rx,
      userclk                => clk_user_SGMII,
      userclk2               => clk_user2_SGMII,
      rxuserclk              => clk_rxuser_SGMII,
      rxuserclk2             => clk_rxuser2_SGMII,
      pma_reset              => reset_pma_SGMII,
      mmcm_locked            => reset_SGMII_MMCM,
      independent_clock_bufg => pl_clk,
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
      status_vector          => open,
      reset                  => '0',     -- from example
      signal_detect          => '1',     -- from example
      gt0_qplloutclk_in      => clk_gt_qpllout,
      gt0_qplloutrefclk_in   => refclk_gt_qpllout);
  


  TCDS_1: entity work.TCDS   
    port map ( 
      sysclk => pl_clk,  
      GT0_QPLLOUTCLK_IN    => clk_gt_qpllout,
      GT0_QPLLOUTREFCLK_IN => refclk_gt_qpllout,
--      refclk => refclk_TCDS,
      refclk => refclk_125Mhz_IBUFG, 
      reset  => reset_MGBT2, 
      tx_P(0)=> tts_P,
      tx_P(1)=> fake_ttc_P,  
      tx_P(2)=> open, 
      tx_N(0)=> tts_N,
      tx_N(1)=> fake_ttc_N,  
      tx_N(2)=> open, 
      rx_P(0)=> ttc_P,
      rx_P(1)=> m1_tts_P,    
      rx_P(2)=> m2_tts_P,    
      rx_N(0)=> ttc_N,
      rx_N(1)=> m1_tts_N,    
      rx_N(2)=> m2_tts_N,    
      clk_txusr     => open,--clk_txusr,   
      clk_rxusr     => open,--clk_rxusr,   
      ttc_data      => ttc_data,    
      ttc_dv => ttc_dv,      
      tts_data      => tts_data,    
      tts_dv => tts_dv,      
      fake_ttc_data => fake_ttc_data,      
      fake_ttc_dv   => fake_ttc_dv, 
      m1_tts_data   => m1_tts_data, 
      m1_tts_dv     => m1_tts_dv,   
      m2_tts_data   => m2_tts_data, 
      m2_tts_dv     => m2_tts_dv);

  tts_data <= m1_tts_data or m2_tts_data;
  tts_dv <= m1_tts_dv and m2_tts_dv; 
  
  fake_ttc_data <= ttc_data; 
  fake_ttc_dv <= ttc_dv; 


--  --IBUFDS_GTE2
--  ibufds_instq3_clk1 : IBUFDS_GTE2 
--    port map 
--    (
--      O => refclk_TCDS,
--      ODIV2 => open, 
--      CEB => '0',
--      I => refclk_TCDS_P,
--      IB=> refclk_TCDS_N 
--      ); 
  
  MGBT2_common_reset_1: entity work.MGBT2_common_reset 
    generic map (
      STABLE_CLOCK_PERIOD => 16) 
    port map ( 
      STABLE_CLOCK => pl_clk, 
      SOFT_RESET => '0', 
      COMMON_RESET => reset_MGBT2);
  MGBT2_common_1: entity work.MGBT2_common 
    port map ( 
      QPLLREFCLKSEL_IN => "001",
      GTREFCLK1_IN => '0', 
      GTREFCLK0_IN => refclk_125Mhz_IBUFG, 
      QPLLLOCK_OUT => open,
      QPLLLOCKDETCLK_IN=> pl_clk, 
      QPLLOUTCLK_OUT   => clk_gt_qpllout, 
      QPLLOUTREFCLK_OUT=> refclk_gt_qpllout, 
      QPLLREFCLKLOST_OUT => open,
      QPLLRESET_IN => reset_MGBT2);




  AXI_C2C_aurora_init_clk <= pl_clk;

  user_clk_bufg : bufg
    port map (
    i => AXI_C2CM1_phy_clk_raw,
    o => AXI_C2CM1_phy_clk);
  
  aurora_64b66b_0_2: entity work.aurora_64b66b_0
    port map (
      gt_refclk1_p            => refclk_C2C_P(0),
      gt_refclk1_n            => refclk_C2C_N(0),
      gt_refclk1_out          => refclk_C2C,
      hard_err                => open,
      soft_err                => open,
      channel_up              => AXI_C2CM1_channel_up,
      lane_up                 => open,
      user_clk_out            => open,
      mmcm_not_locked_out     => AXI_C2C_aurora_mmcm_not_locked,
      sync_clk_out            => open,
      reset_pb                => AXI_C2C_reset,
      gt_rxcdrovrden_in       => '0',
      power_down              => '0',
      loopback                => "000",
      pma_init                => AXI_C2C_aurora_pma_init_out,
      gt_pll_lock             => open,
      drp_clk_in              => AXI_C2C_aurora_init_clk,
      init_clk                => AXI_C2C_aurora_init_clk,
      link_reset_out          => open,
      gt_qpllclk_quad4_out    => open,
      gt_qpllrefclk_quad4_out => open,
      sys_reset_out           => open,
      gt_reset_out            => open,
      tx_out_clk              => AXI_C2CM1_phy_clk_raw,

      rxp                    => AXI_C2C_Rx_P(0 downto 0),
      rxn                    => AXI_C2C_Rx_N(0 downto 0),
      txp                    => AXI_C2C_Tx_P(0 downto 0),
      txn                    => AXI_C2C_Tx_N(0 downto 0),

      s_axi_tx_tdata          => AXI_C2CM1_TX_data,
--      s_axi_tx_tlast          => s_axi_tx_tlast,
--      s_axi_tx_tkeep          => s_axi_tx_tkeep,
      s_axi_tx_tvalid         => AXI_C2CM1_TX_dv,
      s_axi_tx_tready         => AXI_C2CM1_TX_ready,
      m_axi_rx_tdata          => AXI_C2CM1_RX_data,
--      m_axi_rx_tlast          => m_axi_rx_tlast,
--      m_axi_rx_tkeep          => m_axi_rx_tkeep,
      m_axi_rx_tvalid         => AXI_C2CM1_RX_dv,


      s_axi_awaddr           => AXI_C2C_WriteMOSI(0).address,
      s_axi_rresp            => AXI_C2C_ReadMISO(0).response,
      s_axi_bresp            => AXI_C2C_WriteMISO(0).response,
      s_axi_wstrb            => AXI_C2C_WriteMOSI(0).data_write_strobe,
      s_axi_wdata            => AXI_C2C_WriteMOSI(0).data,
      s_axi_araddr           => AXI_C2C_ReadMOSI(0).address,
      s_axi_rdata            => AXI_C2C_ReadMISO(0).data,
      s_axi_bready           => AXI_C2C_WriteMOSI(0).ready_for_response,
      s_axi_awvalid          => AXI_C2C_WriteMOSI(0).address_valid,
      s_axi_awready          => AXI_C2C_WriteMISO(0).ready_for_address,
      s_axi_wvalid           => AXI_C2C_WriteMOSI(0).data_valid,
      s_axi_wready           => AXI_C2C_WriteMISO(0).ready_for_data,
      s_axi_bvalid           => AXI_C2C_WriteMISO(0).response_valid,
      s_axi_arvalid          => AXI_C2C_ReadMOSI(0).address_valid,
      s_axi_arready          => AXI_C2C_ReadMISO(0).ready_for_address,
      s_axi_rvalid           => AXI_C2C_ReadMISO(0).data_valid,
      s_axi_rready           => AXI_C2C_ReadMOSI(0).ready_for_data

      );

  
  
end architecture structure;
