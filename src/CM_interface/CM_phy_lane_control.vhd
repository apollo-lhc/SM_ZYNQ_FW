library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity CM_phy_lane_control is
  generic (
    CLKFREQ        : integer := 50000000; --Frequency of clk (hz)
    DATA_WIDTH     : integer := 32);      --Data width for error counter
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    enable         : in  std_logic;
    phy_lane_up    : in  std_logic;
    initialize_out : out std_logic;
    lock           : out std_logic;
    count          : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity CM_phy_lane_control;
architecture behavioral of CM_phy_lane_control is

  --- *** TIMING *** ---
  signal   counter : unsigned(4 downto 0);
  signal   timer   : integer range 0 to (CLKFREQ/100);
  constant TENMILISEC : integer := CLKFREQ/100;
  
  --- *** STATE_MACINE *** ---
  type state_t is (IDLE, WAITING, INITIALIZING, READING, LOCKED);
  signal state : state_t;

  --- *** COUNTER *** ---
  signal event   : std_logic;
  signal reset_c : std_logic;
  
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
            state <= WAITING;
          else
            state <= IDLE;
          end if;
        -----------------------------------------------------  
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
        -----------------------------------------------------  
        when WAITING => --read phy_lane_up for 1ms
          if enable = '0' then
            state <= IDLE;
          else
            if phy_lane_up = '1' then
              state <= LOCKED;
            else
              if timer = TENMILISEC then
                state <= INITIALIZING;
              else
                state <= WAITING;
              end if;
            end if;
          end if;
        -----------------------------------------------------  
        when LOCKED =>
          if enable = '0' then
            state <= IDLE;
          else
            if phy_lane_up = '0' then
              state <= INITIALIZING;
            else
              state <= LOCKED;
            end if;
          end if;
        -----------------------------------------------------  
        when others => --reset 
          state <= IDLE;          
      end case;
    end if;
  end process STATE_MACHINE;

  --Process for managing timing
  TIMING: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      counter <= "00000";
      timer   <= 0;
      event   <= '0';
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when IDLE => --no counting
          counter <= "00000";
          timer   <= 0;
          event   <= '0';
          
        when INITIALIZING => --count 32 clk's
          if counter = "11111" then
            counter <= "00000";
            event <= '1';
          else
            counter <= counter + 1;
            event   <= '0';
          end if;
          timer <= 0;
          
        when WAITING => --count to 1 ms
          counter <= "00000";
          if timer = TENMILISEC then
            timer <= 0;
          else
            timer <= timer + 1;
          end if;
          event <= '0';
          
        when LOCKED => --no counting
          counter <= "00000";
          timer   <= 0;
          event   <= '0';
          
        when others => --reset 
          counter <= "00000";
          timer   <= 0;
          event   <= '0';
      end case;
    end if;
  end process TIMING;

  --Process for managing output signals
  CONTROL: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      initialize_out <= '0';
      lock <= '0';
      reset_c <= '1';
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when IDLE => --initialize is passed through
          initialize_out <= '0';
          lock <= '0';
          reset_c <= '1';
          
        when INITIALIZING => --force initialize
          initialize_out <= '1';
          lock <='0';
          reset_c <= '0';
          
        when WAITING => --hold at 0
          initialize_out <= '0';
          lock <= '0';
          reset_c <= '0';
          
        when LOCKED => --set locked, hold initialize low
          initialize_out <= '0';
          lock <= '1';
          reset_c <= '1';
          
        when others => --reset
          initialize_out <= '0';
          lock <= '0';
          reset_c <= '0';
      end case;
    end if;
  end process CONTROL;

  --Counter for monitoring
  Count_0: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      A_RST_CNT   => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset,
      reset_sync  => reset_c,
      enable      => enable,
      event       => event,
      count       => count,
      at_max      => open);
end architecture behavioral;
