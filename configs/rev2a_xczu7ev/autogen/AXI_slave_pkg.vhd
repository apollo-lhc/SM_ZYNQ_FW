library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AXISlaveAddrPkg is
constant AXI_ADDR_PL_MEM : unsigned(31 downto 0) := x"A0000000";
constant AXI_ADDR_SI : unsigned(31 downto 0) := x"A1600000";
constant AXI_ADDR_SERV : unsigned(31 downto 0) := x"A3C20000";
constant AXI_ADDR_PLXVC : unsigned(31 downto 0) := x"A0010000";
constant AXI_ADDR_SLAVE_I2C : unsigned(31 downto 0) := x"A0008000";
constant AXI_ADDR_CM : unsigned(31 downto 0) := x"A000A000";
constant AXI_ADDR_SM_INFO : unsigned(31 downto 0) := x"A000C000";
constant AXI_ADDR_MONITOR : unsigned(31 downto 0) := x"A0040000";
constant AXI_ADDR_AXI_MON : unsigned(31 downto 0) := x"B0000000";
constant AXI_ADDR_TCDS_2 : unsigned(31 downto 0) := x"A0170000";
constant AXI_ADDR_LDAQ : unsigned(31 downto 0) := x"A0180000";
-- ranges
constant AXI_RANGE_PL_MEM : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_SI : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_SERV : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_PLXVC : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_SLAVE_I2C : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_CM : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_SM_INFO : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_MONITOR : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_AXI_MON : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_TCDS_2 : unsigned(31 downto 0) :=  x"1000";
constant AXI_RANGE_LDAQ : unsigned(31 downto 0) :=  x"1000";
end package AXISlaveAddrPkg;
