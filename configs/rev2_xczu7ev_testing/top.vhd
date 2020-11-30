library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.AXIRegPKG.all;
 

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    ONBOARD_CLK_P     : in  std_logic;
    ONBOARD_CLK_N     : in  std_logic
    );
end entity top;

architecture structure of top is

  component onboard_CLK
    port
      (-- Clock in ports
        -- Clock out ports
        clk_200Mhz          : out    std_logic;
        clk_50Mhz          : out    std_logic;
        -- Status and control signals
        reset             : in     std_logic;
        locked            : out    std_logic;
        clk_in1_p         : in     std_logic;
        clk_in1_n         : in     std_logic
        );
  end component;


  
-- AXI BUS
  signal AXI_clk : std_logic;
  signal axi_reset_n : std_logic;
  constant PL_AXI_SLAVE_COUNT : integer := 1;
  signal AXI_BUS_RMOSI :  AXIReadMOSI_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIReadMOSI);
  signal AXI_BUS_RMISO :  AXIReadMISO_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIReadMISO);
  signal AXI_BUS_WMOSI : AXIWriteMOSI_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIWriteMOSI);
  signal AXI_BUS_WMISO : AXIWriteMISO_array_t(0 to PL_AXI_SLAVE_COUNT-1) := (others => DefaultAXIWriteMISO);

  signal AXI_MSTR_RMOSI : AXIReadMOSI;
  signal AXI_MSTR_RMISO : AXIReadMISO;
  signal AXI_MSTR_WMOSI : AXIWriteMOSI;
  signal AXI_MSTR_WMISO : AXIWriteMISO;


  signal init_clk : std_logic;
begin  -- architecture structure
  onboard_CLK_1: onboard_CLK
    port map (
      clk_200Mhz => open,
      clk_50Mhz  => init_clk,
      reset      => '0',
      locked     => open, --clk_200Mhz_locked,
      clk_in1_n  => onboard_clk_n,
      clk_in1_p  => onboard_clk_p);

  zynq_bd_wrapper_1: entity work.zynq_bd_wrapper
    port map (
      AXI_RST_N(0)         => axi_reset_n,
      AXI_CLK              => AXI_clk,

      SM_INFO_araddr          => AXI_BUS_RMOSI(0).address,
      SM_INFO_arprot          => AXI_BUS_RMOSI(0).protection_type,
      SM_INFO_arready         => AXI_BUS_RMISO(0).ready_for_address,
      SM_INFO_arvalid         => AXI_BUS_RMOSI(0).address_valid,
      SM_INFO_awaddr          => AXI_BUS_WMOSI(0).address,
      SM_INFO_awprot          => AXI_BUS_WMOSI(0).protection_type,
      SM_INFO_awready         => AXI_BUS_WMISO(0).ready_for_address,
      SM_INFO_awvalid         => AXI_BUS_WMOSI(0).address_valid,
      SM_INFO_bready          => AXI_BUS_WMOSI(0).ready_for_response,
      SM_INFO_bresp           => AXI_BUS_WMISO(0).response,
      SM_INFO_bvalid          => AXI_BUS_WMISO(0).response_valid,
      SM_INFO_rdata           => AXI_BUS_RMISO(0).data,
      SM_INFO_rready          => AXI_BUS_RMOSI(0).ready_for_data,
      SM_INFO_rresp           => AXI_BUS_RMISO(0).response,
      SM_INFO_rvalid          => AXI_BUS_RMISO(0).data_valid,
      SM_INFO_wdata           => AXI_BUS_WMOSI(0).data,
      SM_INFO_wready          => AXI_BUS_WMISO(0).ready_for_data,
      SM_INFO_wstrb           => AXI_BUS_WMOSI(0).data_write_strobe,
      SM_INFO_wvalid          => AXI_BUS_WMOSI(0).data_valid,
      init_clk                => init_clk

      );
  SM_info_1: entity work.SM_info
    port map (
      clk_axi     => axi_clk,
      reset_axi_n => axi_reset_n,
      readMOSI    => AXI_BUS_RMOSI(0),
      readMISO    => AXI_BUS_RMISO(0),
      writeMOSI   => AXI_BUS_WMOSI(0),
      writeMISO   => AXI_BUS_WMISO(0));

end architecture structure;
