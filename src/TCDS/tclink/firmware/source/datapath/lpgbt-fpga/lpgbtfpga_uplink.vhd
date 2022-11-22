-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief lpGBT-FPGA Uplink wrapper
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--! Include the lpGBT-FPGA specific package
USE work.lpgbtfpga_package.all;

--! @brief lpgbtfpga_uplink - Uplink wrapper (top level)
--! @details
--! The lpgbtfpga_uplink wrapper implements the logic required
--! for the frame alignement, the frame construction and the
--! decoding/descrambling of the data.
ENTITY lpgbtfpga_uplink IS
   GENERIC(
        -- General configuration
        DATARATE                        : integer RANGE 0 to 2;                               --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
        FEC                             : integer RANGE 0 to 2;                               --! FEC selection can be: FEC5 or FEC12

        -- Expert parameters
        c_multicyleDelay                : integer RANGE 0 to 7 := 3;                          --! Multicycle delay: Used to relax the timing constraints
        c_clockRatio                    : integer;                                            --! Clock ratio is mgt_Userclk / 40 (shall be an integer)
        c_mgtWordWidth                  : integer;                                            --! Bus size of the input word (typically 32 bits)
        c_allowedFalseHeader            : integer;                                            --! Number of false header allowed (among c_allowedFalseHeaderOverN) to avoid unlock on frame error
        c_allowedFalseHeaderOverN       : integer;                                            --! Number of header checked to know wether the lock is lost or not
        c_requiredTrueHeader            : integer;                                            --! Number of consecutive correct header required to go in locked state
        c_bitslip_mindly                : integer := 1;                                       --! Number of clock cycle required when asserting the bitslip signal
        c_bitslip_waitdly               : integer := 40                                       --! Number of clock cycle required before being back in a stable state
   );
   PORT (
        -- Clock and reset
        uplinkClk_i                     : in  std_logic;                                      --! Uplink datapath clock (Transceiver Rx User clock, typically 320MHz)
        uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable indicating a new data is valid
        uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset signal (Rx ready from the transceiver)

        -- Input
        mgt_word_i                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT

        -- Data
        userData_o                      : out std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depending on the
                                                                                              --! datarate/FEC configuration:
                                                                                              --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                              --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                              --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                              --!     * *FEC12 / 10.24 Gbps*: 202bit
        EcData_o                        : out std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT
        IcData_o                        : out std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT

        -- Control
        bypassInterleaver_i             : in  std_logic;                                      --! Bypass uplink interleaver (test purpose only)
        bypassFECEncoder_i              : in  std_logic;                                      --! Bypass uplink FEC (test purpose only)
        bypassScrambler_i               : in  std_logic;                                      --! Bypass uplink scrambler (test purpose only)

        -- Transceiver control
        mgt_bitslipCtrl_o               : out std_logic;                                      --! Control the Bitslip/RxSlide port of the Mgt

        -- Status
        dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
        IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
        EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
        rdy_o                           : out std_logic;                                      --! Ready SIGNAL from the uplink decoder
        frameAlignerEven_o              : out std_logic                                       --! Number of bit slip is even (required only for advanced applications)

   );
END lpgbtfpga_uplink;

--! @brief lpgbtfpga_uplink - Uplink wrapper (top level)
--! @details
--! The lpgbtfpga_uplink module receives the data from the transceiver
--! and decode them to generate the User frame. It supports the 4
--! following configurations:
--!     * *(FEC5 / 5.12 Gbps)*: User data output is 112bit (can correct up to 5 consecutives bits)
--!     * *(FEC12 / 5.12 Gbps)*: User data output is 98bit (can correct up to 12 consecutives bits)
--!     * *(FEC5 / 10.24 Gbps)*: User data output is 230bit (can correct up to 10 consecutives bits)
--!     * *(FEC12 / 10.24 Gbps)*: User data output is 202bit (can correct up to 24 consecutives bits)
ARCHITECTURE behavioral OF lpgbtfpga_uplink IS

    COMPONENT lpgbtfpga_framealigner IS
        GENERIC (
            c_wordRatio                      : integer;             --! Word ration: frameclock / mgt_wordclock
            c_wordSize                       : integer;             --! Size of the mgt word
            c_headerPattern                  : std_logic_vector;    --! Header pattern specified by the standard
            c_allowedFalseHeader             : integer;             --! Number of false header allowed to avoid unlock on frame error
            c_allowedFalseHeaderOverN        : integer;             --! Number of header checked to know wether the lock is lost or not
            c_requiredTrueHeader             : integer;             --! Number of true header required to go in locked state
    
            c_bitslip_mindly                 : integer := 1;        --! Number of clock cycle required WHEN asserting the bitslip SIGNAL
            c_bitslip_waitdly                : integer := 40        --! Number of clock cycle required before being back in a stable state
        );
        PORT (
            -- Clock(s)
            clk_pcsRx_i                      : in  std_logic;       --! MGT Wordclock
    
            -- Reset(s)
            rst_pattsearch_i                 : in  std_logic;       --! Rst the pattern search state machines
    
            -- Control
            cmd_bitslipCtrl_o                : out std_logic;       --! Bitslip SIGNAL to shift the parrallel word
    
            -- Status
            sta_headerLocked_o               : out std_logic;       --! Status: header is locked	
            sta_headerFlag_o                 : out std_logic;       --! Status: header flag (1 pulse over c_wordRatio)
            sta_bitSlipEven_o                : out std_logic;       --!	Status: number of bit slips is even
    
            -- Data
            dat_word_i                       : in  std_logic_vector(c_headerPattern'length-1 downto 0)  --! Header bits from the MGT word (compared with c_headerPattern)
       );
    END COMPONENT;

    COMPONENT lpgbtfpga_rxGearbox
        GENERIC (
            c_clockRatio                  : integer;                                                         --! Clock ratio is clock_out / clock_in (shall be an integer)
            c_inputWidth                  : integer;                                                         --! Bus size of the input word
            c_outputWidth                 : integer;                                                         --! Bus size of the output word (Warning: c_clockRatio/(c_inputWidth/c_outputWidth) shall be an integer)
            c_counterInitValue            : integer := 2                                                     --! Initialization value of the gearbox counter (3 for simulation / 2 for real HW)
        );
        PORT (
            -- Clock and reset
            clk_inClk_i                   : in  std_logic;                                                   --! Input clock (from MGT)
            clk_outClk_i                  : in  std_logic;                                                   --! Output clock (from MGT)
            clk_clkEn_i                   : in  std_logic;                                                   --! Clock enable (e.g.: header flag)
            clk_dataFlag_o                : out std_logic;

            rst_gearbox_i                 : in  std_logic;                                                   --! Reset SIGNAL

            -- Data
            dat_inFrame_i                 : in  std_logic_vector((c_inputWidth-1) downto 0);                 --! Input data from MGT
            dat_outFrame_o                : out std_logic_vector((c_inputWidth*c_clockRatio)-1 downto 0);    --! Output data, concatenation of word WHEN the word ratio is lower than clock ration (e.g.: out <= word & word;)

            -- Status
            sta_gbRdy_o                   : out std_logic                                                    --! Ready SIGNAL
        );
    END COMPONENT;

    --! Uplink de-interleaver component
    COMPONENT lpgbtfpga_deinterleaver
       GENERIC(
            DATARATE                        : integer RANGE 0 to 2;
            FEC                             : integer RANGE 0 to 2
       );
       PORT (
            -- Data
            data_i                          : in  std_logic_vector(255 downto 0);

            fec5_data_o                     : out std_logic_vector(233 downto 0);
            fec5_fec_o                      : out std_logic_vector(19 downto 0);
            fec12_data_o                    : out std_logic_vector(205 downto 0);
            fec12_fec_o                     : out std_logic_vector(47 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;

    --! Uplink decoder component
    COMPONENT lpgbtfpga_decoder
       GENERIC(
            DATARATE                        : integer RANGE 0 to 2;
            FEC                             : integer RANGE 0 to 2
       );
       PORT (
            uplinkClk_i                     : in  std_logic;
            uplinkClkInEn_i                 : in  std_logic;
            uplinkClkOutEn_i                : in  std_logic;
            -- Data
            fec5_data_i                     : in  std_logic_vector(233 downto 0);
            fec5_fec_i                      : in  std_logic_vector(19 downto 0);
            fec12_data_i                    : in  std_logic_vector(205 downto 0);
            fec12_fec_i                     : in  std_logic_vector(47 downto 0);

            fec5_data_o                     : out std_logic_vector(233 downto 0);
            fec12_data_o                    : out std_logic_vector(205 downto 0);

            fec5_correction_pattern_o       : out std_logic_vector(233 downto 0);
            fec12_correction_pattern_o      : out std_logic_vector(205 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;
    --! Uplink datapath
    COMPONENT lpgbtfpga_descrambler
       GENERIC(
            FEC                             : integer RANGE 0 to 2
       );
       PORT (
            -- Clock and reset
            clk_i                           : in  std_logic;
            clkEn_i                         : in  std_logic;

            reset_i                         : in  std_logic;

            -- Data
            fec5_data_i                     : in  std_logic_vector(233 downto 0);
            fec12_data_i                    : in  std_logic_vector(205 downto 0);

            fec5_data_o                     : out std_logic_vector(233 downto 0);
            fec12_data_o                    : out std_logic_vector(205 downto 0);

            -- Control
            bypass                          : in  std_logic
       );
    END COMPONENT;


    SIGNAL sta_headerFlag_s                 : std_logic;
    SIGNAL sta_dataflag_s                   : std_logic;
    SIGNAL rst_gearbox_s                    : std_logic;
    SIGNAL sta_headerLocked_s               : std_logic;

    SIGNAL gbxFrame_s                       : std_logic_vector(255 downto 0);
    SIGNAL gbxFrame_5g12_s                  : std_logic_vector(127 downto 0);

    SIGNAL sta_gbRdy_s                      : std_logic;
    SIGNAL rst_pattsearch_s                 : std_logic;
    SIGNAL datapath_rst_s                   : std_logic;

    SIGNAL fec5_data_from_deinterleaver_s   : std_logic_vector(233 downto 0);    --! Data from de-interleaver (FEC5)
    SIGNAL fec5_fec_from_deinterleaver_s    : std_logic_vector(19 downto 0);     --! FEC from de-interleaver (FEC5)
    SIGNAL fec12_data_from_deinterleaver_s  : std_logic_vector(205 downto 0);    --! Data from de-interleaver (FEC12)
    SIGNAL fec12_fec_from_deinterleaver_s   : std_logic_vector(47 downto 0);     --! FEC from de-interleaver (FEC12)

    SIGNAL fec5_data_from_decoder_s         : std_logic_vector(233 downto 0);    --! Data from decoder (FEC5)
    SIGNAL fec12_data_from_decoder_s        : std_logic_vector(205 downto 0);    --! Data from decoder (FEC12)

    SIGNAL fec5_data_from_descrambler_s     : std_logic_vector(233 downto 0);    --! Data from descrambler (FEC5)
    SIGNAL fec12_data_from_descrambler_s    : std_logic_vector(205 downto 0);    --! Data from descrambler (FEC12)

    SIGNAL fec5_correction_s                : std_logic_vector(233 downto 0);    --! Correction flag (FEC5)
    SIGNAL fec12_correction_s               : std_logic_vector(205 downto 0);    --! Correction flag (FEC12)

    SIGNAL rdy_0_s                          : std_logic;                         --! Ready register to delay the ready SIGNAL
    SIGNAL rdy_1_s                          : std_logic;                         --! Ready register to delay the ready SIGNAL

    SIGNAL UserData_10g24_s                 : std_logic_vector(229 downto 0);    --! Uplink output for 10g24 datarate configuration (User data)
    SIGNAL EcData_10g24_s                   : std_logic_vector(1 downto 0);      --! Uplink output for 10g24 datarate configuration (EC)
    SIGNAL IcData_10g24_s                   : std_logic_vector(1 downto 0);      --! Uplink output for 10g24 datarate configuration (IC)

    SIGNAL UserData_5g12_s                  : std_logic_vector(229 downto 0);    --! Uplink output for 5g12 datarate configuration (User data)
    SIGNAL EcData_5g12_s                    : std_logic_vector(1 downto 0);      --! Uplink output for 5g12 datarate configuration (EC)
    SIGNAL IcData_5g12_s                    : std_logic_vector(1 downto 0);      --! Uplink output for 5g12 datarate configuration (IC)

    SIGNAL uplinkCorrData_10g24_s           : std_logic_vector(229 downto 0);    --! Uplink correction flag output for 10g24 datarate configuration (User data)
    SIGNAL uplinkCorrEc_10g24_s             : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 10g24 datarate configuration (EC)
    SIGNAL uplinkCorrIc_10g24_s             : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 10g24 datarate configuration (IC)

    SIGNAL uplinkCorrData_5g12_s            : std_logic_vector(229 downto 0);    --! Uplink correction flag output for 5g12 datarate configuration (User data)
    SIGNAL uplinkCorrEc_5g12_s              : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 5g12 datarate configuration (EC)
    SIGNAL uplinkCorrIc_5g12_s              : std_logic_vector(1 downto 0);      --! Uplink correction flag output for 5g12 datarate configuration (IC)

    SIGNAL frame_pipelined_s                : std_logic_vector(255 downto 0);    --! Store input data in register to ensure stability
    SIGNAL clkEnOut_s                       : std_logic;
    SIGNAL rst_synch_s                      : std_logic;

BEGIN                 --========####   Architecture Body   ####========--

    rst_pattsearch_s         <= not(uplinkRst_n_i);

    -- lpgbtfpga_framealigner is used to align the input frame using the
    -- lpGBT header.
    lpgbtfpga_framealigner_inst: lpgbtfpga_framealigner
        GENERIC MAP(
            c_wordRatio                      => c_clockRatio,
            c_wordSize                       => c_mgtWordWidth,
            c_headerPattern                  => "01",
            c_allowedFalseHeader             => c_allowedFalseHeader,
            c_allowedFalseHeaderOverN        => c_allowedFalseHeaderOverN,
            c_requiredTrueHeader             => c_requiredTrueHeader,

            c_bitslip_mindly                 => c_bitslip_mindly,
            c_bitslip_waitdly                => c_bitslip_waitdly
        )
        PORT MAP(
            -- Clock(s)
            clk_pcsRx_i                      => uplinkClk_i,

            -- Reset(s)
            rst_pattsearch_i                 => rst_pattsearch_s,

            -- Control
            cmd_bitslipCtrl_o                => mgt_bitslipCtrl_o,

            -- Status
            sta_headerLocked_o               => sta_headerLocked_s,
            sta_headerFlag_o                 => sta_headerFlag_s,
            sta_bitSlipEven_o                => frameAlignerEven_o,

            -- Data
            dat_word_i                       => mgt_word_i(1 downto 0)
        );

    rst_gearbox_s <= not(sta_headerLocked_s);

    -- lpgbtfpga_rxGearbox is used to pass from mgt word size (e.g.: 32b @ 320MHz)
    -- to lpgbt frame size (e.g.: 256b at 40MHz)
    rxgearbox_10g_gen: IF DATARATE = DATARATE_10G24 GENERATE
        rxGearbox_10g24_inst: lpgbtfpga_rxGearbox
            GENERIC MAP(
                c_clockRatio                  => c_clockRatio,
                c_inputWidth                  => c_mgtWordWidth,
                c_outputWidth                 => 256,
                c_counterInitValue            => 2
            )
            PORT MAP(
                -- Clock and reset
                clk_inClk_i                   => uplinkClk_i,
                clk_outClk_i                  => uplinkClk_i,
                clk_clkEn_i                   => sta_headerFlag_s,
                clk_dataFlag_o                => sta_dataflag_s,

                rst_gearbox_i                 => rst_gearbox_s,

                -- Data
                dat_inFrame_i                 => mgt_word_i,
                dat_outFrame_o                => gbxFrame_s,

                -- Status
                sta_gbRdy_o                   => sta_gbRdy_s
            );
    END GENERATE;

    rxgearbox_5g_gen: IF DATARATE = DATARATE_5G12 GENERATE
        rxGearbox_5g12_inst: lpgbtfpga_rxGearbox
            GENERIC MAP(
                c_clockRatio                  => c_clockRatio,
                c_inputWidth                  => c_mgtWordWidth,
                c_outputWidth                 => 128,
                c_counterInitValue            => 2
            )
            PORT MAP(
                -- Clock and reset
                clk_inClk_i                   => uplinkClk_i,
                clk_outClk_i                  => uplinkClk_i,
                clk_clkEn_i                   => sta_headerFlag_s,
                clk_dataFlag_o                => sta_dataflag_s,

                rst_gearbox_i                 => rst_gearbox_s,

                -- Data
                dat_inFrame_i                 => mgt_word_i,
                dat_outFrame_o                => gbxFrame_5g12_s,

                -- Status
                sta_gbRdy_o                   => sta_gbRdy_s
            );

        gbxFrame_s(127 downto 0)   <= gbxFrame_5g12_s;
        gbxFrame_s(255 downto 128) <= (OTHERS => '0');

    END GENERATE;

    datapath_rst_s    <= not(sta_gbRdy_s);

    --! Data input pipeline
    dataInPipeliner_proc: PROCESS(uplinkClk_i, datapath_rst_s)
    BEGIN
        IF datapath_rst_s = '1' THEN
            frame_pipelined_s      <= (OTHERS => '0');
        ELSIF rising_edge(uplinkClk_i) THEN
            IF sta_dataflag_s = '1' THEN
                frame_pipelined_s  <= gbxFrame_s;
            END IF;
        END IF;
    END PROCESS;


    --! Multicycle path configuration
    syncShIFtReg_proc: PROCESS(datapath_rst_s, uplinkClk_i)
        VARIABLE cnter  : integer RANGE 0 TO 7;
    BEGIN

        IF datapath_rst_s = '1' THEN
              cnter              := 0;
              clkEnOut_s   <= '0';

        ELSIF rising_edge(uplinkClk_i) THEN
            IF sta_dataflag_s = '1' THEN
                cnter                 := 0;
                rst_synch_s  <= '1';
            ELSIF rst_synch_s = '1' THEN
                cnter            := cnter + 1;
            END IF;

            clkEnOut_s       <= '0';
            IF cnter = c_multicyleDelay THEN
                clkEnOut_s   <= '1';
            END IF;
        END IF;
    END PROCESS;

    uplinkClkOutEn_o  <= clkEnOut_s;

    -- lpgbtfpga_deinterleaver deinterleaves the input frame
    lpgbtfpga_deinterleaver_inst: lpgbtfpga_deinterleaver
       GENERIC MAP(
            DATARATE                        => DATARATE,
            FEC                             => FEC
       )
       PORT MAP (
            -- Data
            data_i                          => frame_pipelined_s,

            fec5_data_o                     => fec5_data_from_deinterleaver_s,
            fec5_fec_o                      => fec5_fec_from_deinterleaver_s,
            fec12_data_o                    => fec12_data_from_deinterleaver_s,
            fec12_fec_o                     => fec12_fec_from_deinterleaver_s,

            -- Control
            bypass                          => bypassInterleaver_i
       );

    -- lpgbtfpga_decoder decodes the input frame and corrects the error(s) using the FEC part
    -- of the frame
    lpgbtfpga_decoder_inst: lpgbtfpga_decoder
        GENERIC MAP(
            DATARATE                        => DATARATE,
            FEC                             => FEC
        )
        PORT MAP (
            uplinkClk_i                     => uplinkClk_i,
            uplinkClkInEn_i                 => sta_dataflag_s,
            uplinkClkOutEn_i                => clkEnOut_s,

            -- Data
            fec5_data_i                     => fec5_data_from_deinterleaver_s,
            fec5_fec_i                      => fec5_fec_from_deinterleaver_s,
            fec12_data_i                    => fec12_data_from_deinterleaver_s,
            fec12_fec_i                     => fec12_fec_from_deinterleaver_s,

            fec5_data_o                     => fec5_data_from_decoder_s,
            fec12_data_o                    => fec12_data_from_decoder_s,

            fec5_correction_pattern_o       => fec5_correction_s,
            fec12_correction_pattern_o      => fec12_correction_s,

            -- Control
            bypass                          => bypassFECEncoder_i
        );

    -- lpgbtfpga_descrambler descrambles the input frame
    lpgbtfpga_descrambler_inst: lpgbtfpga_descrambler
        GENERIC MAP(
            FEC                             => FEC
        )
        PORT MAP(
            -- Clock and reset
            clk_i                           => uplinkClk_i,
            clkEn_i                         => clkEnOut_s,

            reset_i                         => datapath_rst_s,

            -- Data
            fec5_data_i                     => fec5_data_from_decoder_s,
            fec12_data_i                    => fec12_data_from_decoder_s,

            fec5_data_o                     => fec5_data_from_descrambler_s,
            fec12_data_o                    => fec12_data_from_descrambler_s,

            -- Control
            bypass                          => bypassScrambler_i
        );

    --! Generate ready SIGNAL from the reset (2 clock cycle delay)
    readySync_proc: PROCESS(uplinkClk_i, datapath_rst_s)
    BEGIN

        IF datapath_rst_s = '1' THEN
            rdy_1_s  <= '0';
            rdy_0_s  <= '0';
            rdy_o    <= '0';

        ELSIF rising_edge(uplinkClk_i) THEN

            IF clkEnOut_s = '1' THEN
                rdy_o    <= rdy_1_s;
                rdy_1_s  <= rdy_0_s;
                rdy_0_s  <= '1';
            END IF;

        END IF;
    END PROCESS;

    -- Routes data depending on the datarate and FEC configurations
    UserData_10g24_s        <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_data_from_descrambler_s(229 downto 0) WHEN (FEC = FEC5) ELSE
                               "0000000000000000000000000000" & fec12_data_from_descrambler_s(201 downto 0);

    EcData_10g24_s          <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_data_from_descrambler_s(231 downto 230) WHEN (FEC = FEC5) ELSE
                               fec12_data_from_descrambler_s(203 downto 202);

    IcData_10g24_s          <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_data_from_descrambler_s(233 downto 232) WHEN (FEC = FEC5) ELSE
                               fec12_data_from_descrambler_s(205 downto 204);

    UserData_5g12_s         <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               x"00000000000000000000000000000" & "00" & fec5_data_from_descrambler_s(111 downto 0) WHEN (FEC = FEC5) ELSE
                               x"000000000000000000000000000000000" & fec12_data_from_descrambler_s(97 downto 0);

    EcData_5g12_s           <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_data_from_descrambler_s(113 downto 112) WHEN (FEC = FEC5) ELSE
                               fec12_data_from_descrambler_s(99 downto 98);

    IcData_5g12_s           <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_data_from_descrambler_s(115 downto 114) WHEN (FEC = FEC5) ELSE
                               fec12_data_from_descrambler_s(101 downto 100);


    userData_o              <= UserData_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               UserData_5g12_s;

    EcData_o                <= EcData_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               EcData_5g12_s;

    IcData_o                <= IcData_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               IcData_5g12_s;

    uplinkCorrData_10g24_s  <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_correction_s(229 downto 0) WHEN (FEC = FEC5) ELSE
                               "0000000000000000000000000000" & fec12_correction_s(201 downto 0);

    uplinkCorrEc_10g24_s    <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_correction_s(231 downto 230) WHEN (FEC = FEC5) ELSE
                               fec12_correction_s(203 downto 202);

    uplinkCorrIc_10g24_s    <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_correction_s(233 downto 232) WHEN (FEC = FEC5) ELSE
                               fec12_correction_s(205 downto 204);

    uplinkCorrData_5g12_s   <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               x"00000000000000000000000000000" & "00" & fec5_correction_s(111 downto 0) WHEN (FEC = FEC5) ELSE
                               x"000000000000000000000000000000000" & fec12_correction_s(97 downto 0);

    uplinkCorrEc_5g12_s     <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_correction_s(113 downto 112) WHEN (FEC = FEC5) ELSE
                               fec12_correction_s(99 downto 98);

    uplinkCorrIc_5g12_s     <= (OTHERS => '0') WHEN rdy_1_s = '0' ELSE
                               fec5_correction_s(115 downto 114) WHEN (FEC = FEC5) ELSE
                               fec12_correction_s(101 downto 100);

    dataCorrected_o         <= uplinkCorrData_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               uplinkCorrData_5g12_s;

    EcCorrected_o           <= uplinkCorrEc_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               uplinkCorrEc_5g12_s;

    IcCorrected_o           <= uplinkCorrIc_10g24_s WHEN (DATARATE = DATARATE_10G24) ELSE
                               uplinkCorrIc_5g12_s;
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--