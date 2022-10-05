library ieee;
use ieee.std_logic_1164.all;
-- timestamp package
package FW_TIMESTAMP is
  constant TS_CENT     : std_logic_vector(7 downto 0) := x"20";
  constant TS_YEAR     : std_logic_vector(7 downto 0) := x"22";
  constant TS_MONTH    : std_logic_vector(7 downto 0) := x"10";
  constant TS_DAY      : std_logic_vector(7 downto 0) := x"03";
  constant TS_HOUR     : std_logic_vector(7 downto 0) := x"15";
  constant TS_MIN      : std_logic_vector(7 downto 0) := x"25";
  constant TS_SEC      : std_logic_vector(7 downto 0) := x"48";
end package FW_TIMESTAMP;
 
 
library ieee;
use ieee.std_logic_1164.all;
-- fw version package
package FW_VERSION is
  constant FW_HASH_VALID : std_logic                      := '1';
  constant FW_HASH_1     : std_logic_vector(31 downto  0) := x"e4fa0b79";
  constant FW_HASH_2     : std_logic_vector(31 downto  0) := x"fef52e7d";
  constant FW_HASH_3     : std_logic_vector(31 downto  0) := x"c915bc16";
  constant FW_HASH_4     : std_logic_vector(31 downto  0) := x"f52c0202";
  constant FW_HASH_5     : std_logic_vector(31 downto  0) := x"18ba89b8";
end package FW_VERSION;
 
 
library ieee;
use ieee.std_logic_1164.all;
-- fw FPGA package
package FW_FPGA is
  constant FPGA_TYPE     : string(1 to 32)       := "             xczu7ev-fbvb900-2-i";
end package FW_FPGA;
