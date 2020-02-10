--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS_CTRL is
  type TCDS_LINK0_CLOCKING_MON_t is record
    CLK_LOCKED                 : std_logic;   
    FB_CLK_LOST                : std_logic;   
  end record TCDS_LINK0_CLOCKING_MON_t;

  type TCDS_LINK0_CLOCKING_CTRL_t is record
    RESET                      : std_logic;   
  end record TCDS_LINK0_CLOCKING_CTRL_t;

  constant DEFAULT_TCDS_LINK0_CLOCKING_CTRL_t : TCDS_LINK0_CLOCKING_CTRL_t := (
                                                                               RESET => (others => '0')
                                                                              );
  type TCDS_LINK0_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    MONITOR                    : std_logic_vector( 6 downto  0);
    PRBS_ERROR                 : std_logic;                     
    RESET_DONE                 : std_logic;                     
  end record TCDS_LINK0_RX_MON_t;

  type TCDS_LINK0_RX_CTRL_t is record
    DFELPM_RESET               : std_logic;                     
    MONITOR_SEL                : std_logic_vector( 1 downto  0);
    PMA_RESET                  : std_logic;                     
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK0_RX_CTRL_t;

  constant DEFAULT_TCDS_LINK0_RX_CTRL_t : TCDS_LINK0_RX_CTRL_t := (
                                                                   MONITOR_SEL => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PMA_RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   DFELPM_RESET => (others => '0'),
                                                                   PRBS_RESET => (others => '0'),
                                                                   USER_READY => (others => '0')
                                                                  );
  type TCDS_LINK0_TX_MON_t is record
    RESET_DONE                 : std_logic;   
  end record TCDS_LINK0_TX_MON_t;

  type TCDS_LINK0_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK0_TX_CTRL_t;

  constant DEFAULT_TCDS_LINK0_TX_CTRL_t : TCDS_LINK0_TX_CTRL_t := (
                                                                   PRBS_FORCE_ERROR => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   USER_READY => (others => '0'),
                                                                   INHIBIT => (others => '0')
                                                                  );
  type TCDS_LINK0_EYESCAN_MON_t is record
    DATA_ERROR                 : std_logic;   
  end record TCDS_LINK0_EYESCAN_MON_t;

  type TCDS_LINK0_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record TCDS_LINK0_EYESCAN_CTRL_t;

  constant DEFAULT_TCDS_LINK0_EYESCAN_CTRL_t : TCDS_LINK0_EYESCAN_CTRL_t := (
                                                                             RESET => (others => '0'),
                                                                             TRIGGER => (others => '0')
                                                                            );
  type TCDS_LINK0_MON_t is record
    CLOCKING                   : TCDS_LINK0_CLOCKING_MON_t;     
    DMONITOR                   : std_logic_vector( 7 downto  0);
    EYESCAN                    : TCDS_LINK0_EYESCAN_MON_t;      
    RX                         : TCDS_LINK0_RX_MON_t;           
    TX                         : TCDS_LINK0_TX_MON_t;           
  end record TCDS_LINK0_MON_t;

  type TCDS_LINK0_CTRL_t is record
    CLOCKING                   : TCDS_LINK0_CLOCKING_CTRL_t;    
    EYESCAN                    : TCDS_LINK0_EYESCAN_CTRL_t;     
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RX                         : TCDS_LINK0_RX_CTRL_t;          
    TX                         : TCDS_LINK0_TX_CTRL_t;          
  end record TCDS_LINK0_CTRL_t;

  constant DEFAULT_TCDS_LINK0_CTRL_t : TCDS_LINK0_CTRL_t := (
                                                             EYESCAN => DEFAULT_TCDS_LINK0_EYESCAN_CTRL_t,
                                                             RX => DEFAULT_TCDS_LINK0_RX_CTRL_t,
                                                             TX => DEFAULT_TCDS_LINK0_TX_CTRL_t,
                                                             CLOCKING => DEFAULT_TCDS_LINK0_CLOCKING_CTRL_t,
                                                             LOOPBACK => (others => '0')
                                                            );
  type TCDS_LINK1_CLOCKING_MON_t is record
    CLK_LOCKED                 : std_logic;   
    FB_CLK_LOST                : std_logic;   
  end record TCDS_LINK1_CLOCKING_MON_t;

  type TCDS_LINK1_CLOCKING_CTRL_t is record
    RESET                      : std_logic;   
  end record TCDS_LINK1_CLOCKING_CTRL_t;

  constant DEFAULT_TCDS_LINK1_CLOCKING_CTRL_t : TCDS_LINK1_CLOCKING_CTRL_t := (
                                                                               RESET => (others => '0')
                                                                              );
  type TCDS_LINK1_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    MONITOR                    : std_logic_vector( 6 downto  0);
    PRBS_ERROR                 : std_logic;                     
    RESET_DONE                 : std_logic;                     
  end record TCDS_LINK1_RX_MON_t;

  type TCDS_LINK1_RX_CTRL_t is record
    DFELPM_RESET               : std_logic;                     
    MONITOR_SEL                : std_logic_vector( 1 downto  0);
    PMA_RESET                  : std_logic;                     
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK1_RX_CTRL_t;

  constant DEFAULT_TCDS_LINK1_RX_CTRL_t : TCDS_LINK1_RX_CTRL_t := (
                                                                   MONITOR_SEL => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PMA_RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   DFELPM_RESET => (others => '0'),
                                                                   PRBS_RESET => (others => '0'),
                                                                   USER_READY => (others => '0')
                                                                  );
  type TCDS_LINK1_TX_MON_t is record
    RESET_DONE                 : std_logic;   
  end record TCDS_LINK1_TX_MON_t;

  type TCDS_LINK1_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK1_TX_CTRL_t;

  constant DEFAULT_TCDS_LINK1_TX_CTRL_t : TCDS_LINK1_TX_CTRL_t := (
                                                                   PRBS_FORCE_ERROR => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   USER_READY => (others => '0'),
                                                                   INHIBIT => (others => '0')
                                                                  );
  type TCDS_LINK1_EYESCAN_MON_t is record
    DATA_ERROR                 : std_logic;   
  end record TCDS_LINK1_EYESCAN_MON_t;

  type TCDS_LINK1_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record TCDS_LINK1_EYESCAN_CTRL_t;

  constant DEFAULT_TCDS_LINK1_EYESCAN_CTRL_t : TCDS_LINK1_EYESCAN_CTRL_t := (
                                                                             RESET => (others => '0'),
                                                                             TRIGGER => (others => '0')
                                                                            );
  type TCDS_LINK1_MON_t is record
    CLOCKING                   : TCDS_LINK1_CLOCKING_MON_t;     
    DMONITOR                   : std_logic_vector( 7 downto  0);
    EYESCAN                    : TCDS_LINK1_EYESCAN_MON_t;      
    RX                         : TCDS_LINK1_RX_MON_t;           
    TX                         : TCDS_LINK1_TX_MON_t;           
  end record TCDS_LINK1_MON_t;

  type TCDS_LINK1_CTRL_t is record
    CLOCKING                   : TCDS_LINK1_CLOCKING_CTRL_t;    
    EYESCAN                    : TCDS_LINK1_EYESCAN_CTRL_t;     
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RX                         : TCDS_LINK1_RX_CTRL_t;          
    TX                         : TCDS_LINK1_TX_CTRL_t;          
  end record TCDS_LINK1_CTRL_t;

  constant DEFAULT_TCDS_LINK1_CTRL_t : TCDS_LINK1_CTRL_t := (
                                                             EYESCAN => DEFAULT_TCDS_LINK1_EYESCAN_CTRL_t,
                                                             RX => DEFAULT_TCDS_LINK1_RX_CTRL_t,
                                                             TX => DEFAULT_TCDS_LINK1_TX_CTRL_t,
                                                             CLOCKING => DEFAULT_TCDS_LINK1_CLOCKING_CTRL_t,
                                                             LOOPBACK => (others => '0')
                                                            );
  type TCDS_LINK2_CLOCKING_MON_t is record
    CLK_LOCKED                 : std_logic;   
    FB_CLK_LOST                : std_logic;   
  end record TCDS_LINK2_CLOCKING_MON_t;

  type TCDS_LINK2_CLOCKING_CTRL_t is record
    RESET                      : std_logic;   
  end record TCDS_LINK2_CLOCKING_CTRL_t;

  constant DEFAULT_TCDS_LINK2_CLOCKING_CTRL_t : TCDS_LINK2_CLOCKING_CTRL_t := (
                                                                               RESET => (others => '0')
                                                                              );
  type TCDS_LINK2_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    MONITOR                    : std_logic_vector( 6 downto  0);
    PRBS_ERROR                 : std_logic;                     
    RESET_DONE                 : std_logic;                     
  end record TCDS_LINK2_RX_MON_t;

  type TCDS_LINK2_RX_CTRL_t is record
    DFELPM_RESET               : std_logic;                     
    MONITOR_SEL                : std_logic_vector( 1 downto  0);
    PMA_RESET                  : std_logic;                     
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK2_RX_CTRL_t;

  constant DEFAULT_TCDS_LINK2_RX_CTRL_t : TCDS_LINK2_RX_CTRL_t := (
                                                                   MONITOR_SEL => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PMA_RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   DFELPM_RESET => (others => '0'),
                                                                   PRBS_RESET => (others => '0'),
                                                                   USER_READY => (others => '0')
                                                                  );
  type TCDS_LINK2_TX_MON_t is record
    RESET_DONE                 : std_logic;   
  end record TCDS_LINK2_TX_MON_t;

  type TCDS_LINK2_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 2 downto  0);
    RESET                      : std_logic;                     
    USER_READY                 : std_logic;                     
  end record TCDS_LINK2_TX_CTRL_t;

  constant DEFAULT_TCDS_LINK2_TX_CTRL_t : TCDS_LINK2_TX_CTRL_t := (
                                                                   PRBS_FORCE_ERROR => (others => '0'),
                                                                   RESET => (others => '0'),
                                                                   PRBS_SEL => (others => '0'),
                                                                   USER_READY => (others => '0'),
                                                                   INHIBIT => (others => '0')
                                                                  );
  type TCDS_LINK2_EYESCAN_MON_t is record
    DATA_ERROR                 : std_logic;   
  end record TCDS_LINK2_EYESCAN_MON_t;

  type TCDS_LINK2_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record TCDS_LINK2_EYESCAN_CTRL_t;

  constant DEFAULT_TCDS_LINK2_EYESCAN_CTRL_t : TCDS_LINK2_EYESCAN_CTRL_t := (
                                                                             RESET => (others => '0'),
                                                                             TRIGGER => (others => '0')
                                                                            );
  type TCDS_LINK2_MON_t is record
    CLOCKING                   : TCDS_LINK2_CLOCKING_MON_t;     
    DMONITOR                   : std_logic_vector( 7 downto  0);
    EYESCAN                    : TCDS_LINK2_EYESCAN_MON_t;      
    RX                         : TCDS_LINK2_RX_MON_t;           
    TX                         : TCDS_LINK2_TX_MON_t;           
  end record TCDS_LINK2_MON_t;

  type TCDS_LINK2_CTRL_t is record
    CLOCKING                   : TCDS_LINK2_CLOCKING_CTRL_t;    
    EYESCAN                    : TCDS_LINK2_EYESCAN_CTRL_t;     
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RX                         : TCDS_LINK2_RX_CTRL_t;          
    TX                         : TCDS_LINK2_TX_CTRL_t;          
  end record TCDS_LINK2_CTRL_t;

  constant DEFAULT_TCDS_LINK2_CTRL_t : TCDS_LINK2_CTRL_t := (
                                                             EYESCAN => DEFAULT_TCDS_LINK2_EYESCAN_CTRL_t,
                                                             RX => DEFAULT_TCDS_LINK2_RX_CTRL_t,
                                                             TX => DEFAULT_TCDS_LINK2_TX_CTRL_t,
                                                             CLOCKING => DEFAULT_TCDS_LINK2_CLOCKING_CTRL_t,
                                                             LOOPBACK => (others => '0')
                                                            );
  type TCDS_CTRL0_MON_t is record
    CAPTURE_D                  : std_logic_vector(31 downto  0);
    CAPTURE_K                  : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL0_MON_t;

  type TCDS_CTRL0_CTRL_t is record
    CAPTURE                    : std_logic;                     
    FIXED_SEND_D               : std_logic_vector(31 downto  0);
    FIXED_SEND_K               : std_logic_vector( 3 downto  0);
    MODE                       : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL0_CTRL_t;

  constant DEFAULT_TCDS_CTRL0_CTRL_t : TCDS_CTRL0_CTRL_t := (
                                                             CAPTURE => (others => '0'),
                                                             FIXED_SEND_D => (others => '0'),
                                                             MODE => (others => '0'),
                                                             FIXED_SEND_K => (others => '0')
                                                            );
  type TCDS_CTRL1_MON_t is record
    CAPTURE_D                  : std_logic_vector(31 downto  0);
    CAPTURE_K                  : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL1_MON_t;

  type TCDS_CTRL1_CTRL_t is record
    CAPTURE                    : std_logic;                     
    FIXED_SEND_D               : std_logic_vector(31 downto  0);
    FIXED_SEND_K               : std_logic_vector( 3 downto  0);
    MODE                       : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL1_CTRL_t;

  constant DEFAULT_TCDS_CTRL1_CTRL_t : TCDS_CTRL1_CTRL_t := (
                                                             CAPTURE => (others => '0'),
                                                             FIXED_SEND_D => (others => '0'),
                                                             MODE => (others => '0'),
                                                             FIXED_SEND_K => (others => '0')
                                                            );
  type TCDS_CTRL2_MON_t is record
    CAPTURE_D                  : std_logic_vector(31 downto  0);
    CAPTURE_K                  : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL2_MON_t;

  type TCDS_CTRL2_CTRL_t is record
    CAPTURE                    : std_logic;                     
    FIXED_SEND_D               : std_logic_vector(31 downto  0);
    FIXED_SEND_K               : std_logic_vector( 3 downto  0);
    MODE                       : std_logic_vector( 3 downto  0);
  end record TCDS_CTRL2_CTRL_t;

  constant DEFAULT_TCDS_CTRL2_CTRL_t : TCDS_CTRL2_CTRL_t := (
                                                             CAPTURE => (others => '0'),
                                                             FIXED_SEND_D => (others => '0'),
                                                             MODE => (others => '0'),
                                                             FIXED_SEND_K => (others => '0')
                                                            );
  type TCDS_MON_t is record
    CTRL0                      : TCDS_CTRL0_MON_t;
    CTRL1                      : TCDS_CTRL1_MON_t;
    CTRL2                      : TCDS_CTRL2_MON_t;
    LINK0                      : TCDS_LINK0_MON_t;
    LINK1                      : TCDS_LINK1_MON_t;
    LINK2                      : TCDS_LINK2_MON_t;
  end record TCDS_MON_t;

  type TCDS_CTRL_t is record
    CTRL0                      : TCDS_CTRL0_CTRL_t;
    CTRL1                      : TCDS_CTRL1_CTRL_t;
    CTRL2                      : TCDS_CTRL2_CTRL_t;
    LINK0                      : TCDS_LINK0_CTRL_t;
    LINK1                      : TCDS_LINK1_CTRL_t;
    LINK2                      : TCDS_LINK2_CTRL_t;
  end record TCDS_CTRL_t;

  constant DEFAULT_TCDS_CTRL_t : TCDS_CTRL_t := (
                                                 LINK1 => DEFAULT_TCDS_LINK1_CTRL_t,
                                                 LINK0 => DEFAULT_TCDS_LINK0_CTRL_t,
                                                 LINK2 => DEFAULT_TCDS_LINK2_CTRL_t,
                                                 CTRL0 => DEFAULT_TCDS_CTRL0_CTRL_t,
                                                 CTRL1 => DEFAULT_TCDS_CTRL1_CTRL_t,
                                                 CTRL2 => DEFAULT_TCDS_CTRL2_CTRL_t
                                                );


end package TCDS_CTRL;