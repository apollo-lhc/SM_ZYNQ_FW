--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package SERV_CTRL is
  type SERV_SI5344_MON_t is record
    INT                        :std_logic;     -- Si5344 i2c interrupt
    LOL                        :std_logic;     -- Si5344 Loss of lock
    LOS                        :std_logic;     -- Si5344 Loss of signal
  end record SERV_SI5344_MON_t;


  type SERV_SI5344_CTRL_t is record
    OE                         :std_logic;     -- Enable Si5344 outputs
    EN                         :std_logic;     -- Power on Si5344
    FPGA_PLL_RESET             :std_logic;   
  end record SERV_SI5344_CTRL_t;


  constant DEFAULT_SERV_SI5344_CTRL_t : SERV_SI5344_CTRL_t := (
                                                               FPGA_PLL_RESET => '0',
                                                               OE => '1',
                                                               EN => '1'
                                                              );
  type SERV_TCDS_MON_t is record
    REFCLK_LOCKED              :std_logic;     -- TCDS refclk locked
  end record SERV_TCDS_MON_t;


  type SERV_TCDS_CTRL_t is record
    TTC_SOURCE                 :std_logic;     -- TTC source select (0:TCDS,1:TTC_FAKE
  end record SERV_TCDS_CTRL_t;


  constant DEFAULT_SERV_TCDS_CTRL_t : SERV_TCDS_CTRL_t := (
                                                           TTC_SOURCE => '1'
                                                          );
  type SERV_CLOCKING_MON_t is record
    LHC_LOS_BP                 :std_logic;     -- Backplane LHC clk LOS
    LHC_LOS_OSC                :std_logic;     -- Local Si LHC clk LOS
    HQ_LOS_BP                  :std_logic;     -- Backplane HQ clk LOS
    HQ_LOS_OSC                 :std_logic;     -- Local Si HQ clk LOS
  end record SERV_CLOCKING_MON_t;


  type SERV_CLOCKING_CTRL_t is record
    LHC_SEL                    :std_logic;     -- LHC clk source select
    HQ_SEL                     :std_logic;     -- HQ clk source select
  end record SERV_CLOCKING_CTRL_t;


  constant DEFAULT_SERV_CLOCKING_CTRL_t : SERV_CLOCKING_CTRL_t := (
                                                                   HQ_SEL => '1',
                                                                   LHC_SEL => '1'
                                                                  );
  type SERV_FP_LEDS_MON_t is record
    BUTTON                     :std_logic;     -- FP button (not debounced)
    FP_SHDWN_REQ               :std_logic;     -- FP button shutdown request
  end record SERV_FP_LEDS_MON_t;


  type SERV_FP_LEDS_CTRL_t is record
    RESET                      :std_logic;     -- reset FP LEDs
    PAGE0_FORCE                :std_logic;     -- override FP LED page 0
    PAGE0_MODE                 :std_logic_vector( 2 downto 0);  -- override FP LED page 0 pattern
    PAGE0_SPEED                :std_logic_vector( 3 downto 0);  -- page 0 speed
    FORCED_PAGE                :std_logic_vector( 5 downto 0);  -- Page to display
    FORCE_PAGE                 :std_logic;                      -- Force the display of a page (override button UI)
    PAGE                       :std_logic_vector( 5 downto 0);  -- Page to display
  end record SERV_FP_LEDS_CTRL_t;


  constant DEFAULT_SERV_FP_LEDS_CTRL_t : SERV_FP_LEDS_CTRL_t := (
                                                                 RESET => '0',
                                                                 PAGE0_FORCE => '0',
                                                                 PAGE0_SPEED => x"8",
                                                                 FORCE_PAGE => '0',
                                                                 PAGE0_MODE => (others => '0'),
                                                                 FORCED_PAGE => (others => '0'),
                                                                 PAGE => (others => '0')
                                                                );
  type SERV_SWITCH_MON_t is record
    STATUS                     :std_logic_vector(15 downto 0);  -- Ethernet switch LEDs
  end record SERV_SWITCH_MON_t;


  type SERV_SGMII_MON_t is record
    PMA_RESET                  :std_logic;     -- SGMII pma reset
    MMCM_RESET                 :std_logic;     -- SGMII mmcm reset
    RESET_DONE                 :std_logic;     -- SGMII reset sequence done
    CPLL_LOCK                  :std_logic;     -- SGMII GT CPLL locked
    MMCM_LOCK                  :std_logic;     -- SGMII MMCM locked
    SV_LINK_STATUS             :std_logic;     -- This signal indicates the status of the link. When High, the link is valid:          synchronization of the link has been obtained and Auto-Negotiation (if present and enabled)          has successfully completed and the reset sequence of the transceiver (if present) has          completed.
    SV_LINK_SYNC               :std_logic;     -- When High, link synchronization has been obtained and in the synchronization state machine,               sync_status=OK. When Low, synchronization has failed
    SV_RUDI_AUTONEG            :std_logic;     -- The core is receiving /C/ ordered sets (Auto-Negotiation Configuration sequences)           as defined in IEEE 802.3-2008 clause 36.2.4.10.
    SV_RUDI_IDLE               :std_logic;     -- The core is receiving /I/ ordered sets (Idles) as defined in IEEE 802.3-2008 clause               36.2.4.12.
    SV_RUDI_INVALID            :std_logic;     -- The core has received invalid data while receiving/C/ or /I/ ordered set as            defined in IEEE 802.3-2008 clause 36.2.5.1.6. This can be caused, for example, by bit errors            occurring in any clock cycle of the /C/ or /I/ ordered set.
    SV_RX_DISP_ERR             :std_logic;     -- The core has received a running disparity error during the 8B/10B decoding           function.
    SV_RX_NOT_IN_TABLE         :std_logic;     -- The core has received a code group which is not recognized from the 8B/10B               coding tables.
    SV_PHY_LINK_STATUS         :std_logic;     -- this bit represents the               link status of the external PHY device attached to the other end of the SGMII link (High               indicates that the PHY has obtained a link with its link partner; Low indicates that is has not               linked with its link partner). The value reflected is Link Partner Base AN Register 5 bit 15 in               SGMII MAC mode and the Advertisement Ability register 4 bit 15 in PHY mode. However, this               bit is only valid after successful completion of auto-negotiation across the SGMII link.
    SV_DUPLEX                  :std_logic;     -- 1/0 Full/Half duplex
    SV_REMOTE_FAULT            :std_logic;     --  When this bit is logic one, it indicates that a remote fault is detected and the              type of remote fault is indicated by status_vector bits[9:8]. This bit reflects MDIO              register bit 1.4.
  end record SERV_SGMII_MON_t;


  type SERV_SGMII_CTRL_t is record
    RESET                      :std_logic;     -- Reset SGMII + SGMII clocking
  end record SERV_SGMII_CTRL_t;


  constant DEFAULT_SERV_SGMII_CTRL_t : SERV_SGMII_CTRL_t := (
                                                             RESET => '0'
                                                            );
  type SERV_MON_t is record
    SI5344                     :SERV_SI5344_MON_t;
    TCDS                       :SERV_TCDS_MON_t;  
    CLOCKING                   :SERV_CLOCKING_MON_t;
    FP_LEDS                    :SERV_FP_LEDS_MON_t; 
    SWITCH                     :SERV_SWITCH_MON_t;  
    SGMII                      :SERV_SGMII_MON_t;   
  end record SERV_MON_t;


  type SERV_CTRL_t is record
    SI5344                     :SERV_SI5344_CTRL_t;
    TCDS                       :SERV_TCDS_CTRL_t;  
    CLOCKING                   :SERV_CLOCKING_CTRL_t;
    FP_LEDS                    :SERV_FP_LEDS_CTRL_t; 
    SGMII                      :SERV_SGMII_CTRL_t;   
  end record SERV_CTRL_t;


  constant DEFAULT_SERV_CTRL_t : SERV_CTRL_t := (
                                                 FP_LEDS => DEFAULT_SERV_FP_LEDS_CTRL_t,
                                                 SGMII => DEFAULT_SERV_SGMII_CTRL_t,
                                                 SI5344 => DEFAULT_SERV_SI5344_CTRL_t,
                                                 TCDS => DEFAULT_SERV_TCDS_CTRL_t,
                                                 CLOCKING => DEFAULT_SERV_CLOCKING_CTRL_t
                                                );


end package SERV_CTRL;