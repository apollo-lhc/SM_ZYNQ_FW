----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/24/2019 01:06:51 PM
-- Design Name: 
-- Module Name: Debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Button_Decoder is
    generic (CLKFREQ    : integer); --frequency of onboard clock signal in hz
    Port    (clk        : in std_logic;
             reset      : in std_logic;
             buttonin   : in std_logic;
             short      : out std_logic;
             long       : out std_logic;
             two        : out std_logic;
             shutdown   : out std_logic);
end Button_Decoder;

architecture Behavioral of Button_Decoder is

--constants used for timing
constant longtime       : integer := CLKFREQ;
constant shorttime      : integer := (CLKFREQ / 6);
constant waittime       : integer := (CLKFREQ / 10);
--counters
signal count            : integer range 0 to longtime;
signal shutdowncount    : integer range 0 to longtime;
signal shutdownshift    : unsigned (2 downto 0);
--1 bit signals
signal twoflip          : std_logic; --to recognize a double press
signal button           : std_logic; --clean button output from the debouncer
signal forcestop        : std_logic; --signal to go to shutdown state

--state machine for main process
type states is (SM_IDLE,       --Waiting for a button press
                SM_WAIT,    --Timing how long button is held
                SM_READ,  --waiting for a multipress
                SM_HOLD,
                SM_SHUTDOWN);  --used to buffer between button presses
signal State : states;


begin

TD1 : entity  work.Button_Debouncer --using debouncer
generic map (CLKFREQ    => CLKFREQ)
port map    (clk        => clk,
             reset      => reset,
             buttonin   => buttonin,
             buttonout  => button);

--This process defines what each state does
StateFcn: process (clk, reset) begin

    if reset = '1' then  
        --going to idle is an effective reset
        
    elsif clk'event and clk='1' then

        case State is
        
            when SM_IDLE =>
                --no counting
                count <= 0;
                --no outputs
                short <= '0';
                long <= '0';
                two <= '0';
                shutdown <= '0';
                --twoflip is 0;
                twoflip <= '0';
                
            when SM_WAIT =>
                if button = '1' then
                    count <= count + 1;
                    if count = longtime then
                        long <= '1';
                        count <= 0;
                    end if;
                else
                    count <= 0;
                end if;
            
            when SM_READ =>
                count <= count + 1;
                if button = '1' then
                    twoflip <= '1';
                end if;
                if count = shorttime then
                    count <= 0;
                    if twoflip = '1' then
                        two <= '1';
                    else
                        short <= '1';
                    end if;
                end if;
                
            when SM_HOLD =>
                short <= '0';
                long <= '0';
                two <= '0';
                count <= count + 1;
                if count = waittime then
                    count <= 0;
                end if;
                
            when SM_SHUTDOWN =>
                shutdown <= '1';
                
            when others => null;
        end case; --end state machine
    
    
    end if; --end clk & reset
end process; --end StateFcn

--This process describes the transition between states
--An ASCII flowchart is commented into the bottom of this file
StateFlow: process (clk, reset) begin
    
    if reset = '1' then
        state <= SM_IDLE;
    
    
    elsif clk'event and clk='1' then

        case State is 
        
            when SM_IDLE =>
                if forcestop = '1' then
                    State <= SM_SHUTDOWN;
                elsif button = '1' then
                    State <= SM_WAIT;
                else   
                    State <= SM_IDLE;
                end if;   
                
            when SM_WAIT =>
                if forcestop = '1' then
                    State <= SM_SHUTDOWN;      
                elsif button = '1' then
                    if count = longtime then
                        State <= SM_HOLD;
                    end if;
                else
                    State <= SM_READ;
                end if;
            
            when SM_READ =>
                if forcestop = '1' then
                    State <= SM_SHUTDOWN;
                elsif count = shorttime then
                    State <= SM_HOLD;
                end if;
                
                
            when SM_HOLD =>
                if forcestop = '1' then
                    State <= SM_SHUTDOWN;                    
                elsif count = waittime  then
                    State <= SM_IDLE;
                end if;
                
            when SM_SHUTDOWN =>
                null; --only way to leave shutdown is a reset
            
            when others => 
                State <= SM_IDLE;
        end case; --end state machine
    
    
    end if; --end clk & reset
end process; --end StateFlow


STOP: process (clk, reset)
begin
    if reset = '1' then
        shutdowncount <= 0;
        shutdownshift <= "000";
        
    elsif clk'event and clk='1' then
        
        if State = SM_SHUTDOWN then
            forcestop <= '0';
            shutdowncount <= 0;
            shutdownshift <= "000";
            
        elsif button = '1' then
            shutdowncount <= shutdowncount + 1;
            if shutdowncount = longtime then
                shutdowncount <= 0;
                shutdownshift <= shutdownshift + 1;
                if shutdownshift = "111" then
                    forcestop <= '1';
                    shutdownshift <= "000";
                end if;
            end if;
        else
            shutdowncount <= 0;
            shutdownshift <= "000";
        end if;
    end if; --end clk & reset
    
end process; --end STOP process
    
end Behavioral;

                            
--                                            +------+<----------------------------------------------------+
--                                            |      |                                                     | button = 1
--                                            |      +<--------------------------------------------+       | during .5s
--                                            | HOLD |                                   button = 0|       | two <= 1
--                                            |      +<-------------------+                 for .5s|       |
--                                            +--+---+          button = 1|              short <= 1|       |
--                                               |              for 1s    |                        |       |
--                            +---------+        v              long <= 1 |                        |       |
--                            |reset = 1|     Wait 1s                     |                        |       |
--                            +---+-----+        +                        |                        |       |
--                                |              |                        |                        |       |
--                                |           +--v---+               +----+----+               +---+---+   |
--                                |           |      |  button = 1   |         |   button = 0  |       |   |
--                                +------>+-->+ IDLE +---------------> WAITING +-------------->+ READ  +---+
--                                        |   |      |               |         |               |       |
--                                        |   +---+--+               +---------+               +-------+
--                                        |       |
--                                        |       |
--                                        +-------+ button = 0
