library ieee;
use ieee.std_logic_1164.all;

entity TCDS is
  
  port (
    sysclk               : in  std_logic;
    GT0_QPLLOUTCLK_IN    : in  std_logic;
    GT0_QPLLOUTREFCLK_IN : in  std_logic;
    refclk               : in  std_logic;
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
  
  Transcievers: for iTXRX in 0 to 2 generate
--    LHC_1: entity work.LHC
--      port map (
--        SYSCLK_IN                   => sysclk,
--        SOFT_RESET_TX_IN            => reset,
--        SOFT_RESET_RX_IN            => reset,
--        DONT_RESET_ON_DATA_ERROR_IN => '1',
--        GT0_TX_FSM_RESET_DONE_OUT   => open,
--        GT0_RX_FSM_RESET_DONE_OUT   => open,
--        GT0_DATA_VALID_IN           => tx_dv(iTXRX)
--        gt0_cpllfbclklost_out       => open,
--        gt0_cplllock_out            => open,
--        gt0_cplllockdetclk_in       => 
--        gt0_cpllreset_in            => reset,
--        gt0_gtrefclk0_in            => 
--        gt0_gtrefclk1_in            => 
--        gt0_drpaddr_in              => 
--        gt0_drpclk_in               => 
--        gt0_drpdi_in                => 
--        gt0_drpdo_out               => 
--        gt0_drpen_in                => 
--        gt0_drprdy_out              => 
--        gt0_drpwe_in                => 
--        gt0_dmonitorout_out         => 
--        gt0_eyescanreset_in         => 
--        gt0_rxuserrdy_in            => 
--        gt0_eyescandataerror_out    => 
--        gt0_eyescantrigger_in       => 
--        gt0_rxusrclk_in             => 
--        gt0_rxusrclk2_in            => 
--        gt0_rxdata_out              => 
--        gt0_gtxrxp_in               => 
--        gt0_gtxrxn_in               => 
--        gt0_rxdfelpmreset_in        => 
--        gt0_rxmonitorout_out        => 
--        gt0_rxmonitorsel_in         => 
--        gt0_rxoutclkfabric_out      => 
--        gt0_rxdatavalid_out         => 
--        gt0_rxheader_out            => 
--        gt0_rxheadervalid_out       => 
--        gt0_rxgearboxslip_in        => 
--        gt0_gtrxreset_in            => 
--        gt0_rxpmareset_in           => 
--        gt0_rxresetdone_out         => 
--        gt0_gttxreset_in            => 
--        gt0_txuserrdy_in            => 
--        gt0_txusrclk_in             => 
--        gt0_txusrclk2_in            => 
--        gt0_txdata_in               => 
--        gt0_gtxtxn_out              => 
--        gt0_gtxtxp_out              => 
--        gt0_txoutclk_out            => 
--        gt0_txoutclkfabric_out      => 
--        gt0_txoutclkpcs_out         => 
--        gt0_txgearboxready_out      => 
--        gt0_txheader_in             => 
--        gt0_txstartseq_in           => 
--        gt0_txresetdone_out         => 
--        GT0_QPLLOUTCLK_IN           => 
--        GT0_QPLLOUTREFCLK_IN        => 
--
    LHC_support_1: entity work.LHC_support
      port map (
        SOFT_RESET_TX_IN            => reset,
        SOFT_RESET_RX_IN            => reset,
        DONT_RESET_ON_DATA_ERROR_IN => '1',
        GT0_TX_FSM_RESET_DONE_OUT   => open,
        GT0_RX_FSM_RESET_DONE_OUT   => open,
        GT0_DATA_VALID_IN           => tx_dv(iTXRX),
        GT0_TX_MMCM_LOCK_OUT        => open,
        GT0_RX_MMCM_LOCK_OUT        => open,
        GT0_TXUSRCLK_OUT            => clk_txusr(iTXRX),
        GT0_TXUSRCLK2_OUT           => open,
        GT0_RXUSRCLK_OUT            => clk_rxusr(iTXRX),
        GT0_RXUSRCLK2_OUT           => open,
        gt0_cpllfbclklost_out       => open,
        gt0_cplllock_out            => open,
        gt0_cpllreset_in            => reset,
        gt0_drpaddr_in              => (others => '0'),
        gt0_drpdi_in                => (others => '0'),
        gt0_drpdo_out               => open,
        gt0_drpen_in                => '0',
        gt0_drprdy_out              => open,
        gt0_drpwe_in                => '0',
        gt0_dmonitorout_out         => open,
        gt0_eyescanreset_in         => '0',
        gt0_rxuserrdy_in            => '1',
        gt0_eyescandataerror_out    => open,
        gt0_eyescantrigger_in       => '0',
        gt0_rxdata_out              => rx_data(iTXRX),
        gt0_rxdisperr_out           => open,
        gt0_rxnotintable_out        => open,
        gt0_gtxrxp_in               => rx_P(iTXRX),
        gt0_gtxrxn_in               => rx_N(iTXRX),
        gt0_rxdfelpmreset_in        => '0',
        gt0_rxmonitorout_out        => open,
        gt0_rxmonitorsel_in         => "00",
        gt0_rxoutclkfabric_out      => open,
        gt0_gtrxreset_in            => reset,
        gt0_rxpmareset_in           => reset,
        gt0_rxcharisk_out           => rx_kdata(iTXRX),
        gt0_rxresetdone_out         => open,
        gt0_gttxreset_in            => reset,
        gt0_txuserrdy_in            => '1',
        gt0_txdata_in               => tx_data(iTXRX),
        gt0_gtxtxn_out              => tx_N(iTXRX),
        gt0_gtxtxp_out              => tx_P(iTXRX),
        gt0_txoutclkfabric_out      => open,
        gt0_txoutclkpcs_out         => open,
        gt0_txcharisk_in            => tx_kdata(iTXRX),
        gt0_txresetdone_out         => open,
        GT0_QPLLOUTCLK_OUT          => GT0_QPLLOUTCLK_IN,
        GT0_QPLLOUTREFCLK_OUT       => GT0_QPLLOUTREFCLK_IN,
        Q3_CLK1_GTREFCLK_OUT        => refclk,
        sysclk_in                   => sysclk);
  end generate Transcievers;
end architecture Behavioral;
