library ieee;
use ieee.std_logic_1164.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.LDAQ_Ctrl.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity LDAQ is
  generic (
    ALLOCATED_MEMORY_RANGE : integer
    );
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

  signal bypass_data : slv_32_t;
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
      gtwiz_userclk_tx_reset_in(0)          => Ctrl.RESET.USERCLK_TX,
      gtwiz_userclk_tx_srcclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk2_out(0)       => open,
      gtwiz_userclk_tx_active_out(0)        => Mon.STATUS.userclk_tx_active,
      gtwiz_userclk_rx_reset_in(0)          => Ctrl.RESET.USERCLK_RX,
      gtwiz_userclk_rx_srcclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk2_out(0)       => open,
      gtwiz_userclk_rx_active_out(0)        => Mon.STATUS.userclk_rx_active,
      gtwiz_reset_clk_freerun_in(0)         => '0',
      gtwiz_reset_all_in(0)                 => Ctrl.RESET.RESET_ALL,
      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl.RESET.TX_PLL_AND_DATAPATH,
      gtwiz_reset_tx_datapath_in(0)         => Ctrl.RESET.TX_DATAPATH,
      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl.RESET.RX_PLL_AND_DATAPATH,
      gtwiz_reset_rx_datapath_in(0)         => Ctrl.RESET.RX_DATAPATH,
      gtwiz_reset_rx_cdr_stable_out(0)      => Mon.STATUS.reset_rx_cdr_stable,
      gtwiz_reset_tx_done_out(0)            => Mon.STATUS.reset_tx_done,
      gtwiz_reset_rx_done_out(0)            => Mon.STATUS.reset_rx_done,
      gtwiz_userdata_tx_in                  => bypass_data,
      gtwiz_userdata_rx_out                 => bypass_data,
      gtrefclk00_in(0)                      => LDAQ_CLK,
      qpll0outclk_out(0)                    => open,
      qpll0outrefclk_out(0)                 => open,
      gthrxn_in(0)                          => LDAQ_RX_N,
      gthrxp_in(0)                          => LDAQ_RX_P,
      rx8b10ben_in(0)                       => '1',
      rxcommadeten_in(0)                    => '1',
      rxmcommaalignen_in(0)                 => '1',
      rxpcommaalignen_in(0)                 => '1',
      tx8b10ben_in(0)                       => '1',
      txctrl0_in                            => Ctrl.tx.ctrl0,
      txctrl1_in                            => Ctrl.tx.ctrl1,
      txctrl2_in                            => Ctrl.tx.ctrl2,
      gthtxn_out(0)                         => LDAQ_TX_N,
      gthtxp_out(0)                         => LDAQ_TX_P,
      gtpowergood_out(0)                    => Mon.STATUS.gt_power_good,
      rxbyteisaligned_out(0)                => Mon.STATUS.rx_byte_isaligned,
      rxbyterealign_out(0)                  => Mon.STATUS.rx_byte_realign,
      rxcommadet_out(0)                     => Mon.STATUS.rx_commadet,
      rxctrl0_out                           => Mon.RX.ctrl0,
      rxctrl1_out                           => Mon.RX.ctrl1,
      rxctrl2_out                           => Mon.RX.ctrl2,
      rxctrl3_out                           => Mon.RX.ctrl3,
      rxpmaresetdone_out(0)                 => Mon.STATUS.rx_pma_reset_done,
      txpmaresetdone_out(0)                 => Mon.STATUS.tx_pma_reset_done);


  LDAQ_interface_1: entity work.LDAQ_map
    generic map(
      ALLOCATED_MEMORY_RANGE => ALLOCATED_MEMORY_RANGE
      )              
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
