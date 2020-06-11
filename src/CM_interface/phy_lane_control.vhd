library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity phy_lane_control is
  generic (
    CLKFREQ  : integer := 50000000);
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    enable         : in  std_logic;
    initialize_in  : in  std_logic;
    phy_lane_up    : in  std_logic;
    initialize_out : out std_logic;
    locked         : out std_logic);
end entity phy_lane_control;
architecture behavioral of phy_lane_control is

  --- *** TIMING *** ---
  signal   count   : unsigned(4 downto 0);
  signal   timer   : integer range 0 to (CLKFREQ/1000);
  constant MILISEC : integer := CLKFREQ/1000;
  
  --- *** STATE_MACINE *** ---
  type state_t is (IDLE, WAITING, INITIALIZING, READING, LOCKED);
  signal state : state_t;

begin
-----------------------------------------------------------------------------------------
--  
--                                                          +-----------+
--                                                          |           |
--                                                          |  LOCKED   |
--                                    +-------------------->+           |
--                                    |    phylaneup = 1    +-------+---+
--                                    |                             |
--  ALL STATES                        |                             |
--       +                            |                             |phylaneup = 0
--       | enable = 0                 |                             |
--       v                            |      timer = 1ms            v
--   +---+----+             +---------+-+   phylaneup = 0   +-------+--------+
--   |        |             |           +------------------>+                |
--   |  IDLE  +------------>+   WAIT    |                   |  INITIALIZING  +-------+
--   |        | enable = 1  |           +<------------------+                |       |
--   +--------+             +-+--------++   COUNTER = 32    +-----------+----+       |
--                            ^        |                                ^            |
--                            |        |                                |            |
--                            +--------+                                +------------+
--                           Timer /= 1ms                                 COUNTER /= 32
--                         
-----------------------------------------------------------------------------------------
                         
--process for managing state
  STATE_MACHINE: process (clk, reset) is
  begin
    if reset = '1' then --async reset
      state <= IDLE;
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when IDLE => --move to INITIALIZE on enable
          if enable = '1' then
            state <= INITIALIZING;
          else
            state <= IDLE;
          end if;
          
        when INITIALIZING => --move to WAITING after 32 clk's
          if enable = '0' then
            state <= IDLE;
          else
            if counter = "11111" then
              state <= WAITING;
            else
              state <= INITIALIZING;
            end if;
          end if;
          
        when WAITING => --read phy_lane_up for 1ms
          if enable = '0' then
            state <= IDLE;
          else
            if phy_lane_up = '1' then
              state <= LOCKED;
            else
              if timer = MILISEC then
                state <= INITIALIZING;
              else
                state <= WAITING;
              end if;
            end if;
          end if;
          
        when LOCKED =>
          if enable = '0' then
            state <= IDLE;
          else
            if phy_lane_up '0' then
              state <= INITIALIZING;
            else
              state <= LOCKED;
            end if;
          end if;
          
        when others => --reset 
          state <= IDLE;          
      end case;
    end if;
  end process STATE_MACHINE;

  --Process for managing timing
  TIMING: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      count <= "00000";
      timer <= 0;
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when IDLE => --no counting
          count <= "00000";
          timer <= 0;
          
        when INITIALIZING => --count 32 clk's
          if count = "11111" then
            count <= "00000";
          else
            count <= count + 1;
          end if;
          timer <= 0;
          
        when WAITING => --count to 1 ms
          count <= "00000";
          if timer = MILISEC then
            timer <= 0;
          else
            timer <= timer + 1;
          end if;
          
        when LOCKED => --no counting
          count <= "00000";
          timer <= 0;
          
        when others => --reset 
          count <= "00000";
          timer <= 0;
      end case;
    end if;
  end process TIMING;

  --Process for managing output signals
  CONTROL: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      initialize_out <= '0';
      locked <= '0';
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when IDLE => --initialize is passed through
          initialize_out <= initialize_in;
          locked <= '0';
          
        when INITIALIZING => --force initialize
          initialize_out <= '1';
          locked <='0';
          
        when WAITING => --hold at 0
          initialize_out <= '0';
          locked <= '0';
          
        when LOCKED => --set locked, hold initialize low
          initialize_out <= '0';
          locked <= '1';
          
        when others => --reset
          initialize_out <= '0';
          locked <= '0';
      end case;
    end if;
  end process CONTROL;
end architecture behavioral;
