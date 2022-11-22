-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA IP - Common package
-------------------------------------------------------

-- IEEE VHDL standard LIBRARY:
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE lpgbtfpga_package is

   --=============================== Constant Declarations ===============================--
	CONSTANT FEC5						  : integer := 1;
	CONSTANT FEC12						  : integer := 2;
	CONSTANT DATARATE_5G12				  : integer := 1;
	CONSTANT DATARATE_10G24				  : integer := 2;
	CONSTANT PCS         				  : integer := 0;
	CONSTANT PMA         				  : integer := 1;
   --=====================================================================================--

END lpgbtfpga_package;