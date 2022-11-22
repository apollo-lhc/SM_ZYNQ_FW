library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity XILINX_DNA is
  generic (
    ALLOCATED_MEMORY_RANGE : integer ;
    FPGA_GENERATION : string := "ULTRASCALE"
    );            
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    DNA             : out std_logic_vector(95 downto 0);
    DNA_valid       : out std_logic
    );
end entity XILINX_DNA;

architecture behavioral of XILINX_DNA is

  constant DNA_COUNTER_MAX : integer := 97;
  signal DNA_LOAD      : integer range 0 to DNA_COUNTER_MAX;
  signal DNA_BIT_END   : integer range 0 to DNA_COUNTER_MAX;
  constant DNA_BIT_START : integer range 0 to DNA_COUNTER_MAX := 1;
  constant DNA_IDLE      : integer range 0 to DNA_COUNTER_MAX := 0;
  signal DNA_readout_counter : integer range 0 to DNA_COUNTER_MAX;

  type DNA_SM_t is (SM_START,SM_SHIFT_OUT,SM_END,SM_IDLE);
  signal state : DNA_SM_t;
  
  signal shift_DNA : std_logic;
  signal load_DNA  : std_logic;
  signal DNA_out   : std_logic;
  signal valid : std_logic;
  signal value : std_logic_vector(DNA_COUNTER_MAX-2 downto 0);
begin  -- architecture behavioral

  
  DNA <= value;
  DNA_valid <= valid;

  dna_readout_SM: process(clk , reset) is
  begin  -- process dna_readout
    if reset = '1' then           -- asynchronous reset (active low)
      state <= SM_START;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when SM_START =>
          --Setup the readout system
          state <= SM_SHIFT_OUT;
        when SM_SHIFT_OUT =>
          --shift out and record the bits until BIT_END
          if DNA_readout_counter = DNA_BIT_END then
            state <= SM_END;
          else
            state <= SM_SHIFT_OUT;
          end if;
        when SM_END =>
          --Placeholder for any other work (currently none)
          state <= SM_IDLE;
        when others =>
          --Idle in good state (valid)
          state <= SM_IDLE;
      end case;
    end if;
  end process dna_readout_SM;
  
  dna_readout: process (clk, reset) is
  begin  -- process dna_readout
    if reset = '1' then           -- asynchronous reset (active low)
      load_DNA <= '0';
      shift_DNA <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      --Zero pulses
      load_DNA <= '0';
      shift_DNA <= '0';
      DNA_valid <= '0';

      case state is
        when SM_START =>
          --Load the DNA into the beginning of the SR in the IPCore
          load_DNA <= '1' ;
          --Start the readout counter
          DNA_readout_counter <= DNA_BIT_START;
          --Clear the SR this is going into         
          value <= (others => '0');
        when SM_SHIFT_OUT =>
          --Move along in the readout counter 
          DNA_readout_counter <= DNA_readout_counter +1;
          --Shift in the new data (MSB first)
          value(95 downto 0) <= value(94 downto 0) & dna_out;
          --Shift out the next bit
          shift_DNA <= '1';          
        when SM_IDLE =>
          DNA_valid <= '1';
        when others => null;
      end case;

    end if;
  end process dna_readout;


  ULTRASCALE_DNA: if FPGA_GENERATION = "ULTRASCALE" generate
    DNA_LOAD    <= 97;
    DNA_BIT_END <= 96;
    dna : DNA_PORTE2
    generic map (
      SIM_DNA_VALUE => X"000000000000000000000000"
      )
      port map (
        DOUT => dna_out,
        CLK => clk,
        DIN => '0',
        READ => load_DNA,
        SHIFT => shift_DNA);
  end generate ULTRASCALE_DNA;

  SERIES7_DNA: if FPGA_GENERATION = "7SERIES" generate
    DNA_LOAD    <= 65;
    DNA_BIT_END <= 64;
    dna : DNA_PORT
    generic map (
      SIM_DNA_VALUE => X"00000000000000" & B"000"
      )
      port map (
        DOUT => dna_out,
        CLK => clk,
        DIN => '0',
        READ => load_DNA,
        SHIFT => shift_DNA);
  end generate SERIES7_DNA;


end architecture behavioral;
