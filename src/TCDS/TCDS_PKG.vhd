--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS_CTRL is
  type TCDS_LINK_CLOCKING_MON_t is record
    FB_CLK_LOST                :std_logic;   
    CLK_LOCKED                 :std_logic;   
  end record TCDS_LINK_CLOCKING_MON_t;


  type TCDS_LINK_CLOCKING_CTRL_t is record
    RESET                      :std_logic;   
  end record TCDS_LINK_CLOCKING_CTRL_t;


  constant DEFAULT_TCDS_LINK_CLOCKING_CTRL_t : TCDS_LINK_CLOCKING_CTRL_t := (
                                                                             RESET => '0'
                                                                            );
  type TCDS_LINK_RX_MON_t is record
    PRBS_ERROR                 :std_logic;   
    RESET_DONE                 :std_logic;   
    BAD_CHAR                   :std_logic_vector( 3 downto 0);
    DISP_ERROR                 :std_logic_vector( 3 downto 0);
    MONITOR                    :std_logic_vector( 6 downto 0);
  end record TCDS_LINK_RX_MON_t;


  type TCDS_LINK_RX_CTRL_t is record
    PRBS_SEL                   :std_logic_vector( 2 downto 0);
    PRBS_RESET                 :std_logic;                    
    USER_READY                 :std_logic;                    
    DFELPM_RESET               :std_logic;                    
    MONITOR_SEL                :std_logic_vector( 1 downto 0);
    RESET                      :std_logic;                    
    PMA_RESET                  :std_logic;                    
  end record TCDS_LINK_RX_CTRL_t;


  constant DEFAULT_TCDS_LINK_RX_CTRL_t : TCDS_LINK_RX_CTRL_t := (
                                                                 RESET => '0',
                                                                 MONITOR_SEL => (others => '0'),
                                                                 USER_READY => '0',
                                                                 PRBS_SEL => (others => '0'),
                                                                 DFELPM_RESET => '0',
                                                                 PRBS_RESET => '0',
                                                                 PMA_RESET => '0'
                                                                );
  type TCDS_LINK_TX_MON_t is record
    RESET_DONE                 :std_logic;   
  end record TCDS_LINK_TX_MON_t;


  type TCDS_LINK_TX_CTRL_t is record
    PRBS_SEL                   :std_logic_vector( 2 downto 0);
    PRBS_FORCE_ERROR           :std_logic;                    
    INHIBIT                    :std_logic;                    
    USER_READY                 :std_logic;                    
    RESET                      :std_logic;                    
  end record TCDS_LINK_TX_CTRL_t;


  constant DEFAULT_TCDS_LINK_TX_CTRL_t : TCDS_LINK_TX_CTRL_t := (
                                                                 PRBS_FORCE_ERROR => '0',
                                                                 RESET => '0',
                                                                 PRBS_SEL => (others => '0'),
                                                                 USER_READY => '0',
                                                                 INHIBIT => '0'
                                                                );
  type TCDS_LINK_EYESCAN_MON_t is record
    DATA_ERROR                 :std_logic;   
  end record TCDS_LINK_EYESCAN_MON_t;


  type TCDS_LINK_EYESCAN_CTRL_t is record
    RESET                      :std_logic;   
    TRIGGER                    :std_logic;   
  end record TCDS_LINK_EYESCAN_CTRL_t;


  constant DEFAULT_TCDS_LINK_EYESCAN_CTRL_t : TCDS_LINK_EYESCAN_CTRL_t := (
                                                                           RESET => '0',
                                                                           TRIGGER => '0'
                                                                          );
  type TCDS_LINK_MON_t is record
    CLOCKING                   :TCDS_LINK_CLOCKING_MON_t;
    DMONITOR                   :std_logic_vector( 7 downto 0);
    RX                         :TCDS_LINK_RX_MON_t;           
    TX                         :TCDS_LINK_TX_MON_t;           
    EYESCAN                    :TCDS_LINK_EYESCAN_MON_t;      
  end record TCDS_LINK_MON_t;
  type TCDS_LINK_MON_t_ARRAY is array(0 to 2) of TCDS_LINK_MON_t;

  type TCDS_LINK_CTRL_t is record
    CLOCKING                   :TCDS_LINK_CLOCKING_CTRL_t;
    LOOPBACK                   :std_logic_vector( 2 downto 0);
    RX                         :TCDS_LINK_RX_CTRL_t;          
    TX                         :TCDS_LINK_TX_CTRL_t;          
    EYESCAN                    :TCDS_LINK_EYESCAN_CTRL_t;     
  end record TCDS_LINK_CTRL_t;
  type TCDS_LINK_CTRL_t_ARRAY is array(0 to 2) of TCDS_LINK_CTRL_t;

  constant DEFAULT_TCDS_LINK_CTRL_t : TCDS_LINK_CTRL_t := (
                                                           EYESCAN => DEFAULT_TCDS_LINK_EYESCAN_CTRL_t,
                                                           RX => DEFAULT_TCDS_LINK_RX_CTRL_t,
                                                           TX => DEFAULT_TCDS_LINK_TX_CTRL_t,
                                                           CLOCKING => DEFAULT_TCDS_LINK_CLOCKING_CTRL_t,
                                                           LOOPBACK => (others => '0')
                                                          );
  type TCDS_CTRL_MON_t is record
    CAPTURE_D                  :std_logic_vector(31 downto 0);
    CAPTURE_K                  :std_logic_vector( 3 downto 0);
  end record TCDS_CTRL_MON_t;
  type TCDS_CTRL_MON_t_ARRAY is array(0 to 2) of TCDS_CTRL_MON_t;

  type TCDS_CTRL_CTRL_t is record
    CAPTURE                    :std_logic;   
    MODE                       :std_logic_vector( 3 downto 0);
    FIXED_SEND_D               :std_logic_vector(31 downto 0);
    FIXED_SEND_K               :std_logic_vector( 3 downto 0);
  end record TCDS_CTRL_CTRL_t;
  type TCDS_CTRL_CTRL_t_ARRAY is array(0 to 2) of TCDS_CTRL_CTRL_t;

  constant DEFAULT_TCDS_CTRL_CTRL_t : TCDS_CTRL_CTRL_t := (
                                                           CAPTURE => '0',
                                                           FIXED_SEND_D => (others => '0'),
                                                           MODE => (others => '0'),
                                                           FIXED_SEND_K => (others => '0')
                                                          );
  type TCDS_MON_t is record
    LINK                       :TCDS_LINK_MON_t_ARRAY;
    CTRL                       :TCDS_CTRL_MON_t_ARRAY;
  end record TCDS_MON_t;


  type TCDS_CTRL_t is record
    LINK                       :TCDS_LINK_CTRL_t_ARRAY;
    CTRL                       :TCDS_CTRL_CTRL_t_ARRAY;
  end record TCDS_CTRL_t;


  constant DEFAULT_TCDS_CTRL_t : TCDS_CTRL_t := (
                                                 LINK => (others => DEFAULT_TCDS_LINK_CTRL_t ),
                                                 CTRL => (others => DEFAULT_TCDS_CTRL_CTRL_t )
                                                );


end package TCDS_CTRL;