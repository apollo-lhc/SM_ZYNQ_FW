library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.types.all;
use work.axiRegPkg.all;


Library UNISIM;
use UNISIM.vcomponents.all;


entity CM_Monitoring is
  generic (
    BAUD_COUNT_BITS : integer := 8;
    INACTIVE_COUNT  : slv_32_t := x"03FFFFFF";
    BASE_ADDRESS    : unsigned(31 downto 0) := x"00000000");
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    uart_rx         : in  std_logic;
    baud_16x_count  : in std_logic_vector(BAUD_COUNT_BITS-1 downto 0);
    readMOSI        : out AXIreadMOSI;
    readMISO        : in  AXIreadMISO;
    writeMOSI       : out AXIwriteMOSI;
    writeMISO       : in  AXIwriteMISO;
    uart_byte_count : out slv_32_t;
    debug_history   : out slv_32_t;
    debug_valid     : out slv_4_t;
    error_reset     : in  std_logic;
    error_count     : out slv16_array_t(5 downto 0);
    bad_transaction : out slv_32_t;
    last_transaction: out slv_32_t;
    channel_active  : out std_logic);

end entity CM_Monitoring;

architecture behavioral of CM_Monitoring is

  signal channel_inactive : std_logic;
  constant ERROR_BAD_SOF : integer := 0;
  constant ERROR_AXI_BUSY_BYTE2 : integer := 1;
  constant ERROR_BYTE2_NOT_DATA : integer := 2;
  constant ERROR_BYTE3_NOT_DATA : integer := 3;
  constant ERROR_BYTE4_NOT_DATA : integer := 4;
  constant ERROR_UNKNOWN        : integer := 5;
  signal error_pulse : std_logic_vector(ERROR_UNKNOWN downto 0);  
  signal uart_history : slv_32_t;
  signal uart_history_valid : slv_4_t;
  
  signal en_16_x_baud : std_logic;
  signal baud_counter : unsigned(BAUD_COUNT_BITS-1 downto 0);
  signal baud_counter_end : unsigned(BAUD_COUNT_BITS-1 downto 0);
  signal uart_rd_en : std_logic;
  signal uart_data : slv_8_t;
  signal uart_data_present : std_logic;
  signal uart_full : std_logic;
  signal uart_half_full : std_logic;
  signal uart_reset  : std_logic;
  

  signal reset_axi_n : std_logic;
  signal axi_address : slv_32_t;
  signal axi_rd_en : std_logic;
  signal axi_rd_data : slv_32_t;
  signal axi_rd_data_valid : std_logic;
  signal axi_wr_data : slv_32_t;
  signal axi_wr_en : std_logic;
  signal busy : std_logic;

  signal axi_read_finished : std_logic;
  

  constant BS_SOF  : slv_2_t := "10";
  constant BS_DATA : slv_2_t := "00";
  signal sensor_number : slv_8_t;
  signal sensor_value : slv_16_t;

  signal sensor_address_offset : slv_32_t;
 
  type state_t is (SM_RESET,
                   SM_WAIT_FOR_SOF,
                   SM_WAIT_FOR_BYTE2,
                   SM_WAIT_FOR_BYTE3,
                   SM_WAIT_FOR_BYTE4,
                   SM_WAIT_FOR_AXI_READ,
                   SM_ERROR);
  signal state : state_t;
  
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  --AXI-Lite master
  -------------------------------------------------------------------------------
  reset_axi_n <= not reset;
  axiLiteMaster_1: entity work.axiLiteMaster
    port map (
      clk_axi       => clk,
      reset_axi_n   => reset_axi_n,
      readMOSI      => readMOSI,
      readMISO      => readMISO,
      writeMOSI     => writeMOSI,
      writeMISO     => writeMISO,
      busy          => busy,
      address       => axi_address,
      rd_en         => axi_rd_en,
      rd_data       => axi_rd_data,
      rd_data_valid => axi_rd_data_valid,
      wr_data       => axi_wr_data,
      wr_en         => axi_wr_en);

  -------------------------------------------------------------------------------
  -- Monitor state machine
  -------------------------------------------------------------------------------
  --                                                       Start
  --+----------+    +----------+            +----------+ AXI Read   +----------+
  --|          |    |  WAIT    |            |  WAIT    |            |  WAIT    |
  --|  RESET  ----->+   FOR    +----------->+   FOR    +----------->+   FOR    |
  --|          |    |   SOF    | DP = '1'   |  BYTE 2  | DP = '1'   |  BYTE 3  |
  --+----+-----+    +-+------+-+ TYPE 0b10  +----+-----+ TYPE 0b00  +-+--+-----+
  --     ^            ^      |                   |                    |  |
  --     |            |      |                   |  DP = '1'          |  |
  --     |            +------+                   |  Type != 0b00      |  |
  --     |            ^                          +<----------+--------+  | DP = '1'
  --     |            ^                          |           ^           v TYPE 0b00
  --     |            |                     -----v-----+     |      +----+-----+
  --     |            |                     |          |     |      |  WAIT    |
  --     +----------------------------------+  ERROR   |     +------+   FOR    |
  --                  |                     |          |            |  BYTE 4  |
  --                  |                     +----------+            +----+-----+
  --                  |                                                  |
  --                  |                                                  | DP = '1'
  --                  |                                                  v TYPE 0b00
  --                  |                                             +----+-----+
  --                  |                                             |  WAIT    +-------+
  --                  +---------------------------------------------+ FOR AXI  |       |
  --                                                                |  READ    +<------+
  --                                                                +----------+  AXI READ
  --                                                                              Finished
  --                                                                               = 0
  --
  -------------------------------------------------------------------------------
  Mon_SM: process (clk, reset) is
  begin  -- process Mon_SM_proc
    if reset = '1' then                 -- asynchronous reset (active high)
      state <= SM_RESET;
      error_pulse     <= (others => '0');      
    elsif clk'event and clk = '1' then  -- rising clock edge
      error_pulse <= (others => '0');
      case state is
        when SM_RESET =>
          state <= SM_WAIT_FOR_SOF;
        when SM_WAIT_FOR_SOF =>
          if uart_data_present = '1' then
            --We got a word
            if uart_data(7 downto 6) = BS_SOF then
              --This was a start of frame word
              state <= SM_WAIT_FOR_BYTE2;
            else
              error_pulse(ERROR_BAD_SOF) <= '1';
            --This was not a start of frame word, do nothing other than eat
            --it. (we'll skip the restart)
            end if;            
          end if;
        when SM_WAIT_FOR_BYTE2 =>
          if uart_data_present = '1' then
            --check if the data is valid
            if uart_data(7 downto 6) = BS_DATA then
              state <= SM_WAIT_FOR_BYTE3;
            else
              error_pulse(ERROR_BYTE2_NOT_DATA) <= '1';
              state <= SM_ERROR;
            end if;
            
            --also check if the AXI master is busy
            if busy = '1' then
              state <= SM_ERROR;
              error_pulse(ERROR_AXI_BUSY_BYTE2) <= '1';            
            end if;
            
          end if;
        when SM_WAIT_FOR_BYTE3 =>
          if uart_data_present = '1' then
            if uart_data(7 downto 6) = BS_DATA then
              state <= SM_WAIT_FOR_BYTE4;
            else
              state <= SM_ERROR;
              error_pulse(ERROR_BYTE3_NOT_DATA) <= '1';
            end if;
          end if;
        when SM_WAIT_FOR_BYTE4 =>
          if uart_data_present = '1' then
            if uart_data(7 downto 6) = BS_DATA then
              state <= SM_WAIT_FOR_AXI_READ;
            else
              state <= SM_ERROR;
              error_pulse(ERROR_BYTE4_NOT_DATA) <= '1';
            end if;
          end if;
        when SM_WAIT_FOR_AXI_READ =>
          if axi_read_finished = '1' then
            state <= SM_WAIT_FOR_SOF;
          end if;
        when SM_ERROR =>          
          state <= SM_RESET;
        when others =>
          error_pulse(ERROR_UNKNOWN) <= '1';
          state <=SM_ERROR;
      end case;
    end if;
  end process Mon_SM;

  -------------------------------------------------------------------------------
  -- State machine operations
  -------------------------------------------------------------------------------

  --keep the SM waiting until the read request finishes. 
  read_capture: process (clk, reset) is
  begin  -- process read_capture
    if reset = '1' then                 -- asynchronous reset (active high)
      axi_read_finished <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if axi_rd_en = '1' then
        axi_read_finished <= '0';
      elsif axi_rd_data_valid = '1' then
        axi_read_finished <= '1';        
      end if;
    end if;
  end process read_capture;

  --Quickly read the UART data when in a reading state
  data_ack: process (uart_data_present, state) is
  begin  -- process data_ack
    case state is
      when SM_WAIT_FOR_SOF | SM_WAIT_FOR_BYTE2 | SM_WAIT_FOR_BYTE3 | SM_WAIT_FOR_BYTE4  =>
        uart_rd_en <= uart_data_present;        
      when others => uart_rd_en <= '0';
    end case;
  end process data_ack;


  --  Build the sensor ram address using the partial sensor_number from the last
  --  UART word and the MSB of the last two address bits that were included in
  --  this current UART word.
  --  This is used to compute the final axi address and then re-used in the
  --  ending axi write
  sensor_address_offset <= x"00000" & "000" & sensor_number(7 downto 2) & uart_data(5) & "00";

  Mon_SM_proc: process (clk, reset) is
  begin  -- process Mon_SM_proc
    if reset = '1' then                 -- asynchronous reset (active high)

    elsif clk'event and clk = '1' then  -- rising clock edge
      axi_rd_en       <= '0';
      axi_wr_en       <= '0';
      uart_reset      <= '0';
      case state is
        when SM_RESET =>
          --Reset the UART corea
          uart_reset <= '1';
        when SM_WAIT_FOR_SOF =>
          if uart_data_present = '1' then
            --start building the sensor_number ID
            sensor_number(7 downto 2) <= uart_data(5 downto 0);
          else
            sensor_number <= (others => '0');
            sensor_value  <= (others => '0');
          end if;
        when SM_WAIT_FOR_BYTE2 =>
          if uart_data_present = '1' then            
            --construct the AXI address we will use for transactions
            axi_address <= slv_32_t(BASE_ADDRESS + unsigned(sensor_address_offset));
            axi_rd_en <= '1';

            --finish sensor_number, start on sensor_value
            sensor_number( 1 downto  0) <= uart_data(5 downto 4);
            sensor_value (15 downto 12) <= uart_data(3 downto 0);
          end if;
        when SM_WAIT_FOR_BYTE3 =>
          if uart_data_present = '1' then            
            sensor_value(11 downto  6) <= uart_data(5 downto 0);
          end if;          
        when SM_WAIT_FOR_BYTE4 =>
          if uart_data_present = '1' then
            --finish sensor_value
            sensor_value(5 downto  0) <= uart_data(5 downto 0);
          end if;          
        when SM_WAIT_FOR_AXI_READ =>
          --Wait for AXI read to finish
          if axi_read_finished = '1' then
            --Write 16 bit sensor value into either the upper or lower part of
            --the axi 32bit word based on LSB
            if sensor_number(0) = '0' then
              axi_wr_data <= axi_rd_data(31 downto 16) & sensor_value;
            else
              axi_wr_data <= sensor_value & axi_rd_data(15 downto  0);
            end if;
            axi_wr_en <= '1';

            --latch this transaction
            last_transaction(31 downto 24) <= "00"&error_pulse;
            last_transaction(23 downto  8) <= sensor_value;
            last_transaction( 7 downto  0) <= sensor_number;
          end if;
        when SM_ERROR => NULL;
          --error_pulse <= '1';
        when others => null;
      end case;
    end if;
  end process Mon_SM_proc;

  -------------------------------------------------------------------------------
  -- UART Rx
  -------------------------------------------------------------------------------  

  ---------------------------------------
  --Build the RX 16x baud rate signal
  ---------------------------------------
  baud_counter_end <= unsigned(baud_16x_count);  
  uart_baud_16x_en_proc: process (clk,reset) is
  begin  -- process uart_baud_16x_en_proc
    if reset = '1' then
      baud_counter <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      en_16_x_baud <= '0';
      if baud_counter = baud_counter_end then
        baud_counter <= (others => '0');
        en_16_x_baud <= '1';
      else
        baud_counter <= baud_counter + 1;  
      end if;
    end if;
  end process uart_baud_16x_en_proc;

  ---------------------------------------
  --uart rx core
  ---------------------------------------
  uart_rx6_1: entity work.uart_rx6
    port map (
      serial_in           => uart_rx,
      en_16_x_baud        => en_16_x_baud,
      data_out            => uart_data,
      buffer_read         => uart_rd_en,
      buffer_data_present => uart_data_present,
      buffer_half_full    => uart_half_full,
      buffer_full         => uart_full,
      buffer_reset        => uart_reset,
      clk                 => clk);


  debug_history <= uart_history;
  debug_valid   <= uart_history_valid;
  debugging: process (clk, reset) is
  begin  -- process debugging
    if reset = '1' then                 -- asynchronous reset (active high)
      uart_history <= x"00000000";
      uart_history_valid <= x"0";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if uart_rd_en = '1' then
        uart_history       <= uart_history      (uart_history'left       - 8 downto 0) & uart_data;
        uart_history_valid <= uart_history_valid(uart_history_valid'left - 1 downto 0) & '1';
      end if;
    end if;
  end process debugging;


  last_transaction_capture: process (clk, reset) is
  begin  -- process last_transaction_capture
    if reset = '0' then                 -- asynchronous reset (active low)
      bad_transaction <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if or_reduce(error_pulse) = '1' then
        --latch this transaction
        bad_transaction(31 downto 24) <= "00"&error_pulse;
        bad_transaction(23 downto  8) <= sensor_value;
        bad_transaction( 7 downto  0) <= sensor_number;
      end if;
    end if;
  end process last_transaction_capture;

  
  error_counting: for iErr in 0 to ERROR_UNKNOWN generate   
    counter_1: entity work.counter
      generic map (
        roll_over   => '0',
        end_value   => x"0000FFFF",
        start_value => x"00000000",
        DATA_WIDTH  => 16)
      port map (
        clk         => clk,
        reset_async => reset,
        reset_sync  => error_reset,
        enable      => '1',
        event       => error_pulse(iErr),
        count       => error_count(iErr),
        at_max      => open);
  end generate error_counting;

  byte_counter_1: entity work.counter
    generic map (
      roll_over   => '1',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => 32)
    port map (
      clk         => clk,
      reset_async => reset,
      reset_sync  => '0',
      enable      => '1',
      event       => uart_rd_en,
      count       => uart_byte_count,
      at_max      => open);

  
  channel_active <= not channel_inactive;
  counter_2: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => INACTIVE_COUNT,
      start_value => x"00000000",
      DATA_WIDTH  => 26)
    port map (
      clk         => clk,
      reset_async => reset,
      reset_sync  => axi_rd_en,
      enable      => '1',
      event       => '1',
      count       => open,
      at_max      => channel_inactive);
end architecture behavioral;
