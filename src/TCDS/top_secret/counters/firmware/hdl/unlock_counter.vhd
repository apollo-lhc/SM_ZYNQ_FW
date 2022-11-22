--======================================================================
-- Simple counter for unlock (i.e., '1' -> '0') events. Rolls over to 1
-- instead of 0 to avoid false negatives.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==================================================

entity unlock_counter is

  generic (
    G_WIDTH : positive := 32
  );

  port (
    clk : in std_logic;
    rst : in std_logic;

    locked : in std_logic;

    unlock_count : out std_logic_vector(G_WIDTH - 1 downto 0)
  );

end unlock_counter;

--==================================================

architecture arch of unlock_counter is

  constant max_count : unsigned(G_WIDTH - 1 downto 0) := (others => '1');
  signal count : unsigned(G_WIDTH - 1 downto 0);
  signal locked_d : std_logic;

begin

  cnt : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        count <= (others => '0');
      else
        if locked = '0' and locked_d = '1' then
          if count = max_count then
            count <= to_unsigned(1, count'length);
          else
            count <= count + 1;
          end if;
        else
          count <= count;
        end if;
      end if;
      locked_d <= locked;
    end if;
  end process;

  unlock_count <= std_logic_vector(count);

end arch;

--======================================================================
