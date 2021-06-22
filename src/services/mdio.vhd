-- The MDIO serial control interface allows communication be-
-- tween a station management controller and SCAN25100 de-
-- vices. MDIO and MDC pins are 3.3V LVTTL compliant, not
-- 1.2V compatiable. It is software compatible with the station
-- management bus defined in IEEE 802.3ae-2002. The serial
-- control interface consists of two pins, the data clock MDC and
-- bidirectional data MDIO. MDC has a maximum clock rate of
-- 2.5 MHz and no minimum limit. The MDIO is bidirectional and
-- can be shared by up to 32 physical devices.

-- The MDIO pin requires a pull-up resistor which, during IDLE
-- and turnaround, will pull MDIO high. The parallel equivalence
-- of the MDIO when shared with other devices should not be
-- less than 1.5 kΩ. Note that with many devices in parallel, the
-- internal pull-up resistors add in parallel. Signal quality on the
-- net should provide incident wave switching. It may be desir-
-- able to control the edge rate of MDC and MDIO from the
-- station management controller to optimize signal quality de-
-- pending upon the trace net and any resulting stub lengths.

-- In order to initialize the MDIO interface, the station manage-
-- ment sends a sequence of 32 contiguous logic ones on MDIO
-- with MDC clocking. This preamble may be generated either
-- by driving MDIO high for 32 consecutive MDC clock cycles,
-- or by simply allowing the MDIO pull-up resistor to pull the
-- MDIO high for 32 MDC clock cycles. A preamble is required
-- for every operation (64-bit frames, do not suppress preambles).
-- MDC is an a periodic signal. Its high or low duration is 160 ns
-- minimum and has no maximum limit. Its period is 400 ns min-
-- imum. MDC is not required to maintain a constant phase
-- relationship with TXCLK, SYSCLK, and REFCLK. The follow-
-- ing table shows the management frame structure in according
-- to IEEE 802.3ae.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mdio is
   generic (
        COUNT_WIDTH     : integer := 32
   );
   port (
        reset		: in std_logic;
        -- led		: buffer std_logic_vector(3 downto 0) := (OTHERS => '0');

	clk_in 		: in std_logic; -- deve essere < 2.5 MHz!

	serial_clock    : out std_logic := '0'; -- deve essere < 2.5 MHz!
	serial_data     : inout std_logic;

	-- 00: Address
        -- 10: Read-Inc
	-- 11: Read
        -- 01: Write
	opcode  	: in std_logic_vector(1 downto 0);
   	mdio_address    : in std_logic_vector(4 downto 0);
   	device_address  : in std_logic_vector(4 downto 0);

	data_read       : out std_logic_vector(15 downto 0);
	data_write      : in std_logic_vector(15 downto 0);
	start_conversion : in std_logic;

	running_conversion  : out std_logic;
	error_code          : out std_logic_vector(2 downto 0);
	hexint 		    : out std_logic_vector(3 downto 0)
   );
end entity mdio;

architecture rtl of mdio is

   type tipo_stato is ( WaitStart, WaitStart2, Preamble, StartOpcode, MdioAddress, DeviceAddress, TurnAroundDataRead, TurnAroundDataWrite, DataRead, DataWrite );
   signal start_opcode : std_logic_vector(3 downto 0);

   signal stato       	: tipo_stato := WaitStart;
   signal start_conversion_loc : std_logic := '0';
   
   signal serial_trigger : std_logic_vector(1 downto 0) := "00";

   signal serial_clock_local : std_logic;
   signal hexint_local       : std_logic_vector( 3 downto 0);
   signal data_read_local    : std_logic_vector(15 downto 0);
   signal running_conversion_local : std_logic;
   signal error_code_local   : std_logic_vector(2 downto 0);
   
   --Added
   signal counter  : unsigned(COUNT_WIDTH-1 downto 0);
begin
   start_opcode <= "00" & opcode;

--    with stato select led(3 downto 1) <=
-- 	"000" when WaitStart,
-- 	"001" when Preamble,
-- 	"010" when StartOpcode,
-- 	"011" when MdioAddress,
-- 	"100" when DeviceAddress,
-- 	"110" when DataWrite,
-- 	"111" when DataRead,
-- 	"101" when OTHERS;

   hexint <= hexint_local;
   serial_clock <= serial_clock_local;
   data_read <= data_read_local;
   running_conversion <= running_conversion_local;
   error_code <= error_code_local;
   process(clk_in,reset)
   begin
     if reset = '1' then
       counter <= (others => '0');
     elsif clk_in'event and clk_in = '1' then
        counter <= counter + 1;
        serial_clock_local <= counter(COUNT_WIDTH-1);
        serial_trigger <= serial_trigger(0) & counter(COUNT_WIDTH-1) ;       
      end if;
   end process;

   -- serial_clock_local <= clk_in;

--    process(clk_in)
--    begin
--       if falling_edge(clk_in) then
--          serial_trigger <= not serial_trigger;
--       end if;
--    end process;

   -- process(serial_trigger, reset)
   process(clk_in, reset)
      variable bit_counter : natural range 0 to 31 := 0;
   begin
      
      if reset = '1' then
	 stato <= WaitStart;
	 bit_counter := 0;
         start_conversion_loc <= '0';
	 running_conversion_local <= '0';
	 error_code_local <= "000";
	 serial_data <= 'Z';
	 hexint_local <= x"0";
      elsif clk_in'event and clk_in = '1' then
        if start_conversion = '1' then
          start_conversion_loc <= '1';
        end if;
        if serial_trigger = "10" then

	    case stato is

	       when WaitStart =>
		  serial_data <= 'Z';
		  stato <= WaitStart2;
		  
	       when WaitStart2 =>

		  if hexint_local = x"0" and serial_data = '0' then
		     hexint_local <= x"1";
		  end if;

		  if start_conversion_loc = '1' then
		     start_conversion_loc <= '0';
		     bit_counter := 31;
		     stato <= Preamble;
		     running_conversion_local <= '1';
		     error_code_local <= "000";
	          else
		     running_conversion_local <= '0';
		  end if;

	       when Preamble =>
		  -- serial_data <= '1';

		  if serial_data = '0' then
		     hexint_local <= x"2";
		     stato <= WaitStart;
                  else
		     if bit_counter > 0 then
		        bit_counter := bit_counter - 1;
		     else
   		        stato <= StartOpcode;
		        bit_counter := 3;
		     end if;
		  end if;

	       when StartOpcode =>
		  serial_data <= start_opcode(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= MdioAddress;
		     bit_counter := 4;
		  end if;

	       when MdioAddress =>
		  serial_data <= mdio_address(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= DeviceAddress;
		     bit_counter := 4;
		  end if;

	       when DeviceAddress =>
		  serial_data <= device_address(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     if opcode(1) = '1' then
			stato <= TurnAroundDataRead;
		     else
			stato <= TurnAroundDataWrite;
		     end if;
		  end if;

	       when TurnAroundDataWrite =>
		  if bit_counter = 0 then
		     serial_data <= '1';
		     bit_counter := 15;
		  else 
		     serial_data <= '0';
		     stato <= DataWrite;
		  end if;

	       when DataWrite =>
		  serial_data <= data_write(bit_counter);

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= WaitStart;
		  end if;

	       when TurnAroundDataRead =>
		  serial_data <= 'Z';
		  
		  if bit_counter = 0 then
  	             bit_counter := 15;
		  else

 	             if serial_data = '0' then
		        stato <= DataRead;
		     else
		        stato <= WaitStart; -- ERRORE!
		        -- stato <= DataRead;
		        error_code_local <= "001";
		        hexint_local <= x"4";
		     end if;
                  end if;

	       when DataRead =>
	          data_read_local(bit_counter) <= serial_data;

		  if bit_counter > 0 then
		     bit_counter := bit_counter - 1;
		  else
		     stato <= WaitStart;
		  end if;
		  
	       when others =>
		  stato <= WaitStart;
 		  serial_data <= 'Z';
		  error_code_local <= "111";
		  hexint_local <= x"3";

	    end case;
	 end if;
      end if; -- if reset
   end process;

   myila_0: entity work.my_ila
     port map(
       clk       => clk_in,
       probe0(0)    => serial_clock_local,
       probe1(0)    => serial_data,
       probe2(0)    => start_conversion,
       probe3    => opcode,
       probe4    => mdio_address,
       probe5    => device_address,
       probe6    => data_read_local,
       probe7    => data_write,
       probe8(0)    => running_conversion_local,
       probe9    => error_code_local,
       probe10   => hexint_local
       );
   
end rtl;

