library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity phy_lane_control is
  generic (
    CM_COUNT : integer range 1 to 2 := 1;
    CLKFREQ : integer := 50000000);
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    initialize_in1  : in  std_logic;
    initialize_in2  : in  std_logic;
    phy_lane_1      : in  std_logic;
    phy_lane_2      : in  std_logic;
    initialize_out1 : out std_logic;
    initialize_out2 : out std_logic);
end entity phy_lane_control;
architecture behavioral of phy_lane_control is

  --- *** TIMING *** ---
  signal   count   : unsigned(4 downto 0);
  signal   timer   : integer range 0 to (CLKFREQ/1000);
  constant MILISEC : integer := CLKFREQ/1000;
  
  --- *** STATE_MACINE *** ---
  type state_t is (WAITING, INITIALIZING, READING, RUNNING);
  signal state : state_t;

  --- *** CONTROL *** ---
  signal initialize_buffer : std_logic;
  
begin

  --continuous output
  INITIALIZE_out1 <= INITIALIZE_in1;
  INITIALIZE_out2 <= INITIALIZE_in2 when (CM_COUNT = 2) else initialize_buffer;

  --process for managing state
  STATE_MACHINE: process (clk, reset) is
  begin
    if reset = '1' then --async reset
      state <= WAITING;
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when WAITING => --wait for phylane1 then transition based on phylane2
          if phy_lane_1 = '1' then
            if phy_lane_2 = '1' then
              state <= RUNNING;
            else
              state <= INITIALIZING;
            end if;
          else
            state <= WAITING;
          end if;
          
        when INITIALIZING => --wait for 32 clk
          if count = "11111" then
            state <= READING;
          else
            state <= INITIALIZING;
          end if;
          
        when READING => --after 1ms, evaluate phy lane 2
          if timer = MILISEC then
            if phy_lane_2 = '1' then
              state <= RUNNING;
            else
              state <= INITIALIZING;
            end if;
          else
            state <= READING;
          end if;
          
        when RUNNING => --holding state as long as phylan2 = 1
          if phy_lane_2 = '1' then
            state <= RUNNING;
          else
            state <= INITIALIZING;
          end if;
          
        when others => --reset state
          state <= WAITING;
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
        when WAITING => --no counting
          count <= "00000";
          timer <= 0;
          
        when INITIALIZING => --count to 32
          if count = "11111" then
            count <= "00000";
          else
            count <= count + 1;
          end if;
          timer <= 0;
          
        when READING => --count to 1ms
          count <= "00000";
          if timer = MILISEC then
            timer <= 0;
          else
            timer <= timer + 1;
          end if;
          
        when RUNNING => --no counting
          count <= "00000";
          timer <= 0;
          
        when others => --no counting
          count <= "00000";
          timer <= 0;
      end case;
    end if;  
  end process TIMING;

  --Process for managing output signals
  CONTROL: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      initialize_buffer <= '0';
      
    elsif clk'event and clk='1' then --rising clk edge
      case state is
        when WAITING =>
          if phy_lane_1 = '1' then
            if phy_lane_2 = '1' then
              initialize_buffer <= '0';
            else
              initialize_buffer <= '1';
            end if;
          else
            initialize_buffer <= '0';
          end if;

        when INITIALIZING =>
          if count = "11111" then
            initialize_buffer <= '0';
          else
            initialize_buffer <= '1';
          end if;

        when READING =>
          if timer = MILISEC then
            if phy_lane_2 = '0' then
              initialize_buffer <= '1';
            else
              initialize_buffer <= '0';
            end if;
          else
            initialize_buffer <= '0';
          end if;

        when RUNNING =>
          if phy_lane_2 = '0' then
            initialize_buffer <= '1';
          else
            initialize_buffer <= '0';
          end if;
          
        when others =>
          initialize_buffer <= '0';
      end case;
    end if;  
  end process CONTROL;
end architecture behavioral;

