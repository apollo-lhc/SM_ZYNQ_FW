library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

use work.TCDS_2_Ctrl.all;

entity TCDS_local is
  port (
    -- AXI interface
    clk_axi      : in  std_logic;
    reset_axi_n  : in  std_logic;
    QPLL_clk     : in  std_logic_vector(2 downto 1);
    QPLL_refclk  : in  std_logic_vector(2 downto 1);
    QPLL_locked  : in  std_logic_vector(2 downto 1);

    LTTC_P       : out std_logic_vector(1 downto 0);
    LTTC_N       : out std_logic_vector(1 downto 0);
    LTTS_P       : in  std_logic_vector(1 downto 0);
    LTTS_N       : in  std_logic_vector(1 downto 0);
                 
    ttc_data     : in  std_logic_vector(31 downto 0);
    tts_data     : out std_logic_vector(31 downto 0);
                 
    Ctrl         : in  TCDS_2_LTCDS_CTRL_t_ARRAY;
    Mon          : out TCDS_2_LTCDS_MON_t_ARRAY
    );
end entity TCDS_local;

architecture behavioral of TCDS_local is

  signal reset            : std_logic;
  
  signal rx_datas         : slv32_array_t(1 downto 0);
  signal rx_k_datas        : slv4_array_t(1 downto 0);

  signal clk_tx_int        : std_logic_vector( 1 downto 0);
                         
  signal tx_datas          : slv32_array_t(1 downto 0);
  signal tx_k_datas        : slv4_array_t(1 downto 0);
  signal tx_datas_fixed    : slv32_array_t(1 downto 0);
  signal tx_k_datas_fixed  : slv4_array_t(1 downto 0);

  signal capture_datas     : std_logic_vector(1 downto 0);
  signal mode              : slv4_array_t(1 downto 0);
    
begin
  reset <= not reset_axi_n;
  
--  clk_tx_int <= QPLL_clk(1);
  tts_data <= rx_datas(1) or rx_datas(0);
  
  local_TCDS: for iCM in 1 to 2 generate

    DC_data_CDC_1: entity work.DC_data_CDC
      generic map (
        DATA_WIDTH => 4)
      port map (
        clk_in   => clk_axi,
        clk_out  => clk_tx_int(iCM-1),
        reset    => reset,
        pass_in  => Ctrl(iCM).DATA_CTRL.MODE,
        pass_out => mode(iCM-1));

    --pass fixed data to the txrx domain for sending
    DC_data_CDC_2: entity work.DC_data_CDC
      generic map (
        DATA_WIDTH => 36)
      port map (
        clk_in   => clk_axi,
        clk_out  => clk_tx_int(iCM-1),
        reset    => reset,
        pass_in(31 downto  0)  => Ctrl(iCM).DATA_CTRL.FIXED_SEND_D,
        pass_in(35 downto 32)  => Ctrl(iCM).DATA_CTRL.FIXED_SEND_K,
        pass_out(31 downto  0) => tx_datas_fixed(iCM-1),
        pass_out(35 downto 32) => tx_k_datas_fixed(iCM-1));
    

    --Capture rx data from the txrx domain via a capture pulse
    capture_CDC_2: entity work.capture_CDC
      generic map (
        WIDTH => 36)
      port map (
        clkA           => clk_axi,
        resetA         => reset,
        clkB           => clk_tx_int(iCM-1),
        resetB         => reset,
        capture_pulseA => Ctrl(iCM).DATA_CTRL.CAPTURE,
        outA(31 downto  0) => Mon(iCM).DATA_CTRL.CAPTURE_D,
        outA(35 downto 32) => Mon(iCM).DATA_CTRL.CAPTURE_K,
        outA_valid     => open,
        capture_pulseB => open,
        inB(31 downto  0) => rx_datas(iCM-1),
        inB(35 downto 32) => rx_k_datas(iCM-1),
        inB_valid      => '1');

    data_proc: process (clk_tx_int(iCM-1), reset) is
    begin  -- process data_proc
      if reset = '1' then               -- asynchronous reset (active high)
        tx_datas(iCM-1) <= x"BCBCBCBC";
        tx_k_datas(iCM-1) <= x"F";      
      elsif clk_tx_int(iCM-1)'event and clk_tx_int(iCM-1) = '1' then  -- rising clock edge
        case mode(iCM-1) is
          when x"0"  =>
            tx_datas(iCM-1) <= ttc_data;
            tx_k_datas(iCM-1) <= x"0";
          when x"1"  => 
            tx_datas(iCM-1) <= rx_datas(iCM-1);
            tx_k_datas(iCM-1) <= rx_k_datas(iCM-1);
          when x"2" =>
            tx_datas(iCM-1) <= x"BCBCBCBC";
            tx_k_datas(iCM-1) <= x"F";
          when x"3" =>
            tx_datas(iCM-1)   <= tx_datas_fixed(iCM-1);
            tx_k_datas(iCM-1) <= tx_k_datas_fixed(iCM-1);            
          when others =>
            tx_datas(iCM-1) <= x"BCBCBCBC";
            tx_k_datas(iCM-1) <= x"F";
        end case;
      end if;
    end process data_proc;

    
    local_TCDS_MGBT_1: entity work.LOCAL_TCDS2
    port map (
      gtwiz_userclk_tx_reset_in(0)          => Ctrl(iCM).RESET.USERCLK_TX,
      gtwiz_userclk_tx_srcclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk_out(0)        => open,
      gtwiz_userclk_tx_usrclk2_out(0)       => open,
      gtwiz_userclk_tx_active_out(0)        => open,--Mon(iCM).STATUS.userclk_tx_active,
      gtwiz_userclk_rx_reset_in(0)          => Ctrl(iCM).RESET.USERCLK_RX,
      gtwiz_userclk_rx_srcclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk_out(0)        => open,
      gtwiz_userclk_rx_usrclk2_out(0)       => clk_tx_int(iCM-1),
      gtwiz_userclk_rx_active_out(0)        => open,--Mon(iCM).STATUS.userclk_rx_active,
      gtwiz_reset_clk_freerun_in(0)         => '0',
      gtwiz_reset_all_in(0)                 => Ctrl(iCM).RESET.RESET_ALL,
      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl(iCM).RESET.TX_PLL_AND_DATAPATH,
      gtwiz_reset_tx_datapath_in(0)         => Ctrl(iCM).RESET.TX_DATAPATH,
      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl(iCM).RESET.RX_PLL_AND_DATAPATH,
      gtwiz_reset_rx_datapath_in(0)         => Ctrl(iCM).RESET.RX_DATAPATH,
      gtwiz_reset_qpll0lock_in(0)           => QPLL_locked(1),
      gtwiz_reset_rx_cdr_stable_out(0)      => open,--Mon(iCM).STATUS.reset_rx_cdr_stable,
      gtwiz_reset_tx_done_out(0)            => Mon(iCM).DEBUG.tx.reset_done,
      gtwiz_reset_rx_done_out(0)            => Mon(iCM).DEBUG.rx.reset_done,
      gtwiz_reset_qpll0reset_out(0)         => open,
      gtwiz_userdata_tx_in                  => tx_datas(iCM-1),
      gtwiz_userdata_rx_out                 => rx_datas(iCM-1),
      drpaddr_in                            => Ctrl(iCM).DRP.address,
      drpclk_in(0)                          => Ctrl(iCM).DRP.clk,
      drpdi_in                              => Ctrl(iCM).DRP.wr_data,
      drpen_in(0)                           => Ctrl(iCM).DRP.enable or Ctrl(iCM).DRP.wr_enable,
      drpwe_in(0)                           => Ctrl(iCM).DRP.wr_enable,
      eyescanreset_in(0)                    => Ctrl(iCM).DEBUG.EYESCAN_RESET,
      eyescantrigger_in(0)                  => Ctrl(iCM).DEBUG.EYESCAN_TRIGGER,
      gthrxn_in(0)                          => LTTS_N(iCM-1),
      gthrxp_in(0)                          => LTTS_P(iCM-1),
      pcsrsvdin_in                          => Ctrl(iCM).DEBUG.PCS_RSV_DIN,
--      loopback_in                           => ,
      qpll0clk_in(0)                        => QPLL_clk(1),   
      qpll0refclk_in(0)                     => QPLL_refclk(1),
      qpll1clk_in(0)                        => QPLL_clk(2),   
      qpll1refclk_in(0)                     => QPLL_refclk(2),
      rx8b10ben_in(0)                       => '1',
      rxbufreset_in(0)                      => Ctrl(iCM).DEBUG.RX.BUF_RESET,
      rxcdrhold_in(0)                       => Ctrl(iCM).DEBUG.RX.CDR_HOLD,
      rxcommadeten_in(0)                    => '1',
      rxdfelpmreset_in(0)                   => Ctrl(iCM).DEBUG.RX.DFE_LPM_RESET,
      rxlpmen_in(0)                         => Ctrl(iCM).DEBUG.RX.LPM_EN,
      rxmcommaalignen_in(0)                 => '1',
      rxpcommaalignen_in(0)                 => '1',
      rxpcsreset_in(0)                      => Ctrl(iCM).DEBUG.RX.PCS_RESET,
      rxpmareset_in(0)                      => Ctrl(iCM).DEBUG.RX.PMA_RESET,
      rxprbscntreset_in(0)                  => Ctrl(iCM).DEBUG.RX.PRBS_CNT_RST,
      rxprbssel_in                          => Ctrl(iCM).DEBUG.RX.PRBS_SEL,
      rxrate_in                             => Ctrl(iCM).DEBUG.RX.RATE,
      tx8b10ben_in(0)                       => '1',
      txctrl0_in                            => Ctrl(iCM).tx.ctrl0,
      txctrl1_in                            => Ctrl(iCM).tx.ctrl1,
      txctrl2_in( 3 downto  0)              => tx_k_datas(iCM-1),
      txctrl2_in( 7 downto  4)              => Ctrl(iCM).tx.ctrl2(7 downto 4),
      txdiffctrl_in                         => Ctrl(iCM).DEBUG.TX.DIFF_CTRL,
      txinhibit_in(0)                       => Ctrl(iCM).DEBUG.TX.INHIBIT,
      txpcsreset_in(0)                      => Ctrl(iCM).DEBUG.TX.PCS_RESET,
      txpmareset_in(0)                      => Ctrl(iCM).DEBUG.TX.PMA_RESET,
      txpolarity_in(0)                      => Ctrl(iCM).DEBUG.TX.POLARITY,
      txpostcursor_in                       => Ctrl(iCM).DEBUG.TX.POST_CURSOR,
      txprbsforceerr_in(0)                  => Ctrl(iCM).DEBUG.TX.PRBS_FORCE_ERR,
      txprbssel_in                          => Ctrl(iCM).DEBUG.TX.PRBS_SEL,
      txprecursor_in                        => Ctrl(iCM).DEBUG.TX.PRE_CURSOR,
      cplllock_out(0)                       => Mon(iCM).DEBUG.CPLL_LOCK,
      dmonitorout_out                       => Mon(iCM).DEBUG.DMONITOR,
      drpdo_out                             => Mon(iCM).DRP.rd_data,
      drprdy_out(0)                         => Mon(iCM).DRP.rd_data_valid,
      eyescandataerror_out(0)               => Mon(iCM).DEBUG.EYESCAN_DATA_ERROR,
      gthtxn_out(0)                         => LTTC_N(iCM-1),
      gthtxp_out(0)                         => LTTC_P(iCM-1),
      gtpowergood_out(0)                    => open,--Mon(iCM).STATUS.gt_power_good,
      rxbufstatus_out                       => Mon(iCM).DEBUG.rx.BUF_STATUS,
      rxbyteisaligned_out(0)                => open,--Mon(iCM).STATUS.rx_byte_isaligned,
      rxbyterealign_out(0)                  => open,--Mon(iCM).STATUS.rx_byte_realign,
      rxcommadet_out(0)                     => open,--Mon(iCM).STATUS.rx_commadet,
      rxctrl0_out( 3 downto  0)             => rx_k_datas(iCM-1),
      rxctrl0_out(15 downto  4)             => Mon(iCM).RX.ctrl0(15 downto  4),
      rxctrl1_out                           => Mon(iCM).RX.ctrl1,
      rxctrl2_out                           => Mon(iCM).RX.ctrl2,
      rxctrl3_out                           => Mon(iCM).RX.ctrl3,
      rxpmaresetdone_out(0)                 => Mon(iCM).DEBUG.RX.pma_reset_done,
      rxprbserr_out(0)                      => Mon(iCM).DEBUG.RX.PRBS_ERR,
--      rxresetdone_out(0)                    => Mon(iCM).DEBUG.RX.RESET_DONE,
      txbufstatus_out                       => Mon(iCM).DEBUG.TX.BUF_STATUS,
--      txresetdone_out(0)                    => Mon(iCM).DEBUG.TX.RESET_DONE,
      txpmaresetdone_out(0)                 => open);--Mon(iCM).DEBUG.tx.pma_reset_done);
  end generate local_TCDS;





  
  
  
end behavioral;

