-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Uplink datapath
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_decoder - Uplink FEC decoder
--! @details Decodes the received data and corrects error WHEN possible. The decoding
--! is based on the N=31, K=29 and SymbWidth=5 or the N=15, K=13 and SymbWidth=4
--! implementation of the Reed-Solomon scheme depending on the configuration (FEC5 or FEC12).
ENTITY lpgbtfpga_decoder IS
   GENERIC(
        DATARATE                        : integer RANGE 0 TO 2;                   --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
        FEC                             : integer RANGE 0 TO 2                    --! FEC selection can be: FEC5 or FEC12
   );
   PORT (
        -- Clock
        uplinkClk_i                     : in  std_logic;
        uplinkClkInEn_i                 : in  std_logic;
        uplinkClkOutEn_i                : in  std_logic;

        -- Data
        fec5_data_i                     : in  std_logic_vector(233 downto 0);     --! Data input from de-interleaver for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
        fec5_fec_i                      : in  std_logic_vector(19 downto 0);      --! FEC input from de-interleaver for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
        fec12_data_i                    : in  std_logic_vector(205 downto 0);     --! Data input from de-interleaver for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
        fec12_fec_i                     : in  std_logic_vector(47 downto 0);      --! FEC input from de-interleaver for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)

        fec5_data_o                     : out std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
        fec12_data_o                    : out std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)

        fec5_correction_pattern_o       : out std_logic_vector(233 downto 0);
        fec12_correction_pattern_o      : out std_logic_vector(205 downto 0);

        -- Control
        bypass                          : in  std_logic                           --! Bypass uplink FEC (test purpose only)
   );
END lpgbtfpga_decoder;

--! @brief lpgbtfpga_decoder - Uplink FEC decoder
--! @details The lpgbtfpga_decoder module instantiates the Reed-Solomon N31K29 and N15K13
--! modules to correct errors for both FEC5 and FEC12 configuration. Only the required logic is USEd WHEN
--! the DATARATE is configured to run at 5.12gbps.
ARCHITECTURE behavioral OF lpgbtfpga_decoder IS


    -- N31K29 decoder component
    COMPONENT rs_decoder_N31K29
       GENERIC (
            N								: integer := 31;
            K 								: integer := 29;
            SYMB_BITWIDTH					: integer := 5
       );
       PORT (
            payloadData_i                   : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
            fecData_i                       : in  std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0);

            data_o                          : out std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0)
       );
    END COMPONENT;

    -- N15K13 decoder component
    COMPONENT rs_decoder_N15K13
       GENERIC (
            N								: integer := 15;
            K 								: integer := 13;
            SYMB_BITWIDTH					: integer := 4
       );
       PORT (
            payloadData_i                   : in  std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0);
            fecData_i                       : in  std_logic_vector(((N-K)*SYMB_BITWIDTH)-1 downto 0);

            data_o                          : out std_logic_vector((K*SYMB_BITWIDTH)-1 downto 0)
       );
    END COMPONENT;

    -- Signals
    SIGNAL fec5_encoded_code0_s           : std_logic_vector(144 downto 0);   --! FEC5 encoded data (code 0)
    SIGNAL fec5_encoded_code1_s           : std_logic_vector(144 downto 0);   --! FEC5 encoded data (code 1)

    SIGNAL fec5_decoded_code0_s           : std_logic_vector(144 downto 0);   --! FEC5 decoded data (code 0)
    SIGNAL fec5_decoded_code1_s           : std_logic_vector(144 downto 0);   --! FEC5 decoded data (code 1)

    SIGNAL fec12_encoded_code0_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 0)
    SIGNAL fec12_encoded_code1_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 1)
    SIGNAL fec12_encoded_code2_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 2)
    SIGNAL fec12_encoded_code3_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 3)
    SIGNAL fec12_encoded_code4_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 4)
    SIGNAL fec12_encoded_code5_s          : std_logic_vector(51 downto 0);    --! FEC12 encoded data (code 5)

    SIGNAL fec12_decoded_code0_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 0)
    SIGNAL fec12_decoded_code1_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 1)
    SIGNAL fec12_decoded_code2_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 2)
    SIGNAL fec12_decoded_code3_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 3)
    SIGNAL fec12_decoded_code4_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 4)
    SIGNAL fec12_decoded_code5_s          : std_logic_vector(51 downto 0);    --! FEC12 decoded data (code 5)

    SIGNAL fec5_data_s                    : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec5_toenc_data_s              : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec5_data_output_synch_s       : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec5_data_input_synch_s        : std_logic_vector(233 downto 0);     --! Data output for FEC5 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec12_data_s                   : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec12_toenc_data_s              : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec12_data_output_synch_s      : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)
    SIGNAL fec12_data_input_synch_s       : std_logic_vector(205 downto 0);     --! Data output for FEC12 decoding (redundant on upper/lower part of the bus @5.12Gbps)

    SIGNAL uplinkClkInEn_pipe_s           : std_logic;

BEGIN                 --========####   Architecture Body   ####========--

    -- FEC5 decoders
    fec5_dec_gen: IF FEC = FEC5 GENERATE

        fec5_encoded_code0_s   <= "00000000000000000000000000" &
                                  fec5_data_i(233 downto 232) &
                                  fec5_data_i(116 downto 0)       WHEN (DATARATE = DATARATE_10G24) ELSE
                                  "00000000000000000000000000000" &
                                  fec5_data_i(115 downto 0);

        rs_decoder_N31K29_c0_inst: rs_decoder_N31K29
            PORT MAP (
                payloadData_i        => fec5_encoded_code0_s,
                fecData_i            => fec5_fec_i(9 downto 0),

                data_o               => fec5_decoded_code0_s
            );

        dec10g24_fec5_gen: IF DATARATE = DATARATE_10G24 GENERATE

            fec5_encoded_code1_s   <= "000000000000000000000000000000" & fec5_data_i(231 downto 117) WHEN (DATARATE = DATARATE_10G24) ELSE
                                      "00000000000000000000000000000" & fec5_data_i(231 downto 116);

            rs_decoder_N31K29_c1_inst: rs_decoder_N31K29
                PORT MAP (
                    payloadData_i        => fec5_encoded_code1_s,
                    fecData_i            => fec5_fec_i(19 downto 10),

                    data_o               => fec5_decoded_code1_s
                );

        END GENERATE;

        dec5g12_fec5_gen: IF DATARATE = DATARATE_5G12 GENERATE
            fec5_decoded_code1_s <= (OTHERS =>  '0');
        END GENERATE;

    END GENERATE;

    -- FEC12 decoders
    fec12_dec_gen: IF FEC = FEC12 GENERATE

        fec12_encoded_code0_s   <= "0000000000000000" & fec12_data_i(135 downto 134) & fec12_data_i(33 downto 0) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "0000000000000000" & fec12_data_i(67 downto 66) & fec12_data_i(33 downto 0);

        fec12_encoded_code1_s   <= "0000000000000000" & fec12_data_i(169 downto 168) & fec12_data_i(67 downto 34) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "000000000000000000" & fec12_data_i(101 downto 100) & fec12_data_i(65 downto 34);

        fec12_encoded_code2_s   <= "0000000000000000" & fec12_data_i(203 downto 202) & fec12_data_i(101 downto 68) WHEN (DATARATE = DATARATE_10G24) ELSE
                                   "00000000000000000000" & fec12_data_i(99 downto 68);

        rs_decoder_N15K13_c0_inst: rs_decoder_N15K13
            PORT MAP (
                payloadData_i        => fec12_encoded_code0_s,
                fecData_i            => fec12_fec_i(7 downto 0),

                data_o               => fec12_decoded_code0_s
            );

        rs_decoder_N15K13_c1_inst: rs_decoder_N15K13
            PORT MAP (
                payloadData_i        => fec12_encoded_code1_s,
                fecData_i            => fec12_fec_i(15 downto 8),

                data_o               => fec12_decoded_code1_s
            );

        rs_decoder_N15K13_c2_inst: rs_decoder_N15K13
            PORT MAP (
                payloadData_i        => fec12_encoded_code2_s,
                fecData_i            => fec12_fec_i(23 downto 16),

                data_o               => fec12_decoded_code2_s
            );

        dec5g12_fec12_gen: IF DATARATE = DATARATE_5G12 GENERATE
            fec12_decoded_code3_s <= (OTHERS => '0');
            fec12_decoded_code4_s <= (OTHERS => '0');
            fec12_decoded_code5_s <= (OTHERS => '0');
        END GENERATE;

        dec10g24_fec12_gen: IF DATARATE = DATARATE_10G24 GENERATE

            fec12_encoded_code3_s   <= "000000000000000000" & fec12_data_i(205 downto 204) & fec12_data_i(133 downto 102)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "0000000000000000" & fec12_data_i(169 downto 168) & fec12_data_i(135 downto 102);

            fec12_encoded_code4_s   <= "00000000000000000000" & fec12_data_i(167 downto 136)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "000000000000000000" & fec12_data_i(203 downto 202) & fec12_data_i(167 downto 136);

            fec12_encoded_code5_s   <= "00000000000000000000" & fec12_data_i(201 downto 170)  WHEN (DATARATE = DATARATE_10G24) ELSE
                                       "00000000000000000000" & fec12_data_i(201 downto 170);

            rs_decoder_N15K13_c3_inst: rs_decoder_N15K13
                PORT MAP (
                    payloadData_i        => fec12_encoded_code3_s,
                    fecData_i            => fec12_fec_i(31 downto 24),

                    data_o               => fec12_decoded_code3_s
                );

            rs_decoder_N15K13_c4_inst: rs_decoder_N15K13
                PORT MAP (
                    payloadData_i        => fec12_encoded_code4_s,
                    fecData_i            => fec12_fec_i(39 downto 32),

                    data_o               => fec12_decoded_code4_s
                );

            rs_decoder_N15K13_c5_inst: rs_decoder_N15K13
                PORT MAP (
                    payloadData_i        => fec12_encoded_code5_s,
                    fecData_i            => fec12_fec_i(47 downto 40),

                    data_o               => fec12_decoded_code5_s
                );
        END GENERATE;

    END GENERATE;

    -- If FEC5 is disabled, force value to 0
    fec5_dec_dis_gen: IF FEC = FEC12 GENERATE
        fec5_decoded_code0_s <= (OTHERS => '0');
        fec5_decoded_code1_s <= (OTHERS => '0');
    END GENERATE;

    -- If FEC12 is disabled, force value to 0
    fec12_dec_dis_gen: IF FEC = FEC5 GENERATE
        fec12_decoded_code0_s <= (OTHERS => '0');
        fec12_decoded_code1_s <= (OTHERS => '0');
        fec12_decoded_code2_s <= (OTHERS => '0');
        fec12_decoded_code3_s <= (OTHERS => '0');
        fec12_decoded_code4_s <= (OTHERS => '0');
        fec12_decoded_code5_s <= (OTHERS => '0');
    END GENERATE;

    PROCESS(uplinkClk_i)
    BEGIN
        IF rising_edge(uplinkClk_i) THEN
            IF uplinkClkOutEn_i = '1' THEN
                fec5_data_input_synch_s    <= fec5_toenc_data_s;
                fec12_data_input_synch_s   <= fec12_toenc_data_s;
                fec5_correction_pattern_o  <= fec5_toenc_data_s xor fec5_data_s;
                fec12_correction_pattern_o <= fec12_toenc_data_s xor fec12_data_s;
            END IF;
        END IF;
    END PROCESS;

--    PROCESS(uplinkClk_i)
--    BEGIN
--        IF rising_edge(uplinkClk_i) THEN
--            uplinkClkInEn_pipe_s <= uplinkClkInEn_i;
--            IF uplinkClkInEn_pipe_s = '1' THEN
--            END IF;
--        END IF;
--    END PROCESS;


    fec5_data_o    <= fec5_data_s;
    fec12_data_o   <= fec12_data_s;

    fec5_data_s    <= fec5_data_i                              WHEN bypass = '1' ELSE
                      fec5_decoded_code0_s(118 downto 117)     &
                      fec5_decoded_code1_s(114 downto 0)       &
                      fec5_decoded_code0_s(116 downto 0)       WHEN DATARATE = DATARATE_10G24 ELSE
                      '0' & fec5_decoded_code1_s(115 downto 0) &
                      '0' & fec5_decoded_code0_s(115 downto 0);

    fec12_data_s   <= fec12_data_i                        WHEN bypass = '1' ELSE
                      fec12_decoded_code3_s(33 downto 32) &
                      fec12_decoded_code2_s(35 downto 34) &
                      fec12_decoded_code5_s(31 downto 0)  &
                      fec12_decoded_code1_s(35 downto 34) &
                      fec12_decoded_code4_s(31 downto 0)  &
                      fec12_decoded_code0_s(35 downto 34) &
                      fec12_decoded_code3_s(31 downto 0)  &
                      fec12_decoded_code2_s(33 downto 0)  &
                      fec12_decoded_code1_s(33 downto 0)  &
                      fec12_decoded_code0_s(33 downto 0)  WHEN DATARATE = DATARATE_10G24 ELSE
                      '0'                                 &
                      fec12_decoded_code4_s(33 downto 32) &
                      fec12_decoded_code5_s(31 downto 0)  &
                      fec12_decoded_code3_s(35 downto 34) &
                      fec12_decoded_code4_s(31 downto 0)  &
                      fec12_decoded_code3_s(33 downto 0)  &
                      '0'                                 &
                      fec12_decoded_code1_s(33 downto 32) &
                      fec12_decoded_code2_s(31 downto 0)  &
                      fec12_decoded_code0_s(35 downto 34) &
                      fec12_decoded_code1_s(31 downto 0)  &
                      fec12_decoded_code0_s(33 downto 0);

    fec5_toenc_data_s <= fec5_data_i                              WHEN bypass = '1' ELSE
                      fec5_encoded_code0_s(118 downto 117)     &
                      fec5_encoded_code1_s(114 downto 0)       &
                      fec5_encoded_code0_s(116 downto 0)       WHEN DATARATE = DATARATE_10G24 ELSE
                      '0' & fec5_encoded_code1_s(115 downto 0) &
                      '0' & fec5_encoded_code0_s(115 downto 0);

    fec12_toenc_data_s <= fec12_data_i                        WHEN bypass = '1' ELSE
                      fec12_encoded_code3_s(33 downto 32) &
                      fec12_encoded_code2_s(35 downto 34) &
                      fec12_encoded_code5_s(31 downto 0)  &
                      fec12_encoded_code1_s(35 downto 34) &
                      fec12_encoded_code4_s(31 downto 0)  &
                      fec12_encoded_code0_s(35 downto 34) &
                      fec12_encoded_code3_s(31 downto 0)  &
                      fec12_encoded_code2_s(33 downto 0)  &
                      fec12_encoded_code1_s(33 downto 0)  &
                      fec12_encoded_code0_s(33 downto 0)  WHEN DATARATE = DATARATE_10G24 ELSE
                      '0'                                 &
                      fec12_encoded_code4_s(33 downto 32) &
                      fec12_encoded_code5_s(31 downto 0)  &
                      fec12_encoded_code3_s(35 downto 34) &
                      fec12_encoded_code4_s(31 downto 0)  &
                      fec12_encoded_code3_s(33 downto 0)  &
                      '0'                                 &
                      fec12_encoded_code1_s(33 downto 32) &
                      fec12_encoded_code2_s(31 downto 0)  &
                      fec12_encoded_code0_s(35 downto 34) &
                      fec12_encoded_code1_s(31 downto 0)  &
                      fec12_encoded_code0_s(33 downto 0);

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--