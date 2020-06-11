library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.SGMII_MONITOR.all;
use work.CM_package.all;
use work.SERV_Ctrl.all;

entity services is
  
  port (
    clk_axi            : in  std_logic;
    reset_axi_n        : in  std_logic;
    readMOSI           : in  AXIReadMOSI;
    readMISO           : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI          : in  AXIWriteMOSI;
    writeMISO          : out AXIWriteMISO := DefaultAXIWriteMISO;
                       
    SGMII_MON          : in  SGMII_MONITOR_t;
    SGMII_CTRL         : out SGMII_CONTROL_t;
                       
    SI_INT             : in  std_logic;
    SI_LOL             : in  std_logic;
    SI_LOS             : in  std_logic;
    SI_OUT_EN          : out std_logic;
    SI_ENABLE          : out std_logic;
    SI_init_reset      : out std_logic;
                       
    TTC_SRC_SEL        : out std_logic;
    TCDS_REFCLK_LOCKED :  in std_logic;

    LHC_CLK_CMS_LOS    : in  std_logic;
    LHC_CLK_OSC_LOS    : in  std_logic;
    LHC_SRC_SEL        : out std_logic;
    HQ_CLK_CMS_LOS     : in  std_logic;
    HQ_CLK_OSC_LOS     : in  std_logic;
    HQ_SRC_SEL         : out std_logic;
    FP_LED_RST         : out std_logic;
    FP_LED_CLK         : out std_logic;
    FP_LED_SDA         : out std_logic;
    FP_switch          : in  std_logic;
    linux_booted       : in  std_logic;
                       
    ESM_LED_CLK        : in  std_logic;
    ESM_LED_SDA        : in  std_logic;
    CM1_C2C_Mon        : in  C2C_Monitor_t;
    CM2_C2C_Mon        : in  C2C_Monitor_t
    );
end entity services;

architecture behavioral of services is
 signal Mon              :  SERV_Mon_t;
 signal Ctrl             :  SERV_Ctrl_t;


  signal ESM_LEDs : slv_16_t;
  signal ESM_clk_last : std_logic;

  signal SGMII_MON_buf1 : SGMII_MONITOR_t;
  signal SGMII_MON_buf2 : SGMII_MONITOR_t;

  constant FP_REG_COUNT : integer := 4;
  signal FP_regs : slv8_array_t(0 to (FP_REG_COUNT - 1)) := (others => (others => '0'));
  signal FP_addr : slv_6_t;
  
  signal LED_mode : slv_3_t;
  signal  FP_shutdown : std_logic;
  constant FP_LED_ORDER : int8_array_t(0 to 7) := (0,1,2,3,7,6,5,4);
  
begin  -- architecture behavioral

  ESM_LED_CAP: process (clk_axi, reset_axi_n) is
  begin  -- process ESM_LED_CAP
    if reset_axi_n = '0' then           -- asynchronous reset (active high)
      ESM_LEDs <= (others => '0');
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      ESM_clk_last <= ESM_LED_CLK;
      if ESM_clk_last = '0' and ESM_LED_CLK = '1' then
        ESM_LEDs <= ESM_LEDs(14 downto 0) & ESM_LED_SDA;
      end if;
      
    end if;
  end process ESM_LED_CAP;


  FP_regs(1)(0) <= SGMII_MON.mmcm_locked;
  FP_regs(1)(1) <= SGMII_MON.pma_reset;
  FP_regs(1)(2) <= SGMII_MON.reset_done;
  FP_regs(1)(3) <= SGMII_MON.cpll_lock ;

  FP_regs(2)(0) <= CM1_C2C_Mon.axi_c2c_config_error_out   ;
  FP_regs(2)(1) <= CM1_C2C_Mon.axi_c2c_link_error_out     ;
  FP_regs(2)(2) <= CM1_C2C_Mon.axi_c2c_link_status_out    ;
  FP_regs(2)(3) <= CM1_C2C_Mon.axi_c2c_multi_bit_error_out;

  FP_regs(3)(0) <= CM1_C2C_Mon.aurora_do_cc               ;
  FP_regs(3)(1) <= CM1_C2C_Mon.phy_gt_pll_lock            ;
  FP_regs(3)(2) <= CM1_C2C_Mon.phy_hard_err               ;
  FP_regs(3)(3 downto 3) <= CM1_C2C_Mon.phy_lane_up                ;
  FP_regs(3)(5) <= CM1_C2C_Mon.phy_link_reset_out         ;
  FP_regs(3)(6) <= CM1_C2C_Mon.phy_mmcm_not_locked_out    ;
  FP_regs(3)(7) <= CM1_C2C_Mon.phy_soft_err               ;

  LED0_Mode_sel: process (linux_booted,Ctrl.FP_LEDS.PAGE0_FORCE ) is
  begin  -- process LED0_Mode_sel
    if(Ctrl.FP_LEDS.PAGE0_FORCE = '1') then
      LED_mode <= Ctrl.FP_LEDS.PAGE0_MODE;
    else
      if linux_booted = '1' then
        LED_mode <= "100";
      else
        LED_mode <= "010";
      end if;
    end if;
  end process LED0_Mode_sel;
  LED_Patterns_1: entity work.LED_Patterns
    generic map (
      CLKFREQ => 50000000)
    port map (
      clk   => clk_axi,
      reset => '0',
      mode  => LED_mode,
      speed => Ctrl.FP_LEDS.PAGE0_SPEED,
      LEDs  => FP_regs(0));  
  FrontPanel_UI_1: entity work.FrontPanel_UI
    generic map (
      CLKFREQ      => 50000000,
      REG_COUNT    => FP_REG_COUNT,
      LEDORDER      => FP_LED_ORDER)
    port map (
      clk           => clk_axi,
      reset         => '0',
      buttonin      => FP_switch,
      addressin     => Ctrl.FP_LEDS.FORCED_PAGE,
      force_address => Ctrl.FP_LEDS.FORCE_PAGE,
      display_regs  => FP_regs,
      addressout    => FP_addr,
      SCK           => FP_LED_CLK,
      SDA           => FP_LED_SDA,
      shutdownout   => FP_shutdown);

  latch_SGMII_domain: process (clk_axi) is
  begin  -- process latch_SGMII_domain
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      SGMII_MON_buf1 <= SGMII_MON;
      SGMII_MON_buf2 <= SGMII_MON_buf1;
    end if;
  end process latch_SGMII_domain;

  
  SERV_interface_1: entity work.SERV_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
 
  Mon.SI5344.INT               <= not SI_INT;
  Mon.SI5344.LOL               <= not SI_LOL;
  Mon.SI5344.LOS               <= not SI_LOS;
  Mon.TCDS.REFCLK_LOCKED       <= TCDS_REFCLK_LOCKED;
  Mon.CLOCKING.HQ_LOS_BP       <= HQ_CLK_CMS_LOS;
  Mon.CLOCKING.HQ_LOS_OSC      <= HQ_CLK_OSC_LOS;
  Mon.CLOCKING.LHC_LOS_BP      <= LHC_CLK_CMS_LOS;
  Mon.CLOCKING.LHC_LOS_OSC     <= LHC_CLK_OSC_LOS;
  Mon.FP_LEDS.BUTTON           <= FP_switch;
  Mon.FP_LEDS.FP_SHDWN_REQ     <= FP_shutdown;
  Mon.SWITCH.STATUS            <= ESM_LEDs;
  Mon.SGMII.PMA_RESET          <= SGMII_MON_buf2.pma_reset;
  Mon.SGMII.MMCM_RESET         <= SGMII_MON_buf2.mmcm_reset;
  Mon.SGMII.RESET_DONE         <= SGMII_MON_buf2.reset_done;
  Mon.SGMII.CPLL_LOCK          <= SGMII_MON_buf2.cpll_lock;
  Mon.SGMII.MMCM_LOCK          <= SGMII_MON_buf2.mmcm_locked;
  Mon.SGMII.SV_LINK_STATUS     <= SGMII_MON_buf2.status_vector(0);
  Mon.SGMII.SV_LINK_SYNC       <= SGMII_MON_buf2.status_vector(1);
  Mon.SGMII.SV_RUDI_AUTONEG    <= SGMII_MON_buf2.status_vector(2);
  Mon.SGMII.SV_RUDI_IDLE       <= SGMII_MON_buf2.status_vector(3);
  Mon.SGMII.SV_RUDI_INVALID    <= SGMII_MON_buf2.status_vector(4);
  Mon.SGMII.SV_RX_DISP_ERR     <= SGMII_MON_buf2.status_vector(5);
  Mon.SGMII.SV_RX_NOT_IN_TABLE <= SGMII_MON_buf2.status_vector(6);
  Mon.SGMII.SV_PHY_LINK_STATUS <= SGMII_MON_buf2.status_vector(7);
  Mon.SGMII.SV_DUPLEX          <= SGMII_MON_buf2.status_vector(12);
  Mon.SGMII.SV_REMOTE_FAULT    <= SGMII_MON_buf2.status_vector(13);

  SI_OUT_EN     <= Ctrl.SI5344.OE;
  SI_ENABLE     <= Ctrl.SI5344.EN; 
  SI_init_reset <= Ctrl.SI5344.FPGA_PLL_RESET;
  TTC_SRC_SEL   <= Ctrl.TCDS.TTC_SOURCE;
  LHC_SRC_SEL   <= Ctrl.CLOCKING.LHC_SEL;
  HQ_SRC_SEL    <= Ctrl.CLOCKING.HQ_SEL;
  FP_LED_RST    <= not Ctrl.FP_LEDS.RESET;
  SGMII_CTRL.reset <= Ctrl.SGMII.RESET;


  
end architecture behavioral;
