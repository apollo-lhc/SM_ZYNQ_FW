library ieee;
use ieee.std_logic_1164.all;
-- timestamp package
package FW_TIMESTAMP is
  constant TS_CENT     : std_logic_vector(7 downto 0) := x"20";
  constant TS_YEAR     : std_logic_vector(7 downto 0) := x"22";
  constant TS_MONTH    : std_logic_vector(7 downto 0) := x"11";
  constant TS_DAY      : std_logic_vector(7 downto 0) := x"18";
  constant TS_HOUR     : std_logic_vector(7 downto 0) := x"13";
  constant TS_MIN      : std_logic_vector(7 downto 0) := x"08";
  constant TS_SEC      : std_logic_vector(7 downto 0) := x"20";
end package FW_TIMESTAMP;
 
 
library ieee;
use ieee.std_logic_1164.all;
-- fw version package
package FW_VERSION is
  constant FW_HASH_VALID : std_logic                      := '1';
  constant FW_HASH_1     : std_logic_vector(31 downto  0) := x"8ec8c6a8";
  constant FW_HASH_2     : std_logic_vector(31 downto  0) := x"e17de8af";
  constant FW_HASH_3     : std_logic_vector(31 downto  0) := x"7646e986";
  constant FW_HASH_4     : std_logic_vector(31 downto  0) := x"905d52e0";
  constant FW_HASH_5     : std_logic_vector(31 downto  0) := x"bfefd2c3";
end package FW_VERSION;
 
 
library ieee;
use ieee.std_logic_1164.all;
-- fw FPGA package
package FW_FPGA is
  constant FPGA_TYPE     : string(1 to 32)       := "                 xc7z035fbg676-1";
end package FW_FPGA;
