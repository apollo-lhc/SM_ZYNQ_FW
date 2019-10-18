library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.SGMII_MONITOR.all;

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
                    
    ESM_LED_CLK     : in  std_logic;
    ESM_LED_SDA     : in  std_logic
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
                                                                       8 => x"00000000",
                                                                       others => x"00000000");


  signal ESM_LEDs : slv_16_t;
  signal ESM_clk_last : std_logic;

  signal SGMII_MON_buf1 : SGMII_MONITOR_t;
  signal SGMII_MON_buf2 : SGMII_MONITOR_t;


  
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
          localRdData( 1) <= reg_data(8)( 1);   -- FP LED clk
          localRdData( 2) <= reg_data(8)( 2);   -- FP LED sda
          localRdData( 4) <= FP_switch;        -- FP Switch (should be debounced)
          localRdData(31 downto 16) <= ESM_LEDs; -- decoded ESM LEDs
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
  FP_LED_CLK  <= reg_data(8)( 1);   -- FP LED clk
  FP_LED_SDA  <= reg_data(8)( 2);   -- FP LED sda

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
            reg_data(8)( 0) <= localWrData( 0);   -- FP LED reste
            reg_data(8)( 1) <= localWrData( 1);   -- FP LED clk
            reg_data(8)( 2) <= localWrData( 2);   -- FP LED sda
          when x"C" =>
            reg_data(12)( 0) <= localWrData( 0);

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


  

  
end architecture behavioral;
