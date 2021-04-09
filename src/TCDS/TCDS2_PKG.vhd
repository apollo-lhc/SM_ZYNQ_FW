--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS2_CTRL is
  type TCDS2_TCDS2_hw_cfg_MON_t is record
    has_spy_registers          :std_logic;   
    has_link_test_mode         :std_logic;   
  end record TCDS2_TCDS2_hw_cfg_MON_t;


  type TCDS2_TCDS2_link_test_control_CTRL_t is record
    link_test_mode             :std_logic;   
    prbs_gen_reset             :std_logic;   
    prbs_chk_reset             :std_logic;   
  end record TCDS2_TCDS2_link_test_control_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_link_test_control_CTRL_t : TCDS2_TCDS2_link_test_control_CTRL_t := (
                                                                                                   link_test_mode => '0',
                                                                                                   prbs_gen_reset => '0',
                                                                                                   prbs_chk_reset => '0'
                                                                                                  );
  type TCDS2_TCDS2_link_test_status_MON_t is record
    prbs_chk_error             :std_logic;   
    prbs_chk_locked            :std_logic;   
    prbs_chk_unlock_counter    :std_logic_vector(31 downto 0);
    prbs_gen_o_hint            :std_logic_vector( 7 downto 0);
    prbs_chk_i_hint            :std_logic_vector( 7 downto 0);
    prbs_chk_o_hint            :std_logic_vector( 7 downto 0);
  end record TCDS2_TCDS2_link_test_status_MON_t;


  type TCDS2_TCDS2_link_test_MON_t is record
    status                     :TCDS2_TCDS2_link_test_status_MON_t;
  end record TCDS2_TCDS2_link_test_MON_t;


  type TCDS2_TCDS2_link_test_CTRL_t is record
    control                    :TCDS2_TCDS2_link_test_control_CTRL_t;
  end record TCDS2_TCDS2_link_test_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_link_test_CTRL_t : TCDS2_TCDS2_link_test_CTRL_t := (
                                                                                   control => DEFAULT_TCDS2_TCDS2_link_test_control_CTRL_t
                                                                                  );
  type TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t is record
    lo                         :std_logic_vector(31 downto 0);  -- Lower 32 bits of status.tclink_phase_offset.
    hi                         :std_logic_vector(15 downto 0);  -- Upper 16 bits of status.tclink_phase_offset.
  end record TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t : TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t := (
                                                                                                                               lo => (others => '0'),
                                                                                                                               hi => (others => '0')
                                                                                                                              );
  type TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t is record
    rxlpmgcovrden              :std_logic;   
    rxlpmhfovrden              :std_logic;   
    rxlpmlfklovrden            :std_logic;   
    rxlpmosovrden              :std_logic;   
  end record TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t : TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t := (
                                                                                                                               rxlpmhfovrden => '0',
                                                                                                                               rxlpmosovrden => '0',
                                                                                                                               rxlpmlfklovrden => '0',
                                                                                                                               rxlpmgcovrden => '0'
                                                                                                                              );
  type TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t is record
    rxosovrden                 :std_logic;   
    rxdfeagcovrden             :std_logic;   
    rxdfelfovrden              :std_logic;   
    rxdfeutovrden              :std_logic;   
    rxdfevpovrden              :std_logic;   
  end record TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t : TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t := (
                                                                                                                               rxdfelfovrden => '0',
                                                                                                                               rxdfevpovrden => '0',
                                                                                                                               rxdfeutovrden => '0',
                                                                                                                               rxdfeagcovrden => '0',
                                                                                                                               rxosovrden => '0'
                                                                                                                              );
  type TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t is record
    lpm                        :TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t;
    dfe                        :TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t;
  end record TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t : TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t := (
                                                                                                                       dfe => DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_dfe_CTRL_t,
                                                                                                                       lpm => DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_lpm_CTRL_t
                                                                                                                      );
  type TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(15 downto 0);
  end record TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t : TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t := (
                                                                                                                                                             lo => (others => '0'),
                                                                                                                                                             hi => (others => '0')
                                                                                                                                                            );
  type TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(15 downto 0);
  end record TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t : TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t := (
                                                                                                                                                         lo => (others => '0'),
                                                                                                                                                         hi => (others => '0')
                                                                                                                                                        );
  type TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(15 downto 0);
  end record TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t : TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t := (
                                                                                                                           lo => (others => '0'),
                                                                                                                           hi => (others => '0')
                                                                                                                          );
  type TCDS2_TCDS2_csr_control_CTRL_t is record
    reset_all                  :std_logic;   
    mgt_reset_all              :std_logic;     -- Direct full (i.e., both TX and RX) reset of the MGT. Only enabled when the TCLink channel controller is disabled (i.e., control.tclink_channel_ctrl_enable is low).
    mgt_reset_tx_pll_and_datapath  :std_logic;     -- Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    mgt_reset_tx_datapath          :std_logic;     -- Direct TX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    mgt_reset_rx_pll_and_datapath  :std_logic;     -- Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    mgt_reset_rx_datapath          :std_logic;     -- Direct RX reset of the MGT. Only enabled when the TCLink channel controller is disabled.
    tclink_channel_ctrl_reset      :std_logic;     -- Resets the TCLink channel controller.
    tclink_channel_ctrl_enable     :std_logic;     -- Enables/disables the TCLink channel controller.
    tclink_channel_ctrl_gentle     :std_logic;     -- When high: tells the TCLink channel controller to use the 'gentle' instead of the 'full' reset procedure. The 'gentle' procedure does not reset the MGT QUAD PLLs, whereas the 'full' procedure does.
    tclink_close_loop              :std_logic;     -- When high: activates the TCLink phase stabilisation.
    tclink_phase_offset            :TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t;
    phase_cdc40_tx_calib           :std_logic_vector( 9 downto 0);                     
    phase_cdc40_tx_force           :std_logic;                                         
    phase_cdc40_rx_calib           :std_logic_vector( 2 downto 0);                     
    phase_cdc40_rx_force           :std_logic;                                         
    phase_pi_tx_calib              :std_logic_vector( 6 downto 0);                     
    phase_pi_tx_force              :std_logic;                                         
    mgt_rx_dfe_vs_lpm              :std_logic;                                           -- Choice of MGT mode: 1: LPM, 0: DFE.
    mgt_rx_dfe_vs_lpm_reset        :std_logic;                                           -- Reset to be strobed after changing MGT RXmode (LPM/DFE).
    mgt_rxeq_params                :TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t;    
    fec_monitor_reset              :std_logic;                                           -- Reset of the lpGBT FEC monitoring.
    tclink_param_metastability_deglitch  :std_logic_vector(15 downto 0);                     
    tclink_param_phase_detector_navg     :std_logic_vector(11 downto 0);                     
    tclink_param_modulo_carrier_period   :TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t;
    tclink_param_master_rx_ui_period     :TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t;  
    tclink_param_aie                     :std_logic_vector( 3 downto 0);                                    
    tclink_param_aie_enable              :std_logic;                                                        
    tclink_param_ape                     :std_logic_vector( 3 downto 0);                                    
    tclink_param_sigma_delta_clk_div     :std_logic_vector(15 downto 0);                                    
    tclink_param_enable_mirror           :std_logic;                                                        
    tclink_param_adco                    :TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t;                 
  end record TCDS2_TCDS2_csr_control_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_CTRL_t : TCDS2_TCDS2_csr_control_CTRL_t := (
                                                                                       tclink_param_modulo_carrier_period => DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_modulo_carrier_period_CTRL_t,
                                                                                       phase_cdc40_tx_calib => (others => '0'),
                                                                                       phase_cdc40_rx_force => '0',
                                                                                       phase_pi_tx_calib => (others => '0'),
                                                                                       fec_monitor_reset => '0',
                                                                                       phase_pi_tx_force => '0',
                                                                                       tclink_param_ape => (others => '0'),
                                                                                       tclink_close_loop => '0',
                                                                                       tclink_param_adco => DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_adco_CTRL_t,
                                                                                       mgt_rxeq_params => DEFAULT_TCDS2_TCDS2_csr_control_mgt_rxeq_params_CTRL_t,
                                                                                       mgt_rx_dfe_vs_lpm => '0',
                                                                                       tclink_param_master_rx_ui_period => DEFAULT_TCDS2_TCDS2_csr_control_tclink_param_master_rx_ui_period_CTRL_t,
                                                                                       tclink_param_phase_detector_navg => (others => '0'),
                                                                                       tclink_param_metastability_deglitch => (others => '0'),
                                                                                       mgt_reset_rx_datapath => '0',
                                                                                       mgt_reset_tx_pll_and_datapath => '0',
                                                                                       tclink_param_aie_enable => '0',
                                                                                       phase_cdc40_tx_force => '0',
                                                                                       tclink_phase_offset => DEFAULT_TCDS2_TCDS2_csr_control_tclink_phase_offset_CTRL_t,
                                                                                       reset_all => '0',
                                                                                       tclink_channel_ctrl_reset => '0',
                                                                                       mgt_rx_dfe_vs_lpm_reset => '0',
                                                                                       tclink_param_sigma_delta_clk_div => (others => '0'),
                                                                                       tclink_channel_ctrl_gentle => '0',
                                                                                       tclink_param_enable_mirror => '0',
                                                                                       mgt_reset_tx_datapath => '0',
                                                                                       mgt_reset_all => '0',
                                                                                       phase_cdc40_rx_calib => (others => '0'),
                                                                                       tclink_channel_ctrl_enable => '0',
                                                                                       mgt_reset_rx_pll_and_datapath => '0',
                                                                                       tclink_param_aie => (others => '0')
                                                                                      );
  type TCDS2_TCDS2_csr_status_tclink_phase_error_MON_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(15 downto 0);
  end record TCDS2_TCDS2_csr_status_tclink_phase_error_MON_t;


  type TCDS2_TCDS2_csr_status_MON_t is record
    is_link_optical            :std_logic;   
    is_link_speed_10g          :std_logic;   
    is_leader                  :std_logic;   
    is_quad_leader             :std_logic;   
    is_mgt_rx_mode_lpm         :std_logic;   
    mmcm_locked                :std_logic;   
    mgt_power_good             :std_logic;   
    mgt_tx_pll_locked          :std_logic;   
    mgt_rx_pll_locked          :std_logic;   
    mgt_reset_tx_done          :std_logic;   
    mgt_reset_rx_done          :std_logic;   
    mgt_tx_ready               :std_logic;   
    mgt_rx_ready               :std_logic;   
    cdc40_tx_ready             :std_logic;   
    cdc40_rx_ready             :std_logic;   
    rx_data_not_idle           :std_logic;   
    rx_frame_locked            :std_logic;   
    tx_user_data_ready         :std_logic;   
    rx_user_data_ready         :std_logic;   
    tclink_ready               :std_logic;   
    initializer_fsm_state      :std_logic_vector(30 downto 0);
    initializer_fsm_running    :std_logic;                    
    rx_frame_unlock_counter    :std_logic_vector(31 downto 0);
    phase_cdc40_tx_measured    :std_logic_vector( 9 downto 0);
    phase_cdc40_rx_measured    :std_logic_vector( 2 downto 0);
    phase_pi_tx_measured       :std_logic_vector( 6 downto 0);
    fec_correction_applied     :std_logic;                      -- Latched flag indicating that the link is not error-free.
    tclink_loop_closed         :std_logic;                      -- High if the TCLink control loop is closed (i.e. configured as closed and not internally opened due to issues).
    tclink_operation_error     :std_logic;                      -- High if the TCLink encountered a DCO error during operation.
    tclink_phase_measured      :std_logic_vector(31 downto 0);  -- Phase value measured by the TCLink. Signed two's complement number. Conversion to ps: DDMTD_UNIT / navg * value.
    tclink_phase_error         :TCDS2_TCDS2_csr_status_tclink_phase_error_MON_t;
  end record TCDS2_TCDS2_csr_status_MON_t;


  type TCDS2_TCDS2_csr_MON_t is record
    status                     :TCDS2_TCDS2_csr_status_MON_t;
  end record TCDS2_TCDS2_csr_MON_t;


  type TCDS2_TCDS2_csr_CTRL_t is record
    control                    :TCDS2_TCDS2_csr_control_CTRL_t;
  end record TCDS2_TCDS2_csr_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_CTRL_t : TCDS2_TCDS2_csr_CTRL_t := (
                                                                       control => DEFAULT_TCDS2_TCDS2_csr_control_CTRL_t
                                                                      );
  type TCDS2_TCDS2_spy_frame_tx_MON_t is record
    word0                      :std_logic_vector(31 downto 0);
    word1                      :std_logic_vector(31 downto 0);
    word2                      :std_logic_vector(31 downto 0);
    word3                      :std_logic_vector(31 downto 0);
    word4                      :std_logic_vector(31 downto 0);
    word5                      :std_logic_vector(31 downto 0);
    word6                      :std_logic_vector(31 downto 0);
    word7                      :std_logic_vector( 9 downto 0);
  end record TCDS2_TCDS2_spy_frame_tx_MON_t;


  type TCDS2_TCDS2_spy_frame_rx_MON_t is record
    word0                      :std_logic_vector(31 downto 0);
    word1                      :std_logic_vector(31 downto 0);
    word2                      :std_logic_vector(31 downto 0);
    word3                      :std_logic_vector(31 downto 0);
    word4                      :std_logic_vector(31 downto 0);
    word5                      :std_logic_vector(31 downto 0);
    word6                      :std_logic_vector(31 downto 0);
    word7                      :std_logic_vector( 9 downto 0);
  end record TCDS2_TCDS2_spy_frame_rx_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel0_l1a_info_MON_t is record
    physics                    :std_logic;   
    calibration                :std_logic;   
    random                     :std_logic;   
    software                   :std_logic;   
    reserved_4                 :std_logic;   
    reserved_5                 :std_logic;   
    reserved_6                 :std_logic;   
    reserved_7                 :std_logic;   
    reserved_8                 :std_logic;   
    reserved_9                 :std_logic;   
    reserved_10                :std_logic;   
    reserved_11                :std_logic;   
    reserved_12                :std_logic;   
    reserved_13                :std_logic;   
    reserved_14                :std_logic;   
    reserved_15                :std_logic;   
    physics_subtype            :std_logic_vector( 7 downto 0);
  end record TCDS2_TCDS2_spy_ttc2_channel0_l1a_info_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel0_timing_and_sync_info_MON_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(16 downto 0);
  end record TCDS2_TCDS2_spy_ttc2_channel0_timing_and_sync_info_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel0_MON_t is record
    l1a_info                   :TCDS2_TCDS2_spy_ttc2_channel0_l1a_info_MON_t;
    bril_trigger_info          :std_logic_vector(15 downto 0);               
    timing_and_sync_info       :TCDS2_TCDS2_spy_ttc2_channel0_timing_and_sync_info_MON_t;
    status_info                :std_logic_vector( 4 downto 0);                           
    reserved                   :std_logic_vector(17 downto 0);                           
  end record TCDS2_TCDS2_spy_ttc2_channel0_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel1_l1a_info_MON_t is record
    physics                    :std_logic;   
    calibration                :std_logic;   
    random                     :std_logic;   
    software                   :std_logic;   
    reserved_4                 :std_logic;   
    reserved_5                 :std_logic;   
    reserved_6                 :std_logic;   
    reserved_7                 :std_logic;   
    reserved_8                 :std_logic;   
    reserved_9                 :std_logic;   
    reserved_10                :std_logic;   
    reserved_11                :std_logic;   
    reserved_12                :std_logic;   
    reserved_13                :std_logic;   
    reserved_14                :std_logic;   
    reserved_15                :std_logic;   
    physics_subtype            :std_logic_vector( 7 downto 0);
  end record TCDS2_TCDS2_spy_ttc2_channel1_l1a_info_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel1_timing_and_sync_info_MON_t is record
    lo                         :std_logic_vector(31 downto 0);
    hi                         :std_logic_vector(16 downto 0);
  end record TCDS2_TCDS2_spy_ttc2_channel1_timing_and_sync_info_MON_t;


  type TCDS2_TCDS2_spy_ttc2_channel1_MON_t is record
    l1a_info                   :TCDS2_TCDS2_spy_ttc2_channel1_l1a_info_MON_t;
    bril_trigger_info          :std_logic_vector(15 downto 0);               
    timing_and_sync_info       :TCDS2_TCDS2_spy_ttc2_channel1_timing_and_sync_info_MON_t;
    status_info                :std_logic_vector( 4 downto 0);                           
    reserved                   :std_logic_vector(17 downto 0);                           
  end record TCDS2_TCDS2_spy_ttc2_channel1_MON_t;


  type TCDS2_TCDS2_spy_tts2_channel0_MON_t is record
    value_0                    :std_logic_vector( 7 downto 0);
    value_1                    :std_logic_vector( 7 downto 0);
    value_2                    :std_logic_vector( 7 downto 0);
    value_3                    :std_logic_vector( 7 downto 0);
    value_4                    :std_logic_vector( 7 downto 0);
    value_5                    :std_logic_vector( 7 downto 0);
    value_6                    :std_logic_vector( 7 downto 0);
    value_7                    :std_logic_vector( 7 downto 0);
    value_8                    :std_logic_vector( 7 downto 0);
    value_9                    :std_logic_vector( 7 downto 0);
    value_10                   :std_logic_vector( 7 downto 0);
    value_11                   :std_logic_vector( 7 downto 0);
    value_12                   :std_logic_vector( 7 downto 0);
    value_13                   :std_logic_vector( 7 downto 0);
  end record TCDS2_TCDS2_spy_tts2_channel0_MON_t;


  type TCDS2_TCDS2_spy_tts2_channel1_MON_t is record
    value_0                    :std_logic_vector( 7 downto 0);
    value_1                    :std_logic_vector( 7 downto 0);
    value_2                    :std_logic_vector( 7 downto 0);
    value_3                    :std_logic_vector( 7 downto 0);
    value_4                    :std_logic_vector( 7 downto 0);
    value_5                    :std_logic_vector( 7 downto 0);
    value_6                    :std_logic_vector( 7 downto 0);
    value_7                    :std_logic_vector( 7 downto 0);
    value_8                    :std_logic_vector( 7 downto 0);
    value_9                    :std_logic_vector( 7 downto 0);
    value_10                   :std_logic_vector( 7 downto 0);
    value_11                   :std_logic_vector( 7 downto 0);
    value_12                   :std_logic_vector( 7 downto 0);
    value_13                   :std_logic_vector( 7 downto 0);
  end record TCDS2_TCDS2_spy_tts2_channel1_MON_t;


  type TCDS2_TCDS2_MON_t is record
    hw_cfg                     :TCDS2_TCDS2_hw_cfg_MON_t;
    link_test                  :TCDS2_TCDS2_link_test_MON_t;
    csr                        :TCDS2_TCDS2_csr_MON_t;      
    spy_frame_tx               :TCDS2_TCDS2_spy_frame_tx_MON_t;
    spy_frame_rx               :TCDS2_TCDS2_spy_frame_rx_MON_t;
    spy_ttc2_channel0          :TCDS2_TCDS2_spy_ttc2_channel0_MON_t;
    spy_ttc2_channel1          :TCDS2_TCDS2_spy_ttc2_channel1_MON_t;
    spy_tts2_channel0          :TCDS2_TCDS2_spy_tts2_channel0_MON_t;
    spy_tts2_channel1          :TCDS2_TCDS2_spy_tts2_channel1_MON_t;
  end record TCDS2_TCDS2_MON_t;


  type TCDS2_TCDS2_CTRL_t is record
    link_test                  :TCDS2_TCDS2_link_test_CTRL_t;
    csr                        :TCDS2_TCDS2_csr_CTRL_t;      
  end record TCDS2_TCDS2_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_CTRL_t : TCDS2_TCDS2_CTRL_t := (
                                                               link_test => DEFAULT_TCDS2_TCDS2_link_test_CTRL_t,
                                                               csr => DEFAULT_TCDS2_TCDS2_csr_CTRL_t
                                                              );
  type TCDS2_MON_t is record
    TCDS2                      :TCDS2_TCDS2_MON_t;
  end record TCDS2_MON_t;


  type TCDS2_CTRL_t is record
    TCDS2                      :TCDS2_TCDS2_CTRL_t;
  end record TCDS2_CTRL_t;


  constant DEFAULT_TCDS2_CTRL_t : TCDS2_CTRL_t := (
                                                   TCDS2 => DEFAULT_TCDS2_TCDS2_CTRL_t
                                                  );


end package TCDS2_CTRL;