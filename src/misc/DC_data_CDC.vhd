-------------------------------------------------------------------------------
-- Pass std_logic_vector between clocks
-- Dan Gastler
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity DC_data_CDC is
  generic(
    DATA_WIDTH : integer := 32
    );
  port (
    clk_in   : in  std_logic; 
    clk_out  : in  std_logic;
    reset    : in  std_logic; --async
    pass_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    pass_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity DC_data_CDC;

architecture behavioral of DC_data_CDC is

  signal pass_in_local    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal pass_out_local_1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal pass_out_local_2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of pass_out_local_1 : signal is "yes";
  attribute ASYNC_REG of pass_out_local_2 : signal is "yes";
  attribute SHREG_EXTRACT : string;
  attribute SHREG_EXTRACT of pass_out_local_1: signal is "no";
  attribute SHREG_EXTRACT of pass_out_local_2: signal is "no";


begin  -- architecture behavioral

  -- buffer the input on the input clock's domain
  buffer_clk_in: process (clk_in, reset) is
  begin  -- process buffer_clk_in
    if reset = '1' then                 -- asynchronous reset (active high)
      pass_in_local <= (others => '0');
    elsif clk_in'event and clk_in = '1' then  -- rising clock edge
      pass_in_local <= pass_in;
    end if;
  end process buffer_clk_in;

  buffer_clk_out: process (clk_out, reset) is
  begin  -- process buffer_clk_out
    if reset = '1' then                 -- asynchronous reset (active high)
      pass_out_local_1 <= (others => '0');
      pass_out_local_2 <= (others => '0');
    elsif clk_out'event and clk_out = '1' then  -- rising clock edge
      pass_out_local_1 <= pass_in_local;
      pass_out_local_2 <= pass_out_local_1;
    end if;
  end process buffer_clk_out;

  pass_out <= pass_out_local_2;
end architecture behavioral;

