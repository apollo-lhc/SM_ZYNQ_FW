-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Downlink Encoder (FEC)
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_encoder - Downlink FEC encoder
--! @details computes the FEC bus USEd by the decoder to correct errors. It
--! is based on the N=7, K=5 and SymbWidth=3 implementation of the Reed-Solomon
--! scheme.
ENTITY lpgbtfpga_encoder IS
   PORT (
		-- Data
		data_i							: in  std_logic_vector(35 downto 0);
		FEC_o							: out std_logic_vector(23 downto 0);

		-- Control
		bypass							: in  std_logic
   );
END lpgbtfpga_encoder;

--! @brief lpgbtfpga_encoder - Downlink FEC encoder
--! @details The lpgbtfpga_encoder module instantiates 4 times the Reed-Solomon
--! N7K5 module WHEN each of them allows correcting a symbol of 3 bits over the
--! 15 of the input message. Additionally, to make the encoding stronger, only
--! 9 bits of each input message are USEd for the lpGBT.
ARCHITECTURE behavioral OF lpgbtfpga_encoder IS

	SIGNAL virtualFrame_C0		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C1		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C2		: std_logic_vector(14 downto 0);
	SIGNAL virtualFrame_C3		: std_logic_vector(14 downto 0);

	SIGNAL FEC_s				: std_logic_vector(23 downto 0);

	--! Reed-Solomon N7K5 encoding component
	COMPONENT rs_encoder_N7K5
	   GENERIC (
			N								: integer := 7;
			K 								: integer := 5;
			SYMB_BITWIDTH					: integer := 3
	   );
	   PORT (
			-- Data
			msg								: in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
			parity							: out std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0)
	   );
	END COMPONENT;

BEGIN                 --========####   Architecture Body   ####========--

	virtualFrame_C0	<= "000000" & data_i(8 downto 0);
	virtualFrame_C1	<= "000000" & data_i(17 downto 9);
	virtualFrame_C2	<= "000000" & data_i(26 downto 18);
	virtualFrame_C3	<= "000000" & data_i(35 downto 27);

	--! Reed-Solomon N7K5 encoder (encodes data_i(8 downto 0))
	RSE0_inst: rs_encoder_N7K5
	PORT MAP (
		msg				=> virtualFrame_C0,
		parity			=> FEC_s(5 downto 0)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(17 downto 9))
	RSE1_inst: rs_encoder_N7K5
	PORT MAP (
		msg				=> virtualFrame_C1,
		parity			=> FEC_s(11 downto 6)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(26 downto 18))
	RSE2_inst: rs_encoder_N7K5
	PORT MAP (
		msg				=> virtualFrame_C2,
		parity			=> FEC_s(17 downto 12)
	);

	--! Reed-Solomon N7K5 encoder (encodes data_i(35 downto 27))
	RSE3_inst: rs_encoder_N7K5
	PORT MAP (
		msg				=> virtualFrame_C3,
		parity			=> FEC_s(23 downto 18)
	);

	FEC_o 	<= 	FEC_s WHEN bypass = '0' ELSE (OTHERS => '0');

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--