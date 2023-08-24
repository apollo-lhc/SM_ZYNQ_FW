----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package FIFOPortPkg is
  type FIROPortMOSI_t is record
    clk       : std_logic;
    rd_enable : std_logic;
    reset     : std_logic;
    wr_enable : std_logic;
    wr_data   : slv_32_t;
   end record FIFOPortMOSI_t;
  type FIFOPortMOSI_array_t is array (integer range <>) of FIFOPortMOSI_t;

  type FIFOPortMISO_t is record
    rd_data   : slv_32_t;
    rd_data_valid : std_logic;
    rd_error  : std_logic;
    wr_error  : std_logic;
    wr_response  : std_logic;
  end record FIFOPortMISO_t;
  type FIFOPortMISO_array_t is array (integer range <>) of FIFOPortMISO_t;

end package FIFOPortPkg;