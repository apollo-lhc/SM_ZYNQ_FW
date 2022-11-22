-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief 36bit Order 36 scrambler
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_scrambler - 36bit Order 36 scrambler
ENTITY lpgbtfpga_scrambler IS
   GENERIC (
        INIT_SEED                         : in std_logic_vector(35 downto 0)    := x"1fba847af"
   );
   PORT (
        -- Clocks & reset
        clk_i                             : in  std_logic;
        clkEn_i                           : in  std_logic;

        reset_i                           : in  std_logic;

        -- Data
        data_i                            : in  std_logic_vector(35 downto 0);
        data_o                            : out std_logic_vector(35 downto 0);

        -- Control
        bypass                            : in  std_logic
   );
END lpgbtfpga_scrambler;

--! @brief lpgbtfpga_scrambler ARCHITECTURE - 36bit Order 36 scrambler
ARCHITECTURE behavioral OF lpgbtfpga_scrambler IS

    SIGNAL scrambledData        : std_logic_vector(35 downto 0);

BEGIN                 --========####   Architecture Body   ####========--

    -- Scrambler output register
    reg_proc: PROCESS(clk_i, reset_i)
    BEGIN

        IF rising_edge(clk_i) THEN
            IF reset_i = '1' THEN
                scrambledData    <= INIT_SEED;

            ELSIF clkEn_i = '1' THEN
                scrambledData(35 downto 25) <=  data_i(35 downto 25) xnor
                                                data_i(10 downto 0)  xnor
                                                scrambledData(21 downto 11) xnor
                                                scrambledData(10 downto 0)  xnor
                                                scrambledData(35 downto 25);


                scrambledData(24 downto 0)  <=  data_i(24 downto 0) xnor
                                                scrambledData(35 downto 11) xnor
                                                scrambledData(24 downto 0);

            END IF;

        END IF;

    END PROCESS;

    data_o    <= scrambledData WHEN bypass = '0' ELSE
                 data_i;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--