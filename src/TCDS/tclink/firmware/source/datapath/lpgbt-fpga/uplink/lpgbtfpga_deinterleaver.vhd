-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Uplink data de-interleaver
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_deinterleaver - Uplink data de-interleaver
--! @details De-interleaves the data to extract the encoded message from
--! the received frame. Interleaving data improves the decoding efficiency
--! by increasing the number of consecutive bits with errors that can be
--! corrected.
ENTITY lpgbtfpga_deinterleaver IS
   GENERIC(
        DATARATE                        : integer RANGE 0 to 2;                 --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
        FEC                             : integer RANGE 0 to 2                  --! FEC selection can be: FEC5 or FEC12
   );
   PORT (
        -- Data
        data_i                          : in  std_logic_vector(255 downto 0);   --! Input frame from the Rx gearbox (data shall be duplicated in upper/lower part of the frame @5.12Gbps)

        fec5_data_o                     : out std_logic_vector(233 downto 0);   --! Output data for FEC5 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
        fec5_fec_o                      : out std_logic_vector(19 downto 0);    --! Output FEC for FEC5 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
        fec12_data_o                    : out std_logic_vector(205 downto 0);   --! Output data for FEC12 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)
        fec12_fec_o                     : out std_logic_vector(47 downto 0);    --! Output FEC for FEC12 encoding (data is duplicated in upper/lower part of the frame @5.12Gbps)

        -- Control
        bypass                          : in  std_logic                         --! Bypass uplink interleaver (test purpose only)
   );
END lpgbtfpga_deinterleaver;

--! @brief lpgbtfpga_deinterleaver - Uplink data de-interleaver
--! @details The lpgbtfpga_deinterleaver routes the data from the MGT to recover
--! the message (symbols) and FEC. It implements both FEC5 and FEC12
--! de-interleaver modules to reconstruct the data for both configuration.
ARCHITECTURE behavioral OF lpgbtfpga_deinterleaver IS

    --! FEC5 de-interleaver component
    COMPONENT upLinkDeinterleaver_fec5
       GENERIC(
            DATARATE                        : integer RANGE 0 TO 2 := DATARATE_5G12
       );
       PORT (
            -- Data
            data_i                          : in  std_logic_vector(255 downto 0);

            data_o                          : out std_logic_vector(233 downto 0);
            fec_o                           : out std_logic_vector(19 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;

    --! FEC12 de-interleaver component
    COMPONENT upLinkDeinterleaver_fec12
       GENERIC(
            DATARATE                        : integer RANGE 0 TO 2 := DATARATE_5G12
       );
       PORT (
            -- Data
            data_i                          : in  std_logic_vector(255 downto 0);

            data_o                          : out std_logic_vector(205 downto 0);
            fec_o                           : out std_logic_vector(47 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;

    SIGNAL fec5_data_5g12_s        : std_logic_vector(233 downto 0);  --! Data output for 5.12Gbps configuration
    SIGNAL fec5_fec_5g12_s         : std_logic_vector(19 downto 0);   --! FEC output for 5.12Gbps configuration

    SIGNAL fec5_data_10g24_s       : std_logic_vector(233 downto 0);  --! Data output for 10.24Gbps configuration
    SIGNAL fec5_fec_10g24_s        : std_logic_vector(19 downto 0);   --! FEC output for 10.24Gbps configuration

    SIGNAL fec12_data_5g12_s       : std_logic_vector(205 downto 0);  --! Data output for 5.12Gbps configuration
    SIGNAL fec12_fec_5g12_s        : std_logic_vector(47 downto 0);   --! FEC output for 5.12Gbps configuration

    SIGNAL fec12_data_10g24_s      : std_logic_vector(205 downto 0);  --! Data output for 10.24Gbps configuration
    SIGNAL fec12_fec_10g24_s       : std_logic_vector(47 downto 0);   --! FEC output for 10.24Gbps configuration

    SIGNAL fec5_data_s             : std_logic_vector(233 downto 0);  --! FEC5 data from de-interleaver
    SIGNAL fec5_fec_s              : std_logic_vector(19 downto 0);   --! FEC5 FEC from de-interleaver
    SIGNAL fec12_data_s            : std_logic_vector(205 downto 0);  --! FEC12 data from de-interleaver
    SIGNAL fec12_fec_s             : std_logic_vector(47 downto 0);   --! FEC12 FEC from de-interleaver

BEGIN                 --========####   Architecture Body   ####========--

    fec5_gen: IF FEC = FEC5 GENERATE

        fec5_5g12: IF DATARATE = DATARATE_5G12 GENERATE

            -- Code 0
            fec5_data_5g12_s(116)            <= '0';
            fec5_data_5g12_s(115 downto 0)   <= data_i(125 downto 10);
            fec5_fec_5g12_s(9 downto 0)      <= data_i(9 downto 0);

            -- Code 1 (Not USEd @5.12Gbps - THEN USEs 2nd phase of data)
            fec5_data_5g12_s(233)            <= '0';
            fec5_data_5g12_s(232 downto 117) <= data_i(253 downto 138);
            fec5_fec_5g12_s(19 downto 10)    <= data_i(137 downto 128);

        END GENERATE;

        fec5_10g24: IF DATARATE = DATARATE_10G24 GENERATE

            -- Code 0
            fec5_data_10g24_s(233 downto 232) <= data_i(253 downto 252);
            fec5_data_10g24_s(116 downto 0)   <= data_i(251 downto 250) &
                                            data_i(244 downto 240) &
                                            data_i(234 downto 230) &
                                            data_i(224 downto 220) &
                                            data_i(214 downto 210) &
                                            data_i(204 downto 200) &
                                            data_i(194 downto 190) &
                                            data_i(184 downto 180) &
                                            data_i(174 downto 170) &
                                            data_i(164 downto 160) &
                                            data_i(154 downto 150) &
                                            data_i(144 downto 140) &
                                            data_i(134 downto 130) &
                                            data_i(124 downto 120) &
                                            data_i(114 downto 110) &
                                            data_i(104 downto 100) &
                                            data_i(94 downto 90) &
                                            data_i(84 downto 80) &
                                            data_i(74 downto 70) &
                                            data_i(64 downto 60) &
                                            data_i(54 downto 50) &
                                            data_i(44 downto 40) &
                                            data_i(34 downto 30) &
                                            data_i(24 downto 20);

            fec5_fec_10g24_s(9 downto 0)      <= data_i(14 downto 10) & data_i(4 downto 0);

            -- Code 1
            fec5_data_10g24_s(231 downto 117) <= data_i(249 downto 245) &
                                            data_i(239 downto 235) &
                                            data_i(229 downto 225) &
                                            data_i(219 downto 215) &
                                            data_i(209 downto 205) &
                                            data_i(199 downto 195) &
                                            data_i(189 downto 185) &
                                            data_i(179 downto 175) &
                                            data_i(169 downto 165) &
                                            data_i(159 downto 155) &
                                            data_i(149 downto 145) &
                                            data_i(139 downto 135) &
                                            data_i(129 downto 125) &
                                            data_i(119 downto 115) &
                                            data_i(109 downto 105) &
                                            data_i(99 downto 95) &
                                            data_i(89 downto 85) &
                                            data_i(79 downto 75) &
                                            data_i(69 downto 65) &
                                            data_i(59 downto 55) &
                                            data_i(49 downto 45) &
                                            data_i(39 downto 35) &
                                            data_i(29 downto 25);

            fec5_fec_10g24_s(19 downto 10)    <= data_i(19 downto 15) & data_i(9 downto 5);

        END GENERATE;

        -- Mux
        fec5_data_s   <= data_i(253 downto 20) WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                         fec5_data_5g12_s WHEN bypass = '1' ELSE
                         fec5_data_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                         fec5_data_10g24_s;

        fec5_fec_s    <= data_i(19 downto 0) WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                         fec5_fec_5g12_s WHEN bypass = '1' ELSE
                         fec5_fec_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                         fec5_fec_10g24_s;

    END GENERATE;

    fec12_gen: IF FEC = FEC12 GENERATE

        fec12_5g12: IF DATARATE = DATARATE_5G12 GENERATE

            -- Code 0
            fec12_data_5g12_s(67 downto 66)   <= data_i(123 downto 122);
            fec12_data_5g12_s(33 downto 0)    <= data_i(121 downto 120) &
                                           data_i(111 downto 108) &
                                           data_i(99 downto 96)   &
                                           data_i(87 downto 84)   &
                                           data_i(75 downto 72)   &
                                           data_i(63 downto 60)   &
                                           data_i(51 downto 48)   &
                                           data_i(39 downto 36)   &
                                           data_i(27 downto 24);

            -- Code 1
            fec12_data_5g12_s(101 downto 100) <= data_i(125 downto 124);
            fec12_data_5g12_s(65 downto 34)   <= data_i(115 downto 112) &
                                           data_i(103 downto 100) &
                                           data_i(91 downto 88)   &
                                           data_i(79 downto 76)   &
                                           data_i(67 downto 64)   &
                                           data_i(55 downto 52)   &
                                           data_i(43 downto 40)   &
                                           data_i(31 downto 28);

            -- Code 2
            fec12_data_5g12_s(99 downto 68)   <= data_i(119 downto 116) &
                                           data_i(107 downto 104) &
                                           data_i(95 downto 92)   &
                                           data_i(83 downto 80)   &
                                           data_i(71 downto 68)   &
                                           data_i(59 downto 56)   &
                                           data_i(47 downto 44)   &
                                           data_i(35 downto 32);

            -- "Code 3, 4 & 5" : Duplicates code 0, 1 and 2 with second phase
            fec12_data_5g12_s(169 downto 168)   <= data_i(251 downto 250);     -- Code 3
            fec12_data_5g12_s(135 downto 102)   <= data_i(249 downto 248) &
                                             data_i(239 downto 236) &
                                             data_i(227 downto 224) &
                                             data_i(215 downto 212) &
                                             data_i(203 downto 200) &
                                             data_i(191 downto 188) &
                                             data_i(179 downto 176) &
                                             data_i(167 downto 164) &
                                             data_i(155 downto 152);

            fec12_data_5g12_s(203 downto 202)   <= data_i(253 downto 252);     -- Code 4
            fec12_data_5g12_s(167 downto 136)   <= data_i(243 downto 240) &
                                             data_i(231 downto 228) &
                                             data_i(219 downto 216) &
                                             data_i(207 downto 204) &
                                             data_i(195 downto 192) &
                                             data_i(183 downto 180) &
                                             data_i(171 downto 168) &
                                             data_i(159 downto 156);

            fec12_data_5g12_s(201 downto 170)   <= data_i(247 downto 244) &    -- Code 5
                                             data_i(235 downto 232) &
                                             data_i(223 downto 220) &
                                             data_i(211 downto 208) &
                                             data_i(199 downto 196) &
                                             data_i(187 downto 184) &
                                             data_i(175 downto 172) &
                                             data_i(163 downto 160);

            -- FEC 0, 1 & 2
            fec12_fec_5g12_s(23 downto 0)     <= data_i(23 downto 20)   &
                                           data_i(11 downto 8)    &
                                           data_i(19 downto 16)   &
                                           data_i(7 downto 4)     &
                                           data_i(15 downto 12)   &
                                           data_i(3 downto 0);

            -- FEC 3, 4 & 5: Duplicates FEC 0, 1 and 2 with second phase
            fec12_fec_5g12_s(47 downto 24)    <= data_i(151 downto 148) &
                                           data_i(139 downto 136) &
                                           data_i(147 downto 144) &
                                           data_i(135 downto 132) &
                                           data_i(143 downto 140) &
                                           data_i(131 downto 128);

        END GENERATE;

        fec12_10g24: IF DATARATE = DATARATE_10G24 GENERATE


            -- Code 0
            fec12_data_10g24_s(135 downto 134) <= data_i(243 downto 242);
            fec12_data_10g24_s(33 downto 0)    <= data_i(241 downto 240) &
                                            data_i(219 downto 216) &
                                            data_i(195 downto 192) &
                                            data_i(171 downto 168) &
                                            data_i(147 downto 144) &
                                            data_i(123 downto 120) &
                                            data_i(99 downto 96)   &
                                            data_i(75 downto 72)   &
                                            data_i(51 downto 48);

            -- Code 1
            fec12_data_10g24_s(169 downto 168) <= data_i(247 downto 246);
            fec12_data_10g24_s(67 downto 34)   <= data_i(245 downto 244) &
                                            data_i(223 downto 220) &
                                            data_i(199 downto 196) &
                                            data_i(175 downto 172) &
                                            data_i(151 downto 148) &
                                            data_i(127 downto 124) &
                                            data_i(103 downto 100) &
                                            data_i(79 downto 76)   &
                                            data_i(55 downto 52);

            -- Code 2
            fec12_data_10g24_s(203 downto 202) <= data_i(251 downto 250);
            fec12_data_10g24_s(101 downto 68)  <= data_i(249 downto 248) &
                                            data_i(227 downto 224) &
                                            data_i(203 downto 200) &
                                            data_i(179 downto 176) &
                                            data_i(155 downto 152) &
                                            data_i(131 downto 128) &
                                            data_i(107 downto 104) &
                                            data_i(83 downto 80)   &
                                            data_i(59 downto 56);

            -- Code 3
            fec12_data_10g24_s(205 downto 204) <= data_i(253 downto 252);
            fec12_data_10g24_s(133 downto 102) <= data_i(231 downto 228) &
                                            data_i(207 downto 204) &
                                            data_i(183 downto 180) &
                                            data_i(159 downto 156) &
                                            data_i(135 downto 132) &
                                            data_i(111 downto 108) &
                                            data_i(87 downto 84)   &
                                            data_i(63 downto 60);

            -- Code 4
            fec12_data_10g24_s(167 downto 136) <= data_i(235 downto 232) &
                                            data_i(211 downto 208) &
                                            data_i(187 downto 184) &
                                            data_i(163 downto 160) &
                                            data_i(139 downto 136) &
                                            data_i(115 downto 112) &
                                            data_i(91 downto 88)   &
                                            data_i(67 downto 64);

            -- Code 5
            fec12_data_10g24_s(201 downto 170) <= data_i(239 downto 236) &
                                            data_i(215 downto 212) &
                                            data_i(191 downto 188) &
                                            data_i(167 downto 164) &
                                            data_i(143 downto 140) &
                                            data_i(119 downto 116) &
                                            data_i(95 downto 92)   &
                                            data_i(71 downto 68);

            fec12_fec_10g24_s                  <= data_i(47 downto 44)   &
                                            data_i(23 downto 20)   &
                                            data_i(43 downto 40)   &
                                            data_i(19 downto 16)   &
                                            data_i(39 downto 36)   &
                                            data_i(15 downto 12)   &
                                            data_i(35 downto 32)   &
                                            data_i(11 downto 8)    &
                                            data_i(31 downto 28)   &
                                            data_i(7 downto 4)     &
                                            data_i(27 downto 24)   &
                                            data_i(3 downto 0);

        END GENERATE;

        -- Mux
        fec12_data_s   <= data_i(253 downto 48) WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                          '0' & data_i (253 downto 152) & '0' & data_i(125 downto 24) WHEN bypass = '1' ELSE
                          fec12_data_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                          fec12_data_10g24_s;

        fec12_fec_s    <= data_i(47 downto 0) WHEN bypass = '1' and (DATARATE = DATARATE_10G24) ELSE
                          data_i(151 downto 128) & data_i(23 downto 0) WHEN bypass = '1' ELSE
                          fec12_fec_5g12_s WHEN DATARATE = DATARATE_5G12 ELSE
                          fec12_fec_10g24_s;

    END GENERATE;

    fec5_data_o  <= fec5_data_s WHEN FEC = FEC5 ELSE (OTHERS => '0');
    fec5_fec_o   <= fec5_fec_s WHEN FEC = FEC5 ELSE (OTHERS => '0');

    fec12_data_o <= fec12_data_s WHEN FEC = FEC12 ELSE (OTHERS => '0');
    fec12_fec_o  <= fec12_fec_s WHEN FEC = FEC12 ELSE (OTHERS => '0');

END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--