----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package localTCDS_MGT_PKG is
type localTCDS_MGT_CommonIn is record
  gtwiz_userclk_tx_reset_in      : std_logic;
  gtwiz_userclk_rx_reset_in      : std_logic;
  gtwiz_reset_clk_freerun_in     : std_logic;
  gtwiz_reset_all_in             : std_logic;
  gtwiz_reset_tx_pll_and_datapath_in : std_logic;
  gtwiz_reset_tx_datapath_in     : std_logic;
  gtwiz_reset_rx_pll_and_datapath_in : std_logic;
  gtwiz_reset_rx_datapath_in     : std_logic;
end record localTCDS_MGT_CommonIn;
type localTCDS_MGT_CommonIn_array_t is array (integer range <>) of localTCDS_MGT_CommonIn;
type localTCDS_MGT_CommonOut is record
  gtwiz_userclk_tx_srcclk_out    : std_logic;
  gtwiz_userclk_tx_usrclk_out    : std_logic;
  gtwiz_userclk_tx_usrclk2_out   : std_logic;
  gtwiz_userclk_tx_active_out    : std_logic;
  gtwiz_userclk_rx_srcclk_out    : std_logic;
  gtwiz_userclk_rx_usrclk_out    : std_logic;
  gtwiz_userclk_rx_usrclk2_out   : std_logic;
  gtwiz_userclk_rx_active_out    : std_logic;
  gtwiz_reset_rx_cdr_stable_out  : std_logic;
  gtwiz_reset_tx_done_out        : std_logic;
  gtwiz_reset_rx_done_out        : std_logic;
end record localTCDS_MGT_CommonOut;
type localTCDS_MGT_CommonOut_array_t is array (integer range <>) of localTCDS_MGT_CommonOut;
type localTCDS_MGT_ClocksIn is record
  gtrefclk0_in                   : std_logic;
end record localTCDS_MGT_ClocksIn;
type localTCDS_MGT_ClocksIn_array_t is array (integer range <>) of localTCDS_MGT_ClocksIn;
type localTCDS_MGT_ChannelIn is record
  gtwiz_userdata_tx_in           : std_logic_vector(32 -1 downto 0);
  cpllreset_in                   : std_logic;
  drpaddr_in                     : std_logic_vector(10 -1 downto 0);
  drpclk_in                      : std_logic;
  drpdi_in                       : std_logic_vector(16 -1 downto 0);
  drpen_in                       : std_logic;
  drprst_in                      : std_logic;
  drpwe_in                       : std_logic;
  eyescanreset_in                : std_logic;
  eyescantrigger_in              : std_logic;
  gthrxn_in                      : std_logic;
  gthrxp_in                      : std_logic;
  loopback_in                    : std_logic_vector(3 -1 downto 0);
  pcsrsvdin_in                   : std_logic_vector(16 -1 downto 0);
  rx8b10ben_in                   : std_logic;
  rxbufreset_in                  : std_logic;
  rxcdrhold_in                   : std_logic;
  rxcommadeten_in                : std_logic;
  rxdfelpmreset_in               : std_logic;
  rxlpmen_in                     : std_logic;
  rxmcommaalignen_in             : std_logic;
  rxoutclksel_in                 : std_logic_vector(3 -1 downto 0);
  rxpcommaalignen_in             : std_logic;
  rxpcsreset_in                  : std_logic;
  rxpmareset_in                  : std_logic;
  rxprbscntreset_in              : std_logic;
  rxprbssel_in                   : std_logic_vector(4 -1 downto 0);
  rxrate_in                      : std_logic_vector(3 -1 downto 0);
  tx8b10ben_in                   : std_logic;
  txctrl0_in                     : std_logic_vector(16 -1 downto 0);
  txctrl1_in                     : std_logic_vector(16 -1 downto 0);
  txctrl2_in                     : std_logic_vector(8 -1 downto 0);
  txdiffctrl_in                  : std_logic_vector(5 -1 downto 0);
  txinhibit_in                   : std_logic;
  txoutclksel_in                 : std_logic_vector(3 -1 downto 0);
  txpcsreset_in                  : std_logic;
  txpmareset_in                  : std_logic;
  txpolarity_in                  : std_logic;
  txpostcursor_in                : std_logic_vector(5 -1 downto 0);
  txprbsforceerr_in              : std_logic;
  txprbssel_in                   : std_logic_vector(4 -1 downto 0);
  txprecursor_in                 : std_logic_vector(5 -1 downto 0);
end record localTCDS_MGT_ChannelIn;
type localTCDS_MGT_ChannelIn_array_t is array (integer range <>) of localTCDS_MGT_ChannelIn;
type localTCDS_MGT_ChannelOut is record
  TXRX_TYPE                      : std_logic_vector(3 downto 0);
  gtwiz_userdata_rx_out          : std_logic_vector(32 -1 downto 0);
  cplllock_out                   : std_logic;
  dmonitorout_out                : std_logic_vector(16 -1 downto 0);
  drpdo_out                      : std_logic_vector(16 -1 downto 0);
  drprdy_out                     : std_logic;
  eyescandataerror_out           : std_logic;
  gthtxn_out                     : std_logic;
  gthtxp_out                     : std_logic;
  gtpowergood_out                : std_logic;
  rxbufstatus_out                : std_logic_vector(3 -1 downto 0);
  rxbyteisaligned_out            : std_logic;
  rxbyterealign_out              : std_logic;
  rxcommadet_out                 : std_logic;
  rxctrl0_out                    : std_logic_vector(16 -1 downto 0);
  rxctrl1_out                    : std_logic_vector(16 -1 downto 0);
  rxctrl2_out                    : std_logic_vector(8 -1 downto 0);
  rxctrl3_out                    : std_logic_vector(8 -1 downto 0);
  rxpmaresetdone_out             : std_logic;
  rxprbserr_out                  : std_logic;
  rxresetdone_out                : std_logic;
  txbufstatus_out                : std_logic_vector(2 -1 downto 0);
  txpmaresetdone_out             : std_logic;
  txresetdone_out                : std_logic;
end record localTCDS_MGT_ChannelOut;
type localTCDS_MGT_ChannelOut_array_t is array (integer range <>) of localTCDS_MGT_ChannelOut;
end package localTCDS_MGT_PKG;
