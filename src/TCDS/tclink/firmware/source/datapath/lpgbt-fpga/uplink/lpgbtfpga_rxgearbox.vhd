-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief Rx gearbox
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--! @brief lpgbtfpga_rxGearbox - Rx Gearbox
--! @details
--! The Rx gearbox module is USEd to ensure the MGT to Datapath clock domain
--! crossing. It takes the c_inputWidth bit words in input and generates an c_outputWidth bit
--! word every c_clockRatio clock cycle. When the clock ratio is bigger than the word ratio (oversampling),
--! each word get from each phase is stored in different words that are concatenated and set in output.
--! E.g.: (A0)(A1)(B0)(B1)(C0)(C1) where (A0) and (A1) are the "same bit" (2 samples took by the MGT in the same UI,
--!       becaUSE of the oversampling), the output is (A0)(B0)(C0)(A1)(B1)(B1).
ENTITY lpgbtfpga_rxGearbox IS
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
END lpgbtfpga_rxGearbox;

--! @brief lpgbtfpga_rxGearbox - Rx Gearbox
--! @details
--! The rxGearbox implements a register based clock domain crossing system. Using different clock
--! for the input and output require a special attention on the phase relation between these two
--! signals.
ARCHITECTURE behavioral OF lpgbtfpga_rxGearbox IS

    --==================================== User Logic =====================================--
    CONSTANT c_oversampling                      : integer := c_clockRatio/(c_outputWidth/c_inputWidth);

    SIGNAL reg0                                  : std_logic_vector (((c_inputWidth*c_clockRatio)-1) downto 0);
    SIGNAL reg1                                  : std_logic_vector (((c_inputWidth*c_clockRatio)-1) downto 0);
    SIGNAL rxFrame_inverted_s                    : std_logic_vector (((c_inputWidth*c_clockRatio)-1) downto 0);

    SIGNAL gbReset_s                             : std_logic;
    SIGNAL sta_gbRdy_s0                          : std_logic;
    SIGNAL sta_gbRdy_s                           : std_logic;
    SIGNAL clk_dataFlag_s                        : std_logic;

    SIGNAL dat_outFrame_s                        : std_logic_vector((c_inputWidth*c_clockRatio)-1 downto 0);

    SIGNAL dat_inFrame_s                         : std_logic_vector((c_inputWidth-1) downto 0);

    SIGNAL gbReset_outsynch_s                    : std_logic;
    SIGNAL clk_dataFlag_outsynch_s               : std_logic;
    SIGNAL sta_gbRdy_outsynch_s                  : std_logic;
    SIGNAL dat_outFrame_outsynch_s               : std_logic_vector((c_inputWidth*c_clockRatio)-1 downto 0);
    --=====================================================================================--

--=================================================================================================--
BEGIN                 --========####   Architecture Body   ####========--
--=================================================================================================--

    gbRstSynch_proc: PROCESS(rst_gearbox_i, clk_inClk_i)
    BEGIN

        IF rst_gearbox_i = '1' THEN
            gbReset_s  <= '1';

        ELSIF rising_edge(clk_inClk_i) THEN

            IF clk_clkEn_i = '1' THEN
                gbReset_s <= '0';
            END IF;

        END IF;
    END PROCESS;

    rxWordPipeline_proc: PROCESS(gbReset_s, clk_inClk_i)
      BEGIN
        IF gbReset_s = '1' THEN
            dat_inFrame_s <= (OTHERS => '0');
        ELSIF rising_edge(clk_inClk_i) THEN
            dat_inFrame_s <= dat_inFrame_i;
        END IF;
    END PROCESS;


    gbRegMan_proc: PROCESS(gbReset_s, clk_inClk_i)
        VARIABLE cnter              : integer RANGE 0 to c_clockRatio;
    BEGIN

        IF gbReset_s = '1' THEN
            reg0           <= (OTHERS => '0');
            reg1           <= (OTHERS => '0');
            sta_gbRdy_s0   <= '0';

            cnter          := c_counterInitValue;

        ELSIF rising_edge(clk_inClk_i) THEN
            clk_dataFlag_s    <= '0';

            IF cnter = 0 THEN
               reg1  <= reg0;
               clk_dataFlag_s <= '1';
               sta_gbRdy_s0   <= '1';
               sta_gbRdy_s    <= sta_gbRdy_s0; --Delay ready for 1 word. First word could be corrupted
            END IF;

            reg0((c_inputWidth*(1+cnter))-1 downto (c_inputWidth*cnter))     <= dat_inFrame_s;
            cnter                                                            := cnter + 1;

            IF cnter = c_clockRatio THEN
               cnter := 0;
            END IF;
        END IF;

    END PROCESS;

    frameInverter: FOR i IN ((c_inputWidth*c_clockRatio)-1) downto 0 GENERATE
        rxFrame_inverted_s(i)                             <= reg1(((c_inputWidth*c_clockRatio)-1)-i);
    END GENERATE;

    oversamplerMultPh: FOR i IN 0 TO (c_oversampling-1) GENERATE
        oversamplerPhN: FOR j IN 0 TO (c_outputWidth-1) GENERATE
            dat_outFrame_s((i*c_outputWidth)+j) <= rxFrame_inverted_s((j*c_oversampling)+i);
        END GENERATE;
    END GENERATE;

    -- Pipeline dat_outFrame_o to avoid clocking issue
    clkEnPipeline_proc: PROCESS(clk_outClk_i)
    BEGIN
        IF rising_edge(clk_outClk_i) THEN
            gbReset_outsynch_s       <= gbReset_s;
        END IF;
    END PROCESS;

    outPipeline_proc: PROCESS(gbReset_outsynch_s, clk_outClk_i)
    BEGIN
        IF gbReset_outsynch_s = '1' THEN
            dat_outFrame_o <= (OTHERS => '0');
            clk_dataFlag_o <= '0';
            sta_gbRdy_o    <= '0';

        ELSIF rising_edge(clk_outClk_i) THEN

            clk_dataFlag_o <= clk_dataFlag_s;
            dat_outFrame_o <= dat_outFrame_s;
            sta_gbRdy_o    <= sta_gbRdy_s;

        END IF;
    END PROCESS;
   --=====================================================================================--
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--