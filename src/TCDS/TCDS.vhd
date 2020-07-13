library ieee;
use ieee.std_logic_1164.all;
use work.types.all;
use work.AXIRegPKG.all;
use work.TCDS_Ctrl.all;

use ieee.std_logic_misc.all;

entity TCDS is
  
  port (
    clk_axi              : in  std_logic;
    reset_axi_n          : in  std_logic;
    clk_axi_DRP          : in  std_logic;
    reset_axi_DRP_n      : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO;
    DRP_readMOSI         : in  AXIreadMOSI;
    DRP_readMISO         : out AXIreadMISO;
    DRP_writeMOSI        : in  AXIwriteMOSI;
    DRP_writeMISO        : out AXIwriteMISO;
    refclk_p             : in  std_logic;
    refclk_n             : in  std_logic;
    QPLL_CLK             : in  std_logic;
    QPLL_REF_CLK         : in  std_logic;
    clk_TCDS             : out std_logic;
    clk_TCDS_reset_n     : out std_logic;
    tx_P                 : out std_logic_vector(2 downto 0);
    tx_N                 : out std_logic_vector(2 downto 0);
    rx_P                 : in  std_logic_vector(2 downto 0);
    rx_N                 : in  std_logic_vector(2 downto 0)
    );  
end entity TCDS;

architecture Behavioral of TCDS is

  signal tx_data : slv32_array_t(0 to 2);
  signal rx_data : slv32_array_t(0 to 2);
  signal tx_kdata : slv4_array_t(0 to 2);
  signal rx_kdata : slv4_array_t(0 to 2);
  signal tx_dv : std_logic_vector(2 downto 0);
  signal rx_dv : std_logic_vector(2 downto 0);
  signal reset : std_logic;
  
  type GT_Mon_t is record
    cpllfbclklost    : std_logic; --ro
    cplllock         : std_logic; --ro
    dmonitorout      : slv_8_t; --ro
    eyescandataerror : std_logic; --ro
    rxprbserr        : STD_LOGIC; --ro
    rxdisperr        : slv_4_t;  --ro
    rxnotintable     : slv_4_t; --ro
    rxmonitor        : slv_7_t; --ro
    rxoutclkfabric   : std_logic;
    rxresetdone      : std_logic; --ro
    txoutclkfabric   : std_logic;
    txoutclkpcs      : std_logic;
    txresetdone      : std_logic; --ro  
  end record GT_Mon_t;
  type GT_Mon_array_t is array (integer range <>) of GT_Mon_t;
  signal gt_mon : GT_Mon_array_t(2 downto 0);  
  
  type GT_Ctrl_t is record
    cpllreset         : std_logic;    --rw
    eyescanreset      : std_logic;    --rw
    rxuserrdy         : std_logic;    --rw
    loopback          : slv_3_t;      --rw
    eyescantrigger    : std_logic;    --w
    rxprbssel         : slv_3_t;      --rw
    rxprbscntreset    : STD_LOGIC;    --w
    rxdfelpmreset     : std_logic;    --rw
    rxmonitorsel      : slv_2_t;      --rw
    gtrxreset         : std_logic;    --rw
    rxpmareset        : std_logic;    --rw
    gttxreset         : std_logic;    --rw
    txuserrdy         : std_logic;    --rw
    prbsforceerr      : std_logic;    --w
    txinhibit         : std_logic;    --rw
    txprbssel         : slv_3_t;      --rw
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
                                             prbsforceerr   => '0',
                                             txinhibit      => '0',
                                             txprbssel      => "000"
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

  signal  gt0_cpll_lock_out : std_logic;
  signal tx_reset_done : slv_3_t;
  signal rx_reset_done : slv_3_t;

  signal refclk : std_logic;
  
  signal tx_user_clk : slv_3_t;
  signal tx_user_clk2 : slv_3_t;
  signal tx_clk : slv_3_t;
  signal rx_user_clk : slv_3_t;
  signal rx_user_clk2 : slv_3_t;
  signal rx_prbs_error : slv_3_t;
  signal rx_prbs_error_buf : slv_3_t;
  signal rx_bad_char : slv4_array_t(2 downto 0);
  signal rx_bad_char_buf : slv4_array_t(2 downto 0);
  signal rx_disp_error : slv4_array_t(2 downto 0);
  signal rx_disp_error_buf : slv4_array_t(2 downto 0);
  signal rx_counter_reset : slv_3_t;

  signal Mon              : TCDS_Mon_t;
  signal Ctrl             : TCDS_Ctrl_t;

  signal local_clk_TCDS : std_logic;
begin  -- architecture Behavioral



  TCDS_interface_1: entity work.TCDS_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
  

  Mon.LINK0.TEST2 <= x"12345678";
  Mon.LINK1.TEST2 <= x"abadcafe";
  Mon.LINK2.TEST2 <= x"deadbeef";
  
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

--  clk_TCDS <= tx_clk(0);
  local_clk_TCDS <= rx_user_clk2(0);
  clk_TCDS <= local_clk_TCDS;
  clk_TCDS_reset_n <= gt0_cpll_lock_out;--not gt0_cpll_lock_out;

--  reset <= not reset_axi_n;
  reset <= not reset_axi_DRP_n;
  Mon.LINK0.CLOCKING.CLK_LOCKED <= gt0_cpll_lock_out;
    LHC_2: entity work.LHC
      port map (
        SYSCLK_IN                   => clk_axi_DRP,--clk_axi,
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
        gt0_cpllfbclklost_out       => Mon.LINK0.CLOCKING.FB_CLK_LOST,         
        gt0_cplllock_out            => gt0_cpll_lock_out,
        gt0_cplllockdetclk_in       => clk_axi_DRP,--clk_axi,
        gt0_cpllreset_in            => Ctrl.LINK0.CLOCKING.RESET,
        gt0_gtrefclk0_in            => refclk,--'0',
        gt0_gtrefclk1_in            => '0',--refclk,
        gt0_drpaddr_in              => drp_intf(0).addr,
        gt0_drpclk_in               => clk_axi_DRP,
        gt0_drpdi_in                => drp_intf(0).di,
        gt0_drpdo_out               => drp_intf(0).do,
        gt0_drpen_in                => drp_intf(0).en,
        gt0_drprdy_out              => drp_intf(0).rdy,
        gt0_drpwe_in                => drp_intf(0).we,
        gt0_dmonitorout_out         => Mon.LINK0.DMONITOR,
        gt0_loopback_in             => Ctrl.LINK0.LOOPBACK,
        gt0_eyescanreset_in         => Ctrl.LINK0.EYESCAN.RESET,
        gt0_rxuserrdy_in            => Ctrl.LINK0.RX.USER_READY,
        gt0_eyescandataerror_out    => Mon.LINK0.EYESCAN.DATA_ERROR,
        gt0_eyescantrigger_in       => Ctrl.LINK0.EYESCAN.TRIGGER, 
        gt0_rxusrclk_in             => rx_user_clk(0),
        gt0_rxusrclk2_in            => rx_user_clk2(0),
        gt0_rxdata_out              => rx_data(0),
        gt0_rxprbserr_out           => rx_prbs_error(0),
        gt0_rxprbssel_in            => Ctrl.LINK0.RX.PRBS_SEL,
        gt0_rxprbscntreset_in       => Ctrl.LINK0.RX.PRBS_RESET,
        gt0_rxdisperr_out           => rx_disp_error(0),
        gt0_rxnotintable_out        => rx_bad_char(0),
        gt0_gtxrxp_in               => rx_P(0),
        gt0_gtxrxn_in               => rx_N(0),
        gt0_rxdfelpmreset_in        => Ctrl.LINK0.RX.DFELPM_RESET, 
        gt0_rxmonitorout_out        => Mon.LINK0.RX.MONITOR,   
        gt0_rxmonitorsel_in         => Ctrl.LINK0.RX.MONITOR_SEL,  
        gt0_rxoutclkfabric_out      => open,
        gt0_gtrxreset_in            => Ctrl.LINK0.RX.RESET,     
        gt0_rxpmareset_in           => Ctrl.LINK0.RX.PMA_RESET, 
        gt0_rxcharisk_out           => rx_kdata(0),           
        gt0_rxresetdone_out         => Mon.LINK0.RX.RESET_DONE, 
        gt0_gttxreset_in            => Ctrl.LINK0.TX.RESET,  
        gt0_txuserrdy_in            => Ctrl.LINK0.TX.USER_READY,  
        gt0_txusrclk_in             => tx_user_clk(0),
        gt0_txusrclk2_in            => tx_user_clk2(0),
        gt0_txprbsforceerr_in       => Ctrl.LINK0.TX.PRBS_FORCE_ERROR,
        gt0_txinhibit_in            => Ctrl.LINK0.TX.INHIBIT,    
        gt0_txdata_in               => tx_data(0),              
        gt0_gtxtxn_out              => tx_n(0),                 
        gt0_gtxtxp_out              => tx_p(0),                 
        gt0_txoutclk_out            => tx_clk(0),
        gt0_txoutclkfabric_out      => open,
        gt0_txoutclkpcs_out         => open,
        gt0_txcharisk_in            => tx_kdata(0),             
        gt0_txresetdone_out         => Mon.LINK0.TX.RESET_DONE,
        gt0_txprbssel_in            => Ctrl.LINK0.TX.PRBS_SEL,
        gt1_cpllfbclklost_out       => Mon.LINK1.CLOCKING.FB_CLK_LOST,         
        gt1_cplllock_out            => Mon.LINK1.CLOCKING.CLK_LOCKED,              
        gt1_cplllockdetclk_in       => clk_axi_DRP,--clk_axi,                                
        gt1_cpllreset_in            => Ctrl.LINK1.CLOCKING.RESET,            
        gt1_gtrefclk0_in            => refclk,--'0',
        gt1_gtrefclk1_in            => '0',--refclk,
        gt1_drpaddr_in              => drp_intf(1).addr,              
        gt1_drpclk_in               => clk_axi_DRP,                          
        gt1_drpdi_in                => drp_intf(1).di,                
        gt1_drpdo_out               => drp_intf(1).do,                 
        gt1_drpen_in                => drp_intf(1).en,                
        gt1_drprdy_out              => drp_intf(1).rdy,                
        gt1_drpwe_in                => drp_intf(1).we,                
        gt1_dmonitorout_out         => Mon.LINK1.DMONITOR,
        gt1_loopback_in             => Ctrl.LINK1.LOOPBACK,
        gt1_eyescanreset_in         => Ctrl.LINK1.EYESCAN.RESET,         
        gt1_rxuserrdy_in            => Ctrl.LINK1.RX.USER_READY,            
        gt1_eyescandataerror_out    => Mon.LINK1.EYESCAN.DATA_ERROR,      
        gt1_eyescantrigger_in       => Ctrl.LINK1.EYESCAN.TRIGGER,       
        gt1_rxusrclk_in             => rx_user_clk(1),                  
        gt1_rxusrclk2_in            => rx_user_clk2(1),                 
        gt1_rxdata_out              => rx_data(1),
        gt1_rxprbserr_out           => rx_prbs_error(1),
        gt1_rxprbssel_in            => Ctrl.LINK1.RX.PRBS_SEL,
        gt1_rxprbscntreset_in       => Ctrl.LINK1.RX.PRBS_RESET,
        gt1_rxdisperr_out           => rx_disp_error(1),
        gt1_rxnotintable_out        => rx_bad_char(1),
        gt1_gtxrxp_in               => rx_P(1),                         
        gt1_gtxrxn_in               => rx_N(1),                         
        gt1_rxdfelpmreset_in        => Ctrl.LINK1.RX.DFELPM_RESET,        
        gt1_rxmonitorout_out        => Mon.LINK1.RX.MONITOR,          
        gt1_rxmonitorsel_in         => Ctrl.LINK1.RX.MONITOR_SEL,         
        gt1_rxoutclkfabric_out      => open,
        gt1_gtrxreset_in            => Ctrl.LINK1.RX.RESET,            
        gt1_rxpmareset_in           => Ctrl.LINK1.RX.PMA_RESET,           
        gt1_rxcharisk_out           => rx_kdata(1),                     
        gt1_rxresetdone_out         => Mon.LINK1.RX.RESET_DONE,           
        gt1_gttxreset_in            => Ctrl.LINK1.TX.RESET,            
        gt1_txuserrdy_in            => Ctrl.LINK1.TX.USER_READY,            
        gt1_txusrclk_in             => tx_user_clk(1),                  
        gt1_txusrclk2_in            => tx_user_clk2(1),
        gt1_txprbsforceerr_in       => Ctrl.LINK1.TX.PRBS_FORCE_ERROR,
        gt1_txinhibit_in            => Ctrl.LINK1.TX.INHIBIT,            
        gt1_txdata_in               => tx_data(1),                      
        gt1_gtxtxn_out              => tx_n(1),                         
        gt1_gtxtxp_out              => tx_p(1),                         
        gt1_txoutclk_out            => tx_clk(1),                                
        gt1_txoutclkfabric_out      => open,
        gt1_txoutclkpcs_out         => open,
        gt1_txcharisk_in            => tx_kdata(1),                     
        gt1_txresetdone_out         => Mon.LINK1.TX.RESET_DONE,
        gt1_txprbssel_in            => Ctrl.LINK1.TX.PRBS_SEL,
        gt2_cpllfbclklost_out       => Mon.LINK2.CLOCKING.FB_CLK_LOST,         
        gt2_cplllock_out            => Mon.LINK2.CLOCKING.CLK_LOCKED,              
        gt2_cplllockdetclk_in       => clk_axi_DRP,--clk_axi,                                
        gt2_cpllreset_in            => Ctrl.LINK2.CLOCKING.RESET,            
        gt2_gtrefclk0_in            => '0',                             
        gt2_gtrefclk1_in            => refclk,                       
        gt2_drpaddr_in              => drp_intf(2).addr,              
        gt2_drpclk_in               => clk_axi_DRP,                          
        gt2_drpdi_in                => drp_intf(2).di,                
        gt2_drpdo_out               => drp_intf(2).do,                 
        gt2_drpen_in                => drp_intf(2).en,                
        gt2_drprdy_out              => drp_intf(2).rdy,                
        gt2_drpwe_in                => drp_intf(2).we,                
        gt2_dmonitorout_out         => Mon.LINK2.DMONITOR,
        gt2_loopback_in             => Ctrl.LINK2.LOOPBACK,
        gt2_eyescanreset_in         => Ctrl.LINK2.EYESCAN.RESET,         
        gt2_rxuserrdy_in            => Ctrl.LINK2.RX.USER_READY,            
        gt2_eyescandataerror_out    => Mon.LINK2.EYESCAN.DATA_ERROR,      
        gt2_eyescantrigger_in       => Ctrl.LINK2.EYESCAN.TRIGGER,       
        gt2_rxusrclk_in             => rx_user_clk(2),                  
        gt2_rxusrclk2_in            => rx_user_clk2(2),                 
        gt2_rxdata_out              => rx_data(2),
        gt2_rxprbserr_out           => rx_prbs_error(2),
        gt2_rxprbssel_in            => Ctrl.LINK2.RX.PRBS_SEL,
        gt2_rxprbscntreset_in       => Ctrl.LINK2.RX.PRBS_RESET,
        gt2_rxdisperr_out           => rx_disp_error(2),
        gt2_rxnotintable_out        => rx_bad_char(2),     
        gt2_gtxrxp_in               => rx_P(2),                         
        gt2_gtxrxn_in               => rx_N(2),                         
        gt2_rxdfelpmreset_in        => Ctrl.LINK2.RX.DFELPM_RESET,        
        gt2_rxmonitorout_out        => Mon.LINK2.RX.MONITOR,          
        gt2_rxmonitorsel_in         => Ctrl.LINK2.RX.MONITOR_SEL,         
        gt2_rxoutclkfabric_out      => open,
        gt2_gtrxreset_in            => Ctrl.LINK2.RX.RESET,            
        gt2_rxpmareset_in           => Ctrl.LINK2.RX.PMA_RESET,           
        gt2_rxcharisk_out           => rx_kdata(2),                     
        gt2_rxresetdone_out         => Mon.LINK2.RX.RESET_DONE,           
        gt2_gttxreset_in            => Ctrl.LINK2.TX.RESET,            
        gt2_txuserrdy_in            => Ctrl.LINK2.TX.USER_READY,            
        gt2_txusrclk_in             => tx_user_clk(2),                  
        gt2_txusrclk2_in            => tx_user_clk2(2),
        gt2_txprbsforceerr_in       => Ctrl.LINK2.TX.PRBS_FORCE_ERROR,
        gt2_txinhibit_in            => Ctrl.LINK2.TX.INHIBIT,            
        gt2_txdata_in               => tx_data(2),                      
        gt2_gtxtxn_out              => tx_n(2),                         
        gt2_gtxtxp_out              => tx_p(2),                         
        gt2_txoutclk_out            => tx_clk(2),                                
        gt2_txoutclkfabric_out      => open,
        gt2_txoutclkpcs_out         => open,
        gt2_txcharisk_in            => tx_kdata(2),                     
        gt2_txresetdone_out         => Mon.LINK2.TX.RESET_DONE,           
        gt2_txprbssel_in            => Ctrl.LINK2.TX.PRBS_SEL,
        GT0_QPLLOUTCLK_IN           => QPLL_CLK,
        GT0_QPLLOUTREFCLK_IN        => QPLL_REF_CLK);


  TCDS_DRP_BRIDGE_1: entity work.TCDS_DRP_BRIDGE
    port map (
      AXI_aclk      => clk_axi_DRP,
      AXI_aresetn   => reset_axi_DRP_n,
      S_AXI_araddr  => DRP_readMOSI.address,            
      S_AXI_arready => DRP_readMISO.ready_for_address,  
      S_AXI_arvalid => DRP_readMOSI.address_valid,      
      S_AXI_arprot  => DRP_readMOSI.protection_type,    
      S_AXI_awaddr  => DRP_writeMOSI.address,            
      S_AXI_awready => DRP_writeMISO.ready_for_address,  
      S_AXI_awvalid => DRP_writeMOSI.address_valid,      
      S_AXI_awprot  => DRP_writeMOSI.protection_type,    
      S_AXI_bresp   => DRP_writeMISO.response,           
      S_AXI_bready  => DRP_writeMOSI.ready_for_response, 
      S_AXI_bvalid  => DRP_writeMISO.response_valid,     
      S_AXI_rdata   => DRP_readMISO.data,               
      S_AXI_rready  => DRP_readMOSI.ready_for_data,     
      S_AXI_rvalid  => DRP_readMISO.data_valid,         
      S_AXI_rresp   => DRP_readMISO.response,           
      S_AXI_wdata   => DRP_writeMOSI.data,               
      S_AXI_wready  => DRP_writeMISO.ready_for_data,     
      S_AXI_wvalid  => DRP_writeMOSI.data_valid,         
      S_AXI_wstrb   => DRP_writeMOSI.data_write_strobe,  
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


  TCDS_Monitor_0: entity work.TCDS_Monitor
    port map(
      clk_axi        => clk_axi,
      axi_reset_n    => reset_axi_n,
      counters_en    => Ctrl.LINK0.RX.Counter_ENABLE,
      prbs_err_count => Mon.LINK0.RX.PRBS_ERR_COUNT,
      bad_word_count => Mon.LINK0.RX.BAD_CHAR_COUNT,
      disp_err_count => Mon.LINK0.RX.DISP_ERR_COUNT,
      clk_txrx       => local_clk_TCDS,
      prbs_error     => rx_prbs_error(0),
      bad_word       => or_reduce(rx_bad_char(0)),
      disp_error     => or_reduce(rx_disp_error(0))
      );

  TCDS_Monitor_1: entity work.TCDS_Monitor
    port map(
      clk_axi        => clk_axi,
      axi_reset_n    => reset_axi_n,
      counters_en    => Ctrl.LINK1.RX.Counter_ENABLE,
      prbs_err_count => Mon.LINK1.RX.PRBS_ERR_COUNT,
      bad_word_count => Mon.LINK1.RX.BAD_CHAR_COUNT,
      disp_err_count => Mon.LINK1.RX.DISP_ERR_COUNT,
      clk_txrx       => local_clk_TCDS,
      prbs_error     => rx_prbs_error(1),
      bad_word       => or_reduce(rx_bad_char(1)),
      disp_error     => or_reduce(rx_disp_error(1))
      );        

  TCDS_Monitor_2: entity work.TCDS_Monitor
    port map(
      clk_axi        => clk_axi,
      axi_reset_n    => reset_axi_n,
      counters_en    => Ctrl.LINK2.RX.Counter_ENABLE,
      prbs_err_count => Mon.LINK2.RX.PRBS_ERR_COUNT,
      bad_word_count => Mon.LINK2.RX.BAD_CHAR_COUNT,
      disp_err_count => Mon.LINK2.RX.DISP_ERR_COUNT,
      clk_txrx       => local_clk_TCDS,
      prbs_error     => rx_prbs_error(2),
      bad_word       => or_reduce(rx_bad_char(2)),
      disp_error     => or_reduce(rx_disp_error(2))
      );

  
  
  TCDS_Control_0: entity work.TCDS_Control
    port map (
      clk_axi      => clk_axi,
      axi_reset_n  => reset_axi_n,
      clk_txrx     => local_clk_TCDS,
      mode         => Ctrl.CTRL0.MODE,
      fixed_send_d => Ctrl.CTRL0.FIXED_SEND_D,
      fixed_send_k => Ctrl.CTRL0.FIXED_SEND_K,
      capture      => Ctrl.CTRL0.CAPTURE,
      capture_d    => Mon.CTRL0.CAPTURE_D,
      capture_k    => Mon.CTRL0.CAPTURE_K,
      tx_data      => tx_data(0),
      tx_k_data    => tx_kdata(0),
      rx_data      => rx_data(0),
      rx_k_data    => rx_kdata(0));
  TCDS_Control_1: entity work.TCDS_Control
    port map (
      clk_axi      => clk_axi,
      axi_reset_n  => reset_axi_n,
      clk_txrx     => local_clk_TCDS,
      mode         => Ctrl.CTRL1.MODE,
      fixed_send_d => Ctrl.CTRL1.FIXED_SEND_D,
      fixed_send_k => Ctrl.CTRL1.FIXED_SEND_K,
      capture      => Ctrl.CTRL1.CAPTURE,
      capture_d    => Mon.CTRL1.CAPTURE_D,
      capture_k    => Mon.CTRL1.CAPTURE_K,
      tx_data      => tx_data(1),
      tx_k_data    => tx_kdata(1),
      rx_data      => rx_data(1),
      rx_k_data    => rx_kdata(1));
  TCDS_Control_2: entity work.TCDS_Control
    port map (
      clk_axi      => clk_axi,
      axi_reset_n  => reset_axi_n,
      clk_txrx     => local_clk_TCDS,
      mode         => Ctrl.CTRL2.MODE,
      fixed_send_d => Ctrl.CTRL2.FIXED_SEND_D,
      fixed_send_k => Ctrl.CTRL2.FIXED_SEND_K,
      capture      => Ctrl.CTRL2.CAPTURE,
      capture_d    => Mon.CTRL2.CAPTURE_D,
      capture_k    => Mon.CTRL2.CAPTURE_K,
      tx_data      => tx_data(2),
      tx_k_data    => tx_kdata(2),
      rx_data      => rx_data(2),
      rx_k_data    => rx_kdata(2));
  
end architecture Behavioral;
