--This file was auto-generated.
--Modifications might be lost.
-- Created : 2021-04-28 10:02:54.224081.
library IEEE;
use IEEE.std_logic_1164.all;



package LDAQ_CTRL is
  type LDAQ_RESET_CTRL_t is record
    RESET_ALL                  :std_logic;   
    TX_PLL_AND_DATAPATH        :std_logic;   
    TX_DATAPATH                :std_logic;   
    RX_PLL_AND_DATAPATH        :std_logic;   
    RX_DATAPATH                :std_logic;   
    USERCLK_TX                 :std_logic;   
    USERCLK_RX                 :std_logic;   
  end record LDAQ_RESET_CTRL_t;


  constant DEFAULT_LDAQ_RESET_CTRL_t : LDAQ_RESET_CTRL_t := (
                                                             USERCLK_TX => '0',
                                                             RX_PLL_AND_DATAPATH => '0',
                                                             RX_DATAPATH => '0',
                                                             TX_PLL_AND_DATAPATH => '0',
                                                             USERCLK_RX => '0',
                                                             RESET_ALL => '0',
                                                             TX_DATAPATH => '0'
                                                            );
  type LDAQ_STATUS_MON_t is record
    RESET_RX_CDR_STABLE        :std_logic;   
    RESET_TX_DONE              :std_logic;   
    RESET_RX_DONE              :std_logic;   
    USERCLK_TX_ACTIVE          :std_logic;   
    USERCLK_RX_ACTIVE          :std_logic;   
    GT_POWER_GOOD              :std_logic;   
    RX_BYTE_ISALIGNED          :std_logic;   
    RX_BYTE_REALIGN            :std_logic;   
    RX_COMMADET                :std_logic;   
    RX_PMA_RESET_DONE          :std_logic;   
    TX_PMA_RESET_DONE          :std_logic;   
  end record LDAQ_STATUS_MON_t;


  type LDAQ_TX_CTRL_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
  end record LDAQ_TX_CTRL_t;


  constant DEFAULT_LDAQ_TX_CTRL_t : LDAQ_TX_CTRL_t := (
                                                       CTRL0 => (others => '0'),
                                                       CTRL1 => (others => '0'),
                                                       CTRL2 => (others => '0')
                                                      );
  type LDAQ_RX_MON_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
    CTRL3                      :std_logic_vector( 7 downto 0);
  end record LDAQ_RX_MON_t;


  type LDAQ_MON_t is record
    STATUS                     :LDAQ_STATUS_MON_t;
    RX                         :LDAQ_RX_MON_t;    
  end record LDAQ_MON_t;


  type LDAQ_CTRL_t is record
    RESET                      :LDAQ_RESET_CTRL_t;
    TX                         :LDAQ_TX_CTRL_t;   
  end record LDAQ_CTRL_t;


  constant DEFAULT_LDAQ_CTRL_t : LDAQ_CTRL_t := (
                                                 RESET => DEFAULT_LDAQ_RESET_CTRL_t,
                                                 TX => DEFAULT_LDAQ_TX_CTRL_t
                                                );


end package LDAQ_CTRL;