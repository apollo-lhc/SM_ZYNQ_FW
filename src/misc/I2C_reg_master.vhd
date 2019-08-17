library IEEE;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;


entity I2C_reg_master is
  generic (
    I2C_QUARTER_PERIOD_CLOCK_COUNT : integer := 10;
    IGNORE_ACK                  : std_logic := '0';
    REG_ADDR_BYTE_COUNT          : integer := 1;
    USE_RESTART_FOR_READ_SEQUENCE : std_logic := '1');
  port (
    clk_sys     : in  std_logic;
    reset       : in  std_logic;
    I2C_Address : in  std_logic_vector(6 downto 0);
    run         : in  std_logic;
    rw          : in  std_logic; --0 write 1 read
    reg_addr    : in  std_logic_vector((REG_ADDR_BYTE_COUNT*8) -1 downto 0);
    rd_data     : out std_logic_vector(31 downto 0);
    wr_data     : in  std_logic_vector(31 downto 0);
    byte_count  : in  std_logic_vector(2 downto 0);
    done        : out std_logic := '0';
    error       : out std_logic;
--    SDA         : inout std_logic;
    SDA_t       : out std_logic;
    SDA_o       : out std_logic;
    SDA_i       : in  std_logic;
    SCLK        : out std_logic);

end entity I2C_reg_master;

architecture Behavioral of I2C_reg_master is

--  constant PERIOD_COUNT_100 : integer 4*i2C_QUARTER_PERIOD_CLOCK_COUNT downto 1 := 4 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
--  constant PERIOD_COUNT_075 : integer 4*i2C_QUARTER_PERIOD_CLOCK_COUNT downto 1 := 3 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
--  constant PERIOD_COUNT_050 : integer 4*i2C_QUARTER_PERIOD_CLOCK_COUNT downto 1 := 2 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
--  constant PERIOD_COUNT_025 : integer 4*i2C_QUARTER_PERIOD_CLOCK_COUNT downto 1 := 1 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
--  constant PERIOD_COUNT_000 : integer 4*i2C_QUARTER_PERIOD_CLOCK_COUNT downto 1 := 1;
  constant PERIOD_COUNT_100 : integer  := 4 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
  constant PERIOD_COUNT_075 : integer  := 3 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
  constant PERIOD_COUNT_050 : integer  := 2 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
  constant PERIOD_COUNT_025 : integer  := 1 * i2C_QUARTER_PERIOD_CLOCK_COUNT;
  constant PERIOD_COUNT_000 : integer  := 1;
  
  signal i2c_counter  : integer := PERIOD_COUNT_000;
  signal enable_clock : std_logic := '0';
  signal done_local : std_logic := '1';
  signal error_local : std_logic := '0';
  
  --Tranaction cached values
  signal transfer_direction : std_logic := '1';
  signal addr : std_logic_vector((REG_ADDR_BYTE_COUNT*8) -1 downto 0) := (others => '0');
  signal i2c_addr : std_logic_vector(7 downto 0) := x"00";
  signal transaction_length : unsigned(2 downto 0) := "000";
  signal transaction_byte   : unsigned(2 downto 0) := "000";
  signal data : std_logic_vector(31 downto 0) := x"00000000";
  signal reg_addr_byte : integer := REG_ADDR_BYTE_COUNT;
  
  -- state machine
  type state_t is (STATE_IDLE,
                   STATE_START,
                   STATE_I2C_ADDRESS,
                   STATE_REG_ADDRESS,
                   STATE_RESTART,
                   STATE_STOP_START,
                   STATE_STOP_START_WAIT,
                   STATE_RESTART_I2C_ADDRESS,
                   STATE_DATA_READ,
                   STATE_DATA_WRITE,
                   STATE_ERROR,
                   STATE_FINISH);
  signal state : state_t := STATE_IDLE;
  signal bit_sequence : integer range 8 downto 0 := 0;
  constant I2C_CLOCK_COUNT_BETWEEN_TRANSACTIONS : integer := 100;
  signal stop_start_counter : integer range I2C_CLOCK_COUNT_BETWEEN_TRANSACTIONS downto 0 := I2C_CLOCK_COUNT_BETWEEN_TRANSACTIONS;

  signal ack : std_logic := '0';
begin  -- architecture Behavioral

  i2c_counter_proc: process (clk_sys) is
  begin  -- process i2c_counter
    if clk_sys'event and clk_sys = '1' then  -- rising clock edge
      if reset = '1' then
        i2c_counter <= PERIOD_COUNT_100;
      elsif enable_clock = '1' then        
        if i2c_counter = 1 then
          i2c_counter <= PERIOD_COUNT_100;
        else
          i2c_counter <= i2c_counter -1;
        end if;
      else
        i2c_counter <= PERIOD_COUNT_100;
      end if;
    end if;
  end process i2c_counter_proc;

  done <= done_local;
  error <= error_local;
  transaction_state_machine: process (clk_sys) is
  begin  -- process transaction_state_machine
    if clk_sys'event and clk_sys = '1' then  -- rising clock edge
      if reset = '1' then
        done_local <= '1';
        error_local <= '0';
      else        
        case state is
          when STATE_IDLE =>
            -----------------------------------------------------------------------
            -- BUS idle
            -----------------------------------------------------------------------
            --idle pattern
            SDA_o <= '1'; SDA_t <= '0';
            SCLK <= '1';
            enable_clock <= '0';
            
            --wait for request
            if run = '1' then
              --capture the mode we are writing
              transfer_direction <= rw;
              -- capture the register address we are writing to
              addr <= reg_addr;
              -- capture the i2c address and set it to write for reg addr byte
              i2c_addr <= I2C_Address & '0';
              -- capture transaction length
              transaction_byte <= unsigned(byte_count) -1;
              transaction_length <= unsigned(byte_count);
              --capture write data if needed
              if rw = '0' then
                data <= wr_data;              
              end if;

              --reset done and error state
              done_local <= '0';
              error_local <= '0';
              
              --go to i2c start state
              state <= STATE_START;
              enable_clock <= '1';
            end if;
            
          when STATE_START =>
            -----------------------------------------------------------------------
            -- perform the I2C start sequence
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 => 
                SDA_o <= '1'; SDA_t <= '0';
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                SDA_o <= '0'; SDA_t <= '0';
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
              when PERIOD_COUNT_000 =>
                state <= STATE_I2C_ADDRESS;
                reg_addr_byte <= REG_ADDR_BYTE_COUNT;
                bit_sequence <= 0;
              when others => null;
            end case;
            
          when STATE_I2C_ADDRESS =>
            -----------------------------------------------------------------------
            -- Send the i2c address of the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                ack <= '0'; --get ack ready
                SCLK <= '0';
                if bit_sequence /= 8 then
                  --write out bit
                  SDA_o <= i2c_addr(7-bit_sequence); SDA_t <= '0';
                else
                  -- get ready to read in a bit
                  SDA_o <= '1'; SDA_t <= '1';
                end if;
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                if bit_sequence = 8 then
                  ack <= not SDA_i;
                end if;
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
              when PERIOD_COUNT_000 =>
                if bit_sequence = 8 then
                  bit_sequence <= 0;
                  --ack bit
                  if (IGNORE_ACK = '1') or (ack = '1') then
                    -- slave acked, move to next state
                    state <= STATE_REG_ADDRESS;                  
                  else
                    state <= STATE_ERROR;
                  end if;
                else
                  bit_sequence <= bit_sequence +1;
                end if;
              when others => null;
            end case;
          when STATE_REG_ADDRESS =>
            -----------------------------------------------------------------------
            -- Send the reg address to the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                ack <= '0';
                SCLK <= '0';
                if bit_sequence /= 8 then
                  --write out bit
                  SDA_o <= addr(((reg_addr_byte*8) -1)-bit_sequence); SDA_t <= '0';
                else
                  -- get ready to read in a bit
                  SDA_o <= '1'; SDA_t <= '1';
                end if;
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                if bit_sequence = 8 then
                  ack <= not SDA_i;
                end if;
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
              when PERIOD_COUNT_000 =>
                if bit_sequence = 8 then
                  bit_sequence <= 0;
                  --ack bit
                  if (IGNORE_ACK = '1') or (ack = '1') then
                    -- slave acked, move to next state
                    if reg_addr_byte /= 1 then                      
                      reg_addr_byte <= reg_addr_byte -1;
                      state <= STATE_REG_ADDRESS;
                    elsif transfer_direction = '1' then
                      if USE_RESTART_FOR_READ_SEQUENCE = '1' then
                        state <= STATE_RESTART;
                      else
                        state <= STATE_STOP_START;
                      end if;
                      --set the address to read for read transc
                      i2c_addr(0) <= '1';
                    else
                      state <= STATE_DATA_WRITE;                    
                    end if;
                  else
                    state <= STATE_ERROR;
                  end if;
                else
                  bit_sequence <= bit_sequence +1;
                end if;
              when others => null;
            end case;
          when STATE_RESTART =>
            -----------------------------------------------------------------------
            -- Send the reg address to the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                SDA_o <= '1'; SDA_t <= '0';
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                SDA_o <= '0'; SDA_t <= '0';
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
              when PERIOD_COUNT_000 =>
                state <= STATE_RESTART_I2C_ADDRESS;
                -- set the next transfer to be a read
                i2c_addr(0) <= '1';
              when others => null;
            end case;
          when STATE_STOP_START=>
            -----------------------------------------------------------------------
            -- Stop the transaction for this type of read
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                SDA_o <= '0'; SDA_t <= '0';
                SCLK <= '0';
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_025 =>
                SDA_o <= '1'; SDA_t <= '0';
              when PERIOD_COUNT_000 =>
                state <= STATE_STOP_START_WAIT;
                stop_start_counter <= I2C_CLOCK_COUNT_BETWEEN_TRANSACTIONS;
                -- set the next transfer to be a read
                i2c_addr(0) <= '1';
              when others => null;
            end case;
          when STATE_STOP_START_WAIT=>
            -----------------------------------------------------------------------
            -- Wait I2C_CLOCK_COUNT_BETWEEN_TRANSACTION+1 I2C clocks between the
            -- address write transaction and a new read transaction
            -----------------------------------------------------------------------
            if stop_start_counter = 0 then
              --start next transaction by doing a start sequence
              case i2c_counter is
                when PERIOD_COUNT_100 => 
                  SDA_o <= '1'; SDA_t <= '0';
                  SCLK <= '1';
                when PERIOD_COUNT_050 =>
                  SDA_o  <= '0'; sda_t <= '0';
                when PERIOD_COUNT_025 =>
                  SCLK <= '0';
                when PERIOD_COUNT_000 =>
                  state <= STATE_RESTART_I2C_ADDRESS;
                  bit_sequence <= 0;
                when others => null;
              end case;
            else
              case i2c_counter is
                when PERIOD_COUNT_000  =>
                  --keep waiting
                  stop_start_counter <= stop_start_counter -1;
                when others => null;
              end case;
            end if;

          when STATE_RESTART_I2C_ADDRESS =>
            -----------------------------------------------------------------------
            -- Send the i2c address of the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                ack <= '0'; --get ack ready
                SCLK <= '0';
                if bit_sequence /= 8 then
                  --write out bit
                  SDA_o <= i2c_addr(7-bit_sequence); sda_t <= '0';
                else
                  -- get ready to read in a bit
                  SDA_o <= '1'; SDA_t <= '1';
                end if;
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                if bit_sequence = 8 then
                  ack <= not SDA_i;
                end if;
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
              when PERIOD_COUNT_000 =>
                if bit_sequence = 8 then
                  bit_sequence <= 0;
                  --ack bit
                  if (IGNORE_ACK = '1') or (ack = '1') then
                    -- slave acked, move to next state              
                    state <= STATE_DATA_READ;
                    data <= x"00000000";
                  else
                    state <= STATE_ERROR;
                  end if;
                else
                  bit_sequence <= bit_sequence+1;
                end if;
              when others => null;
            end case;
          when STATE_DATA_READ   =>
            -----------------------------------------------------------------------
            -- Read data from the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                SCLK <= '0';
                if bit_sequence /= 8 then
                  -- get ready for read
                  SDA_o <= '1'; SDA_t <= '1';
                else
                  -- check if we have more data to read
                  if transaction_byte = 0 then
                    SDA_o <= '1'; SDA_t <= '1';
                  else
                    --request another byte
                    SDA_o <= '0'; SDA_t <= '0';
                  end if;
                end if;
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                if bit_sequence /= 8 then
                  --shift in the data
                  data <= data(30 downto 0) & SDA_i;
                end if;
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
--                if bit_sequence = 8 then
--                  -- get ready for a stop condition
--                  SDA_o <= '0'; SDA_t <= '0';
--                end if;
              when PERIOD_COUNT_000 =>
                if bit_sequence = 8 then
                  bit_sequence <= 0;

                  --keep track of bytes read
                  transaction_byte <= transaction_byte -1;

                  if transaction_byte = 0 then
                    
                    state <= STATE_FINISH;
                    --We shifted in data LSB first, so we need to swap that.
                    case transaction_length is
                      when "100" =>
                        rd_data( 7 downto  0) <= data(31 downto 24);
                        rd_data(15 downto  8) <= data(23 downto 16);
                        rd_data(23 downto 16) <= data(15 downto  8);
                        rd_data(31 downto 24) <= data( 7 downto  0);
                      when "011" =>
                        rd_data( 7 downto  0) <= data(23 downto 16);
                        rd_data(15 downto  8) <= data(15 downto  8);
                        rd_data(23 downto 16) <= data( 7 downto  0);
                        rd_data(31 downto 24) <= x"00";
                      when "010" =>
                        rd_data( 7 downto  0) <= data(15 downto  8);
                        rd_data(15 downto  8) <= data( 7 downto  0);
                        rd_data(23 downto 16) <= x"00";
                        rd_data(31 downto 24) <= x"00";
                      when "001" =>
                        rd_data( 7 downto  0) <= data( 7 downto  0);
                        rd_data(15 downto  8) <= x"00";
                        rd_data(23 downto 16) <= x"00";
                        rd_data(31 downto 24) <= x"00";                        
                      when others => rd_data <= x"00000000";
                    end case;
                    --rd_data <= data;
                  end if;
                else
                  bit_sequence <= bit_sequence +1;
                end if;
              when others => null;
            end case;



                                 
          when STATE_DATA_WRITE  =>
            -----------------------------------------------------------------------
            -- Send the reg address to the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                ack <= '0';
                SCLK <= '0';
                if bit_sequence /= 8 then
                  --write out bit
                  SDA_o <= data(7-bit_sequence); sda_t <= '0';
                else
                  -- get ready to read in a bit
                  SDA_o <= '1'; SDA_t <= '1';
                end if;
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                if bit_sequence = 8 then
                  ack <= not SDA_i;
                end if;
              when PERIOD_COUNT_025 =>
                SCLK <= '0';
--                if bit_sequence = 8 then
--                  -- get ready for a stop condition
--                  SDA_o <= '0'; SDA_t <= '0';
--                end if;
              when PERIOD_COUNT_000 =>
                if bit_sequence = 8 then
                  bit_sequence <= 0;
                  --shift the data down on word
                  data <= x"00"&data(31 downto 8);
                  transaction_byte <= transaction_byte -1;

                  --Check if we are done
                  if transaction_byte = 0 then
                    state <= STATE_FINISH;      
                  elsif (IGNORE_ACK = '0') and (ack = '0') then
                    --bad ack
                    state <= STATE_ERROR;
                  end if;
                else
                  bit_sequence <= bit_sequence +1;
                end if;
              when others => null;
            end case;
            
          when STATE_ERROR       =>                
            error_local <= '1';
            if i2c_counter = PERIOD_COUNT_000 then
              state <= STATE_FINISH;
            end if;
          when STATE_FINISH      =>
            -----------------------------------------------------------------------
            -- Send the reg address to the slave
            -----------------------------------------------------------------------
            case i2c_counter is
              when PERIOD_COUNT_100 =>
                SDA_o  <= '0'; sda_t <= '0';
              when PERIOD_COUNT_075 =>
                SCLK <= '1';
              when PERIOD_COUNT_050 =>
                SDA_o  <= '1'; sda_t <= '0';
              when PERIOD_COUNT_000 =>
                state <= STATE_IDLE;
                done_local <= '1';
              when others => null;
            end case;                
          when others => null;
        end case;
      end if;
    end if;
  end process transaction_state_machine;
  
  
end architecture Behavioral;
