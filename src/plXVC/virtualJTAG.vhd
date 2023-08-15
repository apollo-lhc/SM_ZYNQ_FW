library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --maybe don't need

use work.types.all; --maybe don't need
use work.AXIRegPkg.all; --for AXIReadMOSI, AXIReadMISO, AXIWriteMOSI, and AXIWriteMISO
use work.plXVC_CTRL.all; --for plXVC_MON_t and plXVC_CTRL_t

entity plXVC_intf is
  generic (
    --TCK_RATIO : integer := 1; --ratio of axi_clk to TCK
    COUNT       : integer :=2;  --Number of plXVCs inside of array
    IRQ_LENGTH  : integer :=1;  --Length of IRQ in axi_clk ticks
    IRQ_ENABLE  : std_logic := '1';
    ALLOCATED_MEMORY_RANGE : integer :=1);            
  port (
    --signals for plXVC_interface
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIReadMOSI;
    readMISO    : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI   : in  AXIWriteMOSI;
    writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    IRQ         : out std_logic_vector((COUNT - 1) downto 0); --interupt request
    --signals for in out to virtualJTAG module
    TMS         : out std_logic_vector((COUNT - 1) downto 0);
    TDI         : out std_logic_vector((COUNT - 1) downto 0);
    TCK         : out std_logic_vector((COUNT - 1) downto 0);
    PS_RST      : out std_logic_vector((COUNT - 1) downto 0);
    -- for FIFO
    FIFO_full   : out std_logic_vector((COUNT - 1) downto 0);
    FIFO_overflow : out std_logic_vector((COUNT - 1) downto 0);
    BUS_ERROR   : out std_logic_vector((COUNT - 1) downto 0);
    --for testing, delete later
    Ctrl        : in PLXVC_Ctrl_t;
    Mon         : out PLXVC_Mon_t
    );
end entity plXVC_intf;

architecture behavioral of plXVC_intf is

  -- *** Monitor record *** --
  --signal Mon            : PLXVC_Mon_t;
  signal Mon_BUSY       : std_logic_vector((COUNT - 1) downto 0);
  --signal Mon_TDO_VECTOR : slv32_array_t(1 to COUNT); --Array of 32bit vectors

  -- *** Control record *** --
  --signal Ctrl    : PLXVC_Ctrl_t;

  -- *** For reset *** ---
  signal reset   : std_logic;

  ---*** For FIFO ***---
  signal FIFO         : PLXVC_Ctrl_t;
  signal f_state      : slv7_array_t(1 to COUNT);
  signal TMS_valid    : std_logic;
  signal TDI_valid    : std_logic;
  signal l_valid      : std_logic;
  signal v_interrupt  : std_logic_vector((COUNT - 1) downto 0);

  ---*** For MUX ***---
  signal MUX     : PLXVC_Ctrl_t;
  
begin

--Instansiate plXVC_interface Module
--  PLXVC_interface_1: entity work.PLXVC_map
--    generic map(
--      ALLOCATED_MEMORY_RANGE => ALLOCATED_MEMORY_RANGE
--      )
--    port map (
--      clk_axi             => clk_axi,     --AXI_clk in
--      reset_axi_n         => reset_axi_n, --AXI_reset in
--      slave_readMOSI      => readMOSI,    --read MOSI in
--      slave_readMISO      => readMISO,    --read MISO out
--      slave_writeMOSI     => writeMOSI,   --write MOSI in
--      slave_writeMISO     => writeMISO,   --write MISO out
--      Mon                 => Mon,         --Monitor in
--      Ctrl                => Ctrl);       --Ctrl out
  
  --invert reset for virtualJTAG module
  reset <= not reset_axi_n;

--Generate loop
  GENERATE_JTAG: for I in 1 to COUNT generate
  
    JTAG_FIFO_X: entity work.JTAG_FIFO
        port map (
        axi_clk => clk_axi,
        reset => reset,
        virtual_busy => MON_BUSY(I - 1),
        virtual_interrupt => v_interrupt(I-1),
        valid => '1',
        TMS_valid_in => TMS_valid,
        TDI_valid_in => TDI_valid,
        length_valid_in => l_valid,
        TMS_vector => Ctrl.XVC(I).TMS_VECTOR,
        TDI_vector => Ctrl.XVC(I).TDI_VECTOR,
        length  => Ctrl.XVC(I).LENGTH,
        TMS_vector_out => FIFO.XVC(I).TMS_VECTOR,
        TDI_vector_out => FIFO.XVC(I).TDI_VECTOR,
        Length_out => FIFO.XVC(I).LENGTH,
        go => FIFO.XVC(I).GO,
        CTRL => Ctrl.XVC(I).GO,
        FIFO_STATE => f_state(I),
        FIFO_IRQ => IRQ(I - 1),
        BUS_ERROR => BUS_ERROR(I - 1));
  
     stateDecoder: process (clk_axi, reset)
     begin
     if (reset = '1') then
        FIFO_full(I-1) <= '0';
        FIFO_overflow(I-1) <= '0';
     elsif (clk_axi'event and clk_axi='1') then
       case f_state(I) is 
         when b"0000001" =>
           FIFO_full(I-1) <= '1';
         when b"0010000" =>
           FIFO_overflow(I-1) <= '1';
         when others =>
           FIFO_full(I-1) <= '0';
           FIFO_overflow(I-1) <= '0';
       end case;
      end if;
     end process stateDecoder;

  MUX_X: entity work.MUX
        port map (
        axi_clk => clk_axi,
        reset => reset,
        fifo_enable => '1',
        FIFO => FIFO.XVC(I),
        CTRL_in => CTRL.XVC(I),
        CTRL_out => MUX.XVC(I));
    
    
--Create virtualJTAG modules
    virtualJTAG_X: entity work.virtualJTAG
      generic map(
        --TCK_RATIO => TCK_RATIO,
        IRQ_LENGTH => IRQ_LENGTH)
      port map (
        axi_clk   => clk_axi,
        reset     => reset,
        TMS_vector => MUX.XVC(I).TMS_VECTOR,
        TDI_vector => MUX.XVC(I).TDI_VECTOR,
        length  => MUX.XVC(I).LENGTH,
        CTRL => MUX.XVC(I).GO,
        TMS => TMS(I - 1),
        TDI => TDI(I - 1),
        TCK       => TCK(I - 1),
        busy      => MON_BUSY(I - 1),
        interupt => v_interrupt(I-1));
    PS_RST(I-1) <= 'Z' when Ctrl.XVC(I).PS_RST = '1' else '0';
    --Assign monitor signals
    Mon.XVC(I).BUSY <= MON_BUSY(I - 1);
    --mon.XVC(I).TDO_VECTOR <= MON_TDO_VECTOR(I);
    
  end generate GENERATE_JTAG;
end architecture behavioral;
