----------------------------------------------------------------------------------
-- Company: BU EDF
-- Engineer: Michael Kremer, kremerme@bu.edu
-- Create Date: 07/08/2019 01:35:23 PM
-- Module Name: LED_Patterns - Behavioral
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use work.types.ALL;

entity LED_Patterns is
  generic (CLKFREQ  : integer := 100000000);
  port    (clk      : in std_logic;
           reset    : in std_logic;
           mode     : in std_logic_vector(2 downto 0);
           speed    : in std_logic_vector(3 downto 0);
           LEDs     : out std_logic_vector(7 downto 0));
end LED_Patterns;

architecture Behavioral of LED_Patterns is

  signal counter    : unsigned(7 downto 0);
  signal timer      : integer range 0 to (CLKFREQ + 16);
  signal update     : std_logic;
  signal position   : unsigned(7 downto 0);
  
begin

  --Process to handle timing between updating LEDS
  Timing : process (clk, reset) 
  begin
    if reset = '1' then
      timer <= 0;
      update <= '0';
      
    elsif clk'event and clk='1' then
      --update to next position in patter
      if timer > CLKFREQ then
        update <= '1';
        timer <= 0;

      else --incriment timer based on value of speed
        timer <= timer + to_integer(unsigned(speed));
        update <= '0';
      end if;
    end if; --end clk,reset
  end process Timing;
  
  --Process to create LED patterns
  Patterns : process (clk, reset)
  begin
    if reset = '1' then
      LEDs <= x"00";
      position <= x"00";
      
    elsif clk'event and clk='1' then
      case mode is
        when "000" => --8 bit counter
          if update = '1' then
            LEDs <= std_logic_vector(position);
            position <= position + 1;
          end if;
 
        when "001" => --counterclockwise circle
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "00000000";
              when x"01" =>
                position <= position + 1;
                LEDs <= "01000000";
              when x"02" =>
                position <= position + 1;
                LEDs <= "11000000";
              when x"03" =>
                position <= position + 1;
                LEDs <= "11001000";
              when x"04" =>
                position <= position + 1;
                LEDs <= "11001100";
              when x"05" =>
                position <= position + 1;
                LEDs <= "11001110";
              when x"06" =>
                position <= position + 1;
                LEDs <= "11001111";
              when x"07" =>
                position <= position + 1;
                LEDs <= "11011111";
              when x"08" =>
                position <= x"00";
                LEDS <= "11111111";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;
                  
        when "010" => --clockwise circle
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "00000000";
              when x"01" =>
                position <= position + 1;
                LEDs <= "00100000";
              when x"02" =>
                position <= position + 1;
                LEDs <= "00110000";
              when x"03" =>
                position <= position + 1;
                LEDs <= "00110001";
              when x"04" =>
                position <= position + 1;
                LEDs <= "00110011";
              when x"05" =>
                position <= position + 1;
                LEDs <= "00110111";
              when x"06" =>
                position <= position + 1;
                LEDs <= "00111111";
              when x"07" =>
                position <= position + 1;
                LEDs <= "10111111";
              when x"08" =>
                position <= x"00";
                LEDs <= "11111111";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;
          
        when "011" => --Left&Right synced
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "00010001";
              when x"01" =>
                position <= position + 1;
                LEDs <= "00100010";
              when x"02" =>
                position <= position + 1;
                LEDs <= "01000100";
              when x"03" =>
                position <= position + 1;
                LEDs <= "10001000";
              when x"04" =>
                position <= position + 1;
                LEDs <= "10001000";
              when x"05" =>
                position <= position + 1;
                LEDs <= "01000100";
              when x"06" =>
                position <= position + 1;
                LEDs <= "00100010";
              when x"07" =>
                position <= x"00";
                LEDs <= "00010001";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;
            
        when "100" => --Left&Right criss crossed
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "10000001";
              when x"01" =>
                position <= position + 1;
                LEDs <= "01000010";
              when x"02" =>
                position <= position + 1;
                LEDs <= "00100100";
              when x"03" =>
                position <= position + 1;
                LEDs <= "00011000";
              when x"04" =>
                position <= position + 1;
                LEDs <= "00011000";
              when x"05" =>
                position <= position + 1;
                LEDs <= "00100100";
              when x"06" =>
                position <= position + 1;
                LEDs <= "01000010";
              when x"07" =>
                position <= x"00";
                LEDs <= "10000001";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;

        when "101" => --Alternating checkerboard
          if update = '1' then
            case position is
              when x"00" =>
                position <= x"01";
                LEDs <= "10100101";
              when x"01" =>
                position <= x"00";
                LEDs <= "01011010";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;

        when "110" => --1 bit counterclockwise circle
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "00000000";
              when x"01" =>
                position <= position + 1;
                LEDs <= "01000000";
              when x"02" =>
                position <= position + 1;
                LEDs <= "10000000";
              when x"03" =>
                position <= position + 1;
                LEDs <= "00001000";
              when x"04" =>
                position <= position + 1;
                LEDs <= "00000100";
              when x"05" =>
                position <= position + 1;
                LEDs <= "00000010";
              when x"06" =>
                position <= position + 1;
                LEDs <= "00000001";
              when x"07" =>
                position <= position + 1;
                LEDs <= "00010000";
              when x"08" =>
                position <= x"01";
                LEDS <= "00100000";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;

        when "111" => --1 bit clockwise circle
          if update = '1' then
            case position is
              when x"00" =>
                position <= position + 1;
                LEDs <= "00000000";
              when x"01" =>
                position <= position + 1;
                LEDs <= "00100000";
              when x"02" =>
                position <= position + 1;
                LEDs <= "00010000";
              when x"03" =>
                position <= position + 1;
                LEDs <= "00000001";
              when x"04" =>
                position <= position + 1;
                LEDs <= "00000010";
              when x"05" =>
                position <= position + 1;
                LEDs <= "00000100";
              when x"06" =>
                position <= position + 1;
                LEDs <= "00001000";
              when x"07" =>
                position <= position + 1;
                LEDs <= "10000000";
              when x"08" =>
                position <= x"01";
                LEDs <= "01000000";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;
          
        when others => --Default to flashing
          if update = '1' then
            case position is
              when x"00" =>
                position <= x"01";
                LEDs <= x"00";
              when x"01" =>
                position <= x"00";
                LEDs <= x"FF";
              when others =>
                position <= x"00";
                LEDs <= x"00";
            end case;
          end if;
      end case; --end mode case
    end if; -- end clk, reset
  end process Patterns;
end Behavioral;
