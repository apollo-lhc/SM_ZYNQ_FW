library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.AXIRegPkg.all; --for AXIReadMOSI, AXIReadMISO, AXIWriteMOSI, and AXIWriteMISO

--use work.tclink_lpgbt10G_pkg.all;

use work.tcds2_interface_pkg.all;
use work.tcds2_link_pkg.all;
use work.tcds2_link_speed_pkg.all;
use work.tcds2_streams_pkg.all;

use work.TCDS_2_Ctrl.all;

use work.tclink_lpgbt_pkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity TCDS is
  generic (
    AXI_CLK_FREQ : integer;
    ALLOCATED_MEMORY_RANGE : integer
    );
  port (
    -- AXI interface
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;


    -- System clock at 125 MHz.
    clk_sys_125mhz : in std_logic;

    -- MGT data interface.
    mgt_tx_p_o : out std_logic;
    mgt_tx_n_o : out std_logic;
    mgt_rx_p_i : in std_logic;
    mgt_rx_n_i : in std_logic;

    clk_TCDS_REC_in_p  : in  std_logic;
    clk_TCDS_REC_in_n  : in  std_logic;
    clk_TCDS_320_in_p  : in  std_logic;
    clk_TCDS_320_in_n  : in  std_logic;

    clk_TCDS_REC_out_p : out std_logic;
    clk_TCDS_REC_out_n : out std_logic;
    -- LHC bunch clock output.
    -- NOTE: This clock originates from a BUFGCE_DIV and is intended
    -- for use in the FPGA clocking fabric.
    clk_TCDS : out std_logic;

    LTTC_P   : out std_logic_vector(1 downto 0);
    LTTC_N   : out std_logic_vector(1 downto 0);

    LTTS_P   : in  std_logic_vector(1 downto 0);
    LTTS_N   : in  std_logic_vector(1 downto 0)

    );
end entity TCDS;

architecture behavioral of TCDS is

  signal Mon              :  TCDS_2_Mon_t;
  signal Ctrl             :  TCDS_2_Ctrl_t;

  -- Control and status interfaces.
  signal ctrl_i : tcds2_interface_ctrl_t;
  signal stat_o : tcds2_interface_stat_t;
  
  -- Transceiver control and status signals.
  signal mgt_ctrl : tr_core_to_mgt;
  signal mgt_stat : tr_mgt_to_core;
  
  -- User clock network control and status signals.
  signal mgt_clk_ctrl : tr_clk_to_mgt;
  signal mgt_clk_stat : tr_mgt_to_clk;

  -- LHC bunch clock ODDR outputs.
  -- NOTE: These lines are intended to drive an ODDR1, in order to
  -- extract the bunch clock from the FPGA.
  signal clk_40_oddr_c  : std_logic;
  signal clk_40_oddr_d1 : std_logic;
  signal clk_40_oddr_d2 : std_logic;
  signal clk_40_out     : std_logic;

  signal clk_TCDS_320   : std_logic;
  signal clk_TCDS_REC   : std_logic;

  -- TCDS2 channel 0 interface.
  signal channel0_ttc2_o : tcds2_ttc2;
  signal channel0_tts2_i : tcds2_tts2_value_array(0 downto 0);

  -- TCDS2 channel 1 interface.
  signal channel1_ttc2_o : tcds2_ttc2;
  signal channel1_tts2_i : tcds2_tts2_value_array(0 downto 0);

  constant zero : std_logic := '0';

  signal QPLL_clk    : std_logic_vector(2 downto 1);
  signal QPLL_refclk : std_logic_vector(2 downto 1);
  signal QPLL_locked : std_logic_vector(2 downto 1);

  signal ttc_data : slv_32_t;
  signal tts_data : slv_32_t;

  signal clk_TCDS_o : std_logic;
  signal reset      : std_logic;

  signal pcs_clk    : std_logic_vector(1 downto 0);


begin

  reset <= not reset_axi_n;
  
  -------------------------------------------------------------------------------
  -- AXI slave interface
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  TCDS_2_map_1: entity work.TCDS_2_map
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
  

  ------------------------------------------
  -- TCDS2
  ------------------------------------------

  TCDS_320 : ibufds_gte4
    port map (
      i   => clk_TCDS_320_in_p,
      ib  => clk_TCDS_320_in_n,
      o   => clk_TCDS_320,
      ceb => '0'
      );
  TCDS_REC : ibufds_gte4
    port map (
      i   => clk_TCDS_REC_in_p,
      ib  => clk_TCDS_REC_in_n,
      o   => clk_TCDS_REC,
      ceb => '0'
      );


  TCDS_BP_1: entity work.TCDS_BP
    port map (
      clk_sys_125mhz     => clk_sys_125mhz,
      mgt_tx_p_o         => mgt_tx_p_o,
      mgt_tx_n_o         => mgt_tx_n_o,
      mgt_rx_p_i         => mgt_rx_p_i,
      mgt_rx_n_i         => mgt_rx_n_i,
      clk_TCDS_REC       => clk_TCDS_REC,
      clk_TCDS_320       => clk_TCDS_320,
      clk_TCDS_REC_out_p => clk_TCDS_REC_out_p,
      clk_TCDS_REC_out_n => clk_TCDS_REC_out_n,
      clk_TCDS           => clk_TCDS_o,
      QPLL_clk           => QPLL_clk,
      QPLL_refclk        => QPLL_refclk,
      QPLL_locked        => QPLL_locked,
      ttc_data           => ttc_data,
      tts_data           => tts_data,
      pcs_clk            => pcs_clk,
      Mon                => Mon.TCDS_2,
      Ctrl               => Ctrl.TCDS_2);
  clk_TCDS <= clk_TCDS_o;
  
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => AXI_CLK_FREQ)
    port map (
      clk_A         => clk_axi,
      clk_B         => clk_TCDS_o,
      reset_A_async => reset,
      event_b       => '1'    ,
      rate          => Mon.TCDS2_FREQ);

  rate_counter_2: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => AXI_CLK_FREQ)
    port map (
      clk_A         => clk_axi,
      clk_B         => pcs_clk(0),
      reset_A_async => reset,
      event_b       => '1'    ,
      rate          => Mon.TCDS2_TX_PCS_FREQ);

  rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => AXI_CLK_FREQ)
    port map (
      clk_A         => clk_axi,
      clk_B         => pcs_clk(1),
      reset_A_async => reset,
      event_b       => '1'    ,
      rate          => Mon.TCDS2_RX_PCS_FREQ);


  TCDS_local_1: entity work.TCDS_local
    generic map (
      AXI_CLK_FREQ => AXI_CLK_FREQ)
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      QPLL_clk    => QPLL_clk,
      QPLL_refclk => QPLL_refclk,
      QPLL_locked => QPLL_locked,
      clk_TCDS_REC       => clk_TCDS_REC,
      clk_TCDS_320       => clk_TCDS_320,
      LTTC_P      => LTTC_P,
      LTTC_N      => LTTC_N,
      LTTS_P      => LTTS_P,
      LTTS_N      => LTTS_N,
      ttc_data    => ttc_data,
      tts_data    => tts_data,
      Ctrl        => Ctrl.LTCDS,
      Mon         => Mon.LTCDS);
  






  
  
  
end behavioral;

