-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief Tx gearbox
-------------------------------------------------------

--! Include the IEEE VHDL standard LIBRARY
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--! @brief lpgbtfpga_txGearbox - Tx Gearbox
--! @details
--! The txGearbox module implements a register based clock domain crossing system to
--! pass from the serial clock domain to the MGT clock domain. It manages oversampling
--! meaning that the bit are multiplicated IF the word ratio is lower than the clock
--! ratio.
ENTITY lpgbtfpga_txGearbox IS
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
END lpgbtfpga_txGearbox;

--! @brief lpgbtfpga_txGearbox ARCHITECTURE- Tx Gearbox
--! @details
--! The txGearbox implements a register based clock domain crossing system. Using different clock
--! for the input and output require a special attention on the phase relation between these two
--! signals.
ARCHITECTURE behavioral OF lpgbtfpga_txGearbox is

    --================================ Signal Declarations ================================--
    CONSTANT c_oversampling                      : integer := c_clockRatio/(c_inputWidth/c_outputWidth);

    SIGNAL gearboxSyncReset                      : std_logic;
    SIGNAL rst_gearbox_s                         : std_logic;

    SIGNAL txFrame_from_frameInverter_s          : std_logic_vector (c_inputWidth-1 downto 0);
    SIGNAL txFrame_from_frameInverter_pipe_s     : std_logic_vector (c_inputWidth-1 downto 0);
    SIGNAL in_txFrame_from_frameInverter_s       : std_logic_vector (c_inputWidth-1 downto 0);
    SIGNAL txFrame_from_frameInverter_reg_s      : std_logic_vector (c_inputWidth-1 downto 0);
    SIGNAL txWord_beforeOversampling_s           : std_logic_vector((c_inputWidth/c_clockRatio)-1 downto 0);

    SIGNAL debug                                 : integer;
    SIGNAL clk_clkEn_s                           : std_logic;
    SIGNAL clk_clkEn_pipe_s                      : std_logic;
    SIGNAL dat_outFrame_s                        : std_logic_vector((c_outputWidth-1) downto 0);

   --=====================================================================================--

--=================================================================================================--
BEGIN                 --========####   Architecture Body   ####========--
--=================================================================================================--

   --==================================== User Logic =====================================--

    -- Comment: Bits are inverted to transmit the MSB first on the MGT.
    frameInverter: FOR i IN (c_inputWidth-1) downto 0 GENERATE
        in_txFrame_from_frameInverter_s(i)             <= dat_inFrame_i((c_inputWidth-1)-i);
    END GENERATE;

    -- Comment: Note!! The reset of the gearbox is synchronous to TX_FRAMECLK in order to align the address 0
    --                 of the gearbox with the rising edge of TX_FRAMECLK after reset.
    sta_gbRdy_o    <= not(gearboxSyncReset);

    -- Sync reset
    rst_pipeline_proc: PROCESS(rst_gearbox_i, clk_inClk_i)
    BEGIN
        IF rst_gearbox_i = '1' THEN
            rst_gearbox_s <= '1';

        ELSIF rising_edge(clk_inClk_i) THEN
            IF clk_clkEn_i = '1' THEN
                rst_gearbox_s <= '0';
            END IF;
        END IF;
    END PROCESS;

    gbRstSynch_proc: PROCESS(rst_gearbox_s, clk_outClk_i)
    BEGIN
        IF rst_gearbox_s = '1' THEN
            gearboxSyncReset  <= '1';

        ELSIF rising_edge(clk_outClk_i) THEN
            gearboxSyncReset <= '0';
        END IF;
    END PROCESS;

    pipeline_proc: PROCESS(clk_outClk_i)
    BEGIN
        IF rising_edge(clk_outClk_i) THEN
            txFrame_from_frameInverter_pipe_s  <= in_txFrame_from_frameInverter_s;
        END IF;
    END PROCESS;

    gb_proc: PROCESS(gearboxSyncReset, clk_outClk_i)
        VARIABLE address                       : integer RANGE 0 TO (c_clockRatio-1);
    BEGIN

        IF gearboxSyncReset = '1' THEN
            txWord_beforeOversampling_s         <= (OTHERS => '0');
            address                             := 0;
            debug <= address;

        ELSIF rising_edge(clk_outClk_i) THEN

            debug <= address;
            IF address = 0 THEN
                txWord_beforeOversampling_s         <= txFrame_from_frameInverter_pipe_s((c_inputWidth/c_clockRatio)-1 downto 0);
                txFrame_from_frameInverter_reg_s    <= txFrame_from_frameInverter_pipe_s;
            ELSE
                txWord_beforeOversampling_s         <= txFrame_from_frameInverter_reg_s(((c_inputWidth/c_clockRatio)*(address+1))-1 downto ((c_inputWidth/c_clockRatio)*(address)));
            END IF;

            IF address = (c_clockRatio-1) THEN
                address := 0;
            ELSE
                address  := address + 1;
            END IF;

        END IF;
    END PROCESS;

    -- Comment: Oversampling generator loop.
    oversamplerMultPh: FOR i IN 0 TO (c_inputWidth/c_clockRatio)-1 GENERATE
        oversamplerPhN: FOR j IN 0 TO (c_oversampling-1) GENERATE
            dat_outFrame_s((i*c_oversampling)+j)   <= txWord_beforeOversampling_s(i);
        END GENERATE;
    END GENERATE;

    PROCESS(clk_outClk_i)
    BEGIN
        IF rising_edge(clk_outClk_i) THEN
            dat_outFrame_o <= dat_outFrame_s;
        END IF;
    END PROCESS;
    --=====================================================================================--
END behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
