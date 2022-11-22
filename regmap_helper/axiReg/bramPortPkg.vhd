----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package BRAMPortPkg is
  type BRAMPortMOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : slv_32_t;
    wr_data   : slv_32_t;
   end record BRAMPortMOSI_t;
  type BRAMPortMOSI_array_t is array (integer range <>) of BRAMPortMOSI_t;
  
  type BRAMPortMISO_t is record
    rd_data   : slv_32_t;
    rd_data_valid : std_logic;
  end record BRAMPortMISO_t;
  type BRAMPortMISO_array_t is array (integer range <>) of BRAMPortMISO_t;

end package BRAMPortPkg;
