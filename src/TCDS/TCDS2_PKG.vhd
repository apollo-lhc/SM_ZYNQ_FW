--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS2_CTRL is
  type TCDS2_TCDS2_csr_control_CTRL_t is record
    mgt_reset_all              :std_logic;   
    mgt_reset_tx               :std_logic;   
    mgt_reset_rx               :std_logic;   
    link_test_mode             :std_logic;   
    prbs_gen_reset             :std_logic;   
    prbs_chk_reset             :std_logic;   
  end record TCDS2_TCDS2_csr_control_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_csr_control_CTRL_t : TCDS2_TCDS2_csr_control_CTRL_t := (
                                                                                       link_test_mode => '0',
                                                                                       prbs_chk_reset => '0',
                                                                                       prbs_gen_reset => '0',
                                                                                       mgt_reset_all => '0',
                                                                                       mgt_reset_tx => '0',
                                                                                       mgt_reset_rx => '0'
                                                                                      );
  type TCDS2_TCDS2_csr_status_MON_t is record
    has_spy_registers          :std_logic;   
    is_link_speed_10g          :std_logic;   
    has_link_test_mode         :std_logic;   
    mgt_power_good             :std_logic;   
    mgt_tx_pll_lock            :std_logic;   
    mgt_rx_pll_lock            :std_logic;   
    mgt_reset_tx_done          :std_logic;   
    mgt_reset_rx_done          :std_logic;   
    mgt_tx_ready               :std_logic;   
    mgt_rx_ready               :std_logic;   
    rx_frame_locked            :std_logic;   
    rx_frame_unlock_counter    :std_logic_vector(31 downto 0);
    prbs_chk_error             :std_logic;                    
    prbs_chk_locked            :std_logic;                    
    prbs_chk_unlock_counter    :std_logic_vector(31 downto 0);
    prbs_gen_o_hint            :std_logic_vector( 7 downto 0);
    prbs_chk_i_hint            :std_logic_vector( 7 downto 0);
    prbs_chk_o_hint            :std_logic_vector( 7 downto 0);
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
    csr                        :TCDS2_TCDS2_csr_MON_t;
    spy_frame_tx               :TCDS2_TCDS2_spy_frame_tx_MON_t;
    spy_frame_rx               :TCDS2_TCDS2_spy_frame_rx_MON_t;
    spy_ttc2_channel0          :TCDS2_TCDS2_spy_ttc2_channel0_MON_t;
    spy_ttc2_channel1          :TCDS2_TCDS2_spy_ttc2_channel1_MON_t;
    spy_tts2_channel0          :TCDS2_TCDS2_spy_tts2_channel0_MON_t;
    spy_tts2_channel1          :TCDS2_TCDS2_spy_tts2_channel1_MON_t;
  end record TCDS2_TCDS2_MON_t;


  type TCDS2_TCDS2_CTRL_t is record
    csr                        :TCDS2_TCDS2_csr_CTRL_t;
  end record TCDS2_TCDS2_CTRL_t;


  constant DEFAULT_TCDS2_TCDS2_CTRL_t : TCDS2_TCDS2_CTRL_t := (
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