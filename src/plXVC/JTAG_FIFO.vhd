----------------------------------------------------------------------------------
-- Company: BU HEP
-- Engineer: Aymeric Blaizot, ablaizot@bu.edu
-- 
-- Create Date: 07/25/2023 04:16:13 PM
-- Design Name: 
-- Module Name: JTAG_FIFO - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.plXVC_CTRL.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity JTAG_FIFO is
    port (axi_clk           : in  std_logic;                      --Input axi_clk
         reset              : in  std_logic;                      --reset
         valid              : in  std_logic;
         virtual_busy       : in  std_logic;                      --virtualJTAG is busy
         virtual_interrupt  : in  std_logic;                      --virtualJTAG has finished outputting
         TDO                : in  std_logic;                      --JTAG tdo input
         CTRL               : in  std_logic;                      --Enable operation
         TMS_valid_in       : in  std_logic;
         TDI_valid_in       : in  std_logic;
         length_valid_in    : in  std_logic;
         TMS_vector         : in  std_logic_vector(31 downto 0);  --axi tms input
         TDI_vector         : in  std_logic_vector(31 downto 0);  --axi tdi input
         length             : in  std_logic_vector(31 downto 0);  --lenght of operation in bits, express as an unsigned decimal
         TMS_vector_out     : out std_logic_vector(31 downto 0);  --fifo tms output
         TDI_vector_out     : out std_logic_vector(31 downto 0);  --fifo tdi output
         length_out         : out std_logic_vector(31 downto 0);  --fifo length output
         go                 : out std_logic;
         FIFO_STATE         : out std_logic_vector(6 downto 0);
         TDO_vector         : out std_logic_vector(31 downto 0);  --axi tdo output
		 FIFO_IRQ			: out std_logic);                     --interupt request
         
end JTAG_FIFO;

architecture Behavioral of JTAG_FIFO is
------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT fifo_generator_length
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    full : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0) 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- *** StateMachine *** --
  type states is (IDLE, OPERATING, OVERFLOW, WAITING_FOR_DONE, FIFO_RESET, WAITING_IRQ, FULL);
  signal STATE          : STATES;
  signal done           : std_logic;

-- *** FIFOControl *** --
  --signal write_enable   : std_logic;
  --signal read_enable    : std_logic;
  --signal fifo_enable    : std_logic;

  signal TMS_r_en       : std_logic;
  signal TDI_r_en       : std_logic;
  signal length_r_en    : std_logic; 
  
  signal TMS_w_en       : std_logic;
  signal TDI_w_en       : std_logic;
  signal length_w_en    : std_logic;
  
  signal TMS_full       : std_logic;
  signal TDI_full       : std_logic;
  signal length_full    : std_logic;
  
  signal TMS_empty      : std_logic;
  signal TDI_empty      : std_logic;
  signal length_empty   : std_logic;

  signal TMS_valid      : std_logic;
  signal TDI_valid      : std_logic;
  signal length_valid   : std_logic;

  signal TMS_count       : std_logic_vector(10 DOWNTO 0);
  signal TDI_count       : std_logic_vector(10 DOWNTO 0);
  signal length_count    : std_logic_vector(10 DOWNTO 0);

	signal TMS_overflow		 : std_logic;
  signal TDI_overflow		 : std_logic;
	signal length_overflow : std_logic;

  signal TMS_fifo_out    : std_logic_vector(31 downto 0);
  signal TDI_fifo_out    : std_logic_vector(31 downto 0);
  signal length_fifo_out : std_logic_vector(5 downto 0); 
  
  signal f_reset     		 : std_logic := '0';
	signal F_IRQ 					 : std_logic := '0';
  signal word_out        : std_logic; 

  signal zero_l_out      : std_logic;

begin

  done <= not virtual_busy;

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG 
TMS_FIFO: fifo_generator_0
  PORT MAP (
    clk => axi_clk,
    srst => f_reset,
    din => TMS_vector,
    wr_en => TMS_w_en,
    rd_en => TMS_r_en,
    dout => TMS_fifo_out,
    full => TMS_full,
    overflow => TMS_overflow,
    empty => TMS_empty,
    valid => TMS_valid,
    data_count => TMS_count
  );

TDI_FIFO: fifo_generator_0
  PORT MAP (
    clk => axi_clk,
    srst => f_reset,
    din => TDI_vector,
    wr_en => TDI_w_en,
    rd_en => TDI_r_en,
    dout => TDI_fifo_out,
    full => TDI_full,
    overflow => TDI_overflow,
    empty => TDI_empty,
    valid => TDI_valid,
    data_count => TDI_count
  );
  
Length_FIFO: fifo_generator_length
  PORT MAP (
    clk => axi_clk,
    srst => f_reset,
    din => length(5 downto 0),
    wr_en => length_w_en,
    rd_en => length_r_en,
    dout => length_fifo_out,
    full => length_full,
    overflow => length_overflow,
    empty => length_empty,
    valid => length_valid,
    data_count => length_count
  );
    
  FIFO_IRQ <= F_IRQ;

  Outputting: process(axi_clk, reset)
  begin
    if (reset = '1') then
      TMS_vector_out <= X"00000000";
      TDI_vector_out <= X"00000000";
      length_out <= X"00000000"; 
   elsif (axi_clk'event and axi_clk='1') then
        if(TMS_r_en = '1' and TDI_r_en = '1' and length_r_en = '1' ) then 
          TMS_vector_out <= TMS_fifo_out;
          TDI_vector_out <= TDI_fifo_out;
          length_out <=  X"000000" & b"00" & length_fifo_out;
        else
          TMS_vector_out <= X"00000000";
          TDI_vector_out <= X"00000000";
          length_out <= X"00000000"; --The length needs to be zero so that the virtual jtag knows not to shift bits
        end if;
    end if;
  end process Outputting;

  Length_Check: process(axi_clk, reset)
  begin
    if (reset = '1') then
      zero_l_out <= '0';
    elsif (axi_clk'event and axi_clk='1') then
      if(length_fifo_out = b"000000" and TMS_r_en = '1' and TDI_r_en = '1' and length_r_en = '1') then 
        zero_l_out <= '1';
      end if;
    end if;
  end process Length_Check;
  
  Writing: process(axi_clk,reset)
  begin
    if (reset = '1') then
      TMS_w_en <= '0';
      TDI_w_en <= '0';
      length_w_en <= '0';
    elsif (axi_clk'event and axi_clk='1') then
     case STATE is
        when IDLE =>
          TMS_w_en <= '0';
          TDI_w_en <= '0';
          length_w_en <= '0';

        when OPERATING | WAITING_FOR_DONE | WAITING_IRQ =>
          if ( TMS_valid_in  = '1' and TMS_full = '0') then
            TMS_w_en <= '1';
          else
            TMS_w_en <= '0';
          end if;

          if (TDI_valid_in = '1' and TDI_full = '0') then
            TDI_w_en <= '1';
          else
            TDI_w_en <= '0';
          end if;

          if (length_valid_in = '1' and length_full = '0') then
            length_w_en <= '1';
          else 
            length_w_en <= '0';
          end if;

        when others =>
          TMS_w_en <= '0';
          TDI_w_en <= '0';
          length_w_en <= '0';
    end case;
  end if;
  end process Writing;
  
  Reading: process(axi_clk,reset)
  begin
    if (reset = '1') then
      TMS_r_en <= '0';
      TDI_r_en <= '0';
      length_r_en <= '0';

    elsif (axi_clk'event and axi_clk='1') then
      case STATE is
        when IDLE =>
          word_out <= '0';
          TMS_r_en <= '0';
          TDI_r_en <= '0';
          length_r_en <= '0';
        
        when OPERATING | FULL =>
          if (TMS_empty = '0' and TDI_empty = '0' and length_empty = '0' and word_out = '0') then
            TMS_r_en <= '1';
            TDI_r_en <= '1';
            length_r_en <= '1';
            word_out <= '1';
          else
            word_out <= '0';
            TMS_r_en <= '0';
            TDI_r_en <= '0';
            length_r_en <= '0';          
          end if;        
        
        when others =>
          word_out <= '0';
          TMS_r_en <= '0';
          TDI_r_en <= '0';
          length_r_en <= '0';
        end case;
    end if;        
  end process Reading;

  StateMachine: process(axi_clk,reset)
  begin
   if (reset = '1') then
			STATE <= FIFO_RESET;
      f_reset <= '1';
      go <= '0';
			F_IRQ <= '0';

   elsif (axi_clk'event and axi_clk='1') then
      case STATE is
        when IDLE => 
					F_IRQ <= '0';
          if (CTRL = '1' and valid = '1') then
            STATE <= OPERATING;
            go <= '1';
          else
            go <= '0';
            STATE <= IDLE;
          end if;
        
        when OPERATING =>
          go <= '1';
					F_IRQ <= '0';
          if (length_overflow = '1' or TMS_overflow = '1' or TDI_overflow = '1') then
            STATE <= OVERFLOW;
					elsif (CTRL = '0') then
						go <= '0';
						STATE <= IDLE;
          elsif (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
            STATE <= FULL;
          elsif (done = '0' or word_out = '1') then
            STATE <= WAITING_FOR_DONE;
					elsif (length_empty = '1' and TMS_empty = '1' and TDI_empty = '1') then
						STATE <= WAITING_IRQ;
          else
             STATE <= STATE;
          end if;

        when OVERFLOW =>
          go <= '0';
					if (length_overflow = '1' or TMS_overflow = '1' or TDI_overflow = '1') then
						STATE <= STATE;
          end if;
        
        when WAITING_FOR_DONE =>
          go <= '1';
					F_IRQ <= '0';
         
          if (CTRL = '0') then
             go <= '0';
             STATE <= IDLE;          
          elsif (length_overflow = '1' or TMS_overflow = '1' or TDI_overflow = '1') then
              STATE <= OVERFLOW;
          elsif (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
              STATE <= FULL;
          elsif ((done = '1' and virtual_interrupt = '1') or zero_l_out = '1') then
              STATE <= OPERATING;
					elsif (length_empty = '1' and TMS_empty = '1' and TDI_empty = '1') then
						STATE <= WAITING_IRQ;
          else
            STATE <= STATE;
          end if;
			
				when WAITING_IRQ =>
					F_IRQ <= '1';

					if (CTRL = '0') then
						STATE <= IDLE;
          elsif(length_empty = '0' or TMS_empty = '0' or TDI_empty = '0') then
            STATE <= OPERATING;
          elsif(length_empty = '1' and TMS_empty = '1' and TDI_empty = '1') then
						STATE <= STATE;
					end if;
    
        when FULL =>
          go <= '1';
          if (length_overflow = '1' or TMS_overflow = '1' or TDI_overflow = '1') then
            STATE <= OVERFLOW;
          elsif (length_full = '0' and TMS_full = '0' and TDI_full = '0') then
            STATE <= OPERATING;
          elsif (done = '0' or word_out = '1') then
            STATE <= WAITING_FOR_DONE;
          elsif (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
            STATE <= STATE;
          else
            go <= '0';
            STATE <= IDLE;
          end if;

        when FIFO_RESET =>
          f_reset <= '1';
					F_IRQ <= '0';
          if ((length_full = '1' and length_empty = '1' and TMS_empty = '1' and TMS_full = '1' and TDI_empty = '1' and TDI_full = '1') or reset = '1') then
            STATE <= STATE;
					else
						STATE <= IDLE;
						f_reset <= '0';
					end if;           
        end case;
   end if;
  end process StateMachine;
  
  StateEncoder: process (axi_clk, reset)
  begin
    if (reset = '1') then
      FIFO_STATE <= b"0000100";
   elsif (axi_clk'event and axi_clk='1') then
      case STATE is 
        when IDLE =>
          FIFO_STATE <= b"1000000";
        when OPERATING =>
          FIFO_STATE <= b"0100000";
        when OVERFLOW =>
          FIFO_STATE <= b"0010000";
        when WAITING_FOR_DONE =>
          FIFO_STATE <= b"0001000";
        when FIFO_RESET =>
          FIFO_STATE <= b"0000100";
        when WAITING_IRQ =>
          FIFO_STATE <= b"0000010";
        when FULL =>
          FIFO_STATE <= b"0000001";
      end case;
    end if;
  end process StateEncoder;
  
end Behavioral;
