library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AXISlaveAddrPkg is
constant AXI_ADDR_IRQ0_INTR_CTRL : unsigned(31 downto 0) := x"A0000000";
constant AXI_ADDR_C2C1_AXI_BRIDGE : unsigned(31 downto 0) := x"B0000000";
constant AXI_ADDR_C2C1B_AXI_LITE_BRIDGE : unsigned(31 downto 0) := x"B1000000";
constant AXI_ADDR_C2C2_AXI_BRIDGE : unsigned(31 downto 0) := x"B2000000";
constant AXI_ADDR_C2C2B_AXI_LITE_BRIDGE : unsigned(31 downto 0) := x"B3000000";
constant AXI_ADDR_C2C2_AXI_FW : unsigned(31 downto 0) := x"B4000000";
constant AXI_ADDR_C2C2_AXILITE_FW : unsigned(31 downto 0) := x"B4010000";
constant AXI_ADDR_C2C1_AXI_FW : unsigned(31 downto 0) := x"B4020000";
constant AXI_ADDR_C2C1_AXILITE_FW : unsigned(31 downto 0) := x"B4030000";
constant AXI_ADDR_INT_AXI_FW : unsigned(31 downto 0) := x"B4040000";
constant AXI_ADDR_PL_MEM : unsigned(31 downto 0) := x"A0010000";
constant AXI_ADDR_SI : unsigned(31 downto 0) := x"A0020000";
constant AXI_ADDR_SERV : unsigned(31 downto 0) := x"A0030000";
constant AXI_ADDR_PLXVC : unsigned(31 downto 0) := x"A0040000";
constant AXI_ADDR_SLAVE_I2C : unsigned(31 downto 0) := x"A0050000";
constant AXI_ADDR_CM : unsigned(31 downto 0) := x"A0060000";
constant AXI_ADDR_SM_INFO : unsigned(31 downto 0) := x"A0070000";
constant AXI_ADDR_MONITOR : unsigned(31 downto 0) := x"A0080000";
constant AXI_ADDR_AXI_MON : unsigned(31 downto 0) := x"B4050000";
constant AXI_ADDR_MEM_TEST : unsigned(31 downto 0) := x"A00C0000";
-- ranges
constant AXI_RANGE_IRQ0_INTR_CTRL : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_C2C1_AXI_BRIDGE : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_C2C1B_AXI_LITE_BRIDGE : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_C2C2_AXI_BRIDGE : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_C2C2B_AXI_LITE_BRIDGE : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_C2C2_AXI_FW : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_C2C2_AXILITE_FW : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_C2C1_AXI_FW : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_C2C1_AXILITE_FW : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_INT_AXI_FW : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_PL_MEM : unsigned(31 downto 0) :=  x"00002000";
constant AXI_RANGE_SI : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_SERV : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_PLXVC : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_SLAVE_I2C : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_CM : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_SM_INFO : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_MONITOR : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_AXI_MON : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_MEM_TEST : unsigned(31 downto 0) :=  x"00010000";
end package AXISlaveAddrPkg;
