--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.SERV_Ctrl.all;
entity SERV_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  SERV_Mon_t;
    Ctrl             : out SERV_Ctrl_t
    );
end entity SERV_interface;
architecture behavioral of SERV_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 12);
  constant Default_reg_data : slv32_array_t(integer range 0 to 12) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

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
      case to_integer(unsigned(localAddress(3 downto 0))) is

        when 0 => --0x0
          localRdData( 0)            <=  reg_data( 0)( 0);                  --Enable Si5344 outputs
          localRdData( 1)            <=  reg_data( 0)( 1);                  --Power on Si5344
          localRdData( 2)            <=  reg_data( 0)( 2);                  --
          localRdData( 4)            <=  Mon.SI5344.INT;                    --Si5344 i2c interrupt
          localRdData( 5)            <=  Mon.SI5344.LOL;                    --Si5344 Loss of lock
          localRdData( 6)            <=  Mon.SI5344.LOS;                    --Si5344 Loss of signal
        when 4 => --0x4
          localRdData( 0)            <=  reg_data( 4)( 0);                  --TTC source select (0:TCDS,1:TTC_FAKE
          localRdData( 4)            <=  Mon.TCDS.REFCLK_LOCKED;            --TCDS refclk locked
        when 5 => --0x5
          localRdData( 0)            <=  Mon.CLOCKING.LHC_LOS_BP;           --Backplane LHC clk LOS
          localRdData( 1)            <=  Mon.CLOCKING.LHC_LOS_OSC;          --Local Si LHC clk LOS
          localRdData( 4)            <=  reg_data( 5)( 4);                  --LHC clk source select
          localRdData( 8)            <=  Mon.CLOCKING.HQ_LOS_BP;            --Backplane HQ clk LOS
          localRdData( 9)            <=  Mon.CLOCKING.HQ_LOS_OSC;           --Local Si HQ clk LOS
          localRdData(12)            <=  reg_data( 5)(12);                  --HQ clk source select
        when 8 => --0x8
          localRdData( 0)            <=  reg_data( 8)( 0);                  --reset FP LEDs
          localRdData( 1)            <=  reg_data( 8)( 1);                  --override FP LED page 0
          localRdData( 4 downto  2)  <=  reg_data( 8)( 4 downto  2);        --override FP LED page 0 pattern
          localRdData( 5)            <=  Mon.FP_LEDS.BUTTON;                --FP button (not debounced)
          localRdData(11 downto  8)  <=  reg_data( 8)(11 downto  8);        --page 0 speed
          localRdData(21 downto 16)  <=  reg_data( 8)(21 downto 16);        --Page to display
          localRdData(22)            <=  reg_data( 8)(22);                  --Force the display of a page (override button UI)
          localRdData(29 downto 24)  <=  reg_data( 8)(29 downto 24);        --Page to display
          localRdData(31)            <=  Mon.FP_LEDS.FP_SHDWN_REQ;          --FP button shutdown request
        when 9 => --0x9
          localRdData(15 downto  0)  <=  Mon.SWITCH.STATUS;                 --Ethernet switch LEDs
        when 12 => --0xc
          localRdData( 0)            <=  reg_data(12)( 0);                  --Reset SGMII + SGMII clocking
          localRdData( 1)            <=  Mon.SGMII.PMA_RESET;               --SGMII pma reset
          localRdData( 2)            <=  Mon.SGMII.MMCM_RESET;              --SGMII mmcm reset
          localRdData( 3)            <=  Mon.SGMII.RESET_DONE;              --SGMII reset sequence done
          localRdData( 4)            <=  Mon.SGMII.CPLL_LOCK;               --SGMII GT CPLL locked
          localRdData( 5)            <=  Mon.SGMII.MMCM_LOCK;               --SGMII MMCM locked
          localRdData(16)            <=  Mon.SGMII.SV_LINK_STATUS;          --This signal indicates the status of the link. When High, the link is valid:          synchronization of the link has been obtained and Auto-Negotiation (if present and enabled)          has successfully completed and the reset sequence of the transceiver (if present) has          completed.
          localRdData(17)            <=  Mon.SGMII.SV_LINK_SYNC;            --When High, link synchronization has been obtained and in the synchronization state machine,               sync_status=OK. When Low, synchronization has failed
          localRdData(18)            <=  Mon.SGMII.SV_RUDI_AUTONEG;         --The core is receiving /C/ ordered sets (Auto-Negotiation Configuration sequences)           as defined in IEEE 802.3-2008 clause 36.2.4.10.
          localRdData(19)            <=  Mon.SGMII.SV_RUDI_IDLE;            --The core is receiving /I/ ordered sets (Idles) as defined in IEEE 802.3-2008 clause               36.2.4.12.
          localRdData(20)            <=  Mon.SGMII.SV_RUDI_INVALID;         --The core has received invalid data while receiving/C/ or /I/ ordered set as            defined in IEEE 802.3-2008 clause 36.2.5.1.6. This can be caused, for example, by bit errors            occurring in any clock cycle of the /C/ or /I/ ordered set.
          localRdData(21)            <=  Mon.SGMII.SV_RX_DISP_ERR;          --The core has received a running disparity error during the 8B/10B decoding           function.
          localRdData(22)            <=  Mon.SGMII.SV_RX_NOT_IN_TABLE;      --The core has received a code group which is not recognized from the 8B/10B               coding tables.
          localRdData(23)            <=  Mon.SGMII.SV_PHY_LINK_STATUS;      --this bit represents the               link status of the external PHY device attached to the other end of the SGMII link (High               indicates that the PHY has obtained a link with its link partner; Low indicates that is has not               linked with its link partner). The value reflected is Link Partner Base AN Register 5 bit 15 in               SGMII MAC mode and the Advertisement Ability register 4 bit 15 in PHY mode. However, this               bit is only valid after successful completion of auto-negotiation across the SGMII link.
          localRdData(28)            <=  Mon.SGMII.SV_DUPLEX;               --1/0 Full/Half duplex
          localRdData(29)            <=  Mon.SGMII.SV_REMOTE_FAULT;         -- When this bit is logic one, it indicates that a remote fault is detected and the              type of remote fault is indicated by status_vector bits[9:8]. This bit reflects MDIO              register bit 1.4.


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.SI5344.OE              <=  reg_data( 0)( 0);               
  Ctrl.SI5344.EN              <=  reg_data( 0)( 1);               
  Ctrl.SI5344.FPGA_PLL_RESET  <=  reg_data( 0)( 2);               
  Ctrl.TCDS.TTC_SOURCE        <=  reg_data( 4)( 0);               
  Ctrl.CLOCKING.LHC_SEL       <=  reg_data( 5)( 4);               
  Ctrl.CLOCKING.HQ_SEL        <=  reg_data( 5)(12);               
  Ctrl.FP_LEDS.RESET          <=  reg_data( 8)( 0);               
  Ctrl.FP_LEDS.PAGE0_FORCE    <=  reg_data( 8)( 1);               
  Ctrl.FP_LEDS.PAGE0_MODE     <=  reg_data( 8)( 4 downto  2);     
  Ctrl.FP_LEDS.PAGE0_SPEED    <=  reg_data( 8)(11 downto  8);     
  Ctrl.FP_LEDS.FORCED_PAGE    <=  reg_data( 8)(21 downto 16);     
  Ctrl.FP_LEDS.FORCE_PAGE     <=  reg_data( 8)(22);               
  Ctrl.FP_LEDS.PAGE           <=  reg_data( 8)(29 downto 24);     
  Ctrl.SGMII.RESET            <=  reg_data(12)( 0);               


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)( 0)  <= DEFAULT_SERV_CTRL_t.SI5344.OE;
      reg_data( 0)( 1)  <= DEFAULT_SERV_CTRL_t.SI5344.EN;
      reg_data( 0)( 2)  <= DEFAULT_SERV_CTRL_t.SI5344.FPGA_PLL_RESET;
      reg_data( 4)( 0)  <= DEFAULT_SERV_CTRL_t.TCDS.TTC_SOURCE;
      reg_data( 5)( 4)  <= DEFAULT_SERV_CTRL_t.CLOCKING.LHC_SEL;
      reg_data( 5)(12)  <= DEFAULT_SERV_CTRL_t.CLOCKING.HQ_SEL;
      reg_data( 8)( 0)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.RESET;
      reg_data( 8)( 1)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.PAGE0_FORCE;
      reg_data( 8)( 4 downto  2)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.PAGE0_MODE;
      reg_data( 8)(11 downto  8)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.PAGE0_SPEED;
      reg_data( 8)(21 downto 16)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.FORCED_PAGE;
      reg_data( 8)(22)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.FORCE_PAGE;
      reg_data( 8)(29 downto 24)  <= DEFAULT_SERV_CTRL_t.FP_LEDS.PAGE;
      reg_data(12)( 0)  <= DEFAULT_SERV_CTRL_t.SGMII.RESET;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(3 downto 0))) is
        when 0 => --0x0
          reg_data( 0)( 0)            <=  localWrData( 0);                --Enable Si5344 outputs
          reg_data( 0)( 1)            <=  localWrData( 1);                --Power on Si5344
          reg_data( 0)( 2)            <=  localWrData( 2);                --
        when 8 => --0x8
          reg_data( 8)( 0)            <=  localWrData( 0);                --reset FP LEDs
          reg_data( 8)( 1)            <=  localWrData( 1);                --override FP LED page 0
          reg_data( 8)( 4 downto  2)  <=  localWrData( 4 downto  2);      --override FP LED page 0 pattern
          reg_data( 8)(11 downto  8)  <=  localWrData(11 downto  8);      --page 0 speed
          reg_data( 8)(21 downto 16)  <=  localWrData(21 downto 16);      --Page to display
          reg_data( 8)(22)            <=  localWrData(22);                --Force the display of a page (override button UI)
          reg_data( 8)(29 downto 24)  <=  localWrData(29 downto 24);      --Page to display
        when 4 => --0x4
          reg_data( 4)( 0)            <=  localWrData( 0);                --TTC source select (0:TCDS,1:TTC_FAKE
        when 5 => --0x5
          reg_data( 5)( 4)            <=  localWrData( 4);                --LHC clk source select
          reg_data( 5)(12)            <=  localWrData(12);                --HQ clk source select
        when 12 => --0xc
          reg_data(12)( 0)            <=  localWrData( 0);                --Reset SGMII + SGMII clocking

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;