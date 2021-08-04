library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AXISlaveAddrPkg is
constant AXI_ADDR_C2C2_AXI_FW : unsigned(31 downto 0) := x"B4000000";
constant AXI_ADDR_C2C2_AXILITE_FW : unsigned(31 downto 0) := x"B4010000";
constant AXI_ADDR_C2C2_PHY : unsigned(31 downto 0) := x"B4020000";
constant AXI_ADDR_C2C1_AXI_FW : unsigned(31 downto 0) := x"B4030000";
constant AXI_ADDR_C2C1_AXILITE_FW : unsigned(31 downto 0) := x"B4040000";
constant AXI_ADDR_C2C1_PHY : unsigned(31 downto 0) := x"B4050000";
constant AXI_ADDR_INT_AXI_FW : unsigned(31 downto 0) := x"B4060000";
constant AXI_ADDR_XVC_LOCAL : unsigned(31 downto 0) := x"A0000000";
constant AXI_ADDR_PL_MEM : unsigned(31 downto 0) := x"A0010000";
constant AXI_ADDR_SI : unsigned(31 downto 0) := x"A0020000";
constant AXI_ADDR_SERV : unsigned(31 downto 0) := x"A0030000";
constant AXI_ADDR_PLXVC : unsigned(31 downto 0) := x"A0040000";
constant AXI_ADDR_SLAVE_I2C : unsigned(31 downto 0) := x"A0050000";
constant AXI_ADDR_CM : unsigned(31 downto 0) := x"A0060000";
constant AXI_ADDR_SM_INFO : unsigned(31 downto 0) := x"A0070000";
constant AXI_ADDR_MONITOR : unsigned(31 downto 0) := x"A0080000";
constant AXI_ADDR_AXI_MON : unsigned(31 downto 0) := x"B4070000";
constant AXI_ADDR_MEM_TEST : unsigned(31 downto 0) := x"A00C0000";
-- ranges
constant AXI_RANGE_C2C2_AXI_FW : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_C2C2_AXILITE_FW : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_C2C2_PHY : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_C2C1_AXI_FW : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_C2C1_AXILITE_FW : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_C2C1_PHY : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_INT_AXI_FW : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_XVC_LOCAL : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_PL_MEM : unsigned(31 downto 0) :=  x"2000";
constant AXI_RANGE_SI : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_SERV : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_PLXVC : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_SLAVE_I2C : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_CM : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_SM_INFO : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_MONITOR : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_AXI_MON : unsigned(31 downto 0) :=  x"10000";
constant AXI_RANGE_MEM_TEST : unsigned(31 downto 0) :=  x"10000";
end package AXISlaveAddrPkg;
