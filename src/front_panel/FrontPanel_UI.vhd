----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/25/2019 04:31:24 PM
-- Design Name: 
-- Module Name: FrontGrande - Behavioral
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

entity FrontPanel_UI is
    generic (CLKFREQ        : integer := 100000000;         --frequency of onboard clock signal in hz 
             REG_COUNT      : integer range 1 to 64 := 14;  --how many entries are in the array
             FLASHLENGTH    : integer := 3;                 --how many seconds do you want it to flash for
             FLASHRATE      : integer := 2;                 --how many times do you want it to flash per second
             SHUTDOWNFLIP   : std_logic := '1';             --if 1 flash AA-55, if 0 go to reg0
             LEDORDER       : int8_array_t(0 to 7) := (0 => 0, 1 => 1, 2 =>2, 3 => 3,
                                                       4 => 4, 5 => 5, 6 => 6, 7 =>7)); --Specifies a map for LED
                                                                                        --usage (0 => 5) means bit 0 is displayed on LED 5       
    Port    (clk            : in std_logic;                             --onboard clk
             reset          : in std_logic;                             --reset system
             buttonin       : in std_logic;                             --button input
             addressin      : in std_logic_vector (5 downto 0);               --address input
             force_address  : in std_logic;                           --forces the input address onto the LED_Encoder
             display_regs   : in slv8_array_t(0 to (REG_COUNT - 1));    --Input data
             addressout     : out std_logic_vector (5 downto 0);             --The address in the display_regs currently being displayed
             SCK            : out std_logic;                            --serial clk
             SDA            : out std_logic;                            --serial data
             shutdownout    : out std_logic);                           --shutdown signal            
end FrontPanel_UI;

architecture Behavioral of FrontPanel_UI is

--signals for transmisitting buttons across components
signal short    : std_logic; 
signal long     : std_logic;
signal two      : std_logic;
signal shutdown : std_logic;
--constants for timing
constant STEPS  : integer := CLKFREQ / 1000000; --this makes SCK run at 1 Mhz, 10 us for a full readout, --2 does work
--kinda a placeholder, may go away
signal dataout : std_logic_vector (7 downto 0);


begin

TB1 : entity work.Button_Decoder --using triButton
    generic map (CLKFREQ        => CLKFREQ)
    port map    (clk            => clk,
                 reset          => reset,
                 buttonin       => buttonin,
                 short          => short,
                 long           => long,
                 two            => two,
                 shutdown       => shutdown);
                                
L1 : entity work.LED_Encoder --using LED_Encoder
    generic map (CLKFREQ        => CLKFREQ,
                 STEPS          => STEPS,
                 REG_COUNT      => REG_COUNT,
                 FLASHLENGTH    => FLASHLENGTH,
                 FLASHRATE      => FLASHRATE,
                 SHUTDOWNFLIP   => SHUTDOWNFLIP,
                 LEDORDER       => LEDORDER)
    port map    (clk            => clk,
                 reset          => reset,
                 addressin      => addressin,
                 force_address  => force_address,
                 data           => display_regs,
                 load           => short,
                 prev           => two,
                 flash          => long,
                 shutdown       => shutdown,
                 dataout        => dataout,
                 addressout     => addressout,
                 SCK            => SCK,
                 SDA            => SDA);

--continuous button outputs                   
shutdownout <= shutdown;

end Behavioral;
