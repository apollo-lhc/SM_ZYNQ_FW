
Library xpm;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use xpm.vcomponents.all;
use work.plXVC_CTRL.all; 

entity FIFO_6_bit is
port (
   almost_full       : out std_logic;
   data_valid        : out std_logic;
   dout              : out std_logic_vector(5 downto 0);
   empty             : out std_logic;
   full              : out std_logic;
   overflow          : out std_logic;
   din               : in std_logic_vector(5 downto 0);

   rd_en             : in std_logic;
   rst               : in std_logic;
   wr_clk            : in std_logic;
   wr_en             : in std_logic);
   
end FIFO_6_bit;

architecture Behavioral of FIFO_6_bit is

begin

   xpm_fifo_sync_inst : xpm_fifo_sync
   generic map (
      CASCADE_HEIGHT => 0,        -- DECIMAL
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "block", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 1024,   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 10,    -- DECIMAL
      PROG_FULL_THRESH => 10,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => 1,   -- DECIMAL
      READ_DATA_WIDTH => 6,      -- DECIMAL
      READ_MODE => "fwft",        -- String
      SIM_ASSERT_CHK => 0,        -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_ADV_FEATURES => "1009", --1000 0000 0000 1001
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => 6,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => 1    -- DECIMAL
   )
   port map (
   --    almost_empty => almost_empty,   -- 1-bit output: Almost Empty : When asserted, this signal indicates that
   --                                    -- only one more read can be performed before the FIFO goes to empty.
      sleep=>'0',
      almost_full => almost_full,     -- 1-bit output: Almost Full: When asserted, this signal indicates that
                                    -- only one more write can be performed before the FIFO is full.

      data_valid => data_valid,       -- 1-bit output: Read Data Valid: When asserted, this signal indicates
                                    -- that valid data is available on the output bus (dout).

      dout => dout,                   -- READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                    -- when reading the FIFO.

      empty => empty,                 -- 1-bit output: Empty Flag: When asserted, this signal indicates that
                                    -- the FIFO is empty. Read requests are ignored when the FIFO is empty,
                                    -- initiating a read while empty is not destructive to the FIFO.

      full => full,                   -- 1-bit output: Full Flag: When asserted, this signal indicates that the
                                    -- FIFO is full. Write requests are ignored when the FIFO is full,
                                    -- initiating a write when the FIFO is full is not destructive to the
                                    -- contents of the FIFO.

      overflow => overflow,           -- 1-bit output: Overflow: This signal indicates that a write request
                                    -- (wren) during the prior clock cycle was rejected, because the FIFO is
                                    -- full. Overflowing the FIFO is not destructive to the contents of the
                                    -- FIFO.

      din => din,                     -- WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                    -- writing the FIFO.

      injectdbiterr => '0', -- 1-bit input: Double Bit Error Injection: Injects a double bit error if
   --                                    -- the ECC feature is used on block RAMs or UltraRAM macros.

      injectsbiterr => '0', -- 1-bit input: Single Bit Error Injection: Injects a single bit error if
   --                                    -- the ECC feature is used on block RAMs or UltraRAM macros.

      rd_en => rd_en,                 -- 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                    -- signal causes data (on dout) to be read from the FIFO. Must be held
                                    -- active-low when rd_rst_busy is active high.

      rst => rst,                     -- 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                    -- unstable at the time of applying reset, but reset must be released
                                    -- only after the clock(s) is/are stable.           

      wr_clk => wr_clk,               -- 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                    -- free running clock.

      wr_en => wr_en                  -- 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                    -- signal causes data (on din) to be written to the FIFO Must be held
                                    -- active-low when rst or wr_rst_busy or rd_rst_busy is active high
   );

end Behavioral;