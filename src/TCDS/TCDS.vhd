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
  component LHC_support is
    generic (
      EXAMPLE_SIM_GTRESET_SPEEDUP : string;
      STABLE_CLOCK_PERIOD         : integer);
    port (
      SOFT_RESET_TX_IN            : in  std_logic;
      SOFT_RESET_RX_IN            : in  std_logic;
      DONT_RESET_ON_DATA_ERROR_IN : in  std_logic;
      GT0_TX_FSM_RESET_DONE_OUT   : out std_logic;
      GT0_RX_FSM_RESET_DONE_OUT   : out std_logic;
      GT0_DATA_VALID_IN           : in  std_logic;
      GT0_TX_MMCM_LOCK_OUT        : out std_logic;
      GT0_RX_MMCM_LOCK_OUT        : out std_logic;
      GT0_TXUSRCLK_OUT            : out std_logic;
      GT0_TXUSRCLK2_OUT           : out std_logic;
      GT0_RXUSRCLK_OUT            : out std_logic;
      GT0_RXUSRCLK2_OUT           : out std_logic;
      gt0_cpllfbclklost_out       : out std_logic;
      gt0_cplllock_out            : out std_logic;
      gt0_cpllreset_in            : in  std_logic;
      gt0_drpaddr_in              : in  std_logic_vector(8 downto 0);
      gt0_drpdi_in                : in  std_logic_vector(15 downto 0);
      gt0_drpdo_out               : out std_logic_vector(15 downto 0);
      gt0_drpen_in                : in  std_logic;
      gt0_drprdy_out              : out std_logic;
      gt0_drpwe_in                : in  std_logic;
      gt0_dmonitorout_out         : out std_logic_vector(7 downto 0);
      gt0_eyescanreset_in         : in  std_logic;
      gt0_rxuserrdy_in            : in  std_logic;
      gt0_eyescandataerror_out    : out std_logic;
      gt0_eyescantrigger_in       : in  std_logic;
      gt0_rxdata_out              : out std_logic_vector(31 downto 0);
      gt0_rxdisperr_out           : out std_logic_vector(3 downto 0);
      gt0_rxnotintable_out        : out std_logic_vector(3 downto 0);
      gt0_gtxrxp_in               : in  std_logic;
      gt0_gtxrxn_in               : in  std_logic;
      gt0_rxdfelpmreset_in        : in  std_logic;
      gt0_rxmonitorout_out        : out std_logic_vector(6 downto 0);
      gt0_rxmonitorsel_in         : in  std_logic_vector(1 downto 0);
      gt0_rxoutclkfabric_out      : out std_logic;
      gt0_gtrxreset_in            : in  std_logic;
      gt0_rxpmareset_in           : in  std_logic;
      gt0_rxcharisk_out           : out std_logic_vector(3 downto 0);
      gt0_rxresetdone_out         : out std_logic;
      gt0_gttxreset_in            : in  std_logic;
      gt0_txuserrdy_in            : in  std_logic;
      gt0_txdata_in               : in  std_logic_vector(31 downto 0);
      gt0_gtxtxn_out              : out std_logic;
      gt0_gtxtxp_out              : out std_logic;
      gt0_txoutclkfabric_out      : out std_logic;
      gt0_txoutclkpcs_out         : out std_logic;
      gt0_txcharisk_in            : in  std_logic_vector(3 downto 0);
      gt0_txresetdone_out         : out std_logic;
      GT0_QPLLOUTCLK_OUT          : in  std_logic;
      GT0_QPLLOUTREFCLK_OUT       : in  std_logic;
      Q3_CLK1_GTREFCLK_OUT        : in  std_logic;
      sysclk_in                   : in  std_logic);
  end component LHC_support;

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
