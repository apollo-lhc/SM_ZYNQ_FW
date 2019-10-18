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
    uc_enabled        : in  std_logic;
    start_pwr         : in  std_logic;
    sequence_override : in std_logic;
    current_state     : out std_logic_vector(3 downto 0);
    enabled_PWR       : out std_logic;
    enabled_IOs       : out std_logic;
    power_good        : in  std_logic    
    );
end entity CM_pwr;

architecture behavioral of CM_pwr is

  type SM_state_t is (SM_RESET,SM_PWR_WAIT,SM_PWR_DOWN,SM_RUNNING);
  signal state : SM_state_t;
  
begin  -- architecture behavioral

-----------------------------------------------------------------------------------------------
--  +----------+                 +----------+                             +----------+
--  |          |                 |          |                             |          |
--  |  RESET   +---------------->+ PWR_WAIT +---------------------------->+ RUNNING  |
--  |          |                 |          |    power_good = 1 or        |          |
--  +----+-----+                 +----+-----+    sequence_override = 1    +-----+----+
--       ^                            |                                         |
--       |                            |                                         |
--       |                            |                                         |
--       |                            | start_PWR = 0                           |
--       |                            |                                         |
--       |                            |                                         |
--       |                       +----v-----+                                   |
--       |        power_good = 0 |          |                                   |
--       +-----------------------+ PWR_DOWN +<----------------------------------+
--                               |          |    start_PWR = 0
--                               +----------+         or
--                                               (power_good or sequence_override) = 0
-----------------------------------------------------------------------------------------------
  pwr_seq_SM: process (clk, reset) is
  begin  -- process pwr_seq_SM
    if reset = '1' then                 -- asynchronous reset (active high)
      state <= SM_RESET;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if uc_enabled = '0' then
        state <= SM_RESET;
      else        
        case state is
          --------------------------------        
          when SM_RESET =>
            if start_pwr = '1' then
              --continue up the SM.
              state <= SM_PWR_WAIT;
            else
              --stay here
              state <= SM_RESET;
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

          --------------------------------
          when SM_RUNNING =>
            --moving down
            if start_PWR = '0' or
              (power_good or sequence_override) = '0' then
              state <= SM_PWR_DOWN;
            end if;
          --------------------------------
          when SM_PWR_DOWN =>
            if power_good = '0' then
              state <= SM_RESET;
            else
              state <= SM_PWR_DOWN;
            end if;
          when others => state <= SM_RESET;
        end case;
      end if;
    end if;
  end process pwr_seq_SM;


  pwr_seq_proc: process (clk, reset) is
  begin  -- process pwr_seq_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      enabled_PWR <= '0';
      enabled_IOs <= '0';
      current_state <= x"1";
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when SM_RESET =>
          enabled_PWR <= '0';
          enabled_IOs <= '0';
          current_state <= x"1";
        when SM_PWR_WAIT =>
          enabled_PWR <= '1';
          enabled_IOs <= '0';
          current_state <= x"2";
        when SM_RUNNING =>
          enabled_PWR <= '1';
          enabled_IOs <= '1';
          current_state <= x"3";
        when SM_PWR_DOWN =>
          enabled_PWR <= '0';
          enabled_IOs <= '0';
          current_state <= x"4";
        when others =>
          enabled_PWR <= '0';
          enabled_IOs <= '0';
          current_state <= x"0";
      end case;
      
    end if;
  end process pwr_seq_proc;


  
end architecture behavioral;
