library ieee;
use ieee.std_logic_1164.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.LDAQ_Ctrl.all;

entity LDAQ is
  
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    LDAQ_CLK_P       : in  std_Logic;
    LDAQ_CLK_N       : in  std_Logic;
    LDAQ_RX_P        : in  std_logic;
    LDAQ_RX_N        : in  std_logic;
    LDAQ_TX_P        : out std_logic;
    LDAQ_TX_N        : out std_logic
    );

end entity LDAQ;

architecture behavioral of LDAQ is

  signal Mon  : LDAQ_Mon_t;
  signal Ctrl : LDAQ_Ctrl_t;

  signal bypass_data : slv32_t;
  signal LDAQ_CLK : std_logic;
  
begin  -- architecture behavioral


  LDAQ_CLK_ibuf : ibufds_gte4
    port map (
      i   => LDAQ_CLK_p,
      ib  => LDAQ_CLK_n,
      o   => LDAQ_CLK,
      ceb => '0'
      );

  
  LDAQ_MGBT_1: entity work.LDAQ_MGBT
    port map (
      gtwiz_userclk_tx_reset_in          => Ctrl.RESET.USERCLK_TX,
      gtwiz_userclk_tx_srcclk_out        => open,
      gtwiz_userclk_tx_usrclk_out        => open,
      gtwiz_userclk_tx_usrclk2_out       => open,
      gtwiz_userclk_tx_active_out        => Mon.STATUS.userclk_tx_active,
      gtwiz_userclk_rx_reset_in          => Ctrl.RESET.USERCLK_RX,
      gtwiz_userclk_rx_srcclk_out        => open,
      gtwiz_userclk_rx_usrclk_out        => open,
      gtwiz_userclk_rx_usrclk2_out       => open,
      gtwiz_userclk_rx_active_out        => Mon.STATUS.userclk_rx_active,
      gtwiz_reset_clk_freerun_in         => '0',
      gtwiz_reset_all_in                 => Ctrl.RESET.ALL,
      gtwiz_reset_tx_pll_and_datapath_in => Ctrl.RESET.TX_PLL_AND_DATAPATH,
      gtwiz_reset_tx_datapath_in         => Ctrl.RESET.TX_DATAPATH,
      gtwiz_reset_rx_pll_and_datapath_in => Ctrl.RESET.RX_PLL_AND_DATAPATH,
      gtwiz_reset_rx_datapath_in         => Ctrl.RESET.RX_DATAPATH,
      gtwiz_reset_rx_cdr_stable_out      => Mon.STATUS.reset_rx_cdr_stable,
      gtwiz_reset_tx_done_out            => Mon.STATUS.reset_tx_done,
      gtwiz_reset_rx_done_out            => Mon.STATUS.reset_rx_done,
      gtwiz_userdata_tx_in               => bypass_data,
      gtwiz_userdata_rx_out              => bypass_data,
      gtrefclk00_in                      => LDAQ_CLK,
      qpll0outclk_out                    => open,
      qpll0outrefclk_out                 => open,
      gthrxn_in                          => LDAQ_RX_N,
      gthrxp_in                          => LDAQ_RX_P,
      rx8b10ben_in                       => '1',
      rxcommadeten_in                    => '1',
      rxmcommaalignen_in                 => '1',
      rxpcommaalignen_in                 => '1',
      tx8b10ben_in                       => '1',
      txctrl0_in                         => Ctrl.tx.ctrl0,
      txctrl1_in                         => Ctrl.tx.ctrl1,
      txctrl2_in                         => Ctrl.tx.ctrl2,
      gthtxn_out                         => LDAQ_TX_N,
      gthtxp_out                         => LDAQ_TX_P,
      gtpowergood_out                    => Mon.STATUS.gt_power_good,
      rxbyteisaligned_out                => Mon.STATUS.rx_byte_isaligned,
      rxbyterealign_out                  => Mon.STATUS.rx_byte_realign,
      rxcommadet_out                     => Mon.STATUS.rx_commadet,
      rxctrl0_out                        => Mon.RX.ctrl0,
      rxctrl1_out                        => Mon.RX.ctrl1,
      rxctrl2_out                        => Mon.RX.ctrl2,
      rxctrl3_out                        => Mon.RX.ctrl3,
      rxpmaresetdone_out                 => Mon.STATUS.rx_pma_reset_done,
      txpmaresetdone_out                 => Mon.STATUS.tx_pma_reset_done);


  LDAQ_interface_1: entity work.LDAQ_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => slave_readMOSI,
      slave_readMISO  => slave_readMISO,
      slave_writeMOSI => slave_writeMOSI,
      slave_writeMISO => slave_writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
  
end architecture behavioral;
