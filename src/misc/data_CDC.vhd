library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity data_CDC is
  
  generic (
    WIDTH : integer := 16);
  port (
    clkA       : in  std_logic;
    resetA     : in  std_logic;
    clkB       : in  std_logic;
    resetB     : in  std_logic;
    inA        : in  std_logic_vector(WIDTH-1 downto 0);
    inA_valid  : in  std_logic;
    outB       : out std_logic_vector(WIDTH-1 downto 0);
    outB_valid : out std_logic);
end entity data_CDC;


architecture behavioral of data_CDC is

  --- clkA
  signal iPulseA : std_logic;
  signal inA_valid_last : std_logic;
  signal captureA : std_logic_vector(WIDTH-1 downto 0);
  
  -- clkB
  type capture_SR_t is array (1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  signal captureB : capture_SR_t;
  signal oPulseB : std_logic;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of captureB : signal is "yes";
  attribute SHREG_EXTRACT : string;
  attribute SHREG_EXTRACT of captureB: signal is "no";

  
begin  -- architecture behavioral
  pacd_1: entity work.pacd
    port map (
      iPulseA => iPulseA,
      iClkA   => clkA,
      iRSTA   => resetA,
      iClkB   => clkB,
      iRSTB   => resetB,
      oPulseB => oPulseB);

  capture: process (clkA) is
  begin  -- process capture
    if clkA'event and clkA = '1' then  -- rising clock edge
      --zero pulse
      iPulseA <= '0';

      --make sure valid is force to be a pulse
      inA_valid_last <= inA_valid;
      if inA_valid = '1' then
        --capture input
        captureA <= inA;
        iPulseA <= '1';
      end if;
    end if;
  end process capture;

  display: process (clkB) is
  begin  -- process display
    if clkB'event and clkB = '1' then  -- rising clock edge
      --shift register to transfer to clkB domain
      captureB <= captureB(captureB'left -1 downto 0) & captureA;
      --Add an extra clock to iPulseB
--      outB_valid <= oPulseB;
    end if;
  end process display;
  outB_valid <= oPulseB;
  outB <= captureB(captureB'left);
  
end architecture behavioral;
