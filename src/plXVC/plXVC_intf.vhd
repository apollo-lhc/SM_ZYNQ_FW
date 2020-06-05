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
    IRQ_LENGTH  : integer :=1); --Length of IRQ in axi_clk ticks
  port (
    --signals for plXVC_interface
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIReadMOSI;
    readMISO    : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI   : in  AXIWriteMOSI;
    writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;

    --signals for in out to virtualJTAG module
    TMS         : out std_logic_vector((COUNT - 1) downto 0);
    TDI         : out std_logic_vector((COUNT - 1) downto 0);
    TDO         : in  std_logic_vector((COUNT - 1) downto 0);
    TCK         : out std_logic_vector((COUNT - 1) downto 0));
end entity plXVC_intf;

architecture behavioral of plXVC_intf is

  -- *** Monitor record *** --
  signal Mon            : plXVC_Mon_t;
  signal Mon_BUSY       : std_logic_vector((COUNT - 1) downto 0);
  signal Mon_TDO_VECTOR : slv32_array_t(1 to COUNT); --Array of 32bit vectors

  -- *** Control record *** --
  signal Ctrl   : plXVC_Ctrl_t;

  -- *** For reset *** ---
  signal reset  : std_logic;
  
begin

--Instansiate plXVC_interface Module
  plXVC_interface_1: entity work.plXVC_interface
    port map (
      clk_axi             => clk_axi,     --AXI_clk in
      reset_axi_n         => reset_axi_n, --AXI_reset in
      slave_readMOSI      => readMOSI,    --read MOSI in
      slave_readMISO      => readMISO,    --read MISO out
      slave_writeMOSI     => writeMOSI,   --write MOSI in
      slave_writeMISO     => writeMISO,   --write MISO out
      Mon                 => Mon,         --Monitor in
      Ctrl                => Ctrl);       --Ctrl out
  
  --invert reset for virtualJTAG module
  reset <= not reset_axi_n;

--Generate loop
  GENERATE_JTAG: for I in 1 to COUNT generate

--Create virtualJTAG modules
    virtualJTAG_X: entity work.virtualJTAG
      generic map(
        --TCK_RATIO => TCK_RATIO,
        IRQ_LENGTH => IRQ_LENGTH)
      port map (
        axi_clk   => clk_axi,
        reset     => reset,
        TMS_vector => Ctrl.XVC(I).TMS_VECTOR,
        TDI_vector => Ctrl.XVC(I).TDI_VECTOR,
        TDO       => TDO(I - 1),
        length  => Ctrl.XVC(I).LENGTH,
        CTRL => Ctrl.XVC(I).GO,
        TMS => TMS(I - 1),
        TDI => TDI(I - 1),
        TDO_vector => MON_TDO_VECTOR(I),
        TCK       => TCK(I - 1),
        busy      => MON_BUSY(I - 1),
        interupt => open);

    --Assign monitor signals
    Mon.XVC(I).BUSY <= MON_BUSY(I - 1);
    mon.XVC(I).TDO_VECTOR <= MON_TDO_VECTOR(I);
    
  end generate GENERATE_JTAG;


--  virtualJTAG_1: entity work.virtualJTAG
--    generic map (
--      --TCK_RATIO => TCK_RATIO,           --ratio of axi_clk to TCK
--      IRQ_LENGTH => IRQ_LENGTH)           --Length of IRQ in axi_clk ticks
--    port map (
--      axi_clk     => clk_axi,             --Input clk
--      reset       => reset,               --reset
--      TMS_vector  => Ctrl.TMS_VECTOR,     --axi tms input
--      TDI_vector  => Ctrl.TDI_VECTOR,     --axi tdi input
--      TDO         => TDO,                 --JTAG tdo input from programmable logic
--      length      => Ctrl.LENGTH,         --lenght of operation in bits
--      CTRL        => Ctrl.GO,             --Enable operation
--      TMS         => TMS,                 --JTAG tms output to programmable logic
--      TDI         => TDI,                 --JTAG tdi output to programmable logic
--      TDO_vector  => MON_TDO_VECTOR,      --axi tdo output
--      TCK         => TCK,                 --JTAG output TCK to programmable logic
--      busy        => MON_BUSY,            --virtualJTAG is outputting
--      interupt    => open);               --interupt, open for now TO BE IMPLEMENTED!!!


----Assign Monitor signals
--  Mon.BUSY <= MON_BUSY;
--  Mon.TDO_VECTOR <= MON_TDO_VECTOR;

end architecture behavioral;
