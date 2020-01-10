library ieee;
use ieee.std_logic_1164.all;
use work.types.all;
use work.AXIRegPKG.all;

entity TCDS is
  
  port (
    clk_axi              : in  std_logic;
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO;
    refclk_p             : in  std_logic;
    refclk_n             : in  std_logic;
    QPLL_CLK             : in  std_logic;
    QPLL_REF_CLK         : in  std_logic;
    reset                : in  std_logic;
    tx_P                 : out std_logic_vector(2 downto 0);
    tx_N                 : out std_logic_vector(2 downto 0);
    rx_P                 : in  std_logic_vector(2 downto 0);
    rx_N                 : in  std_logic_vector(2 downto 0);
    clk_txusr            : out std_logic_vector(2 downto 0);
    clk_rxusr            : out std_logic_vector(2 downto 0);
    ttc_data             : out std_logic_vector(35 downto 0);
    ttc_dv               : out std_logic;
    tts_data             : in  std_logic_vector(35 downto 0);
    tts_dv               : in  std_logic;
    fake_ttc_data        : in  std_logic_vector(35 downto 0);
    fake_ttc_dv          : in  std_logic;
    m1_tts_data          : out std_logic_vector(35 downto 0);
    m1_tts_dv            : out std_logic;
    m2_tts_data          : out std_logic_vector(35 downto 0);
    m2_tts_dv            : out std_logic
    );  
end entity TCDS;

architecture Behavioral of TCDS is

  type slv32_array_t is array (integer range <>) of std_logic_vector(31 downto 0);
  type slv4_array_t  is array (integer range <>) of std_logic_vector(3  downto 0);
  signal tx_data : slv32_array_t(0 to 2);
  signal rx_data : slv32_array_t(0 to 2);
  signal tx_kdata : slv4_array_t(0 to 2);
  signal rx_kdata : slv4_array_t(0 to 2);
  signal tx_dv : std_logic_vector(2 downto 0);
  signal rx_dv : std_logic_vector(2 downto 0);

  type GT_Mon_t is record
    cpllfbclklost    : std_logic;
    cplllock         : std_logic;     
    dmonitorout      : slv_8_t;
    eyescandataerror : std_logic;
    rxprbserr        : STD_LOGIC;
    rxdisperr        : slv_4_t;
    rxnotintable     : slv_4_t;
    rxmonitorout     : slv_7_t;
    rxoutclkfabric   : std_logic;
    rxresetdone      : std_logic;  
    txoutclkfabric   : std_logic;
    txoutclkpcs      : std_logic;
    txresetdone      : std_logic;  
  end record GT_Mon_t;
  type GT_Mon_array_t is array (integer range <>) of GT_Mon_t;
  signal gt_mon : GT_Mon_array_t(2 downto 0);  
  
  type GT_Ctrl_t is record
    cpllreset         : std_logic;   
    eyescanreset      : std_logic;
    rxuserrdy         : std_logic;   
    loopback          : slv_3_t;
    eyescantrigger    : std_logic;
    rxprbssel         : slv_3_t;
    rxprbscntreset    : STD_LOGIC;
    rxdfelpmreset     : std_logic;
    rxmonitorsel      : slv_2_t;
    gtrxreset         : std_logic;
    rxpmareset        : std_logic;
    gttxreset         : std_logic;   
    txuserrdy         : std_logic;
    txinhibit         : std_logic;
  end record GT_Ctrl_t;  
  constant DEFAULT_GT_Ctrl_t : GT_Ctrl_t := (
                                             cpllreset      => '0',
                                             eyescanreset   => '0',
                                             rxuserrdy      => '1',
                                             loopback       => "000",
                                             eyescantrigger => '0',
                                             rxprbssel      => "000",
                                             rxprbscntreset => '1',
                                             rxdfelpmreset  => '0',
                                             rxmonitorsel   => "00",
                                             gtrxreset      => '0',
                                             rxpmareset     => '0',
                                             gttxreset      => '0',
                                             txuserrdy      => '1',
                                             txinhibit      => '0'
  );
  type GT_Ctrl_array_t is array (integer range <>) of GT_Ctrl_t;  
  signal gt_ctrl : GT_Ctrl_array_t(2 downto 0) := (others => DEFAULT_GT_Ctrl_t);

  type DRP_t is record
    en   : STD_LOGIC;
    we   : STD_LOGIC;
    addr : STD_LOGIC_VECTOR ( 8 downto 0 );
    di   : STD_LOGIC_VECTOR ( 15 downto 0 );
    do   : STD_LOGIC_VECTOR ( 15 downto 0 );
    rdy  : STD_LOGIC;
  end record DRP_t;
  type DRP_array_t is array (integer range <>) of DRP_t;
  signal drp_intf : DRP_array_t(0 to 2);

  
  signal tx_reset_done : slv_3_t;
  signal rx_reset_done : slv_3_t;

  signal refclk : std_logic;
  
  signal tx_user_clk : slv_3_t;
  signal tx_user_clk2 : slv_3_t;
  signal tx_clk : slv_3_t;
  signal rx_user_clk : slv_3_t;
  signal rx_user_clk2 : slv_3_t;
  
begin  -- architecture Behavioral


  tx_data (0)            <= tts_data(31 downto  0);
  tx_kdata(0)            <= tts_data(35 downto 32);
  tx_dv(0)               <= tts_dv;
  ttc_data(31 downto  0) <= rx_data (0);
  ttc_data(35 downto 32) <= rx_kdata(0);
  ttc_dv                 <= rx_dv(0);   
  
  tx_data (1) <= fake_ttc_data(31 downto  0);
  tx_kdata(1) <= fake_ttc_data(35 downto 32);
  tx_dv(1)    <= fake_ttc_dv;
  m1_tts_data(31 downto  0) <= rx_data (1);
  m1_tts_data(35 downto 32) <= rx_kdata(1);
  m1_tts_dv                 <= rx_dv(1);  
  
  tx_data (2) <= (others => '0');
  tx_kdata(2) <= (others => '0');
  tx_dv(2)    <= '0';
  m2_tts_data(31 downto  0) <= rx_data (2);
  m2_tts_data(35 downto 32) <= rx_kdata(2);
  m2_tts_dv                 <= rx_dv(2);   
  
  LHC_GT_USRCLK_SOURCE_1: entity work.LHC_GT_USRCLK_SOURCE
    port map (
      GT0_TXUSRCLK_OUT          => tx_user_clk(0),
      GT0_TXUSRCLK2_OUT         => tx_user_clk2(0),
      GT0_TXOUTCLK_IN           => tx_clk(0),
      GT0_RXUSRCLK_OUT          => rx_user_clk(0),
      GT0_RXUSRCLK2_OUT         => rx_user_clk2(0),
      GT1_TXUSRCLK_OUT          => tx_user_clk(1), 
      GT1_TXUSRCLK2_OUT         => tx_user_clk2(1),
      GT1_TXOUTCLK_IN           => tx_clk(1),      
      GT1_RXUSRCLK_OUT          => rx_user_clk(1), 
      GT1_RXUSRCLK2_OUT         => rx_user_clk2(1),
      GT2_TXUSRCLK_OUT          => tx_user_clk(2), 
      GT2_TXUSRCLK2_OUT         => tx_user_clk2(2),
      GT2_TXOUTCLK_IN           => tx_clk(2),      
      GT2_RXUSRCLK_OUT          => rx_user_clk(2), 
      GT2_RXUSRCLK2_OUT         => rx_user_clk2(2),
      Q2_CLK1_GTREFCLK_PAD_N_IN => refclk_N,
      Q2_CLK1_GTREFCLK_PAD_P_IN => refclk_P,
      Q2_CLK1_GTREFCLK_OUT      => refclk);
  

    LHC_2: entity work.LHC
      port map (
        SYSCLK_IN                   => clk_axi,
        SOFT_RESET_TX_IN            => reset,
        SOFT_RESET_RX_IN            => reset,
        DONT_RESET_ON_DATA_ERROR_IN => '0',
        GT0_TX_FSM_RESET_DONE_OUT   => tx_reset_done(0),
        GT0_RX_FSM_RESET_DONE_OUT   => rx_reset_done(0),
        GT0_DATA_VALID_IN           => tx_dv(0),        
        GT1_TX_FSM_RESET_DONE_OUT   => tx_reset_done(1),
        GT1_RX_FSM_RESET_DONE_OUT   => rx_reset_done(1),
        GT1_DATA_VALID_IN           => tx_dv(1),        
        GT2_TX_FSM_RESET_DONE_OUT   => tx_reset_done(2),
        GT2_RX_FSM_RESET_DONE_OUT   => rx_reset_done(2),
        GT2_DATA_VALID_IN           => tx_dv(2),        
        gt0_cpllfbclklost_out       => gt_mon(0).cpllfbclklost,         
        gt0_cplllock_out            => gt_mon(0).cplllock,
        gt0_cplllockdetclk_in       => clk_axi,
        gt0_cpllreset_in            => gt_ctrl(0).cpllreset,
        gt0_gtrefclk0_in            => '0',
        gt0_gtrefclk1_in            => refclk,
        gt0_drpaddr_in              => drp_intf(0).addr,
        gt0_drpclk_in               => clk_axi,
        gt0_drpdi_in                => drp_intf(0).di,
        gt0_drpdo_out               => drp_intf(0).do,
        gt0_drpen_in                => drp_intf(0).en,
        gt0_drprdy_out              => drp_intf(0).rdy,
        gt0_drpwe_in                => drp_intf(0).we,
        gt0_dmonitorout_out         => gt_mon(0).dmonitorout,
        gt0_loopback_in             => gt_ctrl(0).loopback,
        gt0_eyescanreset_in         => gt_ctrl(0).eyescanreset,
        gt0_rxuserrdy_in            => gt_ctrl(0).rxuserrdy,
        gt0_eyescandataerror_out    => gt_mon(0).eyescandataerror,
        gt0_eyescantrigger_in       => gt_ctrl(0).eyescantrigger, 
        gt0_rxusrclk_in             => rx_user_clk(0),
        gt0_rxusrclk2_in            => rx_user_clk2(0),
        gt0_rxdata_out              => rx_data(0),
        gt0_rxprbserr_out           => gt_mon(0).rxprbserr,
        gt0_rxprbssel_in            => gt_ctrl(0).rxprbssel,
        gt0_rxprbscntreset_in       => gt_ctrl(0).rxprbscntreset,
        gt0_rxdisperr_out           => gt_mon(0).rxdisperr,
        gt0_rxnotintable_out        => gt_mon(0).rxnotintable,
        gt0_gtxrxp_in               => rx_P(0),
        gt0_gtxrxn_in               => rx_N(0),
        gt0_rxdfelpmreset_in        => gt_ctrl(0).rxdfelpmreset, 
        gt0_rxmonitorout_out        => gt_mon(0).rxmonitorout,   
        gt0_rxmonitorsel_in         => gt_ctrl(0).rxmonitorsel,  
        gt0_rxoutclkfabric_out      => gt_mon(0).rxoutclkfabric, 
        gt0_gtrxreset_in            => gt_ctrl(0).gtrxreset,     
        gt0_rxpmareset_in           => gt_ctrl(0).rxpmareset, 
        gt0_rxcharisk_out           => rx_kdata(0),           
        gt0_rxresetdone_out         => gt_mon(0).rxresetdone, 
        gt0_gttxreset_in            => gt_ctrl(0).gttxreset,  
        gt0_txuserrdy_in            => gt_ctrl(0).txuserrdy,  
        gt0_txusrclk_in             => tx_user_clk(0),
        gt0_txusrclk2_in            => tx_user_clk2(0),
        gt0_txinhibit_in            => gt_ctrl(0).txinhibit,    
        gt0_txdata_in               => tx_data(0),              
        gt0_gtxtxn_out              => tx_n(0),                 
        gt0_gtxtxp_out              => tx_p(0),                 
        gt0_txoutclk_out            => tx_clk(0),
        gt0_txoutclkfabric_out      => gt_mon(0).txoutclkfabric,
        gt0_txoutclkpcs_out         => gt_mon(0).txoutclkpcs,   
        gt0_txcharisk_in            => tx_kdata(0),             
        gt0_txresetdone_out         => gt_mon(0).txresetdone,                 
        gt1_cpllfbclklost_out       => gt_mon(1).cpllfbclklost,         
        gt1_cplllock_out            => gt_mon(1).cplllock,              
        gt1_cplllockdetclk_in       => clk_axi,                                
        gt1_cpllreset_in            => gt_ctrl(1).cpllreset,            
        gt1_gtrefclk0_in            => '0',                             
        gt1_gtrefclk1_in            => refclk,                       
        gt1_drpaddr_in              => drp_intf(1).addr,              
        gt1_drpclk_in               => clk_axi,                          
        gt1_drpdi_in                => drp_intf(1).di,                
        gt1_drpdo_out               => drp_intf(1).do,                 
        gt1_drpen_in                => drp_intf(1).en,                
        gt1_drprdy_out              => drp_intf(1).rdy,                
        gt1_drpwe_in                => drp_intf(1).we,                
        gt1_dmonitorout_out         => gt_mon(1).dmonitorout,
        gt1_loopback_in             => gt_ctrl(1).loopback,
        gt1_eyescanreset_in         => gt_ctrl(1).eyescanreset,         
        gt1_rxuserrdy_in            => gt_ctrl(1).rxuserrdy,            
        gt1_eyescandataerror_out    => gt_mon(1).eyescandataerror,      
        gt1_eyescantrigger_in       => gt_ctrl(1).eyescantrigger,       
        gt1_rxusrclk_in             => rx_user_clk(1),                  
        gt1_rxusrclk2_in            => rx_user_clk2(1),                 
        gt1_rxdata_out              => rx_data(1),
        gt1_rxprbserr_out           => gt_mon(1).rxprbserr,
        gt1_rxprbssel_in            => gt_ctrl(1).rxprbssel,
        gt1_rxprbscntreset_in       => gt_ctrl(1).rxprbscntreset,
        gt1_rxdisperr_out           => gt_mon(1).rxdisperr,             
        gt1_rxnotintable_out        => gt_mon(1).rxnotintable,          
        gt1_gtxrxp_in               => rx_P(1),                         
        gt1_gtxrxn_in               => rx_N(1),                         
        gt1_rxdfelpmreset_in        => gt_ctrl(1).rxdfelpmreset,        
        gt1_rxmonitorout_out        => gt_mon(1).rxmonitorout,          
        gt1_rxmonitorsel_in         => gt_ctrl(1).rxmonitorsel,         
        gt1_rxoutclkfabric_out      => gt_mon(1).rxoutclkfabric,        
        gt1_gtrxreset_in            => gt_ctrl(1).gtrxreset,            
        gt1_rxpmareset_in           => gt_ctrl(1).rxpmareset,           
        gt1_rxcharisk_out           => rx_kdata(1),                     
        gt1_rxresetdone_out         => gt_mon(1).rxresetdone,           
        gt1_gttxreset_in            => gt_ctrl(1).gttxreset,            
        gt1_txuserrdy_in            => gt_ctrl(1).txuserrdy,            
        gt1_txusrclk_in             => tx_user_clk(1),                  
        gt1_txusrclk2_in            => tx_user_clk2(1),                 
        gt1_txinhibit_in            => gt_ctrl(1).txinhibit,            
        gt1_txdata_in               => tx_data(1),                      
        gt1_gtxtxn_out              => tx_n(1),                         
        gt1_gtxtxp_out              => tx_p(1),                         
        gt1_txoutclk_out            => tx_clk(1),                                
        gt1_txoutclkfabric_out      => gt_mon(1).txoutclkfabric,        
        gt1_txoutclkpcs_out         => gt_mon(1).txoutclkpcs,           
        gt1_txcharisk_in            => tx_kdata(1),                     
        gt1_txresetdone_out         => gt_mon(1).txresetdone,           
        gt2_cpllfbclklost_out       => gt_mon(2).cpllfbclklost,         
        gt2_cplllock_out            => gt_mon(2).cplllock,              
        gt2_cplllockdetclk_in       => clk_axi,                                
        gt2_cpllreset_in            => gt_ctrl(2).cpllreset,            
        gt2_gtrefclk0_in            => '0',                             
        gt2_gtrefclk1_in            => refclk,                       
        gt2_drpaddr_in              => drp_intf(2).addr,              
        gt2_drpclk_in               => clk_axi,                          
        gt2_drpdi_in                => drp_intf(2).di,                
        gt2_drpdo_out               => drp_intf(2).do,                 
        gt2_drpen_in                => drp_intf(2).en,                
        gt2_drprdy_out              => drp_intf(2).rdy,                
        gt2_drpwe_in                => drp_intf(2).we,                
        gt2_dmonitorout_out         => gt_mon(2).dmonitorout,
        gt2_loopback_in             => gt_ctrl(2).loopback,
        gt2_eyescanreset_in         => gt_ctrl(2).eyescanreset,         
        gt2_rxuserrdy_in            => gt_ctrl(2).rxuserrdy,            
        gt2_eyescandataerror_out    => gt_mon(2).eyescandataerror,      
        gt2_eyescantrigger_in       => gt_ctrl(2).eyescantrigger,       
        gt2_rxusrclk_in             => rx_user_clk(2),                  
        gt2_rxusrclk2_in            => rx_user_clk2(2),                 
        gt2_rxdata_out              => rx_data(2),
        gt2_rxprbserr_out           => gt_mon(2).rxprbserr,
        gt2_rxprbssel_in            => gt_ctrl(2).rxprbssel,
        gt2_rxprbscntreset_in       => gt_ctrl(2).rxprbscntreset,
        gt2_rxdisperr_out           => gt_mon(2).rxdisperr,             
        gt2_rxnotintable_out        => gt_mon(2).rxnotintable,          
        gt2_gtxrxp_in               => rx_P(2),                         
        gt2_gtxrxn_in               => rx_N(2),                         
        gt2_rxdfelpmreset_in        => gt_ctrl(2).rxdfelpmreset,        
        gt2_rxmonitorout_out        => gt_mon(2).rxmonitorout,          
        gt2_rxmonitorsel_in         => gt_ctrl(2).rxmonitorsel,         
        gt2_rxoutclkfabric_out      => gt_mon(2).rxoutclkfabric,        
        gt2_gtrxreset_in            => gt_ctrl(2).gtrxreset,            
        gt2_rxpmareset_in           => gt_ctrl(2).rxpmareset,           
        gt2_rxcharisk_out           => rx_kdata(2),                     
        gt2_rxresetdone_out         => gt_mon(2).rxresetdone,           
        gt2_gttxreset_in            => gt_ctrl(2).gttxreset,            
        gt2_txuserrdy_in            => gt_ctrl(2).txuserrdy,            
        gt2_txusrclk_in             => tx_user_clk(2),                  
        gt2_txusrclk2_in            => tx_user_clk2(2),                 
        gt2_txinhibit_in            => gt_ctrl(2).txinhibit,            
        gt2_txdata_in               => tx_data(2),                      
        gt2_gtxtxn_out              => tx_n(2),                         
        gt2_gtxtxp_out              => tx_p(2),                         
        gt2_txoutclk_out            => tx_clk(2),                                
        gt2_txoutclkfabric_out      => gt_mon(2).txoutclkfabric,        
        gt2_txoutclkpcs_out         => gt_mon(2).txoutclkpcs,           
        gt2_txcharisk_in            => tx_kdata(2),                     
        gt2_txresetdone_out         => gt_mon(2).txresetdone,           
        GT0_QPLLOUTCLK_IN           => QPLL_CLK,
        GT0_QPLLOUTREFCLK_IN        => QPLL_REF_CLK);


  TCDS_DRP_BRIDGE_1: entity work.TCDS_DRP_BRIDGE
    port map (
      AXI_aclk      => clk_axi,
      AXI_aresetn   => reset_axi_n,
      S_AXI_araddr  => readMOSI.address,            
      S_AXI_arready => readMOSI.protection_type,    
      S_AXI_arvalid => readMISO.ready_for_address,  
      S_AXI_arprot  => readMOSI.address_valid,      
      S_AXI_awaddr  => writeMOSI.address,            
      S_AXI_awready => writeMOSI.protection_type,    
      S_AXI_awvalid => writeMISO.ready_for_address,  
      S_AXI_awprot  => writeMOSI.address_valid,      
      S_AXI_bresp   => writeMOSI.ready_for_response, 
      S_AXI_bready  => writeMISO.response,           
      S_AXI_bvalid  => writeMISO.response_valid,     
      S_AXI_rdata   => readMISO.data,               
      S_AXI_rready  => readMOSI.ready_for_data,     
      S_AXI_rvalid  => readMISO.response,           
      S_AXI_rresp   => readMISO.data_valid,         
      S_AXI_wdata   => writeMOSI.data,               
      S_AXI_wready  => writeMISO.ready_for_data,     
      S_AXI_wvalid  => writeMOSI.data_write_strobe,  
      S_AXI_wstrb   => writeMOSI.data_valid,         
      drp0_en       => drp_intf(0).en,
      drp0_we       => drp_intf(0).we,
      drp0_addr     => drp_intf(0).addr,
      drp0_di       => drp_intf(0).di,
      drp0_do       => drp_intf(0).do,
      drp0_rdy      => drp_intf(0).rdy,
      drp1_en       => drp_intf(1).en,
      drp1_we       => drp_intf(1).we,
      drp1_addr     => drp_intf(1).addr,
      drp1_di       => drp_intf(1).di,
      drp1_do       => drp_intf(1).do,
      drp1_rdy      => drp_intf(1).rdy,
      drp2_en       => drp_intf(2).en,
      drp2_we       => drp_intf(2).we,
      drp2_addr     => drp_intf(2).addr,
      drp2_di       => drp_intf(2).di,
      drp2_do       => drp_intf(2).do,
      drp2_rdy      => drp_intf(2).rdy);

end architecture Behavioral;
