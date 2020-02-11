--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package CM_CTRL is
  type CM_CM1_CTRL_MON_t is record
    IOS_ENABLED                : std_logic;                       -- IOs to CM are enabled
    PWR_ENABLED                : std_logic;                       -- power is enabled
    PWR_GOOD                   : std_logic;                       -- CM power is good
    STATE                      : std_logic_vector( 3 downto  0);  -- CM power up state
  end record CM_CM1_CTRL_MON_t;

  type CM_CM1_CTRL_CTRL_t is record
    ENABLE_PWR                 : std_logic;     -- Tell CM uC to power-up the rest of the CM
    ENABLE_UC                  : std_logic;     -- Tell CM uC to power-up
    ERROR_STATE_RESET          : std_logic;     -- CM power is good
    OVERRIDE_PWR_GOOD          : std_logic;     -- Ignore power good from CM
  end record CM_CM1_CTRL_CTRL_t;

  constant DEFAULT_CM_CM1_CTRL_CTRL_t : CM_CM1_CTRL_CTRL_t := (
                                                               OVERRIDE_PWR_GOOD => '0',
                                                               ERROR_STATE_RESET => '0',
                                                               ENABLE_UC => '0',
                                                               ENABLE_PWR => '0'
                                                              );
  type CM_CM1_C2C_RX_MON_t is record
    BUF_STATUS                 : std_logic_vector( 2 downto  0);  -- DEBUG rx buf status
    MONITOR                    : std_logic_vector( 6 downto  0);  -- DEBUG rx status
    PRBS_ERR                   : std_logic;                       -- DEBUG rx PRBS error
    RESET_DONE                 : std_logic;                       -- DEBUG rx reset done
  end record CM_CM1_C2C_RX_MON_t;

  type CM_CM1_C2C_RX_CTRL_t is record
    BUF_RESET                  : std_logic;                       -- DEBUG rx buf reset
    CDR_HOLD                   : std_logic;                       -- DEBUG rx CDR hold
    DFE_AGC_HOLD               : std_logic;                       -- DEBUG rx DFE AGC HOLD
    DFE_AGC_OVERRIDE           : std_logic;                       -- DEBUG rx DFE AGC OVERRIDE
    DFE_LF_HOLD                : std_logic;                       -- DEBUG rx DFE LF HOLD
    DFE_LPM_RESET              : std_logic;                       -- DEBUG rx DFE LPM RESET
    LPM_EN                     : std_logic;                       -- DEBUG rx LPM ENABLE
    LPM_HF_OVERRIDE            : std_logic;                       -- DEBUG rx LPM HF OVERRIDE enable
    LPM_LFKL_OVERRIDE          : std_logic;                       -- DEBUG rx LPM LFKL override
    MON_SEL                    : std_logic_vector( 1 downto  0);  -- DEBUG rx monitor select
    PCS_RESET                  : std_logic;                       -- DEBUG rx pcs reset
    PMA_RESET                  : std_logic;                       -- DEBUG rx pma reset
    PRBS_CNT_RST               : std_logic;                       -- DEBUG rx PRBS counter reset
    PRBS_SEL                   : std_logic_vector( 2 downto  0);  -- DEBUG rx PRBS select
  end record CM_CM1_C2C_RX_CTRL_t;

  constant DEFAULT_CM_CM1_C2C_RX_CTRL_t : CM_CM1_C2C_RX_CTRL_t := (
                                                                   DFE_LPM_RESET => '0',
                                                                   LPM_EN => '0',
                                                                   PRBS_SEL => (others => '0'),
                                                                   CDR_HOLD => '0',
                                                                   PRBS_CNT_RST => '0',
                                                                   DFE_AGC_HOLD => '0',
                                                                   MON_SEL => (others => '0'),
                                                                   LPM_LFKL_OVERRIDE => '0',
                                                                   DFE_AGC_OVERRIDE => '0',
                                                                   DFE_LF_HOLD => '0',
                                                                   BUF_RESET => '0',
                                                                   PMA_RESET => '0',
                                                                   LPM_HF_OVERRIDE => '0',
                                                                   PCS_RESET => '0'
                                                                  );
  type CM_CM1_C2C_TX_MON_t is record
    BUF_STATUS                 : std_logic_vector( 1 downto  0);  -- DEBUG tx buf status
    RESET_DONE                 : std_logic;                       -- DEBUG tx reset done
  end record CM_CM1_C2C_TX_MON_t;

  type CM_CM1_C2C_TX_CTRL_t is record
    DIFF_CTRL                  : std_logic_vector( 3 downto  0);  -- DEBUG tx diff control
    INHIBIT                    : std_logic;                       -- DEBUG tx inhibit
    MAIN_CURSOR                : std_logic_vector( 6 downto  0);  -- DEBUG tx main cursor
    PCS_RESET                  : std_logic;                       -- DEBUG tx pcs reset
    PMA_RESET                  : std_logic;                       -- DEBUG tx pma reset
    POLARITY                   : std_logic;                       -- DEBUG tx polarity
    POST_CURSOR                : std_logic_vector( 4 downto  0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             : std_logic;                       -- DEBUG force PRBS error
    PRBS_SEL                   : std_logic_vector( 2 downto  0);  -- DEBUG PRBS select
    PRE_CURSOR                 : std_logic_vector( 4 downto  0);  -- DEBUG pre cursor
  end record CM_CM1_C2C_TX_CTRL_t;

  constant DEFAULT_CM_CM1_C2C_TX_CTRL_t : CM_CM1_C2C_TX_CTRL_t := (
                                                                   POLARITY => '0',
                                                                   INHIBIT => '0',
                                                                   POST_CURSOR => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   PRBS_FORCE_ERR => '0',
                                                                   DIFF_CTRL => (others => '0'),
                                                                   MAIN_CURSOR => (others => '0'),
                                                                   PMA_RESET => '0',
                                                                   PRE_CURSOR => (others => '0'),
                                                                   PCS_RESET => '0'
                                                                  );
  type CM_CM1_C2C_MON_t is record
    CONFIG_ERROR               : std_logic;                       -- C2C config error
    CPLL_LOCK                  : std_logic;                       -- DEBUG cplllock
    DMONITOR                   : std_logic_vector( 7 downto  0);  -- DEBUG d monitor
    DO_CC                      : std_logic;                       -- Aurora do CC
    EYESCAN_DATA_ERROR         : std_logic;                       -- DEBUG eyescan data error
    LINK_ERROR                 : std_logic;                       -- C2C link error
    LINK_GOOD                  : std_logic;                       -- C2C link FSM in SYNC
    MB_ERROR                   : std_logic;                       -- C2C multi-bit error
    PHY_GT_PLL_LOCK            : std_logic;                       -- Aurora phy GT PLL locked
    PHY_HARD_ERR               : std_logic;                       -- Aurora phy hard error
    PHY_LANE_UP                : std_logic_vector( 1 downto  0);  -- Aurora phy lanes up
    PHY_MMCM_LOL               : std_logic;                       -- Aurora phy mmcm LOL
    PHY_RESET                  : std_logic;                       -- Aurora phy in reset
    PHY_SOFT_ERR               : std_logic;                       -- Aurora phy soft error
    RX                         : CM_CM1_C2C_RX_MON_t;           
    TX                         : CM_CM1_C2C_TX_MON_t;           
  end record CM_CM1_C2C_MON_t;

  type CM_CM1_C2C_CTRL_t is record
    EYESCAN_RESET              : std_logic;             -- DEBUG eyescan reset
    EYESCAN_TRIGGER            : std_logic;             -- DEBUG eyescan trigger
    INITIALIZE                 : std_logic;             -- C2C initialize
    RX                         : CM_CM1_C2C_RX_CTRL_t;
    TX                         : CM_CM1_C2C_TX_CTRL_t;
  end record CM_CM1_C2C_CTRL_t;

  constant DEFAULT_CM_CM1_C2C_CTRL_t : CM_CM1_C2C_CTRL_t := (
                                                             INITIALIZE => '0',
                                                             RX => DEFAULT_CM_CM1_C2C_RX_CTRL_t,
                                                             EYESCAN_RESET => '0',
                                                             EYESCAN_TRIGGER => '0',
                                                             TX => DEFAULT_CM_CM1_C2C_TX_CTRL_t
                                                            );
  type CM_CM1_MONITOR_MON_t is record
    ACTIVE                     : std_logic;                       -- Monitoring active. Is zero when no update in the last second.
    ERRORS                     : std_logic_vector(15 downto  0);  -- Monitoring errors. Count of invalid byte types in parsing.
    HISTORY                    : std_logic_vector(31 downto  0);  -- 4 bytes of uart history
    HISTORY_VALID              : std_logic_vector( 3 downto  0);  -- bytes valid in debug history
  end record CM_CM1_MONITOR_MON_t;

  type CM_CM1_MONITOR_CTRL_t is record
    COUNT_16X_BAUD             : std_logic_vector( 7 downto  0);  -- Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
  end record CM_CM1_MONITOR_CTRL_t;

  constant DEFAULT_CM_CM1_MONITOR_CTRL_t : CM_CM1_MONITOR_CTRL_t := (
                                                                     COUNT_16X_BAUD => (others => '0')
                                                                    );
  type CM_CM1_MON_t is record
    C2C                        : CM_CM1_C2C_MON_t;    
    CTRL                       : CM_CM1_CTRL_MON_t;   
    MONITOR                    : CM_CM1_MONITOR_MON_t;
  end record CM_CM1_MON_t;

  type CM_CM1_CTRL_t is record
    C2C                        : CM_CM1_C2C_CTRL_t;    
    CTRL                       : CM_CM1_CTRL_CTRL_t;   
    MONITOR                    : CM_CM1_MONITOR_CTRL_t;
  end record CM_CM1_CTRL_t;

  constant DEFAULT_CM_CM1_CTRL_t : CM_CM1_CTRL_t := (
                                                     C2C => DEFAULT_CM_CM1_C2C_CTRL_t,
                                                     MONITOR => DEFAULT_CM_CM1_MONITOR_CTRL_t,
                                                     CTRL => DEFAULT_CM_CM1_CTRL_CTRL_t
                                                    );
  type CM_CM2_CTRL_MON_t is record
    IOS_ENABLED                : std_logic;                       -- IOs to CM are enabled
    PWR_ENABLED                : std_logic;                       -- power is enabled
    PWR_GOOD                   : std_logic;                       -- CM power is good
    STATE                      : std_logic_vector( 3 downto  0);  -- CM power up state
  end record CM_CM2_CTRL_MON_t;

  type CM_CM2_CTRL_CTRL_t is record
    ENABLE_PWR                 : std_logic;     -- Tell CM uC to power-up the rest of the CM
    ENABLE_UC                  : std_logic;     -- Tell CM uC to power-up
    ERROR_STATE_RESET          : std_logic;     -- CM power is good
    OVERRIDE_PWR_GOOD          : std_logic;     -- Ignore power good from CM
  end record CM_CM2_CTRL_CTRL_t;

  constant DEFAULT_CM_CM2_CTRL_CTRL_t : CM_CM2_CTRL_CTRL_t := (
                                                               OVERRIDE_PWR_GOOD => '0',
                                                               ERROR_STATE_RESET => '0',
                                                               ENABLE_UC => '0',
                                                               ENABLE_PWR => '0'
                                                              );
  type CM_CM2_C2C_RX_MON_t is record
    BUF_STATUS                 : std_logic_vector( 2 downto  0);  -- DEBUG rx buf status
    MONITOR                    : std_logic_vector( 6 downto  0);  -- DEBUG rx status
    PRBS_ERR                   : std_logic;                       -- DEBUG rx PRBS error
    RESET_DONE                 : std_logic;                       -- DEBUG rx reset done
  end record CM_CM2_C2C_RX_MON_t;

  type CM_CM2_C2C_RX_CTRL_t is record
    BUF_RESET                  : std_logic;                       -- DEBUG rx buf reset
    CDR_HOLD                   : std_logic;                       -- DEBUG rx CDR hold
    DFE_AGC_HOLD               : std_logic;                       -- DEBUG rx DFE AGC HOLD
    DFE_AGC_OVERRIDE           : std_logic;                       -- DEBUG rx DFE AGC OVERRIDE
    DFE_LF_HOLD                : std_logic;                       -- DEBUG rx DFE LF HOLD
    DFE_LPM_RESET              : std_logic;                       -- DEBUG rx DFE LPM RESET
    LPM_EN                     : std_logic;                       -- DEBUG rx LPM ENABLE
    LPM_HF_OVERRIDE            : std_logic;                       -- DEBUG rx LPM HF OVERRIDE enable
    LPM_LFKL_OVERRIDE          : std_logic;                       -- DEBUG rx LPM LFKL override
    MON_SEL                    : std_logic_vector( 1 downto  0);  -- DEBUG rx monitor select
    PCS_RESET                  : std_logic;                       -- DEBUG rx pcs reset
    PMA_RESET                  : std_logic;                       -- DEBUG rx pma reset
    PRBS_CNT_RST               : std_logic;                       -- DEBUG rx PRBS counter reset
    PRBS_SEL                   : std_logic_vector( 2 downto  0);  -- DEBUG rx PRBS select
  end record CM_CM2_C2C_RX_CTRL_t;

  constant DEFAULT_CM_CM2_C2C_RX_CTRL_t : CM_CM2_C2C_RX_CTRL_t := (
                                                                   DFE_LPM_RESET => '0',
                                                                   LPM_EN => '0',
                                                                   PRBS_SEL => (others => '0'),
                                                                   CDR_HOLD => '0',
                                                                   PRBS_CNT_RST => '0',
                                                                   DFE_AGC_HOLD => '0',
                                                                   MON_SEL => (others => '0'),
                                                                   LPM_LFKL_OVERRIDE => '0',
                                                                   DFE_AGC_OVERRIDE => '0',
                                                                   DFE_LF_HOLD => '0',
                                                                   BUF_RESET => '0',
                                                                   PMA_RESET => '0',
                                                                   LPM_HF_OVERRIDE => '0',
                                                                   PCS_RESET => '0'
                                                                  );
  type CM_CM2_C2C_TX_MON_t is record
    BUF_STATUS                 : std_logic_vector( 1 downto  0);  -- DEBUG tx buf status
    RESET_DONE                 : std_logic;                       -- DEBUG tx reset done
  end record CM_CM2_C2C_TX_MON_t;

  type CM_CM2_C2C_TX_CTRL_t is record
    DIFF_CTRL                  : std_logic_vector( 3 downto  0);  -- DEBUG tx diff control
    INHIBIT                    : std_logic;                       -- DEBUG tx inhibit
    MAIN_CURSOR                : std_logic_vector( 6 downto  0);  -- DEBUG tx main cursor
    PCS_RESET                  : std_logic;                       -- DEBUG tx pcs reset
    PMA_RESET                  : std_logic;                       -- DEBUG tx pma reset
    POLARITY                   : std_logic;                       -- DEBUG tx polarity
    POST_CURSOR                : std_logic_vector( 4 downto  0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             : std_logic;                       -- DEBUG force PRBS error
    PRBS_SEL                   : std_logic_vector( 2 downto  0);  -- DEBUG PRBS select
    PRE_CURSOR                 : std_logic_vector( 4 downto  0);  -- DEBUG pre cursor
  end record CM_CM2_C2C_TX_CTRL_t;

  constant DEFAULT_CM_CM2_C2C_TX_CTRL_t : CM_CM2_C2C_TX_CTRL_t := (
                                                                   POLARITY => '0',
                                                                   INHIBIT => '0',
                                                                   POST_CURSOR => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   PRBS_FORCE_ERR => '0',
                                                                   DIFF_CTRL => (others => '0'),
                                                                   MAIN_CURSOR => (others => '0'),
                                                                   PMA_RESET => '0',
                                                                   PRE_CURSOR => (others => '0'),
                                                                   PCS_RESET => '0'
                                                                  );
  type CM_CM2_C2C_MON_t is record
    CONFIG_ERROR               : std_logic;                       -- C2C config error
    CPLL_LOCK                  : std_logic;                       -- DEBUG cplllock
    DMONITOR                   : std_logic_vector( 7 downto  0);  -- DEBUG d monitor
    DO_CC                      : std_logic;                       -- Aurora do CC
    EYESCAN_DATA_ERROR         : std_logic;                       -- DEBUG eyescan data error
    LINK_ERROR                 : std_logic;                       -- C2C link error
    LINK_GOOD                  : std_logic;                       -- C2C link FSM in SYNC
    MB_ERROR                   : std_logic;                       -- C2C multi-bit error
    PHY_GT_PLL_LOCK            : std_logic;                       -- Aurora phy GT PLL locked
    PHY_HARD_ERR               : std_logic;                       -- Aurora phy hard error
    PHY_LANE_UP                : std_logic_vector( 1 downto  0);  -- Aurora phy lanes up
    PHY_MMCM_LOL               : std_logic;                       -- Aurora phy mmcm LOL
    PHY_RESET                  : std_logic;                       -- Aurora phy in reset
    PHY_SOFT_ERR               : std_logic;                       -- Aurora phy soft error
    RX                         : CM_CM2_C2C_RX_MON_t;           
    TX                         : CM_CM2_C2C_TX_MON_t;           
  end record CM_CM2_C2C_MON_t;

  type CM_CM2_C2C_CTRL_t is record
    EYESCAN_RESET              : std_logic;             -- DEBUG eyescan reset
    EYESCAN_TRIGGER            : std_logic;             -- DEBUG eyescan trigger
    INITIALIZE                 : std_logic;             -- C2C initialize
    RX                         : CM_CM2_C2C_RX_CTRL_t;
    TX                         : CM_CM2_C2C_TX_CTRL_t;
  end record CM_CM2_C2C_CTRL_t;

  constant DEFAULT_CM_CM2_C2C_CTRL_t : CM_CM2_C2C_CTRL_t := (
                                                             INITIALIZE => '0',
                                                             RX => DEFAULT_CM_CM2_C2C_RX_CTRL_t,
                                                             EYESCAN_RESET => '0',
                                                             EYESCAN_TRIGGER => '0',
                                                             TX => DEFAULT_CM_CM2_C2C_TX_CTRL_t
                                                            );
  type CM_CM2_MON_t is record
    C2C                        : CM_CM2_C2C_MON_t; 
    CTRL                       : CM_CM2_CTRL_MON_t;
  end record CM_CM2_MON_t;

  type CM_CM2_CTRL_t is record
    C2C                        : CM_CM2_C2C_CTRL_t; 
    CTRL                       : CM_CM2_CTRL_CTRL_t;
  end record CM_CM2_CTRL_t;

  constant DEFAULT_CM_CM2_CTRL_t : CM_CM2_CTRL_t := (
                                                     C2C => DEFAULT_CM_CM2_C2C_CTRL_t,
                                                     CTRL => DEFAULT_CM_CM2_CTRL_CTRL_t
                                                    );
  type CM_MON_t is record
    CM1                        : CM_CM1_MON_t;
    CM2                        : CM_CM2_MON_t;
  end record CM_MON_t;

  type CM_CTRL_t is record
    CM1                        : CM_CM1_CTRL_t;
    CM2                        : CM_CM2_CTRL_t;
  end record CM_CTRL_t;

  constant DEFAULT_CM_CTRL_t : CM_CTRL_t := (
                                             CM2 => DEFAULT_CM_CM2_CTRL_t,
                                             CM1 => DEFAULT_CM_CM1_CTRL_t
                                            );


end package CM_CTRL;