----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2019 01:49:27 PM
-- Design Name: 
-- Module Name: Top - Behavioral
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


entity SR_Out is
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
end SR_Out;

architecture Behavioral of SR_Out is

--signals for outputs
signal active       : std_logic; --Buffer for busy
signal SCK2         : std_logic; --Buffer for SCK
--counters
signal SCKcount     : integer range 0 to STEPS; --for counting SCK incriments to steps
signal shiftcount   : unsigned (2 downto 0); --for counting the number of shifts
--pulses for signaling
signal SCKpulse     : std_logic; --for signaling SCK flip
signal finish       : std_logic; --for signaling that readout is done
signal shift        : std_logic; --for signaling a shift
--Shiftregister
signal shiftreg     : std_logic_vector (7 downto 0);
--signal for interpreting the LEDMAP
signal datamap      : std_logic_vector (7 downto 0);

begin

--loading datamap based on LEDORDER
datamap(LEDORDER(0)) <= datain(0);
datamap(LEDORDER(1)) <= datain(1);
datamap(LEDORDER(2)) <= datain(2);
datamap(LEDORDER(3)) <= datain(3);
datamap(LEDORDER(4)) <= datain(4);
datamap(LEDORDER(5)) <= datain(5);
datamap(LEDORDER(6)) <= datain(6);
datamap(LEDORDER(7)) <= datain(7);

--continuous assignment of outputs
busy    <= active;
SCK     <= SCk2;
SDA     <= shiftreg(7); --always MSB of shiftreg

--Process for counting and pulsing SCK
counting: process (clk, reset)
begin
    --if reset then SCKcount and pulse are set to 0
    if reset = '1' then
        SCKcount <= 0;
        SCKpulse <= '0';
    --rising edge of clk
    elsif clk'event and clk='1' then 
        SCKpulse <= '0';
        if active = '1' then --if active then count
            SCKcount <= SCKcount + 1;
            --pulse and reset count when steps reached 
            if SCKcount = STEPS - 1 then
                SCKpulse <= '1';
                SCKcount <= 0;
            end if;        
        else --if not active don't count
            SCKcount <= 0;
        end if;
    end if;
end process;

--Process for the rest
Main: process (clk, reset)
begin
    if reset = '1' then
        active <= '0';
        dataout <= X"00";
        shiftreg <= X"00";
        SCK2 <= '0';
        shiftcount <= "000";--shiftcount <= 0;                                                                                                  
        
    elsif clk'event and clk='1' then
        --if not active then wait for an update to load in new data
        if active = '0' then
            if update = '1' then
                active <= '1';
                dataout <= datain;
                shiftreg <= datamap; --datain
            else
                dataout <= X"00";
            end if;
        else
            --respond to SCKpulse
            if SCKpulse = '1' then
                --flip SCK2
                SCK2 <= not SCK2;
                --falling edge of SCK2 shift shiftreg
                if SCK2 = '1' then
                    --count shifts
                    shiftreg <= shiftreg(6 downto 0) & '0';
                    shiftcount <= shiftcount + 1; --shiftcount <= shiftcount + 1;
                    --at 8 shifts deactivate and reset shift count
                    if shiftcount = 7 then --shiftcount = 7 then
                        shiftcount <= "000"; -- shiftcount <= 0;
                        active <= '0';            
                    end if;
                end if;
            end if;
        end if;
    end if;
            
end process;
end Behavioral;
