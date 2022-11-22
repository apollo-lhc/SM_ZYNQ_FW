-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief 51bit Order 49 descrambler
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief descrambler51bitOrder49 - 51bit Order 49 descrambler
ENTITY descrambler51bitOrder49 IS
   PORT (
        -- Clocks & reset
        clk_i                             : in  std_logic;
        clkEn_i                           : in  std_logic;

        reset_i                           : in  std_logic;

        -- Data
        data_i                            : in  std_logic_vector(50 downto 0);
        data_o                            : out std_logic_vector(50 downto 0);

        -- Control
        bypass                            : in  std_logic
   );
END descrambler51bitOrder49;

--! @brief descrambler51bitOrder49 ARCHITECTURE - 51bit Order 49 descrambler
ARCHITECTURE behavioral OF descrambler51bitOrder49 IS

    SIGNAL memory_register        : std_logic_vector(50 downto 0);
    SIGNAL descrambledData        : std_logic_vector(50 downto 0);

BEGIN                 --========####   Architecture Body   ####========--

    -- Scrambler output register
    reg_proc: PROCESS(clk_i, reset_i)
    BEGIN

        IF rising_edge(clk_i) THEN
            IF reset_i = '1' THEN
                descrambledData  <= (OTHERS => '0');
                memory_register  <= (OTHERS => '0');

            ELSIF clkEn_i = '1' THEN
                memory_register               <=  data_i;

                descrambledData(50 downto 49) <=  data_i(50 downto 49) xnor data_i(10 downto 9) xnor data_i(1 downto 0);
                descrambledData(48 downto 40) <=  data_i(48 downto 40) xnor data_i(8 downto 0) xnor memory_register(50 downto 42);
                descrambledData(39 downto 0)  <=  data_i(39 downto 0)  xnor memory_register(50 downto 11) xnor memory_register(41 downto 2);

            END IF;

        END IF;

    END PROCESS;

    data_o    <= descrambledData WHEN bypass = '0' ELSE
                 data_i;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--