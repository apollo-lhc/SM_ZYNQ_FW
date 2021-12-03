--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package CM_CTRL is
  type CM_CM_C2C_DRP_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(9-1 downto 0);
    wr_data   : std_logic_vector(16-1 downto 0);
  end record CM_CM_C2C_DRP_MOSI_t;
  type CM_CM_C2C_DRP_MISO_t is record
    rd_data         : std_logic_vector(16-1 downto 0);
    rd_data_valid   : std_logic;
  end record CM_CM_C2C_DRP_MISO_t;
  constant Default_CM_CM_C2C_DRP_MOSI_t : CM_CM_C2C_DRP_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type CM_CM_C2C_STATUS_MON_t is record
    CONFIG_ERROR               :std_logic;     -- C2C config error
    LINK_ERROR                 :std_logic;     -- C2C link error
    LINK_GOOD                  :std_logic;     -- C2C link FSM in SYNC
    MB_ERROR                   :std_logic;     -- C2C multi-bit error
    DO_CC                      :std_logic;     -- Aurora do CC
    PHY_RESET                  :std_logic;     -- Aurora phy in reset
    PHY_GT_PLL_LOCK            :std_logic;     -- Aurora phy GT PLL locked
    PHY_MMCM_LOL               :std_logic;     -- Aurora phy mmcm LOL
    PHY_LANE_UP                :std_logic_vector( 1 downto 0);  -- Aurora phy lanes up
    PHY_HARD_ERR               :std_logic;                      -- Aurora phy hard error
    PHY_SOFT_ERR               :std_logic;                      -- Aurora phy soft error
    LINK_IN_FW                 :std_logic;                      -- FW includes this link
  end record CM_CM_C2C_STATUS_MON_t;


  type CM_CM_C2C_STATUS_CTRL_t is record
    INITIALIZE                 :std_logic;     -- C2C initialize
  end record CM_CM_C2C_STATUS_CTRL_t;


  constant DEFAULT_CM_CM_C2C_STATUS_CTRL_t : CM_CM_C2C_STATUS_CTRL_t := (
                                                                         INITIALIZE => '0'
                                                                        );
  type CM_CM_C2C_DEBUG_RX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 2 downto 0);  -- DEBUG rx buf status
    MONITOR                    :std_logic_vector( 6 downto 0);  -- DEBUG rx status
    PRBS_ERR                   :std_logic;                      -- DEBUG rx PRBS error
    RESET_DONE                 :std_logic;                      -- DEBUG rx reset done
  end record CM_CM_C2C_DEBUG_RX_MON_t;


  type CM_CM_C2C_DEBUG_RX_CTRL_t is record
    BUF_RESET                  :std_logic;     -- DEBUG rx buf reset
    CDR_HOLD                   :std_logic;     -- DEBUG rx CDR hold
    DFE_AGC_HOLD               :std_logic;     -- DEBUG rx DFE AGC HOLD
    DFE_AGC_OVERRIDE           :std_logic;     -- DEBUG rx DFE AGC OVERRIDE
    DFE_LF_HOLD                :std_logic;     -- DEBUG rx DFE LF HOLD
    DFE_LPM_RESET              :std_logic;     -- DEBUG rx DFE LPM RESET
    LPM_EN                     :std_logic;     -- DEBUG rx LPM ENABLE
    LPM_HF_OVERRIDE            :std_logic;     -- DEBUG rx LPM HF OVERRIDE enable
    LPM_LFKL_OVERRIDE          :std_logic;     -- DEBUG rx LPM LFKL override
    MON_SEL                    :std_logic_vector( 1 downto 0);  -- DEBUG rx monitor select
    PCS_RESET                  :std_logic;                      -- DEBUG rx pcs reset
    PMA_RESET                  :std_logic;                      -- DEBUG rx pma reset
    PRBS_CNT_RST               :std_logic;                      -- DEBUG rx PRBS counter reset
    PRBS_SEL                   :std_logic_vector( 2 downto 0);  -- DEBUG rx PRBS select
  end record CM_CM_C2C_DEBUG_RX_CTRL_t;


  constant DEFAULT_CM_CM_C2C_DEBUG_RX_CTRL_t : CM_CM_C2C_DEBUG_RX_CTRL_t := (
                                                                             BUF_RESET => '0',
                                                                             CDR_HOLD => '0',
                                                                             DFE_AGC_HOLD => '0',
                                                                             DFE_AGC_OVERRIDE => '0',
                                                                             DFE_LF_HOLD => '0',
                                                                             DFE_LPM_RESET => '0',
                                                                             LPM_EN => '0',
                                                                             LPM_HF_OVERRIDE => '0',
                                                                             LPM_LFKL_OVERRIDE => '0',
                                                                             MON_SEL => (others => '0'),
                                                                             PCS_RESET => '0',
                                                                             PMA_RESET => '0',
                                                                             PRBS_CNT_RST => '0',
                                                                             PRBS_SEL => (others => '0')
                                                                            );
  type CM_CM_C2C_DEBUG_TX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 1 downto 0);  -- DEBUG tx buf status
    RESET_DONE                 :std_logic;                      -- DEBUG tx reset done
  end record CM_CM_C2C_DEBUG_TX_MON_t;


  type CM_CM_C2C_DEBUG_TX_CTRL_t is record
    DIFF_CTRL                  :std_logic_vector( 3 downto 0);  -- DEBUG tx diff control
    INHIBIT                    :std_logic;                      -- DEBUG tx inhibit
    MAIN_CURSOR                :std_logic_vector( 6 downto 0);  -- DEBUG tx main cursor
    PCS_RESET                  :std_logic;                      -- DEBUG tx pcs reset
    PMA_RESET                  :std_logic;                      -- DEBUG tx pma reset
    POLARITY                   :std_logic;                      -- DEBUG tx polarity
    POST_CURSOR                :std_logic_vector( 4 downto 0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             :std_logic;                      -- DEBUG force PRBS error
    PRBS_SEL                   :std_logic_vector( 2 downto 0);  -- DEBUG PRBS select
    PRE_CURSOR                 :std_logic_vector( 4 downto 0);  -- DEBUG pre cursor
  end record CM_CM_C2C_DEBUG_TX_CTRL_t;


  constant DEFAULT_CM_CM_C2C_DEBUG_TX_CTRL_t : CM_CM_C2C_DEBUG_TX_CTRL_t := (
                                                                             DIFF_CTRL => (others => '0'),
                                                                             INHIBIT => '0',
                                                                             MAIN_CURSOR => (others => '0'),
                                                                             PCS_RESET => '0',
                                                                             PMA_RESET => '0',
                                                                             POLARITY => '0',
                                                                             POST_CURSOR => (others => '0'),
                                                                             PRBS_FORCE_ERR => '0',
                                                                             PRBS_SEL => (others => '0'),
                                                                             PRE_CURSOR => (others => '0')
                                                                            );
  type CM_CM_C2C_DEBUG_MON_t is record
    DMONITOR                   :std_logic_vector( 7 downto 0);  -- DEBUG d monitor
    CPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    EYESCAN_DATA_ERROR         :std_logic;                      -- DEBUG eyescan data error
    QPLL_LOCK                  :std_logic;                      -- DEBUG qplllock
    RX                         :CM_CM_C2C_DEBUG_RX_MON_t;     
    TX                         :CM_CM_C2C_DEBUG_TX_MON_t;     
  end record CM_CM_C2C_DEBUG_MON_t;


  type CM_CM_C2C_DEBUG_CTRL_t is record
    EYESCAN_RESET              :std_logic;     -- DEBUG eyescan reset
    EYESCAN_TRIGGER            :std_logic;     -- DEBUG eyescan trigger
    RX                         :CM_CM_C2C_DEBUG_RX_CTRL_t;
    TX                         :CM_CM_C2C_DEBUG_TX_CTRL_t;
  end record CM_CM_C2C_DEBUG_CTRL_t;


  constant DEFAULT_CM_CM_C2C_DEBUG_CTRL_t : CM_CM_C2C_DEBUG_CTRL_t := (
                                                                       EYESCAN_RESET => '0',
                                                                       EYESCAN_TRIGGER => '0',
                                                                       RX => DEFAULT_CM_CM_C2C_DEBUG_RX_CTRL_t,
                                                                       TX => DEFAULT_CM_CM_C2C_DEBUG_TX_CTRL_t
                                                                      );
  type CM_CM_C2C_COUNTERS_MON_t is record
    ERRORS_ALL_TIME            :std_logic_vector(31 downto 0);  -- Counter for all errors while locked
    ERRORS_SINCE_LOCKED        :std_logic_vector(31 downto 0);  -- Counter for errors since locked
    CONFIG_ERROR_COUNT         :std_logic_vector(31 downto 0);  -- Counter for CONFIG_ERROR
    LINK_ERROR_COUNT           :std_logic_vector(31 downto 0);  -- Counter for LINK_ERROR
    MB_ERROR_COUNT             :std_logic_vector(31 downto 0);  -- Counter for MB_ERROR
    PHY_HARD_ERROR_COUNT       :std_logic_vector(31 downto 0);  -- Counter for PHY_HARD_ERROR
    PHY_SOFT_ERROR_COUNT       :std_logic_vector(31 downto 0);  -- Counter for PHY_SOFT_ERROR
    PHYLANE_STATE              :std_logic_vector( 2 downto 0);  -- Current state of phy_lane_control module
    ERROR_WAITS_SINCE_LOCKED   :std_logic_vector(31 downto 0);  -- Count for phylane in error state
    USER_CLK_FREQ              :std_logic_vector(31 downto 0);  -- Frequency of the user C2C clk
    XCVR_RESETS                :std_logic_vector(31 downto 0);  -- Count for phylane in error state
    WAITING_TIMEOUTS           :std_logic_vector(31 downto 0);  -- Count for phylane in error state
  end record CM_CM_C2C_COUNTERS_MON_t;


  type CM_CM_C2C_COUNTERS_CTRL_t is record
    RESET_COUNTERS             :std_logic;     -- Reset counters in Monitor
  end record CM_CM_C2C_COUNTERS_CTRL_t;


  constant DEFAULT_CM_CM_C2C_COUNTERS_CTRL_t : CM_CM_C2C_COUNTERS_CTRL_t := (
                                                                             RESET_COUNTERS => '0'
                                                                            );
  type CM_CM_C2C_BRIDGE_INFO_AXI_MON_t is record
    ADDR_LSB                   :std_logic_vector(31 downto 0);
    ADDR_MSB                   :std_logic_vector(31 downto 0);
    SIZE                       :std_logic_vector(31 downto 0);
    VALID                      :std_logic;                    
  end record CM_CM_C2C_BRIDGE_INFO_AXI_MON_t;


  type CM_CM_C2C_BRIDGE_INFO_AXILITE_MON_t is record
    ADDR_LSB                   :std_logic_vector(31 downto 0);
    ADDR_MSB                   :std_logic_vector(31 downto 0);
    SIZE                       :std_logic_vector(31 downto 0);
    VALID                      :std_logic;                    
  end record CM_CM_C2C_BRIDGE_INFO_AXILITE_MON_t;


  type CM_CM_C2C_BRIDGE_INFO_MON_t is record
    AXI                        :CM_CM_C2C_BRIDGE_INFO_AXI_MON_t;
    AXILITE                    :CM_CM_C2C_BRIDGE_INFO_AXILITE_MON_t;
  end record CM_CM_C2C_BRIDGE_INFO_MON_t;


  type CM_CM_C2C_MON_t is record
    DRP                        :CM_CM_C2C_DRP_MISO_t;
    STATUS                     :CM_CM_C2C_STATUS_MON_t;
    DEBUG                      :CM_CM_C2C_DEBUG_MON_t; 
    COUNTERS                   :CM_CM_C2C_COUNTERS_MON_t;
    BRIDGE_INFO                :CM_CM_C2C_BRIDGE_INFO_MON_t;
    USER_FREQ                  :std_logic_vector(31 downto 0);  -- Measured Freq of clock
  end record CM_CM_C2C_MON_t;
  type CM_CM_C2C_MON_t_ARRAY is array(1 to 2) of CM_CM_C2C_MON_t;

  type CM_CM_C2C_CTRL_t is record
    DRP                        :CM_CM_C2C_DRP_MOSI_t;
    STATUS                     :CM_CM_C2C_STATUS_CTRL_t;
    DEBUG                      :CM_CM_C2C_DEBUG_CTRL_t; 
    COUNTERS                   :CM_CM_C2C_COUNTERS_CTRL_t;
    PHY_READ_TIME              :std_logic_vector(23 downto 0);  -- Time spent waiting for phylane to stabilize
    ENABLE_PHY_CTRL            :std_logic;                      -- phy_lane_control is enabled
    PHY_LANE_STABLE            :std_logic_vector(19 downto 0);  -- Contious phy_lane_up signals required to lock phylane control
    PHY_LANE_ERRORS_TO_RESET   :std_logic_vector( 7 downto 0);  -- Number of failures before we reset the pma
    PHY_MAX_SINGLE_BIT_ERROR_RATE  :std_logic_vector(31 downto 0);  -- Max single bit error rate
    PHY_MAX_MULTI_BIT_ERROR_RATE   :std_logic_vector(31 downto 0);  -- Max multi  bit error rate
  end record CM_CM_C2C_CTRL_t;
  type CM_CM_C2C_CTRL_t_ARRAY is array(1 to 2) of CM_CM_C2C_CTRL_t;

  constant DEFAULT_CM_CM_C2C_CTRL_t : CM_CM_C2C_CTRL_t := (
                                                           DRP => Default_CM_CM_C2C_DRP_MOSI_t,
                                                           STATUS => DEFAULT_CM_CM_C2C_STATUS_CTRL_t,
                                                           DEBUG => DEFAULT_CM_CM_C2C_DEBUG_CTRL_t,
                                                           COUNTERS => DEFAULT_CM_CM_C2C_COUNTERS_CTRL_t,
                                                           PHY_READ_TIME => x"4c4b40",
                                                           ENABLE_PHY_CTRL => '1',
                                                           PHY_LANE_STABLE => x"000ff",
                                                           PHY_LANE_ERRORS_TO_RESET => x"ff",
                                                           PHY_MAX_SINGLE_BIT_ERROR_RATE => x"000000ff",
                                                           PHY_MAX_MULTI_BIT_ERROR_RATE => x"000000ff"
                                                          );
  type CM_CM_CTRL_MON_t is record
    PWR_GOOD                   :std_logic;     -- CM power is good
    STATE                      :std_logic_vector( 3 downto 0);  -- CM power up state
    PWR_ENABLED                :std_logic;                      -- power is enabled
    IOS_ENABLED                :std_logic;                      -- IOs to CM are enabled
  end record CM_CM_CTRL_MON_t;


  type CM_CM_CTRL_CTRL_t is record
    ENABLE_UC                  :std_logic;     -- Tell CM uC to power-up
    ENABLE_PWR                 :std_logic;     -- Tell CM uC to power-up the rest of the CM
    OVERRIDE_PWR_GOOD          :std_logic;     -- Ignore power good from CM
    ERROR_STATE_RESET          :std_logic;     -- CM power is good
  end record CM_CM_CTRL_CTRL_t;


  constant DEFAULT_CM_CM_CTRL_CTRL_t : CM_CM_CTRL_CTRL_t := (
                                                             ENABLE_UC => '0',
                                                             ENABLE_PWR => '0',
                                                             OVERRIDE_PWR_GOOD => '0',
                                                             ERROR_STATE_RESET => '0'
                                                            );
  type CM_CM_MONITOR_BAD_TRANS_MON_t is record
    ADDR                       :std_logic_vector( 7 downto 0);  -- Sensor addr bits
    DATA                       :std_logic_vector(15 downto 0);  -- Sensor data bits
    ERROR_MASK                 :std_logic_vector( 7 downto 0);  -- Sensor error bits
  end record CM_CM_MONITOR_BAD_TRANS_MON_t;


  type CM_CM_MONITOR_LAST_TRANS_MON_t is record
    ADDR                       :std_logic_vector( 7 downto 0);  -- Sensor addr bits
    DATA                       :std_logic_vector(15 downto 0);  -- Sensor data bits
    ERROR_MASK                 :std_logic_vector( 7 downto 0);  -- Sensor error bits
  end record CM_CM_MONITOR_LAST_TRANS_MON_t;


  type CM_CM_MONITOR_ERRORS_MON_t is record
    CNT_BAD_SOF                :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_AXI_BUSY_BYTE2         :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_BYTE2_NOT_DATA         :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_BYTE3_NOT_DATA         :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_BYTE4_NOT_DATA         :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_TIMEOUT                :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
    CNT_UNKNOWN                :std_logic_vector(15 downto 0);  -- Monitoring errors. Count of invalid byte types in parsing.
  end record CM_CM_MONITOR_ERRORS_MON_t;


  type CM_CM_MONITOR_ERRORS_CTRL_t is record
    RESET                      :std_logic;     -- Reset monitoring error counters
  end record CM_CM_MONITOR_ERRORS_CTRL_t;


  constant DEFAULT_CM_CM_MONITOR_ERRORS_CTRL_t : CM_CM_MONITOR_ERRORS_CTRL_t := (
                                                                                 RESET => '0'
                                                                                );
  type CM_CM_MONITOR_MON_t is record
    ACTIVE                     :std_logic;     -- Monitoring active. Is zero when no update in the last second.
    HISTORY_VALID              :std_logic_vector( 3 downto 0);  -- bytes valid in debug history
    HISTORY                    :std_logic_vector(31 downto 0);  -- 4 bytes of uart history
    BAD_TRANS                  :CM_CM_MONITOR_BAD_TRANS_MON_t;
    LAST_TRANS                 :CM_CM_MONITOR_LAST_TRANS_MON_t;
    ERRORS                     :CM_CM_MONITOR_ERRORS_MON_t;    
    UART_BYTES                 :std_logic_vector(31 downto 0);   -- Count of UART bytes from CM MCU
  end record CM_CM_MONITOR_MON_t;


  type CM_CM_MONITOR_CTRL_t is record
    COUNT_16X_BAUD             :std_logic_vector( 7 downto 0);  -- Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
    ENABLE                     :std_logic;                      -- Enable readout
    ERRORS                     :CM_CM_MONITOR_ERRORS_CTRL_t;  
    SM_TIMEOUT                 :std_logic_vector(31 downto 0);  -- Count to wait for in state machine before timing out (50Mhz clk)
  end record CM_CM_MONITOR_CTRL_t;


  constant DEFAULT_CM_CM_MONITOR_CTRL_t : CM_CM_MONITOR_CTRL_t := (
                                                                   COUNT_16X_BAUD => x"1b",
                                                                   ENABLE => '0',
                                                                   ERRORS => DEFAULT_CM_CM_MONITOR_ERRORS_CTRL_t,
                                                                   SM_TIMEOUT => x"0001fca0"
                                                                  );
  type CM_CM_MON_t is record
    C2C                        :CM_CM_C2C_MON_t_ARRAY;
    CTRL                       :CM_CM_CTRL_MON_t;     
    MONITOR                    :CM_CM_MONITOR_MON_t;  
  end record CM_CM_MON_t;
  type CM_CM_MON_t_ARRAY is array(1 to 2) of CM_CM_MON_t;

  type CM_CM_CTRL_t is record
    C2C                        :CM_CM_C2C_CTRL_t_ARRAY;
    CTRL                       :CM_CM_CTRL_CTRL_t;     
    MONITOR                    :CM_CM_MONITOR_CTRL_t;  
  end record CM_CM_CTRL_t;
  type CM_CM_CTRL_t_ARRAY is array(1 to 2) of CM_CM_CTRL_t;

  constant DEFAULT_CM_CM_CTRL_t : CM_CM_CTRL_t := (
                                                   C2C => (others => DEFAULT_CM_CM_C2C_CTRL_t ),
                                                   CTRL => DEFAULT_CM_CM_CTRL_CTRL_t,
                                                   MONITOR => DEFAULT_CM_CM_MONITOR_CTRL_t
                                                  );
  type CM_MON_t is record
    CM                         :CM_CM_MON_t_ARRAY;
  end record CM_MON_t;


  type CM_CTRL_t is record
    CM                         :CM_CM_CTRL_t_ARRAY;
  end record CM_CTRL_t;


  constant DEFAULT_CM_CTRL_t : CM_CTRL_t := (
                                             CM => (others => DEFAULT_CM_CM_CTRL_t )
                                            );


end package CM_CTRL;