library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.types.all;

entity tb_CM_pwr is
  port (
    clk     : in std_logic;
    reset   : in std_logic);

end entity tb_CM_pwr;

architecture behavioral of tb_CM_pwr is
  signal counter : integer;
  signal start_uC          : std_logic;
  signal start_PWR         : std_logic;
  signal sequence_override : std_logic;
  signal current_state     : std_logic_vector(3 downto 0);
  signal enable_uC         : std_logic;
  signal enable_PWR        : std_logic;
  signal enable_IOs        : std_logic;
  signal power_good        : std_logic;

begin  -- architecture behavioral

  tb: process (clk, reset) is
  begin  -- process tb
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
      start_uC          <= '0';
      start_PWR         <= '0';
      sequence_override <= '0';
      power_good        <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;

      case counter is
        --test normal procedure
        when 20 =>
          start_uC <= '1';
        when 30 =>
          start_PWR <= '1';
        when 50 =>
          power_good <= '1';
        when 60 =>
          start_PWR <= '0';
        when 80 =>
          power_good <= '0';

        -- power good fails after good startup
        when 120 =>
          start_uC <= '1';
        when 130 =>
          start_PWR <= '1';
        when 150 =>
          power_good <= '1';
        when 160 =>
          power_good <= '0';
          
        when others => null;
      end case;
    end if;
  end process tb;

  CM_pwr_1: entity work.CM_pwr
    port map (
      clk               => clk,
      reset             => reset,
      start_uC          => start_uC,
      start_PWR         => start_PWR,
      sequence_override => sequence_override,
      current_state     => current_state,
      enable_uC         => enable_uC,
      enable_PWR        => enable_PWR,
      enable_IOs        => enable_IOs,
      power_good        => power_good);
  
end architecture behavioral;
