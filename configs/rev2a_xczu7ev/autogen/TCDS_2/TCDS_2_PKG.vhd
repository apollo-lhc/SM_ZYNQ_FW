--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS_2_CTRL is
  type TCDS_2_TCDS_2_HW_CFG_MON_t is record
    HAS_SPY_REGISTERS          :std_logic;   
    HAS_LINK_TEST_MODE         :std_logic;   
  end record TCDS_2_TCDS_2_HW_CFG_MON_t;


  type TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t is record
    LINK_TEST_MODE             :std_logic;   
    PRBS_GEN_RESET             :std_logic;   
    PRBS_CHK_RESET             :std_logic;   
  end record TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t : TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t := (
                                                                                                       LINK_TEST_MODE => '0',
                                                                                                       PRBS_GEN_RESET => '0',
                                                                                                       PRBS_CHK_RESET => '0'
                                                                                                      );
  type TCDS_2_TCDS_2_LINK_TEST_STATUS_MON_t is record
    PRBS_CHK_ERROR             :std_logic;   
    PRBS_CHK_LOCKED            :std_logic;   
    PRBS_CHK_UNLOCK_COUNTER    :std_logic_vector(31 downto 0);
    PRBS_GEN_O_HINT            :std_logic_vector( 7 downto 0);
    PRBS_CHK_I_HINT            :std_logic_vector( 7 downto 0);
    PRBS_CHK_O_HINT            :std_logic_vector( 7 downto 0);
  end record TCDS_2_TCDS_2_LINK_TEST_STATUS_MON_t;


  type TCDS_2_TCDS_2_LINK_TEST_MON_t is record
    STATUS                     :TCDS_2_TCDS_2_LINK_TEST_STATUS_MON_t;
  end record TCDS_2_TCDS_2_LINK_TEST_MON_t;


  type TCDS_2_TCDS_2_LINK_TEST_CTRL_t is record
    CONTROL                    :TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t;
  end record TCDS_2_TCDS_2_LINK_TEST_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_LINK_TEST_CTRL_t : TCDS_2_TCDS_2_LINK_TEST_CTRL_t := (
                                                                                       CONTROL => DEFAULT_TCDS_2_TCDS_2_LINK_TEST_CONTROL_CTRL_t
                                                                                      );
  type TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t is record
    LO                         :std_logic_vector(31 downto 0);  -- Lower 32 bits of status.tclink_phase_offset.
    HI                         :std_logic_vector(15 downto 0);  -- Upper 16 bits of status.tclink_phase_offset.
  end record TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t := (
                                                                                                                                   LO => (others => '0'),
                                                                                                                                   HI => (others => '0')
                                                                                                                                  );
  type TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t is record
    RXLPMGCOVRDEN              :std_logic;   
    RXLPMHFOVRDEN              :std_logic;   
    RXLPMLFKLOVRDEN            :std_logic;   
    RXLPMOSOVRDEN              :std_logic;   
  end record TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t := (
                                                                                                                                   RXLPMGCOVRDEN => '0',
                                                                                                                                   RXLPMHFOVRDEN => '0',
                                                                                                                                   RXLPMLFKLOVRDEN => '0',
                                                                                                                                   RXLPMOSOVRDEN => '0'
                                                                                                                                  );
  type TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t is record
    RXOSOVRDEN                 :std_logic;   
    RXDFEAGCOVRDEN             :std_logic;   
    RXDFELFOVRDEN              :std_logic;   
    RXDFEUTOVRDEN              :std_logic;   
    RXDFEVPOVRDEN              :std_logic;   
  end record TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t := (
                                                                                                                                   RXOSOVRDEN => '0',
                                                                                                                                   RXDFEAGCOVRDEN => '0',
                                                                                                                                   RXDFELFOVRDEN => '0',
                                                                                                                                   RXDFEUTOVRDEN => '0',
                                                                                                                                   RXDFEVPOVRDEN => '0'
                                                                                                                                  );
  type TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t is record
    LPM                        :TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t;
    DFE                        :TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t;
  end record TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t := (
                                                                                                                           LPM => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_LPM_CTRL_t,
                                                                                                                           DFE => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_DFE_CTRL_t
                                                                                                                          );
  type TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(15 downto 0);
  end record TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t := (
                                                                                                                                                                 LO => (others => '0'),
                                                                                                                                                                 HI => (others => '0')
                                                                                                                                                                );
  type TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(15 downto 0);
  end record TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t := (
                                                                                                                                                             LO => (others => '0'),
                                                                                                                                                             HI => (others => '0')
                                                                                                                                                            );
  type TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(15 downto 0);
  end record TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t := (
                                                                                                                               LO => (others => '0'),
                                                                                                                               HI => (others => '0')
                                                                                                                              );
  type TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t is record
    RESET_ALL                  :std_logic;   
    MGT_RESET_ALL              :std_logic;     -- Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
    MGT_RESET_TX_PLL_AND_DATAPATH  :std_logic;     -- Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    MGT_RESET_TX_DATAPATH          :std_logic;     -- Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    MGT_RESET_RX_PLL_AND_DATAPATH  :std_logic;     -- Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    MGT_RESET_RX_DATAPATH          :std_logic;     -- Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    TCLINK_CHANNEL_CTRL_RESET      :std_logic;     -- Resets the TCLink channel controller.
    TCLINK_CHANNEL_CTRL_ENABLE     :std_logic;     -- Enables/disables the TCLink channel controller.
    TCLINK_CHANNEL_CTRL_GENTLE     :std_logic;     -- When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
    TCLINK_CLOSE_LOOP              :std_logic;     -- When high: activates the TCLink phase stabilisation.
    TCLINK_PHASE_OFFSET            :TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t;
    PHASE_CDC40_TX_CALIB           :std_logic_vector( 9 downto 0);                       
    PHASE_CDC40_TX_FORCE           :std_logic;                                           
    PHASE_CDC40_RX_CALIB           :std_logic_vector( 2 downto 0);                       
    PHASE_CDC40_RX_FORCE           :std_logic;                                           
    PHASE_PI_TX_CALIB              :std_logic_vector( 6 downto 0);                       
    PHASE_PI_TX_FORCE              :std_logic;                                           
    MGT_RX_DFE_VS_LPM              :std_logic;                                             -- Choice of MGT mode: 1: LPM, 0: DFE.
    MGT_RX_DFE_VS_LPM_RESET        :std_logic;                                             -- Reset to be strobed after changing MGT RXmode (LPM/DFE).
    MGT_RXEQ_PARAMS                :TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t;    
    FEC_MONITOR_RESET              :std_logic;                                             -- Reset of the lpGBT FEC monitoring.
    TCLINK_PARAM_METASTABILITY_DEGLITCH  :std_logic_vector(15 downto 0);                       
    TCLINK_PARAM_PHASE_DETECTOR_NAVG     :std_logic_vector(11 downto 0);                       
    TCLINK_PARAM_MODULO_CARRIER_PERIOD   :TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t;
    TCLINK_PARAM_MASTER_RX_UI_PERIOD     :TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t;  
    TCLINK_PARAM_AIE                     :std_logic_vector( 3 downto 0);                                      
    TCLINK_PARAM_AIE_ENABLE              :std_logic;                                                          
    TCLINK_PARAM_APE                     :std_logic_vector( 3 downto 0);                                      
    TCLINK_PARAM_SIGMA_DELTA_CLK_DIV     :std_logic_vector(15 downto 0);                                      
    TCLINK_PARAM_ENABLE_MIRROR           :std_logic;                                                          
    TCLINK_PARAM_ADCO                    :TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t;                 
  end record TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t : TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t := (
                                                                                           RESET_ALL => '0',
                                                                                           MGT_RESET_ALL => '0',
                                                                                           MGT_RESET_TX_PLL_AND_DATAPATH => '0',
                                                                                           MGT_RESET_TX_DATAPATH => '0',
                                                                                           MGT_RESET_RX_PLL_AND_DATAPATH => '0',
                                                                                           MGT_RESET_RX_DATAPATH => '0',
                                                                                           TCLINK_CHANNEL_CTRL_RESET => '0',
                                                                                           TCLINK_CHANNEL_CTRL_ENABLE => '0',
                                                                                           TCLINK_CHANNEL_CTRL_GENTLE => '0',
                                                                                           TCLINK_CLOSE_LOOP => '0',
                                                                                           TCLINK_PHASE_OFFSET => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PHASE_OFFSET_CTRL_t,
                                                                                           PHASE_CDC40_TX_CALIB => (others => '0'),
                                                                                           PHASE_CDC40_TX_FORCE => '0',
                                                                                           PHASE_CDC40_RX_CALIB => (others => '0'),
                                                                                           PHASE_CDC40_RX_FORCE => '0',
                                                                                           PHASE_PI_TX_CALIB => (others => '0'),
                                                                                           PHASE_PI_TX_FORCE => '0',
                                                                                           MGT_RX_DFE_VS_LPM => '0',
                                                                                           MGT_RX_DFE_VS_LPM_RESET => '0',
                                                                                           MGT_RXEQ_PARAMS => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_MGT_RXEQ_PARAMS_CTRL_t,
                                                                                           FEC_MONITOR_RESET => '0',
                                                                                           TCLINK_PARAM_METASTABILITY_DEGLITCH => (others => '0'),
                                                                                           TCLINK_PARAM_PHASE_DETECTOR_NAVG => (others => '0'),
                                                                                           TCLINK_PARAM_MODULO_CARRIER_PERIOD => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MODULO_CARRIER_PERIOD_CTRL_t,
                                                                                           TCLINK_PARAM_MASTER_RX_UI_PERIOD => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_MASTER_RX_UI_PERIOD_CTRL_t,
                                                                                           TCLINK_PARAM_AIE => (others => '0'),
                                                                                           TCLINK_PARAM_AIE_ENABLE => '0',
                                                                                           TCLINK_PARAM_APE => (others => '0'),
                                                                                           TCLINK_PARAM_SIGMA_DELTA_CLK_DIV => (others => '0'),
                                                                                           TCLINK_PARAM_ENABLE_MIRROR => '0',
                                                                                           TCLINK_PARAM_ADCO => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_TCLINK_PARAM_ADCO_CTRL_t
                                                                                          );
  type TCDS_2_TCDS_2_CSR_STATUS_TCLINK_PHASE_ERROR_MON_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(15 downto 0);
  end record TCDS_2_TCDS_2_CSR_STATUS_TCLINK_PHASE_ERROR_MON_t;


  type TCDS_2_TCDS_2_CSR_STATUS_MON_t is record
    IS_LINK_OPTICAL            :std_logic;   
    IS_LINK_SPEED_10G          :std_logic;   
    IS_LEADER                  :std_logic;   
    IS_QUAD_LEADER             :std_logic;   
    IS_MGT_RX_MODE_LPM         :std_logic;   
    MMCM_LOCKED                :std_logic;   
    MGT_POWER_GOOD             :std_logic;   
    MGT_TX_PLL_LOCKED          :std_logic;   
    MGT_RX_PLL_LOCKED          :std_logic;   
    MGT_RESET_TX_DONE          :std_logic;   
    MGT_RESET_RX_DONE          :std_logic;   
    MGT_TX_READY               :std_logic;   
    MGT_RX_READY               :std_logic;   
    CDC40_TX_READY             :std_logic;   
    CDC40_RX_READY             :std_logic;   
    RX_DATA_NOT_IDLE           :std_logic;   
    RX_FRAME_LOCKED            :std_logic;   
    TX_USER_DATA_READY         :std_logic;   
    RX_USER_DATA_READY         :std_logic;   
    TCLINK_READY               :std_logic;   
    INITIALIZER_FSM_STATE      :std_logic_vector(30 downto 0);
    INITIALIZER_FSM_RUNNING    :std_logic;                    
    RX_FRAME_UNLOCK_COUNTER    :std_logic_vector(31 downto 0);
    PHASE_CDC40_TX_MEASURED    :std_logic_vector( 9 downto 0);
    PHASE_CDC40_RX_MEASURED    :std_logic_vector( 2 downto 0);
    PHASE_PI_TX_MEASURED       :std_logic_vector( 6 downto 0);
    FEC_CORRECTION_APPLIED     :std_logic;                      -- Latched flag indicating that the link is not error-free.
    TCLINK_LOOP_CLOSED         :std_logic;                      -- High if the TCLink control loop is closed (i.e. configured as closed and not internally opened due to issues).
    TCLINK_OPERATION_ERROR     :std_logic;                      -- High if the TCLink encountered a DCO error during operation.
    TCLINK_PHASE_MEASURED      :std_logic_vector(31 downto 0);  -- Phase value measured by the TCLink. Signed two's complement number. Conversion to ps: DDMTD_UNIT / navg * value.
    TCLINK_PHASE_ERROR         :TCDS_2_TCDS_2_CSR_STATUS_TCLINK_PHASE_ERROR_MON_t;
  end record TCDS_2_TCDS_2_CSR_STATUS_MON_t;


  type TCDS_2_TCDS_2_CSR_MON_t is record
    STATUS                     :TCDS_2_TCDS_2_CSR_STATUS_MON_t;
  end record TCDS_2_TCDS_2_CSR_MON_t;


  type TCDS_2_TCDS_2_CSR_CTRL_t is record
    CONTROL                    :TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t;
  end record TCDS_2_TCDS_2_CSR_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CSR_CTRL_t : TCDS_2_TCDS_2_CSR_CTRL_t := (
                                                                           CONTROL => DEFAULT_TCDS_2_TCDS_2_CSR_CONTROL_CTRL_t
                                                                          );
  type TCDS_2_TCDS_2_SPY_FRAME_TX_MON_t is record
    WORD0                      :std_logic_vector(31 downto 0);
    WORD1                      :std_logic_vector(31 downto 0);
    WORD2                      :std_logic_vector(31 downto 0);
    WORD3                      :std_logic_vector(31 downto 0);
    WORD4                      :std_logic_vector(31 downto 0);
    WORD5                      :std_logic_vector(31 downto 0);
    WORD6                      :std_logic_vector(31 downto 0);
    WORD7                      :std_logic_vector( 9 downto 0);
  end record TCDS_2_TCDS_2_SPY_FRAME_TX_MON_t;


  type TCDS_2_TCDS_2_SPY_FRAME_RX_MON_t is record
    WORD0                      :std_logic_vector(31 downto 0);
    WORD1                      :std_logic_vector(31 downto 0);
    WORD2                      :std_logic_vector(31 downto 0);
    WORD3                      :std_logic_vector(31 downto 0);
    WORD4                      :std_logic_vector(31 downto 0);
    WORD5                      :std_logic_vector(31 downto 0);
    WORD6                      :std_logic_vector(31 downto 0);
    WORD7                      :std_logic_vector( 9 downto 0);
  end record TCDS_2_TCDS_2_SPY_FRAME_RX_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_L1A_INFO_MON_t is record
    PHYSICS                    :std_logic;   
    CALIBRATION                :std_logic;   
    RANDOM                     :std_logic;   
    SOFTWARE                   :std_logic;   
    RESERVED_4                 :std_logic;   
    RESERVED_5                 :std_logic;   
    RESERVED_6                 :std_logic;   
    RESERVED_7                 :std_logic;   
    RESERVED_8                 :std_logic;   
    RESERVED_9                 :std_logic;   
    RESERVED_10                :std_logic;   
    RESERVED_11                :std_logic;   
    RESERVED_12                :std_logic;   
    RESERVED_13                :std_logic;   
    RESERVED_14                :std_logic;   
    RESERVED_15                :std_logic;   
    PHYSICS_SUBTYPE            :std_logic_vector( 7 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_L1A_INFO_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_TIMING_AND_SYNC_INFO_MON_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(16 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_TIMING_AND_SYNC_INFO_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_MON_t is record
    L1A_INFO                   :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_L1A_INFO_MON_t;
    BRIL_TRIGGER_INFO          :std_logic_vector(15 downto 0);                 
    TIMING_AND_SYNC_INFO       :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_TIMING_AND_SYNC_INFO_MON_t;
    STATUS_INFO                :std_logic_vector( 4 downto 0);                             
    RESERVED                   :std_logic_vector(17 downto 0);                             
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_L1A_INFO_MON_t is record
    PHYSICS                    :std_logic;   
    CALIBRATION                :std_logic;   
    RANDOM                     :std_logic;   
    SOFTWARE                   :std_logic;   
    RESERVED_4                 :std_logic;   
    RESERVED_5                 :std_logic;   
    RESERVED_6                 :std_logic;   
    RESERVED_7                 :std_logic;   
    RESERVED_8                 :std_logic;   
    RESERVED_9                 :std_logic;   
    RESERVED_10                :std_logic;   
    RESERVED_11                :std_logic;   
    RESERVED_12                :std_logic;   
    RESERVED_13                :std_logic;   
    RESERVED_14                :std_logic;   
    RESERVED_15                :std_logic;   
    PHYSICS_SUBTYPE            :std_logic_vector( 7 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_L1A_INFO_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_TIMING_AND_SYNC_INFO_MON_t is record
    LO                         :std_logic_vector(31 downto 0);
    HI                         :std_logic_vector(16 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_TIMING_AND_SYNC_INFO_MON_t;


  type TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_MON_t is record
    L1A_INFO                   :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_L1A_INFO_MON_t;
    BRIL_TRIGGER_INFO          :std_logic_vector(15 downto 0);                 
    TIMING_AND_SYNC_INFO       :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_TIMING_AND_SYNC_INFO_MON_t;
    STATUS_INFO                :std_logic_vector( 4 downto 0);                             
    RESERVED                   :std_logic_vector(17 downto 0);                             
  end record TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_MON_t;


  type TCDS_2_TCDS_2_SPY_TTS2_CHANNEL0_MON_t is record
    VALUE_0                    :std_logic_vector( 7 downto 0);
    VALUE_1                    :std_logic_vector( 7 downto 0);
    VALUE_2                    :std_logic_vector( 7 downto 0);
    VALUE_3                    :std_logic_vector( 7 downto 0);
    VALUE_4                    :std_logic_vector( 7 downto 0);
    VALUE_5                    :std_logic_vector( 7 downto 0);
    VALUE_6                    :std_logic_vector( 7 downto 0);
    VALUE_7                    :std_logic_vector( 7 downto 0);
    VALUE_8                    :std_logic_vector( 7 downto 0);
    VALUE_9                    :std_logic_vector( 7 downto 0);
    VALUE_10                   :std_logic_vector( 7 downto 0);
    VALUE_11                   :std_logic_vector( 7 downto 0);
    VALUE_12                   :std_logic_vector( 7 downto 0);
    VALUE_13                   :std_logic_vector( 7 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTS2_CHANNEL0_MON_t;


  type TCDS_2_TCDS_2_SPY_TTS2_CHANNEL1_MON_t is record
    VALUE_0                    :std_logic_vector( 7 downto 0);
    VALUE_1                    :std_logic_vector( 7 downto 0);
    VALUE_2                    :std_logic_vector( 7 downto 0);
    VALUE_3                    :std_logic_vector( 7 downto 0);
    VALUE_4                    :std_logic_vector( 7 downto 0);
    VALUE_5                    :std_logic_vector( 7 downto 0);
    VALUE_6                    :std_logic_vector( 7 downto 0);
    VALUE_7                    :std_logic_vector( 7 downto 0);
    VALUE_8                    :std_logic_vector( 7 downto 0);
    VALUE_9                    :std_logic_vector( 7 downto 0);
    VALUE_10                   :std_logic_vector( 7 downto 0);
    VALUE_11                   :std_logic_vector( 7 downto 0);
    VALUE_12                   :std_logic_vector( 7 downto 0);
    VALUE_13                   :std_logic_vector( 7 downto 0);
  end record TCDS_2_TCDS_2_SPY_TTS2_CHANNEL1_MON_t;


  type TCDS_2_TCDS_2_MON_t is record
    HW_CFG                     :TCDS_2_TCDS_2_HW_CFG_MON_t;
    LINK_TEST                  :TCDS_2_TCDS_2_LINK_TEST_MON_t;
    CSR                        :TCDS_2_TCDS_2_CSR_MON_t;      
    SPY_FRAME_TX               :TCDS_2_TCDS_2_SPY_FRAME_TX_MON_t;
    SPY_FRAME_RX               :TCDS_2_TCDS_2_SPY_FRAME_RX_MON_t;
    SPY_TTC2_CHANNEL0          :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL0_MON_t;
    SPY_TTC2_CHANNEL1          :TCDS_2_TCDS_2_SPY_TTC2_CHANNEL1_MON_t;
    SPY_TTS2_CHANNEL0          :TCDS_2_TCDS_2_SPY_TTS2_CHANNEL0_MON_t;
    SPY_TTS2_CHANNEL1          :TCDS_2_TCDS_2_SPY_TTS2_CHANNEL1_MON_t;
  end record TCDS_2_TCDS_2_MON_t;


  type TCDS_2_TCDS_2_CTRL_t is record
    LINK_TEST                  :TCDS_2_TCDS_2_LINK_TEST_CTRL_t;
    CSR                        :TCDS_2_TCDS_2_CSR_CTRL_t;      
  end record TCDS_2_TCDS_2_CTRL_t;


  constant DEFAULT_TCDS_2_TCDS_2_CTRL_t : TCDS_2_TCDS_2_CTRL_t := (
                                                                   LINK_TEST => DEFAULT_TCDS_2_TCDS_2_LINK_TEST_CTRL_t,
                                                                   CSR => DEFAULT_TCDS_2_TCDS_2_CSR_CTRL_t
                                                                  );
  type TCDS_2_LTCDS_RESET_CTRL_t is record
    RESET_ALL                  :std_logic;   
    TX_PLL_AND_DATAPATH        :std_logic;   
    TX_DATAPATH                :std_logic;   
    RX_PLL_AND_DATAPATH        :std_logic;   
    RX_DATAPATH                :std_logic;   
    USERCLK_TX                 :std_logic;   
    USERCLK_RX                 :std_logic;   
    DRP                        :std_logic;   
  end record TCDS_2_LTCDS_RESET_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_RESET_CTRL_t : TCDS_2_LTCDS_RESET_CTRL_t := (
                                                                             RESET_ALL => '0',
                                                                             TX_PLL_AND_DATAPATH => '0',
                                                                             TX_DATAPATH => '0',
                                                                             RX_PLL_AND_DATAPATH => '0',
                                                                             RX_DATAPATH => '0',
                                                                             USERCLK_TX => '0',
                                                                             USERCLK_RX => '0',
                                                                             DRP => '0'
                                                                            );
  type TCDS_2_LTCDS_STATUS_MON_t is record
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
  end record TCDS_2_LTCDS_STATUS_MON_t;


  type TCDS_2_LTCDS_STATUS_CTRL_t is record
    INITIALIZE                 :std_logic;     -- C2C initialize
  end record TCDS_2_LTCDS_STATUS_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_STATUS_CTRL_t : TCDS_2_LTCDS_STATUS_CTRL_t := (
                                                                               INITIALIZE => '0'
                                                                              );
  type TCDS_2_LTCDS_DEBUG_RX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 2 downto 0);  -- DEBUG rx buf status
    PMA_RESET_DONE             :std_logic;                      -- DEBUG rx reset done
    PRBS_ERR                   :std_logic;                      -- DEBUG rx PRBS error
    RESET_DONE                 :std_logic;                      -- DEBUG rx reset done
  end record TCDS_2_LTCDS_DEBUG_RX_MON_t;


  type TCDS_2_LTCDS_DEBUG_RX_CTRL_t is record
    BUF_RESET                  :std_logic;     -- DEBUG rx buf reset
    CDR_HOLD                   :std_logic;     -- DEBUG rx CDR hold
    DFE_LPM_RESET              :std_logic;     -- DEBUG rx DFE LPM RESET
    LPM_EN                     :std_logic;     -- DEBUG rx LPM ENABLE
    PCS_RESET                  :std_logic;     -- DEBUG rx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG rx pma reset
    PRBS_CNT_RST               :std_logic;     -- DEBUG rx PRBS counter reset
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG rx PRBS select
    RATE                       :std_logic_vector( 2 downto 0);  -- DEBUG rx rate
  end record TCDS_2_LTCDS_DEBUG_RX_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_DEBUG_RX_CTRL_t : TCDS_2_LTCDS_DEBUG_RX_CTRL_t := (
                                                                                   BUF_RESET => '0',
                                                                                   CDR_HOLD => '0',
                                                                                   DFE_LPM_RESET => '0',
                                                                                   LPM_EN => '1',
                                                                                   PCS_RESET => '0',
                                                                                   PMA_RESET => '0',
                                                                                   PRBS_CNT_RST => '0',
                                                                                   PRBS_SEL => (others => '0'),
                                                                                   RATE => (others => '0')
                                                                                  );
  type TCDS_2_LTCDS_DEBUG_TX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 1 downto 0);  -- DEBUG tx buf status
    RESET_DONE                 :std_logic;                      -- DEBUG tx reset done
  end record TCDS_2_LTCDS_DEBUG_TX_MON_t;


  type TCDS_2_LTCDS_DEBUG_TX_CTRL_t is record
    INHIBIT                    :std_logic;     -- DEBUG tx inhibit
    PCS_RESET                  :std_logic;     -- DEBUG tx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG tx pma reset
    POLARITY                   :std_logic;     -- DEBUG tx polarity
    POST_CURSOR                :std_logic_vector( 4 downto 0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             :std_logic;                      -- DEBUG force PRBS error
    PRE_CURSOR                 :std_logic_vector( 4 downto 0);  -- DEBUG pre cursor
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG PRBS select
    DIFF_CTRL                  :std_logic_vector( 4 downto 0);  -- DEBUG tx diff control
  end record TCDS_2_LTCDS_DEBUG_TX_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_DEBUG_TX_CTRL_t : TCDS_2_LTCDS_DEBUG_TX_CTRL_t := (
                                                                                   INHIBIT => '0',
                                                                                   PCS_RESET => '0',
                                                                                   PMA_RESET => '0',
                                                                                   POLARITY => '0',
                                                                                   POST_CURSOR => (others => '0'),
                                                                                   PRBS_FORCE_ERR => '0',
                                                                                   PRE_CURSOR => (others => '0'),
                                                                                   PRBS_SEL => (others => '0'),
                                                                                   DIFF_CTRL => (others => '0')
                                                                                  );
  type TCDS_2_LTCDS_DEBUG_MON_t is record
    DMONITOR                   :std_logic_vector(15 downto 0);  -- DEBUG d monitor
    QPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    CPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    EYESCAN_DATA_ERROR         :std_logic;                      -- DEBUG eyescan data error
    RX                         :TCDS_2_LTCDS_DEBUG_RX_MON_t;  
    TX                         :TCDS_2_LTCDS_DEBUG_TX_MON_t;  
  end record TCDS_2_LTCDS_DEBUG_MON_t;


  type TCDS_2_LTCDS_DEBUG_CTRL_t is record
    EYESCAN_RESET              :std_logic;     -- DEBUG eyescan reset
    EYESCAN_TRIGGER            :std_logic;     -- DEBUG eyescan trigger
    PCS_RSV_DIN                :std_logic_vector(15 downto 0);  -- bit 2 is DRP uber reset
    RX                         :TCDS_2_LTCDS_DEBUG_RX_CTRL_t; 
    TX                         :TCDS_2_LTCDS_DEBUG_TX_CTRL_t; 
  end record TCDS_2_LTCDS_DEBUG_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_DEBUG_CTRL_t : TCDS_2_LTCDS_DEBUG_CTRL_t := (
                                                                             EYESCAN_RESET => '0',
                                                                             EYESCAN_TRIGGER => '0',
                                                                             PCS_RSV_DIN => (others => '0'),
                                                                             RX => DEFAULT_TCDS_2_LTCDS_DEBUG_RX_CTRL_t,
                                                                             TX => DEFAULT_TCDS_2_LTCDS_DEBUG_TX_CTRL_t
                                                                            );
  type TCDS_2_LTCDS_TX_CTRL_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
  end record TCDS_2_LTCDS_TX_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_TX_CTRL_t : TCDS_2_LTCDS_TX_CTRL_t := (
                                                                       CTRL0 => (others => '0'),
                                                                       CTRL1 => (others => '0'),
                                                                       CTRL2 => (others => '0')
                                                                      );
  type TCDS_2_LTCDS_RX_MON_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
    CTRL3                      :std_logic_vector( 7 downto 0);
  end record TCDS_2_LTCDS_RX_MON_t;


  type TCDS_2_LTCDS_DATA_CTRL_MON_t is record
    CAPTURE_D                  :std_logic_vector(31 downto 0);
    CAPTURE_K                  :std_logic_vector( 3 downto 0);
  end record TCDS_2_LTCDS_DATA_CTRL_MON_t;


  type TCDS_2_LTCDS_DATA_CTRL_CTRL_t is record
    CAPTURE                    :std_logic;   
    MODE                       :std_logic_vector( 3 downto 0);
    FIXED_SEND_D               :std_logic_vector(31 downto 0);
    FIXED_SEND_K               :std_logic_vector( 3 downto 0);
  end record TCDS_2_LTCDS_DATA_CTRL_CTRL_t;


  constant DEFAULT_TCDS_2_LTCDS_DATA_CTRL_CTRL_t : TCDS_2_LTCDS_DATA_CTRL_CTRL_t := (
                                                                                     CAPTURE => '0',
                                                                                     MODE => (others => '0'),
                                                                                     FIXED_SEND_D => (others => '0'),
                                                                                     FIXED_SEND_K => (others => '0')
                                                                                    );
  type TCDS_2_LTCDS_DRP_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(10-1 downto 0);
    wr_data   : std_logic_vector(16-1 downto 0);
  end record TCDS_2_LTCDS_DRP_MOSI_t;
  type TCDS_2_LTCDS_DRP_MISO_t is record
    rd_data         : std_logic_vector(16-1 downto 0);
    rd_data_valid   : std_logic;
  end record TCDS_2_LTCDS_DRP_MISO_t;
  constant Default_TCDS_2_LTCDS_DRP_MOSI_t : TCDS_2_LTCDS_DRP_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type TCDS_2_LTCDS_MON_t is record
    STATUS                     :TCDS_2_LTCDS_STATUS_MON_t;
    DEBUG                      :TCDS_2_LTCDS_DEBUG_MON_t; 
    RX                         :TCDS_2_LTCDS_RX_MON_t;    
    DATA_CTRL                  :TCDS_2_LTCDS_DATA_CTRL_MON_t;
    TX_CLK_FREQ                :std_logic_vector(31 downto 0);
    TX_CLK_PCS_FREQ            :std_logic_vector(31 downto 0);
    RX_CLK_PCS_FREQ            :std_logic_vector(31 downto 0);
    DRP                        :TCDS_2_LTCDS_DRP_MISO_t;      
  end record TCDS_2_LTCDS_MON_t;
  type TCDS_2_LTCDS_MON_t_ARRAY is array(1 to 2) of TCDS_2_LTCDS_MON_t;

  type TCDS_2_LTCDS_CTRL_t is record
    RESET                      :TCDS_2_LTCDS_RESET_CTRL_t;
    STATUS                     :TCDS_2_LTCDS_STATUS_CTRL_t;
    DEBUG                      :TCDS_2_LTCDS_DEBUG_CTRL_t; 
    TX                         :TCDS_2_LTCDS_TX_CTRL_t;    
    DATA_CTRL                  :TCDS_2_LTCDS_DATA_CTRL_CTRL_t;
    LOOPBACK                   :std_logic_vector( 2 downto 0);
    DRP                        :TCDS_2_LTCDS_DRP_MOSI_t;      
  end record TCDS_2_LTCDS_CTRL_t;
  type TCDS_2_LTCDS_CTRL_t_ARRAY is array(1 to 2) of TCDS_2_LTCDS_CTRL_t;

  constant DEFAULT_TCDS_2_LTCDS_CTRL_t : TCDS_2_LTCDS_CTRL_t := (
                                                                 RESET => DEFAULT_TCDS_2_LTCDS_RESET_CTRL_t,
                                                                 STATUS => DEFAULT_TCDS_2_LTCDS_STATUS_CTRL_t,
                                                                 DEBUG => DEFAULT_TCDS_2_LTCDS_DEBUG_CTRL_t,
                                                                 TX => DEFAULT_TCDS_2_LTCDS_TX_CTRL_t,
                                                                 DATA_CTRL => DEFAULT_TCDS_2_LTCDS_DATA_CTRL_CTRL_t,
                                                                 LOOPBACK => "000",
                                                                 DRP => Default_TCDS_2_LTCDS_DRP_MOSI_t
                                                                );
  type TCDS_2_MON_t is record
    TCDS_2                     :TCDS_2_TCDS_2_MON_t;
    TCDS2_FREQ                 :std_logic_vector(31 downto 0);
    TCDS2_TX_PCS_FREQ          :std_logic_vector(31 downto 0);
    TCDS2_RX_PCS_FREQ          :std_logic_vector(31 downto 0);
    LTCDS                      :TCDS_2_LTCDS_MON_t_ARRAY;     
  end record TCDS_2_MON_t;


  type TCDS_2_CTRL_t is record
    TCDS_2                     :TCDS_2_TCDS_2_CTRL_t;
    LTCDS                      :TCDS_2_LTCDS_CTRL_t_ARRAY;
  end record TCDS_2_CTRL_t;


  constant DEFAULT_TCDS_2_CTRL_t : TCDS_2_CTRL_t := (
                                                     TCDS_2 => DEFAULT_TCDS_2_TCDS_2_CTRL_t,
                                                     LTCDS => (others => DEFAULT_TCDS_2_LTCDS_CTRL_t )
                                                    );


end package TCDS_2_CTRL;