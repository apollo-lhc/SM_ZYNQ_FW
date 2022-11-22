-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Downlink wrapper
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the LpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_downlink - Downlink wrapper (top level)
--! @details
--! The lpgbtfpga_downlink module implements the logic required
--! for the data encoding as required by the lpGBT for the downlink
--! path (Back-END to Front-END) and split the frame to be compliant
--! with the transceiver interface.
ENTITY lpgbtfpga_downlink IS
   GENERIC(
        -- Expert parameters
        c_multicyleDelay              : integer RANGE 0 to 7 := 3;                          --! Multicycle delay: Used to relax the timing constraints
        c_clockRatio                  : integer := 8;                                       --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
        c_outputWidth                 : integer                                             --! Transceiver's word size (Typically 32 bits)
   );
   PORT (
        -- Clocks
        clk_i                         : in  std_logic;                                      --! Downlink datapath clock (Transceiver Tx User clock, typically 320MHz)
        clkEn_i                       : in  std_logic;                                      --! Clock enable (1 pulse over 8 clock cycles when encoding runs @ 320Mhz)
        rst_n_i                       : in  std_logic;                                      --! Downlink reset SIGNAL (Tx ready from the transceiver)

        -- Down link
        userData_i                    : in  std_logic_vector(31 downto 0);                  --! Downlink data (User)
        ECData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink EC field
        ICData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink IC field

        -- Output
        mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)

        -- Configuration
        interleaverBypass_i           : in  std_logic;                                      --! Bypass downlink interleaver (test purpose only)
        encoderBypass_i               : in  std_logic;                                      --! Bypass downlink FEC (test purpose only)
        scramblerBypass_i             : in  std_logic;                                      --! Bypass downlink scrambler (test purpose only)

        -- Status
        rdy_o                         : out std_logic                                       --! Downlink ready status
   );
END lpgbtfpga_downlink;

--! @brief lpgbtfpga_downlink - Downlink wrapper (top level)
--! @details
--! The lpgbtfpga_downlink module scrambles, encodes and interleaves the data to provide
--! the encoded bus Used in the downlink communication with an LpGBT device. The output
--! bus, which is made of 64 bits running at the LHC clock (about 40MHz) is encoded using
--! a Reed-Solomon scheme and shall be sent using a serial link configured at 2.56Gbps.
ARCHITECTURE behavioral OF lpgbtfpga_downlink IS

    --! Scrambler module used for the downlink encoding
    COMPONENT lpgbtfpga_scrambler
       GENERIC (
            INIT_SEED                 : in std_logic_vector(35 downto 0)    := x"1fba847af"
       );
       PORT (
            -- Clocks & reset
            clk_i                     : in  std_logic;
            clkEn_i                   : in  std_logic;

            reset_i                   : in  std_logic;

            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            data_o                    : out std_logic_vector(35 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

    --! FEC calculator used for the downlink encoding
    COMPONENT lpgbtfpga_encoder IS
       PORT (
            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            FEC_o                     : out std_logic_vector(23 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

    --! Interleaver used to improve the decoding efficiency
    COMPONENT lpgbtfpga_interleaver IS
       GENERIC(
            HEADER_c                  : in  std_logic_vector(3 downto 0)
       );
       PORT (
            -- Data
            data_i                    : in  std_logic_vector(35 downto 0);
            FEC_i                     : in  std_logic_vector(23 downto 0);

            data_o                    : out std_logic_vector(63 downto 0);

            -- Control
            bypass                    : in  std_logic
       );
    END COMPONENT;

    COMPONENT lpgbtfpga_txGearbox
        GENERIC (
            c_clockRatio                  : integer;                                                --! Clock ratio is clock_out / clock_in (shall be an integer)
            c_inputWidth                  : integer;                                                --! Bus size of the input word
            c_outputWidth                 : integer                                                 --! Bus size of the output word (Warning: c_clockRatio/(c_inputWidth/c_outputWidth) shall be an integer)
        );
        PORT (
            -- Clock and reset
            clk_inClk_i                   : in  std_logic;                                          --! Input clock (frame clock)
            clk_clkEn_i                   : in  std_logic;                                          --! Input clock enable WHEN multicycle path or '1'
            clk_outClk_i                  : in  std_logic;                                          --! Output clock (from the MGT)

            rst_gearbox_i                 : in  std_logic;                                          --! Reset SIGNAL

            -- Data
            dat_inFrame_i                 : in  std_logic_vector((c_inputWidth-1) downto 0);        --! Input data
            dat_outFrame_o                : out std_logic_vector((c_outputWidth-1) downto 0);       --! Output data

            -- Status
            sta_gbRdy_o                   : out std_logic                                           --! Ready SIGNAL
        );
    END COMPONENT;

    SIGNAL rst_s              : std_logic;
    SIGNAL gbRst_s            : std_logic;
    SIGNAL gbRdy_s            : std_logic;
    SIGNAL encodedFrame_s     : std_logic_vector(63 downto 0);

    SIGNAL inputData_s        : std_logic_vector(35 downto 0);      --! Data bus made of IC + EC + User Data (Used to input the scrambler)
    SIGNAL scrambledData_s    : std_logic_vector(35 downto 0);      --! Scrambled data
    SIGNAL FECData_s          : std_logic_vector(23 downto 0);      --! FEC bus
    SIGNAL clkOutEn_s         : std_logic;
    SIGNAL rst_synch_s        : std_logic;
BEGIN                 --========####   Architecture Body   ####========-

    rst_s          <= not(gbRdy_s);
    gbRst_s        <= not(rst_n_i);

    --! Multicycle path configuration
    syncShiftReg_proc: PROCESS(rst_s, clk_i)
        VARIABLE cnter  : integer RANGE 0 TO 7;
    BEGIN

        IF rst_s = '1' THEN
              cnter              := 0;
              clkOutEn_s         <= '0';
              rst_synch_s        <= '0';

        ELSIF rising_edge(clk_i) THEN
            IF clkEn_i = '1' THEN
                cnter                 := 0;
                rst_synch_s           <= '1';
            ELSIF rst_synch_s = '1' THEN
                cnter                 := cnter + 1;
            END IF;

            clkOutEn_s                <= '0';
            IF cnter = c_multicyleDelay THEN
                clkOutEn_s            <= '1';
            END IF;
        END IF;
    END PROCESS;

    inputData_s(31 downto 0)    <= userData_i;
    inputData_s(33 downto 32)   <= ECData_i;
    inputData_s(35 downto 34)   <= ICData_i;

    --! Scrambler module Used for the downlink encoding
    lpgbtfpga_scrambler_inst: lpgbtfpga_scrambler
        PORT MAP (
            clk_i                => clk_i,
            clkEn_i              => clkOutEn_s,

            reset_i              => rst_s,

            data_i               => inputData_s,
            data_o               => scrambledData_s,

            bypass               => scramblerBypass_i
        );

    --! FEC calculator Used for the downlink encoding
    lpgbtfpga_encoder_inst: lpgbtfpga_encoder
        PORT MAP (
            -- Data
            data_i               => scrambledData_s,
            FEC_o                => FECData_s,

            -- Control
            bypass               => encoderBypass_i
        );

    --! Interleaver Used to improve the decoding efficiency
    lpgbtfpga_interleaver_inst: lpgbtfpga_interleaver
        GENERIC MAP (
            HEADER_c             => "1001"
        )
        PORT MAP (
            -- Data
            data_i               => scrambledData_s,
            FEC_i                => FECData_s,

            data_o               => encodedFrame_s,

            -- Control
            bypass               => interleaverBypass_i
        );

    rdy_o      <= rst_synch_s;

    --! Bridge between frame word and MGT word
    lpgbtfpga_txGearbox_inst: lpgbtfpga_txGearbox
        GENERIC MAP(
            c_clockRatio                  => c_clockRatio,
            c_inputWidth                  => 64,
            c_outputWidth                 => c_outputWidth
        )
        PORT MAP(
            -- Clock and reset
            clk_inClk_i                   => clk_i,
            clk_clkEn_i                   => clkEn_i,
            clk_outClk_i                  => clk_i,

            rst_gearbox_i                 => gbRst_s,

            -- Data
            dat_inFrame_i                 => encodedFrame_s,
            dat_outFrame_o                => mgt_word_o,

            -- Status
            sta_gbRdy_o                   => gbRdy_s
        );
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--