library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.SGMII_MONITOR.all;
use work.CM_package.all;


entity services is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO;

    SGMII_MON       : in  SGMII_MONITOR_t;
    SGMII_CTRL      : out SGMII_CONTROL_t;
    
    SI_INT          : in  std_logic;
    SI_LOL          : in  std_logic;
    SI_LOS          : in  std_logic;
    SI_OUT_EN       : out std_logic;
    SI_ENABLE       : out std_logic;
    SI_Handoff      : in  std_logic;
    SI_init_reset   : out std_logic;
    
    TTC_SRC_SEL     : out std_logic;

    LHC_CLK_CMS_LOS : in  std_logic;
    LHC_CLK_OSC_LOS : in  std_logic;
    LHC_SRC_SEL     : out std_logic;
    HQ_CLK_CMS_LOS  : in  std_logic;
    HQ_CLK_OSC_LOS  : in  std_logic;
    HQ_SRC_SEL      : out std_logic;
    FP_LED_RST      : out std_logic;
    FP_LED_CLK      : out std_logic;
    FP_LED_SDA      : out std_logic;
    FP_switch       : in  std_logic;
    linux_booted    : in  std_logic;
    
    ESM_LED_CLK     : in  std_logic;
    ESM_LED_SDA     : in  std_logic;
    CM1_C2C_Mon     : in  C2C_Monitor_t;
    CM2_C2C_Mon     : in  C2C_Monitor_t
    );
end entity services;

architecture behavioral of services is
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  

  signal reg_data :  slv32_array_t(integer range 0 to 15);
  constant Default_reg_data : slv32_array_t(integer range 0 to 15) := (0 => x"00000003",
                                                                       4 => x"00000001",
                                                                       5 => x"00001010",
                                                                       8 => x"00000800",
                                                                       others => x"00000000");


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

  LED0_Mode_sel: process (linux_booted,reg_data(8)(1) ) is
  begin  -- process LED0_Mode_sel
    if(reg_data(8)(1) = '1') then
      LED_mode <= reg_data(8)(4 downto 2);
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
      speed => reg_data(8)(11 downto 8),
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
      addressin     => reg_data(8)(21 downto 16),
      force_address => reg_data(8)(22),
      display_regs  => FP_regs,
      addressout    => FP_addr,--reg_data(8)(29 downto 24),
      SCK           => FP_LED_CLK,
      SDA           => FP_LED_SDA,
      shutdownout   => FP_shutdown);--reg_data(8)(31);
  
  
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_SGMII_domain: process (clk_axi) is
  begin  -- process latch_SGMII_domain
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      SGMII_MON_buf1 <= SGMII_MON;
      SGMII_MON_buf2 <= SGMII_MON_buf1;
    end if;
  end process latch_SGMII_domain;
  

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case localAddress(3 downto 0) is
        when x"0" =>
          localRdData( 0) <= reg_data(0)( 0);   -- SI5344 OUTPUT ENABLE
          localRdData( 1) <= reg_data(0)( 1);   -- SI5344 ENABLE
          localRdData( 2) <= reg_data(0)( 2);   -- SI5344 ENABLE
          localRdData( 4) <= not SI_INT;           -- SI5344 interrupt
          localRdData( 5) <= not SI_LOL;           -- SI5344 loss of lock
          localRdData( 6) <= not SI_LOS;           -- SI5344 loss of signal
          localRdData(31) <= SI_Handoff;
        when x"4" =>                           
          localRdData( 0) <= reg_data(4)( 0);   -- TTC source select (0: TCDS, 1: TTC_FAKE)
        when x"5" =>                           
          localRdData( 0) <= LHC_CLK_CMS_LOS;  -- LHC clk TCDS LOS
          localRdData( 1) <= LHC_CLK_OSC_LOS;  -- LHC CLK osc LOS
          localRdData( 4) <= reg_data(5)( 4);   -- LHC clk select
          localRdData( 8) <= HQ_CLK_CMS_LOS;   -- HQ clk TCDS LOS
          localRdData( 9) <= HQ_CLK_OSC_LOS;   -- HQ CLK osc LOS
          localRdData(12) <= reg_data(5)(12); -- HQ clk select
        when x"8" =>
          localRdData( 0) <= reg_data(8)( 0);   -- FP LED reste
          localRdData( 1) <= reg_data(8)( 1);   -- FP page 0 override
          localRdData( 4 downto  2) <= reg_data(8)( 4 downto  2); --FP page 0
                                                                  --override mode
          localRdData( 5) <= FP_switch;        -- FP Switch (should be debounced)
          localRdData(11 downto  8) <= reg_data(8)(11 downto  8);  --FP speed
          localRdData(21 downto 16) <= reg_data(8)(21 downto 16);  -- force
                                                                  -- page value
          localRdData(22) <= reg_data(8)(22);           -- force page
          localRdData(29 downto 24) <= reg_data(8)(29 downto 24);
          localRdData(31) <= FP_shutdown;
        when x"9" =>
          localRdData(15 downto 0) <= ESM_LEDs; -- decoded ESM LEDs
        when x"C" =>
          localRdData( 0) <= reg_data(12)(0);   --overall SGMII reset input
          localRdData( 1) <= SGMII_MON_buf2.pma_reset;   --overall SGMII reset output
          localRdData( 2) <= SGMII_MON_buf2.mmcm_reset;  --SGMII mmcm reset
          localRdData( 3) <= SGMII_MON_buf2.reset_done;  --last SGMII reset is done

          localRdData( 4) <= SGMII_MON_buf2.cpll_lock;   --cpll lock
          localRdData( 5) <= SGMII_MON_buf2.mmcm_locked;   --mmcm locked
          localRdData(31 downto 16) <= SGMII_MON_buf2.status_vector; --SGMII status
                                                                --vector
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  SI_OUT_EN   <= reg_data(0)( 0);   -- SI5344 OUT_DIS
  SI_ENABLE   <= reg_data(0)( 1);   -- SI5344 ENABLE
  SI_init_reset <= reg_data(0)(2);
  TTC_SRC_SEL <= reg_data(4)( 0);   -- TTC source select (0: TCDS, 1: TTC_FAKE)
  LHC_SRC_SEL <= reg_data(5)( 4);   -- LHC clk select
  HQ_SRC_SEL  <= reg_data(5)(12);   -- HQ clk select
  FP_LED_RST  <= not reg_data(8)( 0);   -- FP LED reste

  SGMII_CTRL.reset <= reg_data(12)(0); --SGMII full reset;
  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active high)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge

      
      if localWrEn = '1' then
        case localAddress(3 downto 0) is
          when x"0" =>
            reg_data(0)( 0) <= localWrData( 0);   -- SI5344 OUTPUT ENABLE
            reg_data(0)( 1) <= localWrData( 1);   -- SI5344 ENABLE
            reg_data(0)( 2) <= localWrData( 2);   -- SI5344 ENABLE
          when x"4" =>                           
            reg_data(4)( 0) <= localWrData( 0);   -- TTC source select (0: TCDS, 1: TTC_FAKE)
          when x"5" =>                           
            reg_data(5)( 4) <= localWrData( 4);   -- LHC clk select
            reg_data(5)(12) <= localWrData(12); -- HQ clk select
          when x"8" =>
            reg_data(8)( 0)           <= localWrData( 0);   -- FP LED reste
            reg_data(8)( 1)           <= localWrData( 1);   -- FP page 0 override
            reg_data(8)( 4 downto  2) <= localWrData( 4 downto  2); --FP page 0
                                                                --override mode
            reg_data(8)(11 downto  8) <= localWrData(11 downto  8); --FP speed
            reg_data(8)(21 downto 16) <= localWrData(21 downto 16); -- force
                                                                    -- page value
            reg_data(8)(22)           <= localWrData(22);           -- force page
          when x"C" =>
            reg_data(12)( 0) <= localWrData( 0);

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


  

  
end architecture behavioral;
