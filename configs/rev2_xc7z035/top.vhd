library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.AXIRegPKG.all;
use work.SGMII_MONITOR.all;
use work.CM_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    DDR_addr          : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba            : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n         : inout STD_LOGIC;
    DDR_ck_n          : inout STD_LOGIC;
    DDR_ck_p          : inout STD_LOGIC;
    DDR_cke           : inout STD_LOGIC;
    DDR_cs_n          : inout STD_LOGIC;
    DDR_dm            : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq            : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p         : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt           : inout STD_LOGIC;
    DDR_ras_n         : inout STD_LOGIC;
    DDR_reset_n       : inout STD_LOGIC;
    DDR_we_n          : inout STD_LOGIC;
    FIXED_IO_ddr_vrn  : inout STD_LOGIC;
    FIXED_IO_ddr_vrp  : inout STD_LOGIC;
    FIXED_IO_mio      : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk   : inout STD_LOGIC;
    FIXED_IO_ps_porb  : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    
    ETH1_CLK          : out  std_logic;      
--    ETH1_INT_PWDN_N   :     std_logic;
    ETH1_MDC          : out std_logic;      
    ETH1_MDIO         : inout std_logic;     
    ETH1_RESET_N      : out std_logic; 
    ETH1A_COL_PL      : in  std_logic;  
    ETH1A_CRS_PL      : in  std_logic;
    ETH1A_RXCLK       : in  std_logic;   
    ETH1A_RXD         : in  std_logic_vector(3 downto 0);
    ETH1A_RXDV        : in  std_logic;
    ETH1A_RXER        : in  std_logic;    
    ETH1A_TXCLK       : out std_logic;   
    ETH1A_TXD         : out std_logic_vector(3 downto 0);
    ETH1A_TXEN        : out std_logic;
    
    -------------------------------------
    -- Onboard Enclustra
    I2C_SCL           : inout std_logic;
    I2C_SDA           : inout std_logic;

    onboard_CLK_P     : in  std_logic;
    onboard_CLK_N     : in  std_logic;

    -------------------------------------
    -- Misc SM
    EEPROM_WE_N       : out   std_logic;
    FP_LED_RST        : out   std_logic;
    FP_LED_CLK        : out   std_logic;
    FP_LED_SDA        : out   std_logic;
    FP_BUTTON         : in    std_logic;
    FP_1V8_GPIO       : out   std_logic_vector(5 downto 0);
    
    SATA_DETECT_N     : in    std_logic;
--         UART_Rx_Zynq  : in    std_logic; -- not used
--         UART_Tx_Zynq  : out   std_logic; -- not used

    CPLD_TCK          : out   std_logic;
    CPLD_TDI          : out   std_logic;
    CPLD_TDO          : in    std_logic;
    CPLD_TMS          : out   std_logic;


    -------------------------------------
    -- Clocking/timing
    LHC_CLK_BP_LOS    : in  std_logic;
    LHC_CLK_OSC_LOS   : in  std_logic;
    LHC_SRC_SEL       : out std_logic;

    HQ_CLK_BP_LOS     : in  std_logic;
    HQ_CLK_OSC_LOS    : in  std_logic;
    HQ_SRC_SEL        : out std_logic;

--    CLK_LHC_P         : in std_logic;
--    CLK_LHC_N         : in std_logic;
--    CLK_HQ_P          : in std_logic;
--    CLK_HQ_N          : in std_logic;

--    CLK_TTC_P         : in  std_logic;
--    CLK_TTC_N         : in  std_logic;

--    TTC_P             : in  std_logic;
--    TTC_N             : in  std_logic;
--    TTS_P             : out std_logic;
--    TTS_N             : out std_logic;
    CM_TTC_SEL        : out std_logic_vector(1 downto 0);    

    SI_INT            : in    std_logic;
    SI_LOL            : in    std_logic;
    SI_LOS_XAXB       : in    std_logic;
    SI_OUT_DIS        : out   std_logic;
    SI_ENABLE         : out   std_logic;
    SI_SCL            : inout STD_LOGIC;
    SI_SDA            : inout STD_LOGIC;
    
    -------------------------------------
    -- ESM
    ESM_UART_RX       : in  STD_LOGIC;
    ESM_UART_TX       : out STD_LOGIC;
    ESM_LED_CLK       : in std_logic;
    ESM_LED_SDA       : in std_logic;

    -------------------------------------
    -- GPIOs CPLD
--    ZYNQ_CPLD_GPIO    : in std_logic_vector(3 downto 0);

    -------------------------------------
    -- GPIOs Zynq
    GPIO              : out std_logic_vector(7 downto 0);

    -----------------------------------------------------------------------------
    -- CM interface
    -----------------------------------------------------------------------------

    -------------------------------------
    --Enable
    CM1_EN : out std_logic;         
    CM2_EN : out std_logic;

    -------------------------------------
    --PWR Enable
    CM1_PWR_EN : out std_logic;         
    CM2_PWR_EN : out std_logic;

    -------------------------------------
    --CM power good
    CM1_PWR_GOOD : in std_logic;         
    CM2_PWR_GOOD : in std_logic;

    -------------------------------------
    --CM Mon Rx
    CM1_MON_RX : in std_logic;         
--    CM2_MON_RX : in std_logic;

    -------------------------------------
    --CM UART
    CM1_UART_TX   : out std_logic;
    CM1_UART_RX   : in  std_logic;         
    CM2_UART_TX   : out std_logic;
    CM2_UART_RX   : in  std_logic;         
    
    -------------------------------------
    --CM GPIO
    CM1_GPIO         : in std_logic_vector(2 downto 0);         
    CM2_GPIO         : in std_logic_vector(2 downto 0);


    -------------------------------------
    --CM XVC
    CM1_TCK          : out   STD_LOGIC;
    CM1_TDI          : out   STD_LOGIC;
    CM1_TDO          : in    STD_LOGIC;
    CM1_TMS          : out   STD_LOGIC;
    CM1_PS_RST       : out   STD_LOGIC;
    CM2_TCK          : out   STD_LOGIC;
    CM2_TDI          : out   STD_LOGIC;
    CM2_TDO          : in    STD_LOGIC;
    CM2_TMS          : out   STD_LOGIC;
    CM2_PS_RST       : out   STD_LOGIC;

    
    
    
    
-----    -------------------------------------------------------------------------------------------
-----    -- MGBT 1
-----    -------------------------------------------------------------------------------------------
    AXI_C2C_CM1_Rx_P      : in    std_logic_vector(0 to 0);
    AXI_C2C_CM1_Rx_N      : in    std_logic_vector(0 to 0);
    AXI_C2C_CM1_Tx_P      : out   std_logic_vector(0 to 0);
    AXI_C2C_CM1_Tx_N      : out   std_logic_vector(0 to 0);

    AXI_C2C_CM2_Rx_P      : in    std_logic_vector(0 to 0);
    AXI_C2C_CM2_Rx_N      : in    std_logic_vector(0 to 0);
    AXI_C2C_CM2_Tx_P      : out   std_logic_vector(0 to 0);
    AXI_C2C_CM2_Tx_N      : out   std_logic_vector(0 to 0);

                             
--    SSD_rx_P        : in    std_logic; 
--    SSD_rx_N        : in    std_logic;
--    SSD_tx_P        : out   std_logic; 
--    SSD_tx_N        : out   std_logic; 

--    CM1_TCDS_TTS_P          : in    std_logic; 
--    CM1_TCDS_TTS_N          : in    std_logic;                       
--    TCDS_TTS_P             : out   std_logic; 
--    TCDS_TTS_N             : out   std_logic; 


--    refclk_SSD_P   : in    std_logic; 
--    refclk_SSD_N   : in    std_logic; 
--    
--    refclk_C2C1_P          : in    std_logic_vector(0 downto 0);
--    refclk_C2C1_N          : in    std_logic_vector(0 downto 0);

 
    -------------------------------------------------------------------------------------------
    -- MGBT 2
    -------------------------------------------------------------------------------------------
--    AXI_C2C_CM1_Rx_P      : in    std_logic_vector(1 to 1);
--    AXI_C2C_CM1_Rx_N      : in    std_logic_vector(1 to 1);
--    AXI_C2C_CM1_Tx_P      : out   std_logic_vector(1 to 1);
--    AXI_C2C_CM1_Tx_N      : out   std_logic_vector(1 to 1);
--                                                   1 to 1
--    AXI_C2C_CM2_Rx_P      : in    std_logic_vector(1 to 1);
--    AXI_C2C_CM2_Rx_N      : in    std_logic_vector(1 to 1);
--    AXI_C2C_CM2_Tx_P      : out   std_logic_vector(1 to 1);
--    AXI_C2C_CM2_Tx_N      : out   std_logic_vector(1 to 1);

--    TCDS_TTC_P             : in    std_logic; 
--    TCDS_TTC_N             : in    std_logic; 
--                              
--    LOCAL_TCDS_TTC_P        : out   std_logic; 
--    LOCAL_TCDS_TTC_N        : out   std_logic; 
--    CM2_TCDS_TTS_P          : in    std_logic; 
--    CM2_TCDS_TTS_N          : in    std_logic;
--
--    refclk_CMS_P      : in    std_logic; 
--    refclk_CMS_N      : in    std_logic; 

    refclk_C2C2_P          : in    std_logic_vector(0 downto 0);
    refclk_C2C2_N          : in    std_logic_vector(0 downto 0);

    
    -------------------------------------------------------------------------------------------
    -- IPMC Interface
    -------------------------------------------------------------------------------------------
    ZYNQ_BOOT_DONE         : out   std_logic;
    IPMC_SDA               : inout STD_LOGIC;
    IPMC_SCL               : in    STD_LOGIC;
--    IPMC_IN                : in    std_logic_vector(3 downto 0);
    IPMC_OUT               : out   std_logic_vector(1 downto 0)
    
    );    
end entity top;

architecture structure of top is
  component onboard_CLK
    port
      (-- Clock in ports
        -- Clock out ports
        clk_200Mhz          : out    std_logic;
        clk_50Mhz          : out    std_logic;
        -- Status and control signals
        reset             : in     std_logic;
        locked            : out    std_logic;
        clk_in1_p         : in     std_logic;
        clk_in1_n         : in     std_logic
        );
  end component;

  
  signal pl_clk : std_logic;
  signal axi_reset_n : std_logic;
  signal axi_reset : std_logic;

  signal pl_reset_n : std_logic;
  
------- TCDS
  signal refclk_TCDS : std_logic;
  signal ttc_data : std_logic_vector(35 downto 0); 
  signal tts_data : std_logic_vector(35 downto 0); 
  signal fake_ttc_data : std_logic_vector(35 downto 0);
  signal m1_tts_data : std_logic_vector(35 downto 0);
  signal m2_tts_data : std_logic_vector(35 downto 0);
  signal ttc_dv : std_logic; 
  signal tts_dv : std_logic; 
  signal fake_ttc_dv : std_logic;
  signal m1_tts_dv : std_logic;
  signal m2_tts_dv : std_logic;
  signal TTC_SRC_SEL : std_logic;
  
  -- AXI C2C
  signal AXI_C2CM1_RX_data              : STD_LOGIC_VECTOR(63 downto 0 ); -- (127 downto 0 );
  signal AXI_C2CM1_RX_dv                : STD_LOGIC;                          
  signal AXI_C2CM1_TX_data              : STD_LOGIC_VECTOR(63 downto 0 ); -- (127 downto 0 );
  signal AXI_C2CM1_TX_ready             : STD_LOGIC;                       
  signal AXI_C2CM1_TX_dv                : STD_LOGIC;                         
  signal AXI_C2C_aurora_init_clk        : STD_LOGIC;                  
  signal AXI_C2C_aurora_mmcm_not_locked : STD_LOGIC;           
  signal AXI_C2C_aurora_pma_init_out    : STD_LOGIC;             
  signal AXI_C2C_reset                  : STD_LOGIC;                           
  signal AXI_C2CM1_channel_up           : STD_LOGIC;                     
  signal AXI_C2CM1_phy_clk              : STD_LOGIC;                        
  signal AXI_C2CM1_phy_clk_raw          : std_logic;
  
  signal refclk_C2C        : std_logic;

  signal AXI_C2C_ReadMOSI  : AXIReadMOSI_array_t (1 downto 0);
  signal AXI_C2C_ReadMISO  : AXIReadMISO_array_t (1 downto 0);
  signal AXI_C2C_WriteMOSI : AXIWriteMOSI_array_t(1 downto 0);
  signal AXI_C2C_WriteMISO : AXIWriteMISO_array_t(1 downto 0);
  
  signal C2C_gt_qpllclk_quad4 : std_logic;
  signal C2C_gt_qpllrefclk_quad4 : std_logic;

  signal AXI_C2C_powerdown : std_logic_vector(1 downto 0);


  
-- AXI BUS
  signal AXI_clk : std_logic;
  constant PL_AXI_SLAVE_COUNT : integer := 7;
  signal AXI_BUS_RMOSI :  AXIReadMOSI_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIReadMOSI);
  signal AXI_BUS_RMISO :  AXIReadMISO_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIReadMISO);
  signal AXI_BUS_WMOSI : AXIWriteMOSI_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIWriteMOSI);
  signal AXI_BUS_WMISO : AXIWriteMISO_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIWriteMISO);

  signal AXI_MSTR_RMOSI : AXIReadMOSI;
  signal AXI_MSTR_RMISO : AXIReadMISO;
  signal AXI_MSTR_WMOSI : AXIWriteMOSI;
  signal AXI_MSTR_WMISO : AXIWriteMISO;
  
  --Monitoring
--  signal SGMII_MON : SGMII_MONITOR_t;
  signal SGMII_MON_CDC : SGMII_MONITOR_t;
--  signal SGMII_CTRL : SGMII_CONTROL_t;
  
  signal onbloard_clk_n : std_logic;
  signal onbloard_clk_p : std_logic;
  signal clk_200Mhz : std_logic;
  signal reset_200Mhz : std_logic;
  signal clk_200Mhz_locked : std_logic;

  signal SDA_i_phy : std_logic;
  signal SDA_o_phy : std_logic;
  signal SDA_t_phy : std_logic;
  signal SCL_i_phy : std_logic;
  signal SCL_o_phy : std_logic;
  signal SCL_t_phy : std_logic;
  signal SDA_i_normal : std_logic;
  signal SDA_o_normal : std_logic;
  signal SDA_t_normal : std_logic;
  signal SCL_i_normal : std_logic;
  signal SCL_o_normal : std_logic;
  signal SCL_t_normal : std_logic;

  signal SI_OE_normal : std_logic;
  signal SI_EN_normal : std_logic;
  
  signal IPMC_SDA_o : std_logic;
  signal IPMC_SDA_t : std_logic;
  signal IPMC_SDA_i : std_logic;

  signal  SI_init_reset : std_logic;

  --For plXVC
  constant XVC_COUNT    : integer := 3;
  signal plXVC_TMS      : std_logic_vector((XVC_COUNT -1) downto 0);
  signal plXVC_TDI      : std_logic_vector((XVC_COUNT -1) downto 0);
  signal plXVC_TDO      : std_logic_vector((XVC_COUNT -1) downto 0);
  signal plXVC_TCK      : std_logic_vector((XVC_COUNT -1) downto 0);
  signal plXVC_PS_RST   : std_logic_vector((XVC_COUNT -1) downto 0);

  signal CM1_UART_Tx_internal : std_logic;
  signal CM2_UART_Tx_internal : std_logic;
  signal CM_C2C_Mon     : C2C_Monitor_t;
  
  signal CM_enable_IOs   : std_logic_vector(1 downto 0);
  signal CM_C2C_Ctrl : C2C_Control_t;
  signal C2C1_phy_gt_refclk1_out : std_logic;

  signal linux_booted : std_logic;

  signal clk_TCDS : std_logic;
  signal clk_TCDS_reset_n : std_logic;
  signal clk_TCDS_locked : std_logic;

  signal clk_C2C1_PHY : std_logic;
begin  -- architecture structure

  --debugging start
  FP_1V8_GPIO <= "000000";
  EEPROM_WE_N <= '1';

  GPIO  <= x"00";
  ZYNQ_BOOT_DONE <= linux_booted;
  IPMC_OUT <= "00";
  
  
  pl_reset_n <= axi_reset_n ;
  pl_clk <= axi_clk;
  AXI_C2C_powerdown(0) <= not CM_enable_IOs(0);
  AXI_C2C_powerdown(1) <= not CM_enable_IOs(0); --CM_enable_IOs(1) when (CM_COUNT = 1) else (not CM_enable_IOs(0)); --case for having only 1 CM
  CM_C2C_Mon.CM(2).status.phy_mmcm_lol  <= '0';
  CM_C2C_Mon.CM(2).link_debug.cpll_lock <= '0';
  zynq_bd_wrapper_1: entity work.zynq_bd_wrapper
    port map (
      AXI_RST_N(0)         => axi_reset_n,
      AXI_CLK              => AXI_clk,
      DDR_addr             => DDR_addr,
      DDR_ba               => DDR_ba,
      DDR_cas_n            => DDR_cas_n,
      DDR_ck_n             => DDR_ck_n,
      DDR_ck_p             => DDR_ck_p,
      DDR_cke              => DDR_cke,
      DDR_cs_n             => DDR_cs_n,
      DDR_dm               => DDR_dm,
      DDR_dq               => DDR_dq,
      DDR_dqs_n            => DDR_dqs_n,
      DDR_dqs_p            => DDR_dqs_p,
      DDR_odt              => DDR_odt,
      DDR_ras_n            => DDR_ras_n,
      DDR_reset_n          => DDR_reset_n,
      DDR_we_n             => DDR_we_n,
      FIXED_IO_ddr_vrn     => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp     => FIXED_IO_ddr_vrp,
      FIXED_IO_mio         => FIXED_IO_mio,
      FIXED_IO_ps_clk      => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb     => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb    => FIXED_IO_ps_srstb,
      IIC_0_0_scl_io            => I2C_SCL,
      IIC_0_0_sda_io            => I2C_SDA,
      SI_scl_i                  => SCL_i_phy,--SCL_i_normal,
      SI_scl_o                  => SCL_o_phy,--SCL_o_normal,
      SI_scl_t                  => SCL_t_phy,--SCL_t_normal,
      SI_sda_i                  => SDA_i_phy,--SDA_i_normal,
      SI_sda_o                  => SDA_o_phy,--SDA_o_normal,
      SI_sda_t                  => SDA_t_phy,--SDA_t_normal,

      FCLK_CLK1_0               => ETH1_CLK,
      GMII_ETHERNET_1_0_col     => ETH1A_COL_PL,
      GMII_ETHERNET_1_0_crs     => ETH1A_CRS_PL,
      GMII_ETHERNET_1_0_rx_dv   => ETH1A_RXDV,
      GMII_ETHERNET_1_0_rx_er   => ETH1A_RXER,
      GMII_ETHERNET_1_0_rxd(7 downto 4)  => (others => '0'),
      GMII_ETHERNET_1_0_rxd(3 downto 0)  => ETH1A_RXD,
      GMII_ETHERNET_1_0_tx_en(0) => ETH1A_TXEN,
      GMII_ETHERNET_1_0_tx_er   => open,
      GMII_ETHERNET_1_0_txd(7 downto 4)  => open,
      GMII_ETHERNET_1_0_txd(3 downto 0)  => ETH1A_TXD,
      MDIO_ETHERNET_1_0_mdc     => ETH1_MDC,
      MDIO_ETHERNET_1_0_mdio_io => ETH1_MDIO,


      AXI_CLK_PL                => pl_clk,
      AXI_RSTN_PL               => pl_reset_n,
      AXIM_PL_awaddr            => AXI_MSTR_WMOSI.address,
      AXIM_PL_awprot            => AXI_MSTR_WMOSI.protection_type,
      AXIM_PL_awvalid           => AXI_MSTR_WMOSI.address_valid,
      AXIM_PL_awready           => AXI_MSTR_WMISO.ready_for_address,
      AXIM_PL_wdata             => AXI_MSTR_WMOSI.data,
      AXIM_PL_wstrb             => AXI_MSTR_WMOSI.data_write_strobe,
      AXIM_PL_wvalid            => AXI_MSTR_WMOSI.data_valid,
      AXIM_PL_wready            => AXI_MSTR_WMISO.ready_for_data,
      AXIM_PL_bresp             => AXI_MSTR_WMISO.response,
      AXIM_PL_bvalid            => AXI_MSTR_WMISO.response_valid,
      AXIM_PL_bready            => AXI_MSTR_WMOSI.ready_for_response,
      AXIM_PL_araddr            => AXI_MSTR_RMOSI.address,
      AXIM_PL_arprot            => AXI_MSTR_RMOSI.protection_type,
      AXIM_PL_arvalid           => AXI_MSTR_RMOSI.address_valid,
      AXIM_PL_arready           => AXI_MSTR_RMISO.ready_for_address,
      AXIM_PL_rdata             => AXI_MSTR_RMISO.data,
      AXIM_PL_rresp             => AXI_MSTR_RMISO.response,
      AXIM_PL_rvalid            => AXI_MSTR_RMISO.data_valid,
      AXIM_PL_rready            => AXI_MSTR_RMOSI.ready_for_data,
--      PL_CLK                    => pl_clk,
--      PL_RESET_N                => pl_reset_n,
      SERV_araddr               => AXI_BUS_RMOSI(0).address,
      SERV_arprot               => AXI_BUS_RMOSI(0).protection_type,
      SERV_arready              => AXI_BUS_RMISO(0).ready_for_address,
      SERV_arvalid              => AXI_BUS_RMOSI(0).address_valid,
      SERV_awaddr               => AXI_BUS_WMOSI(0).address,
      SERV_awprot               => AXI_BUS_WMOSI(0).protection_type,
      SERV_awready              => AXI_BUS_WMISO(0).ready_for_address,
      SERV_awvalid              => AXI_BUS_WMOSI(0).address_valid,
      SERV_bready               => AXI_BUS_WMOSI(0).ready_for_response,
      SERV_bresp                => AXI_BUS_WMISO(0).response,
      SERV_bvalid               => AXI_BUS_WMISO(0).response_valid,
      SERV_rdata                => AXI_BUS_RMISO(0).data,
      SERV_rready               => AXI_BUS_RMOSI(0).ready_for_data,
      SERV_rresp                => AXI_BUS_RMISO(0).response,
      SERV_rvalid               => AXI_BUS_RMISO(0).data_valid,
      SERV_wdata                => AXI_BUS_WMOSI(0).data,
      SERV_wready               => AXI_BUS_WMISO(0).ready_for_data,
      SERV_wstrb                => AXI_BUS_WMOSI(0).data_write_strobe,
      SERV_wvalid               => AXI_BUS_WMOSI(0).data_valid,

      SLAVE_I2C_araddr               => AXI_BUS_RMOSI(1).address,
      SLAVE_I2C_arprot               => AXI_BUS_RMOSI(1).protection_type,
      SLAVE_I2C_arready              => AXI_BUS_RMISO(1).ready_for_address,
      SLAVE_I2C_arvalid              => AXI_BUS_RMOSI(1).address_valid,
      SLAVE_I2C_awaddr               => AXI_BUS_WMOSI(1).address,
      SLAVE_I2C_awprot               => AXI_BUS_WMOSI(1).protection_type,
      SLAVE_I2C_awready              => AXI_BUS_WMISO(1).ready_for_address,
      SLAVE_I2C_awvalid              => AXI_BUS_WMOSI(1).address_valid,
      SLAVE_I2C_bready               => AXI_BUS_WMOSI(1).ready_for_response,
      SLAVE_I2C_bresp                => AXI_BUS_WMISO(1).response,
      SLAVE_I2C_bvalid               => AXI_BUS_WMISO(1).response_valid,
      SLAVE_I2C_rdata                => AXI_BUS_RMISO(1).data,
      SLAVE_I2C_rready               => AXI_BUS_RMOSI(1).ready_for_data,
      SLAVE_I2C_rresp                => AXI_BUS_RMISO(1).response,
      SLAVE_I2C_rvalid               => AXI_BUS_RMISO(1).data_valid,
      SLAVE_I2C_wdata                => AXI_BUS_WMOSI(1).data,
      SLAVE_I2C_wready               => AXI_BUS_WMISO(1).ready_for_data,
      SLAVE_I2C_wstrb                => AXI_BUS_WMOSI(1).data_write_strobe,
      SLAVE_I2C_wvalid               => AXI_BUS_WMOSI(1).data_valid,

      CM_araddr               => AXI_BUS_RMOSI(2).address,
      CM_arprot               => AXI_BUS_RMOSI(2).protection_type,
      CM_arready              => AXI_BUS_RMISO(2).ready_for_address,
      CM_arvalid              => AXI_BUS_RMOSI(2).address_valid,
      CM_awaddr               => AXI_BUS_WMOSI(2).address,
      CM_awprot               => AXI_BUS_WMOSI(2).protection_type,
      CM_awready              => AXI_BUS_WMISO(2).ready_for_address,
      CM_awvalid              => AXI_BUS_WMOSI(2).address_valid,
      CM_bready               => AXI_BUS_WMOSI(2).ready_for_response,
      CM_bresp                => AXI_BUS_WMISO(2).response,
      CM_bvalid               => AXI_BUS_WMISO(2).response_valid,
      CM_rdata                => AXI_BUS_RMISO(2).data,
      CM_rready               => AXI_BUS_RMOSI(2).ready_for_data,
      CM_rresp                => AXI_BUS_RMISO(2).response,
      CM_rvalid               => AXI_BUS_RMISO(2).data_valid,
      CM_wdata                => AXI_BUS_WMOSI(2).data,
      CM_wready               => AXI_BUS_WMISO(2).ready_for_data,
      CM_wstrb                => AXI_BUS_WMOSI(2).data_write_strobe,
      CM_wvalid               => AXI_BUS_WMOSI(2).data_valid,

      SM_INFO_araddr          => AXI_BUS_RMOSI(3).address,
      SM_INFO_arprot          => AXI_BUS_RMOSI(3).protection_type,
      SM_INFO_arready         => AXI_BUS_RMISO(3).ready_for_address,
      SM_INFO_arvalid         => AXI_BUS_RMOSI(3).address_valid,
      SM_INFO_awaddr          => AXI_BUS_WMOSI(3).address,
      SM_INFO_awprot          => AXI_BUS_WMOSI(3).protection_type,
      SM_INFO_awready         => AXI_BUS_WMISO(3).ready_for_address,
      SM_INFO_awvalid         => AXI_BUS_WMOSI(3).address_valid,
      SM_INFO_bready          => AXI_BUS_WMOSI(3).ready_for_response,
      SM_INFO_bresp           => AXI_BUS_WMISO(3).response,
      SM_INFO_bvalid          => AXI_BUS_WMISO(3).response_valid,
      SM_INFO_rdata           => AXI_BUS_RMISO(3).data,
      SM_INFO_rready          => AXI_BUS_RMOSI(3).ready_for_data,
      SM_INFO_rresp           => AXI_BUS_RMISO(3).response,
      SM_INFO_rvalid          => AXI_BUS_RMISO(3).data_valid,
      SM_INFO_wdata           => AXI_BUS_WMOSI(3).data,
      SM_INFO_wready          => AXI_BUS_WMISO(3).ready_for_data,
      SM_INFO_wstrb           => AXI_BUS_WMOSI(3).data_write_strobe,
      SM_INFO_wvalid          => AXI_BUS_WMOSI(3).data_valid,

--            TCDS_DRP_araddr          => AXI_BUS_RMOSI(4).address,
--      TCDS_DRP_arprot          => AXI_BUS_RMOSI(4).protection_type,
--      TCDS_DRP_arready         => AXI_BUS_RMISO(4).ready_for_address,
--      TCDS_DRP_arvalid         => AXI_BUS_RMOSI(4).address_valid,
--      TCDS_DRP_awaddr          => AXI_BUS_WMOSI(4).address,
--      TCDS_DRP_awprot          => AXI_BUS_WMOSI(4).protection_type,
--      TCDS_DRP_awready         => AXI_BUS_WMISO(4).ready_for_address,
--      TCDS_DRP_awvalid         => AXI_BUS_WMOSI(4).address_valid,
--      TCDS_DRP_bready          => AXI_BUS_WMOSI(4).ready_for_response,
--      TCDS_DRP_bresp           => AXI_BUS_WMISO(4).response,
--      TCDS_DRP_bvalid          => AXI_BUS_WMISO(4).response_valid,
--      TCDS_DRP_rdata           => AXI_BUS_RMISO(4).data,
--      TCDS_DRP_rready          => AXI_BUS_RMOSI(4).ready_for_data,
--      TCDS_DRP_rresp           => AXI_BUS_RMISO(4).response,
--      TCDS_DRP_rvalid          => AXI_BUS_RMISO(4).data_valid,
--      TCDS_DRP_wdata           => AXI_BUS_WMOSI(4).data,
--      TCDS_DRP_wready          => AXI_BUS_WMISO(4).ready_for_data,
--      TCDS_DRP_wstrb           => AXI_BUS_WMOSI(4).data_write_strobe,
--      TCDS_DRP_wvalid          => AXI_BUS_WMOSI(4).data_valid,
--
--      TCDS_araddr              => AXI_BUS_RMOSI(5).address,
--      TCDS_arprot              => AXI_BUS_RMOSI(5).protection_type,
--      TCDS_arready             => AXI_BUS_RMISO(5).ready_for_address,
--      TCDS_arvalid             => AXI_BUS_RMOSI(5).address_valid,
--      TCDS_awaddr              => AXI_BUS_WMOSI(5).address,
--      TCDS_awprot              => AXI_BUS_WMOSI(5).protection_type,
--      TCDS_awready             => AXI_BUS_WMISO(5).ready_for_address,
--      TCDS_awvalid             => AXI_BUS_WMOSI(5).address_valid,
--      TCDS_bready              => AXI_BUS_WMOSI(5).ready_for_response,
--      TCDS_bresp               => AXI_BUS_WMISO(5).response,
--      TCDS_bvalid              => AXI_BUS_WMISO(5).response_valid,
--      TCDS_rdata               => AXI_BUS_RMISO(5).data,
--      TCDS_rready              => AXI_BUS_RMOSI(5).ready_for_data,
--      TCDS_rresp               => AXI_BUS_RMISO(5).response,
--      TCDS_rvalid              => AXI_BUS_RMISO(5).data_valid,
--      TCDS_wdata               => AXI_BUS_WMOSI(5).data,
--      TCDS_wready              => AXI_BUS_WMISO(5).ready_for_data,
--      TCDS_wstrb               => AXI_BUS_WMOSI(5).data_write_strobe,
--      TCDS_wvalid              => AXI_BUS_WMOSI(5).data_valid,


      PLXVC_araddr               => AXI_BUS_RMOSI(6).address,
      PLXVC_arprot               => AXI_BUS_RMOSI(6).protection_type,
      PLXVC_arready              => AXI_BUS_RMISO(6).ready_for_address,
      PLXVC_arvalid              => AXI_BUS_RMOSI(6).address_valid,
      PLXVC_awaddr               => AXI_BUS_WMOSI(6).address,
      PLXVC_awprot               => AXI_BUS_WMOSI(6).protection_type,
      PLXVC_awready              => AXI_BUS_WMISO(6).ready_for_address,
      PLXVC_awvalid              => AXI_BUS_WMOSI(6).address_valid,
      PLXVC_bready               => AXI_BUS_WMOSI(6).ready_for_response,
      PLXVC_bresp                => AXI_BUS_WMISO(6).response,
      PLXVC_bvalid               => AXI_BUS_WMISO(6).response_valid,
      PLXVC_rdata                => AXI_BUS_RMISO(6).data,
      PLXVC_rready               => AXI_BUS_RMOSI(6).ready_for_data,
      PLXVC_rresp                => AXI_BUS_RMISO(6).response,
      PLXVC_rvalid               => AXI_BUS_RMISO(6).data_valid,
      PLXVC_wdata                => AXI_BUS_WMOSI(6).data,
      PLXVC_wready               => AXI_BUS_WMISO(6).ready_for_data,
      PLXVC_wstrb                => AXI_BUS_WMOSI(6).data_write_strobe,
      PLXVC_wvalid               => AXI_BUS_WMOSI(6).data_valid,

            init_clk        =>  AXI_C2C_aurora_init_clk,
      C2C1_phy_Rx_rxn =>  AXI_C2C_CM1_Rx_N(0 to 0),
      C2C1_phy_Rx_rxp =>  AXI_C2C_CM1_Rx_P(0 to 0),
      C2C1_phy_Tx_txn =>  AXI_C2C_CM1_Tx_N(0 to 0),
      C2C1_phy_Tx_txp =>  AXI_C2C_CM1_Tx_P(0 to 0),
      C2C1_phy_refclk_clk_n => refclk_C2C2_N(0),
      C2C1_phy_refclk_clk_p => refclk_C2C2_P(0),
      C2C1_phy_power_down   => AXI_C2C_powerdown(0),
      C2C1_aurora_do_cc                 => CM_C2C_Mon.CM(1).status.do_cc                ,
      C2C1_aurora_pma_init_in           => CM_C2C_Ctrl.CM(1).status.initialize,
      C2C1_axi_c2c_config_error_out     => CM_C2C_Mon.CM(1).status.config_error    ,
      C2C1_axi_c2c_link_error_out       => CM_C2C_Mon.CM(1).status.link_error      ,
      C2C1_axi_c2c_link_status_out      => CM_C2C_Mon.CM(1).status.link_good     ,
      C2C1_axi_c2c_multi_bit_error_out  => CM_C2C_Mon.CM(1).status.mb_error ,
      C2C1_phy_gt_pll_lock              => CM_C2C_Mon.CM(1).status.phy_gt_pll_lock             ,
      C2C1_phy_hard_err                 => CM_C2C_Mon.CM(1).status.phy_hard_err                ,
      C2C1_phy_lane_up                  => CM_C2C_Mon.CM(1).status.phy_lane_up(0 downto 0)     ,
      C2C1_phy_link_reset_out           => CM_C2C_Mon.CM(1).status.phy_reset          ,
      C2C1_phy_gt_refclk1_out           => C2C1_phy_gt_refclk1_out          ,
      C2C1_phy_mmcm_not_locked_out      => CM_C2C_Mon.CM(1).status.phy_mmcm_lol     ,
      C2C1_phy_soft_err                 => CM_C2C_Mon.CM(1).status.phy_soft_err                ,
      C2C1_PHY_DEBUG_cplllock         => CM_C2C_Mon.CM(1).LINK_DEBUG.cpll_lock,
      C2C1_PHY_DEBUG_dmonitorout      => CM_C2C_Mon.CM(1).LINK_DEBUG.dmonitor,
      C2C1_PHY_DEBUG_eyescandataerror => CM_C2C_Mon.CM(1).LINK_DEBUG.eyescan_data_error,
      C2C1_PHY_DEBUG_eyescanreset     => CM_C2C_Ctrl.CM(1).LINK_DEBUG.eyescan_reset,
      C2C1_PHY_DEBUG_eyescantrigger   => CM_C2C_Ctrl.CM(1).LINK_DEBUG.eyescan_trigger,
      C2C1_PHY_DEBUG_rxbufreset       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.buf_reset,
      C2C1_PHY_DEBUG_rxbufstatus      => CM_C2C_Mon.CM(1).LINK_DEBUG.rx.buf_status,
      C2C1_PHY_DEBUG_rxcdrhold        => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.cdr_hold,
      C2C1_PHY_DEBUG_rxdfeagchold     => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.dfe_agc_hold,
      C2C1_PHY_DEBUG_rxdfeagcovrden   => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.dfe_agc_override,
      C2C1_PHY_DEBUG_rxdfelfhold      => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.dfe_lf_hold,
      C2C1_PHY_DEBUG_rxdfelpmreset    => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.dfe_lpm_reset,
      C2C1_PHY_DEBUG_rxlpmen          => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.lpm_en,
      C2C1_PHY_DEBUG_rxlpmhfovrden    => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.lpm_hf_override,
      C2C1_PHY_DEBUG_rxlpmlfklovrden  => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.lpm_lfkl_override,
      C2C1_PHY_DEBUG_rxmonitorout     => CM_C2C_Mon.CM(1).LINK_DEBUG.rx.monitor,
      C2C1_PHY_DEBUG_rxmonitorsel     => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.mon_sel,
      C2C1_PHY_DEBUG_rxpcsreset       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.pcs_reset,    
      C2C1_PHY_DEBUG_rxpmareset       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.pma_reset,    
      C2C1_PHY_DEBUG_rxprbscntreset   => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.prbs_cnt_rst,
      C2C1_PHY_DEBUG_rxprbserr        => CM_C2C_Mon.CM(1).LINK_DEBUG.rx.prbs_err,
      C2C1_PHY_DEBUG_rxprbssel        => CM_C2C_Ctrl.CM(1).LINK_DEBUG.rx.prbs_sel,
      C2C1_PHY_DEBUG_rxreseTDOne      => CM_C2C_Mon.CM(1).LINK_DEBUG.rx.reseT_DOne,
      C2C1_PHY_DEBUG_txbufstatus      => CM_C2C_Mon.CM(1).LINK_DEBUG.tx.buf_status,
      C2C1_PHY_DEBUG_txdiffctrl       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.diff_ctrl,      
      C2C1_PHY_DEBUG_txinhibit        => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.inhibit,       
      C2C1_PHY_DEBUG_txmaincursor     => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.main_cursor,    
      C2C1_PHY_DEBUG_txpcsreset       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.pcs_reset,      
      C2C1_PHY_DEBUG_txpmareset       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.pma_reset,      
      C2C1_PHY_DEBUG_txpolarity       => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.polarity,      
      C2C1_PHY_DEBUG_txpostcursor     => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.post_cursor,    
      C2C1_PHY_DEBUG_txprbsforceerr   => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.prbs_force_err,  
      C2C1_PHY_DEBUG_txprbssel        => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.prbs_sel,       
      C2C1_PHY_DEBUG_txprecursor      => CM_C2C_Ctrl.CM(1).LINK_DEBUG.tx.pre_cursor,     
      C2C1_PHY_DEBUG_txreseTDOne      => CM_C2C_Mon.CM(1).LINK_DEBUG.tx.reseT_DOne,

      C2C2_phy_Rx_rxn =>  AXI_C2C_CM2_Rx_N(0 to 0),
      C2C2_phy_Rx_rxp =>  AXI_C2C_CM2_Rx_P(0 to 0),
      C2C2_phy_Tx_txn =>  AXI_C2C_CM2_Tx_N(0 to 0),
      C2C2_phy_Tx_txp =>  AXI_C2C_CM2_Tx_P(0 to 0),
      C2C2_phy_power_down   => AXI_C2C_powerdown(1),
      C2C2_aurora_do_cc                 => CM_C2C_Mon.CM(2).status.do_cc                ,
      C2C2_aurora_pma_init_in           => CM_C2C_Ctrl.CM(2).status.initialize,
      C2C2_axi_c2c_config_error_out     => CM_C2C_Mon.CM(2).status.config_error    ,
      C2C2_axi_c2c_link_error_out       => CM_C2C_Mon.CM(2).status.link_error      ,
      C2C2_axi_c2c_link_status_out      => CM_C2C_Mon.CM(2).status.link_good     ,
      C2C2_axi_c2c_multi_bit_error_out  => CM_C2C_Mon.CM(2).status.mb_error ,
      C2C2_phy_gt_pll_lock              => CM_C2C_Mon.CM(2).status.phy_gt_pll_lock             ,
      C2C2_phy_hard_err                 => CM_C2C_Mon.CM(2).status.phy_hard_err                ,
      C2C2_phy_lane_up                  => CM_C2C_Mon.CM(2).status.phy_lane_up(0 downto 0)         ,
      C2C2_phy_link_reset_out           => CM_C2C_Mon.CM(2).status.phy_reset          ,
--      C2C2_phy_mmcm_not_locked_out      => CM2_C2C_Mon.phy_mmcm_not_locked_out     ,
      C2C2_phy_soft_err                 => CM_C2C_Mon.CM(2).status.phy_soft_err                ,
--      C2C2_PHY_DEBUG_cplllock         => CM2_C2C_Mon.cplllock,
      C2C2_PHY_DEBUG_dmonitorout      => CM_C2C_Mon.CM(2).LINK_DEBUG.dmonitor,
      C2C2_PHY_DEBUG_eyescandataerror => CM_C2C_Mon.CM(2).LINK_DEBUG.eyescan_data_error,
      C2C2_PHY_DEBUG_eyescanreset     => CM_C2C_Ctrl.CM(2).LINK_DEBUG.eyescan_reset,
      C2C2_PHY_DEBUG_eyescantrigger   => CM_C2C_Ctrl.CM(2).LINK_DEBUG.eyescan_trigger,
      C2C2_PHY_DEBUG_rxbufreset       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.buf_reset,
      C2C2_PHY_DEBUG_rxbufstatus      => CM_C2C_Mon.CM(2).LINK_DEBUG.rx.buf_status,
      C2C2_PHY_DEBUG_rxcdrhold        => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.cdr_hold,
      C2C2_PHY_DEBUG_rxdfeagchold     => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.dfe_agc_hold,
      C2C2_PHY_DEBUG_rxdfeagcovrden   => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.dfe_agc_override,
      C2C2_PHY_DEBUG_rxdfelfhold      => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.dfe_lf_hold,
      C2C2_PHY_DEBUG_rxdfelpmreset    => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.dfe_lpm_reset,
      C2C2_PHY_DEBUG_rxlpmen          => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.lpm_en,
      C2C2_PHY_DEBUG_rxlpmhfovrden    => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.lpm_hf_override,
      C2C2_PHY_DEBUG_rxlpmlfklovrden  => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.lpm_lfkl_override,
      C2C2_PHY_DEBUG_rxmonitorout     => CM_C2C_Mon.CM(2).LINK_DEBUG.rx.monitor,
      C2C2_PHY_DEBUG_rxmonitorsel     => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.mon_sel,
      C2C2_PHY_DEBUG_rxpcsreset       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.pcs_reset,    
      C2C2_PHY_DEBUG_rxpmareset       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.pma_reset,    
      C2C2_PHY_DEBUG_rxprbscntreset   => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.prbs_cnt_rst,
      C2C2_PHY_DEBUG_rxprbserr        => CM_C2C_Mon.CM(2).LINK_DEBUG.rx.prbs_err,
      C2C2_PHY_DEBUG_rxprbssel        => CM_C2C_Ctrl.CM(2).LINK_DEBUG.rx.prbs_sel,
      C2C2_PHY_DEBUG_rxreseTDOne      => CM_C2C_Mon.CM(2).LINK_DEBUG.rx.reseT_DOne,
      C2C2_PHY_DEBUG_txbufstatus      => CM_C2C_Mon.CM(2).LINK_DEBUG.tx.buf_status,
      C2C2_PHY_DEBUG_txdiffctrl       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.diff_ctrl,      
      C2C2_PHY_DEBUG_txinhibit        => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.inhibit,       
      C2C2_PHY_DEBUG_txmaincursor     => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.main_cursor,    
      C2C2_PHY_DEBUG_txpcsreset       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.pcs_reset,      
      C2C2_PHY_DEBUG_txpmareset       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.pma_reset,      
      C2C2_PHY_DEBUG_txpolarity       => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.polarity,      
      C2C2_PHY_DEBUG_txpostcursor     => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.post_cursor,    
      C2C2_PHY_DEBUG_txprbsforceerr   => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.prbs_force_err,  
      C2C2_PHY_DEBUG_txprbssel        => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.prbs_sel,       
      C2C2_PHY_DEBUG_txprecursor      => CM_C2C_Ctrl.CM(2).LINK_DEBUG.tx.pre_cursor,     
      C2C2_PHY_DEBUG_txreseTDOne      => CM_C2C_Mon.CM(2).LINK_DEBUG.tx.reseT_DOne,

      CM1_UART_rxd => CM1_UART_rx,
      CM1_UART_txd => CM1_UART_Tx_internal,
      CM2_UART_rxd => CM2_UART_rx,
      CM2_UART_txd => CM2_UART_Tx_internal,
      ESM_UART_rxd => ESM_UART_rx,
      ESM_UART_txd => ESM_UART_tx,
      BRAM_PORTB_0_addr => x"00000000",
      BRAM_PORTB_0_clk  => AXI_clk,
      BRAM_PORTB_0_din  => x"00000000",
      BRAM_PORTB_0_dout => open,
      BRAM_PORTB_0_en   => '0',
      BRAM_PORTB_0_rst  => '0',
      BRAM_PORTB_0_we   => x"0",

      C2C1_PHY_CLK      => clk_C2C1_PHY,
      
      TCDS_CLK          => clk_TCDS,
      TCDS_reset_n      => clk_TCDS_locked--clk_TCDS_reset_n
      );




  axi_reset <= not axi_reset_n;


  SI_i2c_SDA : IOBUF
    port map (
      IO => SI_sda,
      I  => SDA_o_phy,
      T  => SDA_t_phy,
      O  => SDA_i_phy);
  SI_i2c_SCL : IOBUF
    port map (
      IO => SI_scl,
      I  => SCL_o_phy,
      T  => SCL_t_phy,
      O  => SCL_i_phy);

  onboard_CLK_1: onboard_CLK
    port map (
      clk_200Mhz => clk_200Mhz,
      clk_50Mhz  => AXI_C2C_aurora_init_clk,
      reset      =>  SI_init_reset,--'0',
      locked     => clk_200Mhz_locked,
      clk_in1_n  => onboard_clk_n,
      clk_in1_p  => onboard_clk_p);
  reset_200Mhz <= not clk_200Mhz_locked ;

  SI_OUT_DIS <= not SI_OE_normal;
  SI_ENABLE  <= SI_EN_normal;

  SGMII_MON_CDC.reset_done    <= '0';
  SGMII_MON_CDC.cpll_lock     <= '0';
  SGMII_MON_CDC.mmcm_reset    <= '0';
  SGMII_MON_CDC.pma_reset     <= '0';
  SGMII_MON_CDC.mmcm_locked   <= '0';
  SGMII_MON_CDC.status_vector <= (others => '0');
  SGMII_MON_CDC.reset         <= '0';





  CM_TTC_SEL(1 downto 0) <= (others => TTC_SRC_SEL);
    
  services_1: entity work.services
    port map (
      clk_axi         => axi_clk,
      reset_axi_n     => pl_reset_n,
      readMOSI        => AXI_BUS_RMOSI(0),
      readMISO        => AXI_BUS_RMISO(0),
      writeMOSI       => AXI_BUS_WMOSI(0),
      writeMISO       => AXI_BUS_WMISO(0),
      SGMII_MON       => SGMII_MON_CDC,
      SGMII_CTRL      => open,
      SI_INT          => SI_INT,
      SI_LOL          => SI_LOL,
      SI_LOS          => SI_LOS_XAXB,
      SI_OUT_EN       => SI_OE_normal,
      SI_ENABLE       => SI_EN_normal,
      SI_init_reset   => SI_init_reset,
      TTC_SRC_SEL     => TTC_SRC_SEL,
      TCDS_REFCLK_LOCKED => clk_TCDS_locked,
      LHC_CLK_CMS_LOS  => LHC_CLK_BP_LOS,
      LHC_CLK_OSC_LOS => LHC_CLK_OSC_LOS,
      LHC_SRC_SEL     => LHC_SRC_SEL,
      HQ_CLK_CMS_LOS   => HQ_CLK_BP_LOS,
      HQ_CLK_OSC_LOS  => HQ_CLK_OSC_LOS,
      HQ_SRC_SEL      => HQ_SRC_SEL,
      FP_LED_RST      => FP_LED_RST,
      FP_LED_CLK      => FP_LED_CLK,
      FP_LED_SDA      => FP_LED_SDA,
      FP_switch       => FP_Button,
      linux_booted    => linux_booted,
      ESM_LED_CLK     => ESM_LED_CLK,
      ESM_LED_SDA     => ESM_LED_SDA,
      CM1_C2C_Mon     => CM_C2C_Mon.CM(1),
      CM2_C2C_Mon     => CM_C2C_Mon.CM(2));

  SM_info_1: entity work.SM_info
    port map (
      clk_axi     => axi_clk,
      reset_axi_n => pl_reset_n,
      readMOSI    => AXI_BUS_RMOSI(3),
      readMISO    => AXI_BUS_RMISO(3),
      writeMOSI   => AXI_BUS_WMOSI(3),
      writeMISO   => AXI_BUS_WMISO(3));
  
  IPMC_i2c_slave_1: entity work.IPMC_i2c_slave
    port map (
      clk_axi      => axi_clk,
      reset_axi_n  => pl_reset_n,
      readMOSI     => AXI_BUS_RMOSI(1),
      readMISO     => AXI_BUS_RMISO(1),
      writeMOSI    => AXI_BUS_WMOSI(1),
      writeMISO    => AXI_BUS_WMISO(1),
      linux_booted => linux_booted,
      SDA_o        => IPMC_SDA_o,
      SDA_t        => IPMC_SDA_t,
      SDA_i        => IPMC_SDA_i,
      SCL          => IPMC_SCL);
  IPMC_i2c_SDA : IOBUF
    port map (
      IO => IPMC_SDA,
      I  => IPMC_SDA_o,
      T  => IPMC_SDA_t,
      O  => IPMC_SDA_i);

  CM_interface_1: entity work.CM_intf
    generic map (
      CM_COUNT             => 1,
      COUNTER_COUNT        => 5,
      CLKFREQ              => 50000000,
      ERROR_WAIT_TIME      => 50000000)
    port map (
      clk_axi              => axi_clk,
      reset_axi_n          => pl_reset_n,
      slave_readMOSI       => AXI_BUS_RMOSI(2),
      slave_readMISO       => AXI_BUS_RMISO(2),
      slave_writeMOSI      => AXI_BUS_WMOSI(2),
      slave_writeMISO      => AXI_BUS_WMISO(2),
      master_readMOSI      => AXI_MSTR_RMOSI,
      master_readMISO      => AXI_MSTR_RMISO,
      master_writeMOSI     => AXI_MSTR_WMOSI,
      master_writeMISO     => AXI_MSTR_WMISO,
      CM_mon_uart          => CM1_MON_RX,
      enableCM(0)            => CM1_EN,
      enableCM(1)            => CM2_EN,
      enableCM_PWR(0)        => CM1_PWR_EN,
      enableCM_PWR(1)        => CM2_PWR_EN,
      enableCM_IOs           => CM_enable_IOs,
      from_CM.CM(1).PWR_good    => CM1_PWR_good,
      from_CM.CM(1).TDO         => '0',
      from_CM.CM(1).GPIO        => CM1_GPIO,
      from_CM.CM(1).UART_Rx     => '0',--CM1_UART_rx,     
      from_CM.CM(2).PWR_good    => CM2_PWR_good,
      from_CM.CM(2).TDO         => '0',
      from_CM.CM(2).GPIO        => CM2_GPIO,
      from_CM.CM(2).UART_Rx     => CM2_UART_rx,
      to_CM_in.CM(1).UART_Tx    => CM1_UART_Tx_internal,
      to_CM_in.CM(1).TMS        => plXVC_TMS(0),
      to_CM_in.CM(1).TDI        => plXVC_TDI(0),
      to_CM_in.CM(1).TCK        => plXVC_TCK(0),
      to_CM_in.CM(2).UART_Tx    => '0',--CM2_UART_Tx_internal,
      to_CM_in.CM(2).TMS        => plXVC_TMS(1),
      to_CM_in.CM(2).TDI        => plXVC_TDI(1),
      to_CM_in.CM(2).TCK        => plXVC_TCK(1),
      to_CM_out.CM(1).UART_Tx   => CM1_UART_Tx,
      to_CM_out.CM(1).TMS       => CM1_TMS,
      to_CM_out.CM(1).TDI       => CM1_TDI,
      to_CM_out.CM(1).TCK       => CM1_TCK,
      to_CM_out.CM(2).UART_Tx   => CM2_UART_Tx,
      to_CM_out.CM(2).TMS       => CM2_TMS,
      to_CM_out.CM(2).TDI       => CM2_TDI,
      to_CM_out.CM(2).TCK       => CM2_TCK,
      clk_C2C(0)                => clk_C2C1_PHY,
      clk_C2C(1)                => clk_C2C1_PHY,
      CM_C2C_Mon                => CM_C2C_Mon,
      CM_C2C_Ctrl               => CM_C2C_Ctrl);
  plXVC_TDO(0) <= CM1_TDO;
  plXVC_TDO(1) <= CM2_TDO;
  CM1_PS_RST   <= plXVC_PS_RST(0);
  CM2_PS_RST   <= plXVC_PS_RST(1);

  
--  TCDS_2: entity work.TCDS
--    port map (
--      clk_axi            => pl_clk,--axi_clk,--clk_TCDS,
--      reset_axi_n        => pl_reset_n,--axi_reset_n,--pl_reset_n,--clk_TCDS_reset_n,--pl_reset_n,
--      clk_axi_DRP        => pl_clk,--axi_clk,
--      reset_axi_DRP_n    => pl_reset_n,--axi_reset_n,--pl_reset_n,
--      readMOSI           => AXI_BUS_RMOSI(5),
--      readMISO           => AXI_BUS_RMISO(5),
--      writeMOSI          => AXI_BUS_WMOSI(5),
--      writeMISO          => AXI_BUS_WMISO(5),
--      DRP_readMOSI       => AXI_BUS_RMOSI(4),
--      DRP_readMISO       => AXI_BUS_RMISO(4),
--      DRP_writeMOSI      => AXI_BUS_WMOSI(4),
--      DRP_writeMISO      => AXI_BUS_WMISO(4),
--      --sysclk        => pl_clk,
--      refclk_p      => refclk_CMS_P,
--      refclk_n      => refclk_CMS_N,
--      QPLL_CLK        => QPLL_CLK,    
--      QPLL_REF_CLK    => QPLL_REF_CLK,        
----      reset         => axi_reset,
--      clk_TCDS    => clk_TCDS,
--      clk_TCDS_reset_n => clk_TCDS_locked,--open,--clk_TCDS_reset_n,
--      tx_P(0)     => TCDS_TTS_P,
--      tx_P(1)     => LOCAL_TCDS_TTC_P,  
--      tx_P(2)     => open, 
--      tx_N(0)     => TCDS_TTS_N,
--      tx_N(1)     => LOCAL_TCDS_TTC_N,  
--      tx_N(2)     => open, 
--      rx_P(0)     => TCDS_TTC_P,
--      rx_P(1)     => CM1_TCDS_TTS_P,    
--      rx_P(2)     => CM2_TCDS_TTS_P,    
--      rx_N(0)     => TCDS_TTC_N,
--      rx_N(1)     => CM1_TCDS_TTS_N,    
--      rx_N(2)     => CM2_TCDS_TTS_N);

  --Adding CPLD JTAG Chain
  CPLD_TMS     <= plXVC_TMS(2);
  CPLD_TDI     <= plXVC_TDI(2);
  plXVC_TDO(2) <= CPLD_TDO;
  CPLD_TCK     <=  plXVC_TCK(2);    
  plXVC_1: entity work.plXVC_intf
    generic map (
      --TCK_RATIO         => 1,
      COUNT           => XVC_COUNT,
      IRQ_LENGTH      => 1)           
    port map (
      clk_axi         => axi_clk,
      reset_axi_n     => pl_reset_n,
      readMOSI        => AXI_BUS_RMOSI(6),
      readMISO        => AXI_BUS_RMISO(6),
      writeMOSI       => AXI_BUS_WMOSI(6),
      writeMISO       => AXI_BUS_WMISO(6),
      TMS             => plXVC_TMS,
      TDI             => plXVC_TDI,
      TDO             => plXVC_TDO,
      TCK             => plXVC_TCK,
      PS_RST          => plXVC_PS_RST);
end architecture structure;
