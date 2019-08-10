library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_misc.all;

-------------------------------------------------------------------------------
-- I2C Slave
-------------------------------------------------------------------------------
-- This is a simple i2c slave to 8bit addressed register block
--
-- Reads:
--   To read from a register first do a full write transaction that sends the
--   8bit address.
--   Then do a read transaction with 1 to N bytes, finishing by master non-ack.
--   The address will auto increment.
--
-- Writes:
--   First write the 8 bit register address, then in the same i2c transaction
--   write your date bytes.  The address will auto increment.
--   
-- Notes for = '1' on inout derived signals.
-- We need to put in /= '0' to replace this to cover the 'Z'/'H'/'1' issue
-------------------------------------------------------------------------------

entity i2c_slave is
  generic (
    REGISTER_COUNT_BIT_SIZE : integer range 1 to 8 := 4;
    TIMEOUT_COUNT : unsigned(31 downto 0) := x"00100000");
  port (
    reset   : in std_logic;
    clk     : in std_logic;             -- several Mhz clock
    
    SDA_in  : in std_logic;
    SDA_out : out std_logic;
    SDA_en  : out std_logic;
    
    SCL     : in  std_logic;
    address    : in  std_logic_vector(6 downto 0);

    data_out : out std_logic_vector(7 downto 0);
    data_out_dv : out std_logic;
    data_in  : in std_logic_vector(7 downto 0);
    register_address : out std_logic_vector(REGISTER_COUNT_BIT_SIZE-1 downto 0)
    
    );        

end i2c_slave;          
architecture Behavioral of i2c_slave is

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------
  signal SDA_in_old : std_logic;
  signal SCL_old : std_logic;
  signal serial_monitor_counter : unsigned(31 downto 0);
  signal internal_reset : std_logic;
  
  signal start : std_logic;
  signal stop : std_logic;

  signal local_register_address : unsigned(REGISTER_COUNT_BIT_SIZE-1 downto 0);
  signal bit_count : unsigned(3 downto 0);
  signal input_byte : std_logic_vector(7 downto 0);
  signal output_byte : std_logic_vector(7 downto 0);
  
  type i2c_state is (STATE_IDLE,
                     STATE_DEV_ADDR,
                     STATE_MASTER_READ,
                     STATE_REG_ADDR_SET,
                     STATE_MASTER_WRITE);
  signal state : i2c_state;

  signal ack_bit : std_logic;
  signal lsb_bit : std_logic;
  
  signal address_detect : std_logic;
begin  -- Behavioral

  -----------------------------------------------------------------------------
  -- Keep an copy of the previous states of SDA and SCL for edge detection
  -----------------------------------------------------------------------------
  serial_monitor: process (clk, reset)
  begin  -- process serial_monitor
    if reset = '1' then                 -- asynchronous reset (active high)
      SDA_in_old <= '1';
      SCL_old <= '1';
      serial_monitor_counter <= x"00000000";
      internal_reset <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- keep track of SDA and SCL transitions      
      SDA_in_old <= SDA_in;
      SCL_old <= SCL;

      --monitor the serial interface for an error
      serial_monitor_counter <= serial_monitor_counter + 1;
      internal_reset <= '0';
      if SDA_in = '1' and SCL = '1' then
        serial_monitor_counter <= x"00000000";
      elsif serial_monitor_counter = TIMEOUT_COUNT then
        internal_reset <= '1';
      end if;      
    end if;
  end process serial_monitor;
  
  -----------------------------------------------------------------------------
  -- detect start of i2c sequence
  -----------------------------------------------------------------------------
  detect_start: process (clk, internal_reset)
  begin  -- process detect_start
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      start <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge      
      -- Look for a start sequence on falling SDA edge if we are not in start      
      if start = '0' then
        if SDA_in_old = '1' and SDA_in = '0' then
          start <= SCL;
        end if;
      -- if we are in start, look for SCL rising to internal_reset start
      else
        if SCL_old = '1' and SCL = '0' then
          start <= '0';
        end if;
      end if;
    end if;
  end process detect_start;
  
  -----------------------------------------------------------------------------
  -- detect stop of a i2c sequence
  -----------------------------------------------------------------------------
  detect_stop: process (clk, internal_reset)
  begin  -- process detect_stop
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      stop <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if stop = '0' then
        if SDA_in_old = '0' and SDA_in = '1' then
          stop <= SCL;
        end if;
      else
        if SCL = '1' then
          stop <= '0';
        end if;
      end if;
    end if;
  end process detect_stop;

  -----------------------------------------------------------------------------
  -- bit counter for 8 bit words and lsb/ack bit signals
  -----------------------------------------------------------------------------
  bit_clock: process (clk, internal_reset)
  begin  -- process bit_clock
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      bit_count <= "0000";
      lsb_bit <= '0';
      ack_bit <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      if start = '1' and SCL = '1' then
        bit_count <= "0000";
        lsb_bit <= '0';
        ack_bit <= '0';                   
      elsif SCL_old = '1' and SCL = '0' then  -- update on the falling edge so we
                                           -- are ready for capture/output on
                                           -- the rising edge
        
        -- count which bit we are on in this 9 bit sequence
        bit_count <= bit_count + 1;

        lsb_bit <= '0';
        ack_bit <= '0';
        if bit_count = 7 then
          lsb_bit <= '1';
        elsif bit_count = 8 then
          ack_bit <= '1';
          bit_count <= "0000";
        elsif bit_count = 0 then
        end if;
      end if;
    end if;
  end process bit_clock;

  -----------------------------------------------------------------------------
  -- capture incoming bit stream
  -----------------------------------------------------------------------------
  input_capture: process (clk, internal_reset)
  begin  -- process input_capture
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      input_byte <= x"00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SCL_old = '0' and SCL = '1' then
        -- shift in new bit on rising clock
        input_byte <= input_byte(6 downto 0) & SDA_in;
      end if;
    end if;
  end process input_capture;

  address_detector: process (clk, internal_reset)
  begin  -- process address_detect
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      address_detect <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SCL_old = '1' and SCL = '0' then
        if bit_count = 7 then           -- we now have the full address
          -- check if this is our address
          if input_byte(6 downto 0) = address then
            address_detect <= '1';
          end if;
        elsif bit_count = 0 then
          address_detect <= '0';
        end if;
      end if;
    end if;
  end process address_detector;

  -----------------------------------------------------------------------------
  -- primary state machine
  -----------------------------------------------------------------------------
  --         
  --         
  --                                                          Master ACK
  --                                                          reg addr++
  --         
  --                                                        +-----------+
  --                                                        |           |
  --              +-----------+  slv addr +------------+    |     +-----+------+
  --              |           |           |            |    v     |            |
  -- start +----->+ DEV_ADDR  +---------->+REG_ADDR_SET+----+---->+MASTER_WRITE|
  --              |           |           |            |          |            |
  --              +-----+-----+           +-----+------+          +-----+------+
  --                    |                       |                       |                    +--------+
  --                    |              +------->+                       |                    |        |
  --                    |   Master ACK |        v                       |                    v        |
  --                    |   reg addr++ |  +-----+-----+                 |              +-----+-----+  |
  --          !slv addr |              |  |           |                 v              |           |  |
  --                    |              +--+MASTER_READ+------------------------------->+   IDLE    +--+
  --                    |                 |           |                 ^              |           |
  --                    |                 +-----------+                 |              +-----------+
  --                    |                                               |
  --                    +-----------------------------------------------+
  --    
  --    
  state_machine: process (clk, internal_reset)
  begin  -- process state_machine
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      state <= STATE_IDLE;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if stop = '1' then
        state <= STATE_IDLE;
      elsif SCL_old = '1' and SCL = '0' then
        if start = '1' then
          state <= STATE_DEV_ADDR;       
        elsif ack_bit = '1' then
          case state is
            -------------------------------------------------------------------
            when STATE_IDLE =>
              state <= STATE_IDLE;
            -------------------------------------------------------------------
            when STATE_DEV_ADDR =>
              if address_detect = '0' then
                -- not our address, go back to idle
                state <= STATE_IDLE;
              elsif input_byte(0) = '0' then
                -- master is going to write to us, so this is a new register address
                state <= STATE_REG_ADDR_SET;                
              else
                -- master is going to read from us
                state <= STATE_MASTER_READ;
              end if;
            ------------------------------------------------------------------
            when STATE_MASTER_READ =>
              state <= STATE_MASTER_READ;
--              if input_byte(0) = '0' then
--                -- master wants to read another byte
--                state <= STATE_MASTER_READ;
--              else
--                -- master is done reading
--                state <= STATE_IDLE;
--              end if;
            ------------------------------------------------------------------
            when STATE_REG_ADDR_SET =>
              state <= STATE_MASTER_WRITE;
            ------------------------------------------------------------------             
            when STATE_MASTER_WRITE =>
                state <= STATE_MASTER_WRITE;
            when others => state <= STATE_IDLE;
          end case;
        end if;
      end if;
    end if;
  end process state_machine;
  


  -----------------------------------------------------------------------------
  -- registers
  -----------------------------------------------------------------------------
  register_address_proc: process (clk, internal_reset)
  begin  -- process register_address
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      local_register_address <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if stop = '1' then
        local_register_address <= (others => '0');
      elsif SCL_old = '0' and SCL = '1' then
        register_address <= std_logic_vector(local_register_address);
        -- update the register address
        if ack_bit = '1' then
          if state = STATE_REG_ADDR_SET then
            local_register_address <= unsigned(input_byte(REGISTER_COUNT_BIT_SIZE-1 downto 0));
          else
            local_register_address <= local_register_address + 1;
          end if;          
        end if;
      end if;      
    end if;
  end process register_address_proc;

 
  write_register: process (clk, internal_reset)
  begin  -- process write_registers
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      data_out_dv <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- if the master has writen all the bits of this byte, set the write
      -- write out the data
      if SCL_old = '0' and SCL = '1' then
        if state = STATE_MASTER_WRITE and ack_bit = '1' then
          data_out <= input_byte;
          data_out_dv <= '1';
        else
          data_out_dv <= '0';        
        end if;
      end if;
    end if;
  end process write_register;

  read_register: process (clk, internal_reset)
  begin  -- process read_register
    if internal_reset = '1' then                 -- asynchronous internal_reset (active low)
      output_byte <= x"00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SCL_old = '0' and SCL = '1' then
        -- load next round of bits on the ack bit on the rising edge of the clock
        if ack_bit = '1' then
          output_byte <= data_in;
        -- shift through the bits on other rising edges
        else
          output_byte <= output_byte(6 downto 0) & '0';
        end if;
      end if;
    end if;
  end process read_register;
  
  -----------------------------------------------------------------------------
  -- Output driver
  -----------------------------------------------------------------------------
  SDA_driver: process (clk, internal_reset)
  begin  -- process SDA_driver
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      SDA_out <= '1';
      SDA_en  <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SCL_old = '1' and SCL = '0' then
        SDA_out <= '1';
        SDA_en  <= '0';
        if lsb_bit = '1' then
          if state = STATE_DEV_ADDR and address_detect = '1' then
            -- acknowledge when being addressed
            SDA_out <= '0';
            SDA_en  <= '1';
          elsif state = STATE_REG_ADDR_SET then
            -- acknowledge an addressing word
            SDA_out <= '0';
            SDA_en  <= '1';
          elsif state = STATE_MASTER_WRITE then
            -- acknowledge a word from the master
            SDA_out <= '0';
            SDA_en  <= '1';
          end if;
        elsif ack_bit = '1' then
          if (state = STATE_MASTER_READ and input_byte(0) = '0') or
             (state = STATE_DEV_ADDR and address_detect = '1') then
            if output_byte(7) = '0' then
              SDA_out <= '0';
              SDA_en  <= '1';
            end if;                     
          end if;
        elsif state = STATE_MASTER_READ then
          if output_byte(7) = '0' then
            SDA_out <= '0';
            SDA_en  <= '1';
          end if;
        end if;
      end if;
    end if;
  end process SDA_driver;

end Behavioral;
