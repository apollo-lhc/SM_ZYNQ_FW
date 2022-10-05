library ieee;
use ieee.std_logic_1164.all;

use work.localTCDS_MGT_PKG.all;

entity localTCDS_MGT_wrapper is

  port (
    common_in   : in  localTCDS_MGT_CommonIn;
    common_out  : out localTCDS_MGT_CommonOut;
    clocks_in   : in  localTCDS_MGT_ClocksIn;
    channel_in  : in  localTCDS_MGT_ChannelIn_array_t(1 downto 1);
    channel_out : out localTCDS_MGT_ChannelOut_array_t(1 downto 1));
end entity localTCDS_MGT_wrapper;

architecture behavioral of localTCDS_MGT_wrapper is
component localTCDS_MGT
  port(
gtwiz_userclk_tx_reset_in : in  std_logic_vector(0 downto 0);
gtwiz_userclk_tx_srcclk_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_tx_usrclk_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_tx_usrclk2_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_tx_active_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_rx_reset_in : in  std_logic_vector(0 downto 0);
gtwiz_userclk_rx_srcclk_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_rx_usrclk_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_rx_usrclk2_out : out std_logic_vector(0 downto 0);
gtwiz_userclk_rx_active_out : out std_logic_vector(0 downto 0);
gtwiz_reset_clk_freerun_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_all_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_tx_datapath_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_rx_datapath_in : in  std_logic_vector(0 downto 0);
gtwiz_reset_rx_cdr_stable_out : out std_logic_vector(0 downto 0);
gtwiz_reset_tx_done_out : out std_logic_vector(0 downto 0);
gtwiz_reset_rx_done_out : out std_logic_vector(0 downto 0);
gtwiz_userdata_tx_in : in  std_logic_vector(31 downto 0);
gtwiz_userdata_rx_out : out std_logic_vector(31 downto 0);
cpllreset_in : in  std_logic_vector(0 downto 0);
drpaddr_in : in  std_logic_vector(9 downto 0);
drpclk_in : in  std_logic_vector(0 downto 0);
drpdi_in : in  std_logic_vector(15 downto 0);
drpen_in : in  std_logic_vector(0 downto 0);
drprst_in : in  std_logic_vector(0 downto 0);
drpwe_in : in  std_logic_vector(0 downto 0);
eyescanreset_in : in  std_logic_vector(0 downto 0);
eyescantrigger_in : in  std_logic_vector(0 downto 0);
gthrxn_in : in  std_logic_vector(0 downto 0);
gthrxp_in : in  std_logic_vector(0 downto 0);
gtrefclk0_in : in  std_logic_vector(0 downto 0);
loopback_in : in  std_logic_vector(2 downto 0);
pcsrsvdin_in : in  std_logic_vector(15 downto 0);
rx8b10ben_in : in  std_logic_vector(0 downto 0);
rxbufreset_in : in  std_logic_vector(0 downto 0);
rxcdrhold_in : in  std_logic_vector(0 downto 0);
rxcommadeten_in : in  std_logic_vector(0 downto 0);
rxdfelpmreset_in : in  std_logic_vector(0 downto 0);
rxlpmen_in : in  std_logic_vector(0 downto 0);
rxmcommaalignen_in : in  std_logic_vector(0 downto 0);
rxoutclksel_in : in  std_logic_vector(2 downto 0);
rxpcommaalignen_in : in  std_logic_vector(0 downto 0);
rxpcsreset_in : in  std_logic_vector(0 downto 0);
rxpmareset_in : in  std_logic_vector(0 downto 0);
rxprbscntreset_in : in  std_logic_vector(0 downto 0);
rxprbssel_in : in  std_logic_vector(3 downto 0);
rxrate_in : in  std_logic_vector(2 downto 0);
tx8b10ben_in : in  std_logic_vector(0 downto 0);
txctrl0_in : in  std_logic_vector(15 downto 0);
txctrl1_in : in  std_logic_vector(15 downto 0);
txctrl2_in : in  std_logic_vector(7 downto 0);
txdiffctrl_in : in  std_logic_vector(4 downto 0);
txinhibit_in : in  std_logic_vector(0 downto 0);
txoutclksel_in : in  std_logic_vector(2 downto 0);
txpcsreset_in : in  std_logic_vector(0 downto 0);
txpmareset_in : in  std_logic_vector(0 downto 0);
txpolarity_in : in  std_logic_vector(0 downto 0);
txpostcursor_in : in  std_logic_vector(4 downto 0);
txprbsforceerr_in : in  std_logic_vector(0 downto 0);
txprbssel_in : in  std_logic_vector(3 downto 0);
txprecursor_in : in  std_logic_vector(4 downto 0);
cplllock_out : out std_logic_vector(0 downto 0);
dmonitorout_out : out std_logic_vector(15 downto 0);
drpdo_out : out std_logic_vector(15 downto 0);
drprdy_out : out std_logic_vector(0 downto 0);
eyescandataerror_out : out std_logic_vector(0 downto 0);
gthtxn_out : out std_logic_vector(0 downto 0);
gthtxp_out : out std_logic_vector(0 downto 0);
gtpowergood_out : out std_logic_vector(0 downto 0);
rxbufstatus_out : out std_logic_vector(2 downto 0);
rxbyteisaligned_out : out std_logic_vector(0 downto 0);
rxbyterealign_out : out std_logic_vector(0 downto 0);
rxcommadet_out : out std_logic_vector(0 downto 0);
rxctrl0_out : out std_logic_vector(15 downto 0);
rxctrl1_out : out std_logic_vector(15 downto 0);
rxctrl2_out : out std_logic_vector(7 downto 0);
rxctrl3_out : out std_logic_vector(7 downto 0);
rxpmaresetdone_out : out std_logic_vector(0 downto 0);
rxprbserr_out : out std_logic_vector(0 downto 0);
rxresetdone_out : out std_logic_vector(0 downto 0);
txbufstatus_out : out std_logic_vector(1 downto 0);
txpmaresetdone_out : out std_logic_vector(0 downto 0);
txresetdone_out : out std_logic_vector(0 downto 0)  );
END COMPONENT;
begin
localTCDS_MGT_inst : entity work.localTCDS_MGT
  port map (
  
    gtwiz_userclk_tx_reset_in (0) => Common_In.gtwiz_userclk_tx_reset_in, 
    gtwiz_userclk_rx_reset_in (0) => Common_In.gtwiz_userclk_rx_reset_in, 
    gtwiz_reset_clk_freerun_in (0) => Common_In.gtwiz_reset_clk_freerun_in, 
    gtwiz_reset_all_in (0) => Common_In.gtwiz_reset_all_in, 
    gtwiz_reset_tx_pll_and_datapath_in (0) => Common_In.gtwiz_reset_tx_pll_and_datapath_in, 
    gtwiz_reset_tx_datapath_in (0) => Common_In.gtwiz_reset_tx_datapath_in, 
    gtwiz_reset_rx_pll_and_datapath_in (0) => Common_In.gtwiz_reset_rx_pll_and_datapath_in, 
    gtwiz_reset_rx_datapath_in (0) => Common_In.gtwiz_reset_rx_datapath_in, 
    gtwiz_userclk_tx_srcclk_out (0) => Common_Out.gtwiz_userclk_tx_srcclk_out, 
    gtwiz_userclk_tx_usrclk_out (0) => Common_Out.gtwiz_userclk_tx_usrclk_out, 
    gtwiz_userclk_tx_usrclk2_out (0) => Common_Out.gtwiz_userclk_tx_usrclk2_out, 
    gtwiz_userclk_tx_active_out (0) => Common_Out.gtwiz_userclk_tx_active_out, 
    gtwiz_userclk_rx_srcclk_out (0) => Common_Out.gtwiz_userclk_rx_srcclk_out, 
    gtwiz_userclk_rx_usrclk_out (0) => Common_Out.gtwiz_userclk_rx_usrclk_out, 
    gtwiz_userclk_rx_usrclk2_out (0) => Common_Out.gtwiz_userclk_rx_usrclk2_out, 
    gtwiz_userclk_rx_active_out (0) => Common_Out.gtwiz_userclk_rx_active_out, 
    gtwiz_reset_rx_cdr_stable_out (0) => Common_Out.gtwiz_reset_rx_cdr_stable_out, 
    gtwiz_reset_tx_done_out (0) => Common_Out.gtwiz_reset_tx_done_out, 
    gtwiz_reset_rx_done_out (0) => Common_Out.gtwiz_reset_rx_done_out, 
    gtrefclk0_in (0) => Clocks_In.gtrefclk0_in, 
    gtwiz_userdata_tx_in => std_logic_vector'( "" &
              Channel_In(1).gtwiz_userdata_tx_in), 
    cpllreset_in => std_logic_vector'( "" &
              Channel_In(1).cpllreset_in), 
    drpaddr_in => std_logic_vector'( "" &
              Channel_In(1).drpaddr_in), 
    drpclk_in => std_logic_vector'( "" &
              Channel_In(1).drpclk_in), 
    drpdi_in => std_logic_vector'( "" &
              Channel_In(1).drpdi_in), 
    drpen_in => std_logic_vector'( "" &
              Channel_In(1).drpen_in), 
    drprst_in => std_logic_vector'( "" &
              Channel_In(1).drprst_in), 
    drpwe_in => std_logic_vector'( "" &
              Channel_In(1).drpwe_in), 
    eyescanreset_in => std_logic_vector'( "" &
              Channel_In(1).eyescanreset_in), 
    eyescantrigger_in => std_logic_vector'( "" &
              Channel_In(1).eyescantrigger_in), 
    gthrxn_in => std_logic_vector'( "" &
              Channel_In(1).gthrxn_in), 
    gthrxp_in => std_logic_vector'( "" &
              Channel_In(1).gthrxp_in), 
    loopback_in => std_logic_vector'( "" &
              Channel_In(1).loopback_in), 
    pcsrsvdin_in => std_logic_vector'( "" &
              Channel_In(1).pcsrsvdin_in), 
    rx8b10ben_in => std_logic_vector'( "" &
              Channel_In(1).rx8b10ben_in), 
    rxbufreset_in => std_logic_vector'( "" &
              Channel_In(1).rxbufreset_in), 
    rxcdrhold_in => std_logic_vector'( "" &
              Channel_In(1).rxcdrhold_in), 
    rxcommadeten_in => std_logic_vector'( "" &
              Channel_In(1).rxcommadeten_in), 
    rxdfelpmreset_in => std_logic_vector'( "" &
              Channel_In(1).rxdfelpmreset_in), 
    rxlpmen_in => std_logic_vector'( "" &
              Channel_In(1).rxlpmen_in), 
    rxmcommaalignen_in => std_logic_vector'( "" &
              Channel_In(1).rxmcommaalignen_in), 
    rxoutclksel_in => std_logic_vector'( "" &
              Channel_In(1).rxoutclksel_in), 
    rxpcommaalignen_in => std_logic_vector'( "" &
              Channel_In(1).rxpcommaalignen_in), 
    rxpcsreset_in => std_logic_vector'( "" &
              Channel_In(1).rxpcsreset_in), 
    rxpmareset_in => std_logic_vector'( "" &
              Channel_In(1).rxpmareset_in), 
    rxprbscntreset_in => std_logic_vector'( "" &
              Channel_In(1).rxprbscntreset_in), 
    rxprbssel_in => std_logic_vector'( "" &
              Channel_In(1).rxprbssel_in), 
    rxrate_in => std_logic_vector'( "" &
              Channel_In(1).rxrate_in), 
    tx8b10ben_in => std_logic_vector'( "" &
              Channel_In(1).tx8b10ben_in), 
    txctrl0_in => std_logic_vector'( "" &
              Channel_In(1).txctrl0_in), 
    txctrl1_in => std_logic_vector'( "" &
              Channel_In(1).txctrl1_in), 
    txctrl2_in => std_logic_vector'( "" &
              Channel_In(1).txctrl2_in), 
    txdiffctrl_in => std_logic_vector'( "" &
              Channel_In(1).txdiffctrl_in), 
    txinhibit_in => std_logic_vector'( "" &
              Channel_In(1).txinhibit_in), 
    txoutclksel_in => std_logic_vector'( "" &
              Channel_In(1).txoutclksel_in), 
    txpcsreset_in => std_logic_vector'( "" &
              Channel_In(1).txpcsreset_in), 
    txpmareset_in => std_logic_vector'( "" &
              Channel_In(1).txpmareset_in), 
    txpolarity_in => std_logic_vector'( "" &
              Channel_In(1).txpolarity_in), 
    txpostcursor_in => std_logic_vector'( "" &
              Channel_In(1).txpostcursor_in), 
    txprbsforceerr_in => std_logic_vector'( "" &
              Channel_In(1).txprbsforceerr_in), 
    txprbssel_in => std_logic_vector'( "" &
              Channel_In(1).txprbssel_in), 
    txprecursor_in => std_logic_vector'( "" &
              Channel_In(1).txprecursor_in), 
    gtwiz_userdata_rx_out ((32*(0+1))-1 downto (32*0)) => Channel_Out(0 + 1).gtwiz_userdata_rx_out
, 
    cplllock_out (0) => Channel_Out(0 + 1).cplllock_out
, 
    dmonitorout_out ((16*(0+1))-1 downto (16*0)) => Channel_Out(0 + 1).dmonitorout_out
, 
    drpdo_out ((16*(0+1))-1 downto (16*0)) => Channel_Out(0 + 1).drpdo_out
, 
    drprdy_out (0) => Channel_Out(0 + 1).drprdy_out
, 
    eyescandataerror_out (0) => Channel_Out(0 + 1).eyescandataerror_out
, 
    gthtxn_out (0) => Channel_Out(0 + 1).gthtxn_out
, 
    gthtxp_out (0) => Channel_Out(0 + 1).gthtxp_out
, 
    gtpowergood_out (0) => Channel_Out(0 + 1).gtpowergood_out
, 
    rxbufstatus_out ((3*(0+1))-1 downto (3*0)) => Channel_Out(0 + 1).rxbufstatus_out
, 
    rxbyteisaligned_out (0) => Channel_Out(0 + 1).rxbyteisaligned_out
, 
    rxbyterealign_out (0) => Channel_Out(0 + 1).rxbyterealign_out
, 
    rxcommadet_out (0) => Channel_Out(0 + 1).rxcommadet_out
, 
    rxctrl0_out ((16*(0+1))-1 downto (16*0)) => Channel_Out(0 + 1).rxctrl0_out
, 
    rxctrl1_out ((16*(0+1))-1 downto (16*0)) => Channel_Out(0 + 1).rxctrl1_out
, 
    rxctrl2_out ((8*(0+1))-1 downto (8*0)) => Channel_Out(0 + 1).rxctrl2_out
, 
    rxctrl3_out ((8*(0+1))-1 downto (8*0)) => Channel_Out(0 + 1).rxctrl3_out
, 
    rxpmaresetdone_out (0) => Channel_Out(0 + 1).rxpmaresetdone_out
, 
    rxprbserr_out (0) => Channel_Out(0 + 1).rxprbserr_out
, 
    rxresetdone_out (0) => Channel_Out(0 + 1).rxresetdone_out
, 
    txbufstatus_out ((2*(0+1))-1 downto (2*0)) => Channel_Out(0 + 1).txbufstatus_out
, 
    txpmaresetdone_out (0) => Channel_Out(0 + 1).txpmaresetdone_out
, 
    txresetdone_out (0) => Channel_Out(0 + 1).txresetdone_out
);
channel_out(1).TXRX_TYPE <= "0001";
end architecture behavioral;
