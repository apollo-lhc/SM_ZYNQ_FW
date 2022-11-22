----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2019 11:47:20 AM
-- Design Name: 
-- Module Name: Loader - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;

entity LED_Encoder is
    generic (CLKFREQ        : integer;                  --onboad clock frequency in hz
             STEPS          : integer;                  --how many clk ticks corresond to a SCK tick
             REG_COUNT      : integer range 1 to 64;    --how many entries are in the array 
             FLASHLENGTH    : integer;                  --how many seconds do you want it to flash for
             FLASHRATE      : integer;                  --how many times do you want it to flash per second
             SHUTDOWNFLIP   : std_logic;
             LEDORDER       : int8_array_t(0 to 7));               --how many times do you want it to flash per second
    Port    (clk            : in std_logic;                             --clk
             reset          : in std_logic;                             --reset            
             addressin      : in std_logic_vector (5 downto 0);                 --input address
             force_address  : in std_logic;                             --forces positon to addressin
             data           : in slv8_array_t(0 to (REG_COUNT - 1));    --Data Array
             load           : in std_logic;                             --moves to the next register value
             prev           : in std_logic;                             --displays the current position in the register
             flash          : in std_logic;                             --blinks the current value
             shutdown       : in std_logic;                             --goes to shutdown state
             dataout        : out std_logic_vector (7 downto 0);        --output data
             addressout     : out std_logic_vector (5 downto 0);                --the current address
             SCK            : out std_logic;                            --serial clk
             SDA            : out std_logic);                           --serial data
end LED_Encoder;

architecture Behavioral of LED_Encoder is

--State Machine
type states is (IDLE,   --Idle
                PRINT,  --Print current value
                BLINK,  --Blink position 
                A5);    --Flash A5   
signal State            : states;
--register for loading data
signal LoadData         : std_logic_vector(7 downto 0);
--1-bit signals
signal update           : std_logic;                                            --used to update
signal active           : std_logic;                                            --used to buffer busy output, never assign directly to this
signal flashbit         : std_logic;                                            --used for flashing data or 0
--constants for timing
constant refresh        : integer := (CLKFREQ / 100);                           --refresh every 10 ms,
constant flashtiming    : integer := (((CLKFREQ / refresh) / FLASHRATE ) / 2);  --the rate which the flash happens
constant endflash       : integer := (2 * (FLASHRATE + 3));                     --the number of times flash is triggered
--counters
signal position         : unsigned (5 downto 0);                                --to count position in register
signal count            : integer range 0 to (CLKFREQ / 2);                     --for general purpose counting
signal flashcount       : integer range 0 to (endflash + 1);                    --to count the amount of times flashed
signal refreshcount     : integer range 0 to flashtiming;                       --to count refreshing in flash state    
signal A5count          : integer range 0 to 50;                                --to count how many refreshes occur in the A5 state


--Declare SR_out
component SR_Out
    generic (STEPS      : integer;
             LEDORDER   : int8_array_t(0 to 7));
    Port    (clk        : in std_logic;
             reset      : in std_logic;
             datain     : in std_logic_vector (7 downto 0);
             update     : in std_logic;
             dataout    : out std_logic_vector (7 downto 0);         
             busy       : out std_logic;
             SCK        : out std_logic;
             SDA        : out std_logic);
end component; --end SR_out

begin

--continuous outputs
addressout <= std_logic_vector(position);


U1 : SR_Out --using SR_Out
    generic map (STEPS      => STEPS,
                 LEDORDER   => LEDORDER)
    port map    (clk        => clk,
                 reset      => reset,
                 datain     => LoadData,
                 update     => update,
                 dataout    => dataout,
                 busy       => active,
                 SCK        => SCK,
                 SDA        => SDA);
              
--continuous assignment of outputs
--busy <= active;

--This process manages the position within the register
Shift: process (clk, reset)
begin

  if reset = '1' then --reset position to 0
    position <= "000000";

  elsif clk'event and clk='1' then

    --forcing shutdown  
    if shutdown = '1' then
        if SHUTDOWNFLIP = '0' then
            position <= "000000";
        end if;
    
    --forcing address  
    elsif force_address = '1' then
        position <= unsigned(addressin);
    
    --normal use    
    elsif state /= BLINK then
      if load = '1' then
        if to_integer(position) = (REG_COUNT - 1) then
          position <= "000000";
        else
          position <= position + 1;
        end if;
      elsif prev = '1' then
        if position = "000000" then
          position <= to_unsigned((REG_COUNT - 1), 6);
        else
          position <= position - 1;
        end if;
      end if;
    else
      position <= position;
    end if; --end position movement
  end if; --end clk & reset
end process; --end position process

        
--This process is for the functionality of each state
StateFunction: process (clk, reset)
begin
  
  if reset = '1' then
    --set signals low
    flashbit    <= '0';
    update      <= '0';
    --reset counters
    count <= 0;
    flashcount <= 0;
    A5count <= 0;
    refreshcount <= 0;
    
  elsif clk'event and clk='1' then
    --state machine
    case State is
      when IDLE => 
        if flash = '1' then
          --reset count if moving to BLINK b/c flash is high
          count <= 0;
          flashbit <= '0';
          flashcount <= 0;
          refreshcount <= 0;
        else --if not going to BLINK
          --increment count
          count <= count + 1;
          if count = refresh then --at refrestrate
            --load data, set update high
            loaddata <= data(to_integer(position));
            update <= '1';
          end if;
        end if;
        
      when PRINT => --set update low and reset count
        update <= '0'; 
        count <= 0;
        
      when BLINK =>
        if active = '1' then --flip update down
            update <= '0';
            count <= 0;
        else
            count <= count + 1;
            if count = refresh then
                update <= '1'; 
                count <= 0;
                refreshcount <= refreshcount + 1;
                if refreshcount = flashtiming then
                    refreshcount <= 0;
                    flashbit <= not flashbit;
                    flashcount <= flashcount + 1;
                --end if;
                elsif flashcount = 0  or flashcount = endflash then
                    loaddata <= X"FF";
                    update <= '1';
                elsif flashbit = '1' then
                    loaddata <= "00" & std_logic_vector(position);
                    update <= '1';
                else
                    loaddata <= X"00";
                    update <= '1';
                end if;
            end if;
        end if;

      when A5 =>
        if active = '1' then --flip update down
            update <= '0';
            count <= 0;
        elsif SHUTDOWNFLIP = '1' then --A5 case
            count <= count + 1;
            if count = refresh then
                --count <= 0;
                A5count <= A5count + 1;
                if A5count = 50 then
                    A5count <= 0;
                    flashbit <= not flashbit;
                end if;
                if flashbit = '1' then
                    loaddata <= X"AA";
                    update <= '1';
                else
                    loaddata <= X"55";
                    update <= '1';
                end if;
            end if;
        else --display reg0 case
            count <= count + 1;
            if count = refresh then
                count <= 0;
                loaddata <= data(to_integer(position));
                update <= '1';
            end if; 
        end if;

      when others =>
        null;
        
    end case; --end state machine
  end if; --end clk & reset
end process; --end StateFunction

--This process is for the transitions between states
StateFlow: process (clk, reset)
begin

  --reset
  if reset = '1' then
    State <= IDLE;

  elsif clk'event and clk='1' then
  
    if shutdown = '1' then
        State <= A5;
    else
        --state machine
        case State is
          when IDLE =>
            --if flash is high go to BLINK
            if flash = '1' then
              state <= BLINK;
            --if readout is active, move to PRINT state
            elsif active = '1' then
              State <= PRINT;
            end if;
    
          when PRINT =>
            --return to IDLE after readout completes
            if active = '0' then
              State <= IDLE;
            end if;
    
          when BLINK =>
            if flashcount = (endflash + 1) then
                State <= IDLE;
            end if;
            
          when others => --if broken, go to IDLE
            State <= IDLE;
            
        end case; --end state machine
    end if; -- end shutdown if
  end if; --end clk & reset
end process; --end stateFlow
end Behavioral; --end it all

