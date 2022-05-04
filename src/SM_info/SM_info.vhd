library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.FW_TIMESTAMP.all;
use work.FW_VERSION.all;
use work.FW_FPGA.all;
use work.SM_INFO_Ctrl.all;


Library UNISIM;
use UNISIM.vcomponents.all;


entity SM_info is
  generic (
    ALLOCATED_MEMORY_RANGE : integer
    );            
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO
    );
end entity SM_info;

architecture behavioral of SM_info is
  signal Mon              :  SM_INFO_Mon_t;

  constant DNA_LOAD      : integer range 0 to 97       := 97;
  constant DNA_BIT_END   : integer range 0 to DNA_LOAD := 96;
  constant DNA_BIT_START : integer range 0 to DNA_LOAD := 1;
  constant DNA_IDLE      : integer range 0 to DNA_LOAD := 0;
  signal DNA_readout_counter : integer range 0 to DNA_LOAD;
  signal shift_DNA : std_logic;
  signal load_DNA  : std_logic;
  signal DNA_out   : std_logic;
  signal DNA_valid : std_logic;
  signal DNA_value : std_logic_vector(DNA_BIT_END-1 downto 0);
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  SM_INFO_interface_1: entity work.SM_INFO_map
    generic map(
      ALLOCATED_MEMORY_RANGE => ALLOCATED_MEMORY_RANGE
      )              
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon);

  Mon.GIT_VALID                     <= FW_HASH_VALID;
  Mon.GIT_HASH_1                    <= FW_HASH_1;
  Mon.GIT_HASH_2                    <= FW_HASH_2;
  Mon.GIT_HASH_3                    <= FW_HASH_3;
  Mon.GIT_HASH_4                    <= FW_HASH_4;
  Mon.GIT_HASH_5                    <= FW_HASH_5;
  Mon.BUILD_DATE.DAY                <= TS_DAY;
  Mon.BUILD_DATE.MONTH              <= TS_MONTH;
  Mon.BUILD_DATE.YEAR( 7 downto  0) <= TS_YEAR;
  Mon.BUILD_DATE.YEAR(15 downto  8) <= TS_CENT;
  Mon.BUILD_TIME.SEC                <= TS_SEC;
  Mon.BUILD_TIME.MIN                <= TS_MIN;
  Mon.BUILD_TIME.HOUR               <= TS_HOUR;
  Mon.FPGA.WORD_00(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 4)),8));
  Mon.FPGA.WORD_00(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 3)),8));
  Mon.FPGA.WORD_00(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 2)),8));
  Mon.FPGA.WORD_00( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 1)),8));
  Mon.FPGA.WORD_01(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 8)),8));
  Mon.FPGA.WORD_01(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 7)),8));
  Mon.FPGA.WORD_01(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 6)),8));
  Mon.FPGA.WORD_01( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 5)),8));
  Mon.FPGA.WORD_02(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(12)),8)); 
  Mon.FPGA.WORD_02(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(11)),8)); 
  Mon.FPGA.WORD_02(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(10)),8)); 
  Mon.FPGA.WORD_02( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 9)),8));
  Mon.FPGA.WORD_03(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(16)),8)); 
  Mon.FPGA.WORD_03(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(15)),8)); 
  Mon.FPGA.WORD_03(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(14)),8)); 
  Mon.FPGA.WORD_03( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(13)),8));
  Mon.FPGA.WORD_04(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(20)),8)); 
  Mon.FPGA.WORD_04(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(19)),8)); 
  Mon.FPGA.WORD_04(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(18)),8)); 
  Mon.FPGA.WORD_04( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(17)),8));
  Mon.FPGA.WORD_05(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(24)),8)); 
  Mon.FPGA.WORD_05(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(23)),8)); 
  Mon.FPGA.WORD_05(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(22)),8)); 
  Mon.FPGA.WORD_05( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(21)),8));
  Mon.FPGA.WORD_06(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(28)),8)); 
  Mon.FPGA.WORD_06(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(27)),8)); 
  Mon.FPGA.WORD_06(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(26)),8)); 
  Mon.FPGA.WORD_06( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(25)),8));
  Mon.FPGA.WORD_07(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(32)),8)); 
  Mon.FPGA.WORD_07(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(31)),8)); 
  Mon.FPGA.WORD_07(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(30)),8)); 
  Mon.FPGA.WORD_07( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(29)),8));
  
  Mon.DNA.valid <= DNA_valid;
  Mon.DNA.WORD_0 <= DNA_value(31 downto  0);
  Mon.DNA.WORD_1 <= DNA_value(63 downto 32);
  Mon.DNA.WORD_2 <= DNA_value(95 downto 64);
  dna_readout: process (clk_axi, reset_axi_n) is
  begin  -- process dna_readout
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      DNA_readout_counter <= DNA_LOAD;
      load_DNA <= '0';
      shift_DNA <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      load_DNA <= '0';
      shift_DNA <= '0';
      DNA_valid <= '0';
      case DNA_readout_counter is
        when DNA_LOAD =>
          load_DNA <= '1' ;
          DNA_readout_counter <= DNA_readout_counter -1;
        when DNA_BIT_START to DNA_BIT_END =>
          --shift in the DNA value
          DNA_value(95 downto 0) <= DNA_value(94 downto 0) & dna_out;
          shift_DNA <= '1';
          DNA_readout_counter <= DNA_readout_counter -1;
        when DNA_IDLE =>
          DNA_valid <= '1';
        when others => null;
      end case;
    end if;
  end process dna_readout;
  dna : DNA_PORTE2
    generic map (
      SIM_DNA_VALUE => X"000000000000000000000000"
      )
    port map (
      DOUT => dna_out,
      CLK => clk_axi,
      DIN => '0',
      READ => load_DNA,
      SHIFT => shift_DNA);
  
end architecture behavioral;
