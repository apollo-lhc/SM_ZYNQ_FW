----------------------------------------------------------------------------------
-- Company: BU EDF
-- Engineer: Michael Kremer, kremerme@bu.edu
-- Create Date: 05/14/2020 09:50:43 AM
-- Module Name: virtualJTAG - Behavioral
-- Description: 
-- Dependencies:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; --For std_logic
use IEEE.NUMERIC_STD.ALL; --For unsigned numbers
-- Not Needed? -- use work.plXVC_Ctrl.all; --For XVC_Ctrl_t

  entity virtualJTAG is
    generic (-- NOT WORKING CURRENTLY TCK_RATIO    : in  integer := 1;                   --ratio of axi_clk to TCK
             IRQ_LENGTH   : in  integer := 1);                  --Length of IRQ in axi_clk ticks
      port  (axi_clk      : in  std_logic;                      --Input axi_clk
             reset        : in  std_logic;                      --reset
             TMS_vector   : in  std_logic_vector(31 downto 0);  --axi tms input
             TDI_vector   : in  std_logic_vector(31 downto 0);  --axi tdi input
             TDO          : in  std_logic;                      --JTAG tdo input
             length       : in  std_logic_vector(31 downto 0);  --lenght of operation in bits, express as an unsigned decimal
             CTRL         : in  std_logic;                      --Enable operation
             TMS          : out std_logic;                      --JTAG tms output
             TDI          : out std_logic;                      --JTAG tdi output
             TDO_vector   : out std_logic_vector(31 downto 0);  --axi tdo output
             TCK          : out std_logic;                      --output TCK
             busy         : out std_logic;                      --virtualJTAG is outputting
             interupt     : out std_logic);                     --interupt
  end virtualJTAG;

architecture Behavioral of virtualJTAG is

-- *** TIMING *** --
  signal timer        : integer := 1;
  signal TCK_buffer   : std_logic;
  signal TCK_counter  : unsigned(5 downto 0);
  constant TCK_RATIO  : integer := 1;

-- *** Shifting *** --
  signal TMS_latch    : std_logic_vector(31 downto 0);
  signal TDI_latch    : std_logic_vector(31 downto 0);
  signal TDO_buffer   : std_logic_vector(31 downto 0);
  signal length_latch : unsigned(5 downto 0);

-- *** StateMachine *** --
  type states is (IDLE, OPERATING);
  signal STATE          : states;
  signal interupt_sr    : std_logic_vector((IRQ_LENGTH - 1) downto 0);
  constant ready        : std_logic_vector((IRQ_LENGTH - 1) downto 0) := (others => '0');

begin

  TCK <= TCK_buffer;            --Assign TCK from buffer
  TDO_vector <= TDO_buffer;     --Assign TDO from buffer
  interupt <= interupt_sr(0);   --Assign interupt from shift reg
  --Assign TDI and TMS from latches
  --TDI <= TDI_latch(31); --if MSB of AXI is bit 0
  --TMS <= TMS_latch(31); --if MSB of AXI is bit 0
  TDI <= TDI_latch(0); --if MSB of AXI is bit 31 shift out bit 0
  TMS <= TMS_latch(0); --if MSB of AXI is bit 31 shift out bit 0

--This process handles the conversion from the axi_clk to the TCK defined by
--the TCK_RATIO generic
  Timing : process (axi_clk, reset)
  begin
    if (reset = '1') then --reset case
      TCK_counter <= "000001";
      timer <= 1;
      TCK_buffer <= '0';
      
    elsif (axi_clk'event and axi_clk='1') then --rising 
      case STATE is
        when IDLE => --do nothing
          TCK_counter <= "000001";
          timer <= 1;
          TCK_buffer <= '0';
          
        when OPERATING => --generate (length + 1) TCK clock cycles
          if (timer = TCK_RATIO) then
            timer <= 1; --reset timer
            TCK_buffer <= not TCK_buffer; --flip TCK
            if (TCK_buffer = '1') then --
              TCK_counter <= TCK_counter + 1;
            else
              TCK_counter <= TCK_counter;
            end if;
          else
            timer <= timer + 1; 
          end if;                
          
        when others => --default case
          TCK_counter <= "000001";
          timer <= 1;
          TCK_buffer <= '0';
      end case;
    end if;
    
  end process Timing;

--This process latchs the AXI inputs on CTRL signal and then shift out these
--vectors to the JTAG single bit outputs
  Shifting : process(axi_clk, reset)
  begin
    if (reset = '1') then
      TMS_latch <= X"00000000";
      TDI_latch <= X"00000000";
      length_latch <= "000000";
      
    elsif (axi_clk'event and axi_clk='1') then
      case STATE is
        when IDLE =>
          if (CTRL = '1') then
            TMS_latch <= TMS_vector;
            TDI_latch <= TDI_vector;
            --TDO_buffer <= X"00000000";
 
            length_latch <= unsigned(length(5 downto 0)) + 0;

         --length_latch <= unsigned(length(5 downto 0)) + 1;

          end if;
          
        -- *** NOTE *** ---
        -- This assumes bits are loaded into JTAG MSB first, sources seem to be conflicting,
        -- so if stuff starts to look backwards, these shifts are where thats happening    
        when OPERATING =>
          if (timer = TCK_RATIO) then --TCK flip
            if (TCK_buffer = '1') then --negative edge of TCK so shift TDI & TMS
              TDI_latch(31 downto 0) <= '0' & TDI_latch(31 downto 1); --if MSB of AXI is b31
              --TDI_latch(31 downto 0) <= TDI_latch(30 downto 0) & '0'; --if MSB of AXI is bit 0
              TMS_latch(31 downto 0) <= '0' & TMS_latch(31 downto 1); --if MSB of AXI is bit 31
              --TMS_latch(31 downto 0) <= TMS_latch(30 downto 0) & '0'; --if MSB of AXI is bit 0
              --TDO_buffer(to_integer(TCK_counter) - 1) <= TDO; --if MSB of AXI is bit 31???
            --else --positive edge of TCK so read in TDO
              --if (TCK_counter /= "000000") then --not first TCK cycle
                --TDO_buffer(to_integer(TCK_counter - 1 )) <= TDO; --if MSB of AXI is bit 31???
                --TDO_buffer(31 downto 0) <= TDO & TDO_buffer(31 downto 1); --if MSB of AXI is bit 0???
              --end if;
            end if;
          end if;
          
        when others => --default case
          TMS_latch <= X"00000000";
          TDI_latch <= X"00000000";
          length_latch <= "000000";
      end case;
    end if;
  end process Shifting;

--This process sets the STATE of the vritualJTAG cable between IDLE and OPERATING
  StateMachine : process(axi_clk, reset)
  begin
    if (reset = '1') then
      STATE <= IDLE;
      TDO_buffer <= X"00000000";
      interupt_sr <= (others => '0');
      
    elsif (axi_clk'event and axi_clk='1') then
      case STATE is
        when IDLE =>
          interupt_sr <= '0' & interupt_sr((IRQ_LENGTH - 1) downto 1);
          if (CTRL = '1') then
            if (length /= X"00000000") then --don't do anything if length is 0
              --if (interupt_sr = ready) then --not still in interupt
                STATE <= OPERATING;
                TDO_buffer <= X"00000000";
                busy <= '1';
              --else
                --STATE <= IDLE;
                --busy <= '0';
              --end if;
            else
              STATE <= IDLE;
              busy <= '0';
            end if;
          else
            STATE <= IDLE;
            busy <= '0';
          end if;
          
        when OPERATING =>
          TDO_buffer(to_integer(TCK_counter) - 1) <= TDO; --if MSB of AXI is bit 31???
          if (TCK_counter = length_latch) then 
            if (timer = TCK_RATIO) then
              if (TCK_buffer = '1') then --After (length + 1) TCK clocks
                STATE <= IDLE;
                busy <= '0';
                interupt_sr <= (others => '1');
              else
                STATE <= STATE;
                busy <= '1';
                interupt_sr <= '0' & interupt_sr((IRQ_LENGTH - 1) downto 1);
              end if;
            else
              STATE <= STATE;
              busy <= '1';
              interupt_sr <= '0' & interupt_sr((IRQ_LENGTH - 1) downto 1);
            end if;
          else
            STATE <= STATE;
            busy <= '1';
            interupt_sr <= '0' & interupt_sr((IRQ_LENGTH - 1) downto 1);
          end if;
          
        when others => --default to IDLE
          STATE <= IDLE;
          TDO_buffer <= X"00000000";
          busy <= '0';
          interupt_sr <= (others => '0');
      end case;
    end if;
  end process StateMachine;
end Behavioral;
