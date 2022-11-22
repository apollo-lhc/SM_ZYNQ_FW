-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Uplink descrambler
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_descrambler - Uplink descrambler
--! @details
--! The lpgbtfpga_descrambler module restores the scrambled data using the algorithm specified
--! by the lpGBT.
ENTITY lpgbtfpga_descrambler IS
   GENERIC(
        FEC                             : integer RANGE 0 to 2                  --! FEC selection can be: FEC5 or FEC12
   );
   PORT (
        -- Clock and reset
        clk_i                           : in  std_logic;                        --! Input clock USEd to decode the received data
        clkEn_i                         : in  std_logic;                        --! Clock enable USEd WHEN the input clock is different from 40MHz

        reset_i                         : in  std_logic;                        --! Uplink datapath's reset SIGNAL

        -- Data
        fec5_data_i                     : in  std_logic_vector(233 downto 0);   --! FEC5 User data input from decoder (scrambled)
        fec12_data_i                    : in  std_logic_vector(205 downto 0);   --! FEC12 User data input from decoder (scrambled)

        fec5_data_o                     : out std_logic_vector(233 downto 0);   --! FEC5 User data output (descrambled)
        fec12_data_o                    : out std_logic_vector(205 downto 0);   --! FEC12 User data output (descrambled)

        -- Control
        bypass                          : in  std_logic                         --! Bypass uplink scrambler (test purpose only)
   );
END lpgbtfpga_descrambler;

--! @brief lpgbtfpga_descrambler - Uplink descrambler
--! @details The lpgbtfpga_descrambler ARCHITECTURE instantiates 58bit and 51bit descramblers to descrambles the
--! data for all of the available configuration: FEC5 / FEC12 and DATARATE_5G12 / DATARATE_10G24
ARCHITECTURE behavioral OF lpgbtfpga_descrambler IS


    -- Components declaration
    COMPONENT descrambler60bitOrder58
       PORT (
            -- Clocks & reset
            clk_i                             : in  std_logic;
            clkEn_i                           : in  std_logic;

            reset_i                           : in  std_logic;

            -- Data
            data_i                            : in  std_logic_vector(59 downto 0);
            data_o                            : out std_logic_vector(59 downto 0);

            -- Control
            bypass                            : in  std_logic
       );
    END COMPONENT;

    COMPONENT descrambler58bitOrder58
       PORT (
            -- Clocks & reset
            clk_i                             : in  std_logic;
            clkEn_i                           : in  std_logic;

            reset_i                           : in  std_logic;

            -- Data
            data_i                            : in  std_logic_vector(57 downto 0);
            data_o                            : out std_logic_vector(57 downto 0);

            -- Control
            bypass                            : in  std_logic
       );
    END COMPONENT;

    COMPONENT descrambler51bitOrder49
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
    END COMPONENT;

    COMPONENT descrambler53bitOrder49
       PORT (
            -- Clocks & reset
            clk_i                             : in  std_logic;
            clkEn_i                           : in  std_logic;

            reset_i                           : in  std_logic;

            -- Data
            data_i                            : in  std_logic_vector(52 downto 0);
            data_o                            : out std_logic_vector(52 downto 0);

            -- Control
            bypass                            : in  std_logic
       );
    END COMPONENT;

BEGIN                 --========####   Architecture Body   ####========--

    fec5_gen: IF FEC = FEC5 GENERATE

        -- 5.12Gbps and 10.24Gbps
        descrambler58bitOrder58_l0_inst: descrambler58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(57 downto 0),
                data_o                            => fec5_data_o(57 downto 0),

                -- Control
                bypass                            => bypass
           );

        descrambler58bitOrder58_l1_inst: descrambler58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(115 downto 58),
                data_o                            => fec5_data_o(115 downto 58),

                -- Control
                bypass                            => bypass
           );

        -- 10.24Gbps only
        descrambler58bitOrder58_h0_inst: descrambler58bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(173 downto 116),
                data_o                            => fec5_data_o(173 downto 116),

                -- Control
                bypass                            => bypass
           );

        descrambler60bitOrder58_h1_inst: descrambler60bitOrder58
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec5_data_i(233 downto 174),
                data_o                            => fec5_data_o(233 downto 174),

                -- Control
                bypass                            => bypass
           );

    END GENERATE;

    fec12_gen: IF FEC = FEC12 GENERATE

        -- 5.12Gbps and 10.24Gbps
        descrambler51bitOrder49_l0_inst: descrambler51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(50 downto 0),
                data_o                            => fec12_data_o(50 downto 0),

                -- Control
                bypass                            => bypass
           );

        descrambler51bitOrder49_l1_inst: descrambler51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(101 downto 51),
                data_o                            => fec12_data_o(101 downto 51),

                -- Control
                bypass                            => bypass
           );

        -- 10.24Gbps only
        descrambler51bitOrder49_h0_inst: descrambler51bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(152 downto 102),
                data_o                            => fec12_data_o(152 downto 102),

                -- Control
                bypass                            => bypass
           );

        descrambler53bitOrder49_h1_inst: descrambler53bitOrder49
           PORT MAP (
                -- Clocks & reset
                clk_i                             => clk_i,
                clkEn_i                           => clkEn_i,

                reset_i                           => reset_i,

                -- Data
                data_i                            => fec12_data_i(205 downto 153),
                data_o                            => fec12_data_o(205 downto 153),

                -- Control
                bypass                            => bypass
           );

    END GENERATE;

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--