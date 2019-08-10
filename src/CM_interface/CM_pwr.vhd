library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;


Library UNISIM;
use UNISIM.vcomponents.all;


entity CM_pwr is
  
  port (
    clk               : in  std_logic;
    reset             : in  std_logic;
    start_uC          : in  std_logic;
    start_PWR         : in  std_logic;
    sequence_override : in std_logic;
    current_state     : out std_logic_vector(3 downto 0);
    enable_uC         : out std_logic;
    enable_PWR        : out std_logic;
    enable_IOs        : out std_logic;
    power_good        : in  std_logic    
    );
end entity CM_pwr;

architecture behavioral of CM_pwr is

  type SM_state_t is (SM_RESET,SM_STARTUP,SM_PWR_WAIT,SM_PWR_DOWN,SM_RUNNING);
  signal state : SM_state_t;
  
begin  -- architecture behavioral

-----------------------------------------------------------------------------------------------
--  +----------+                 +----------+                 +----------+  power_good = 1 or
--  |          |  start_uC = 1   |          |  start_PWR = 1  |          |  sequence_override = 1
--  |  RESET   +---------------->+ STARTUP  +---------------->+ PWR_WAIT +---------------+
--  |          |                 |          |                 |          |               |
--  +----+-----+                 +----------+                 +----------+               |
--       ^                            |start_uC = 0                |start_uC = 0         |
--       |                            |                            |     or              |
--       |                            |                            |start_PWR = 0        |
--       |                            +----------------------------+                     |
--       |                            |                                                  |
--       |                            v                                                  |
--       |                       +----+-----+                                      +-----v----+
--       |        power_good = 0 |          |                                      |          |
--       +-----------------------+ PWR_DOWN +<-------------------------------------+ RUNNING  |
--                               |          |             start_uC = 0             |          |
--                               +----------+                  or                  +----------+
--                                                        start_PWR = 0
--                                                             or
--                                                        (power_good or sequence_override) = 0
-----------------------------------------------------------------------------------------------
  pwr_seq_SM: process (clk, reset) is
  begin  -- process pwr_seq_SM
    if reset = '1' then                 -- asynchronous reset (active high)
      state <= SM_RESET;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        --------------------------------        
        when SM_RESET =>
          if start_uC = '1' then
            --continue up the SM.
            state <= SM_STARTUP;
          else
            --stay here
            state <= SM_RESET;
          end if;
        --------------------------------                  
        when SM_STARTUP =>
          if start_PWR = '1' then
            --Continue up the SM. 
            state <= SM_PWR_WAIT;
          else
            -- stay here
            state <= SM_STARTUP;
          end if;

          --moving down
          if start_uC = '0' then
            -- go down the SM
            state <= SM_PWR_DOWN;
          end if;
        --------------------------------
        when SM_PWR_WAIT =>
          --Moving up
          if power_good = '1' or sequence_override = '1' then
            state <= SM_RUNNING;
          else
            state <= SM_PWR_WAIT;
          end if;

          --moving down
          if start_PWR = '0' then 
            state <= SM_PWR_DOWN;
          end if;

          --moving to the end
          if start_uC = '0' then
            state <= SM_RESET;
          end if;
        --------------------------------
        when SM_RUNNING =>
          --moving down
          if start_PWR = '0' or start_uC = '0' or
            (power_good or sequence_override) = '0' then
            state <= SM_PWR_DOWN;
          end if;
        --------------------------------
        when SM_PWR_DOWN =>
          if power_good = '0' then
            if start_uC = '1' then
              state <= SM_STARTUP;
            else
              state <= SM_RESET;
            end if;
          else
            state <= SM_PWR_DOWN;
          end if;

          if start_uC = '0' then
            state <= SM_RESET;
          end if;
        when others => state <= SM_RESET;
      end case;
    end if;
  end process pwr_seq_SM;


  pwr_seq_proc: process (clk, reset) is
  begin  -- process pwr_seq_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      enable_uC  <= '0';
      enable_PWR <= '0';
      enable_IOs <= '0';
      current_state <= x"1";
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when SM_RESET =>
          enable_uC  <= '0';
          enable_PWR <= '0';
          enable_IOs <= '0';
          current_state <= x"1";
        when SM_STARTUP =>
          enable_uC  <= '1';
          enable_PWR <= '0';
          enable_IOs <= '0';
          current_state <= x"2";
        when SM_PWR_WAIT =>
          enable_uC  <= '1';
          enable_PWR <= '1';
          enable_IOs <= '0';
          current_state <= x"3";
        when SM_RUNNING =>
          enable_uC  <= '1';
          enable_PWR <= '1';
          enable_IOs <= '1';
          current_state <= x"4";
        when SM_PWR_DOWN =>
          enable_uC  <= '1';
          enable_PWR <= '0';
          enable_IOs <= '0';
          current_state <= x"5";
        when others =>
          enable_uC  <= '0';
          enable_PWR <= '0';
          enable_IOs <= '0';
          current_state <= x"0";
      end case;
      
    end if;
  end process pwr_seq_proc;


  
end architecture behavioral;
