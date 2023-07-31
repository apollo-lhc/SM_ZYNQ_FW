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
         done               : in  std_logic;                      --virtualJTAG is done outputting
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
         FIFO_STATE         : out std_logic_vector(5 downto 0);
         TDO_vector         : out std_logic_vector(31 downto 0);  --axi tdo output
         busy               : out std_logic;                      --virtualJTAG is outputting
         interupt           : out std_logic);                     --interupt
         
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
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- *** StateMachine *** --
  type states is (IDLE, OPERATING, FULL, WAITING_DONE, FIFO_RESET, WAITING_IRQ);
  signal STATE          : STATES;
  signal interrupt_sr   : std_logic;

-- *** FIFOControl *** --
  --signal write_enable   : std_logic;
  signal read_enable    : std_logic;
  signal fifo_enable    : std_logic;

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
  
  signal TMS_fifo_out    : std_logic_vector(31 downto 0);
  signal TDI_fifo_out    : std_logic_vector(31 downto 0);
  signal length_fifo_out : std_logic_vector(31 downto 0); 
  
  signal f_reset     : std_logic; 

begin
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
TDI_FIFO: fifo_generator_0
  PORT MAP (
    clk => axi_clk,
    srst => reset,
    din => TDI_vector,
    wr_en => TDI_w_en,
    rd_en => TDI_r_en,
    dout => TDI_fifo_out,
    full => TDI_full,
    overflow => open,
    empty => TDI_empty,
    valid => TDI_valid,
    data_count => TDI_count
  );
  
TMS_FIFO: fifo_generator_0
  PORT MAP (
    clk => axi_clk,
    srst => reset,
    din => TMS_vector,
    wr_en => TMS_w_en,
    rd_en => TMS_r_en,
    dout => TMS_fifo_out,
    full => TMS_full,
    overflow => open,
    empty => TMS_empty,
    valid => TMS_valid,
    data_count => TMS_count
  );
  
Length_FIFO: fifo_generator_0
  PORT MAP (
    clk => axi_clk,
    srst => reset,
    din => length,
    wr_en => length_w_en,
    rd_en => length_r_en,
    dout => length_fifo_out,
    full => length_full,
    overflow => open,
    empty => length_empty,
    valid => length_valid,
    data_count => length_count
  );
    
  interupt <= interrupt_sr;
  
  Outputting: process(axi_clk,reset)
  begin
    if (reset = '1') then
      TMS_vector_out <= X"00000000";
      TDI_vector_out <= X"00000000";
      length_out <= X"00000000"; 
   elsif (axi_clk'event and axi_clk='1') then
        if(TMS_r_en = '1' and TDI_r_en = '1' and length_r_en = '1' ) then 
          TMS_vector_out <= TMS_fifo_out;
          TDI_vector_out <= TDI_fifo_out;
          length_out <= length_fifo_out;
        else
          TMS_vector_out <= X"00000000";
          TDI_vector_out <= X"00000000";
          length_out <= X"00000000"; --The length needs to be zero so that the virtual jtag knows not to shift bits
        end if;
    end if;
  end process Outputting;
  
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

        when OPERATING =>
          if fifo_enable = '1' then
              TMS_w_en <= '1';
              TDI_w_en <= '1';
              length_w_en <= '1';
          else
              if (TMS_full = '0' and TMS_valid_in  = '1') then
                TMS_w_en <= '1';
              else
                TMS_w_en <= '0';
              end if;
    
              if (TDI_full = '0' and TDI_valid_in = '1') then
                TDI_w_en <= '1';
              else
                TDI_w_en <= '0';
              end if;
    
              if (length_full = '0' and length_valid_in = '1') then
                length_w_en <= '1';
              else 
                length_w_en <= '0';
              end if;
          end if;
        
        when WAITING_DONE =>
           if (TMS_full = '0' and TMS_valid_in  = '1') then
            TMS_w_en <= '1';
          else
            TMS_w_en <= '0';
          end if;

          if (TDI_full = '0' and TDI_valid_in = '1') then
            TDI_w_en <= '1';
          else
            TDI_w_en <= '0';
          end if;

          if (length_full = '0' and length_valid_in = '1') then
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
          TMS_r_en <= '0';
          TDI_r_en <= '0';
          length_r_en <= '0';
        
        when OPERATING =>
          if (TMS_empty = '0' and TDI_empty = '0' and length_empty = '0') then
            TMS_r_en <= '1';
            TDI_r_en <= '1';
            length_r_en <= '1';
          else
            TMS_r_en <= '0';
            TDI_r_en <= '0';
            length_r_en <= '0';          
          end if;
          
        when FULL =>
          if (TMS_valid = '1' and TDI_valid = '1' and length_valid = '1') then
            TMS_r_en <= '1';
            TDI_r_en <= '1';
            length_r_en <= '1';
          else
            TMS_r_en <= '0';
            TDI_r_en <= '0';
            length_r_en <= '0';          
          end if;
        
        when others =>
          TMS_r_en <= '0';
          TDI_r_en <= '0';
          length_r_en <= '0';
        end case;
    end if;        
  end process Reading;

  StateMachine: process(axi_clk,reset)
  begin
   if (reset = '1') then
      STATE <= IDLE;
      interupt <= '0';
      go <= '0';

   elsif (axi_clk'event and axi_clk='1') then
      case STATE is
        when IDLE => 
          interupt <= '0';
          if (CTRL = '1' and valid = '1') then
            fifo_enable <= '1';
            STATE <= OPERATING;
            go <= '1';
          else
            go <= '0';
            STATE <= IDLE;
          end if;
        
        when OPERATING =>
          fifo_enable <= '0';
          go <= '1';
          if (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
             STATE <= FULL;
          elsif (done = '0') then
             STATE <= WAITING_DONE;  
          elsif (CTRL = '0') then
             go <= '0';
             STATE <= IDLE;
          else
             STATE <= STATE;
          end if;
        
        when FULL =>
          go <= '1';
          if (length_full = '0' and TMS_full = '0' and TDI_full = '0') then
            STATE <= OPERATING;
          elsif (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
            STATE <= STATE;
          elsif (done = '0') then
            STATE <= WAITING_DONE;
          else
            go <= '0';
            STATE <= IDLE;
          end if;
        
        when WAITING_DONE =>
          go <= '1';
          if (length_full = '1' or TMS_full = '1' or TDI_full = '1') then
            STATE <= FULL;
          elsif (done = '1') then
            STATE <= OPERATING;
          elsif (CTRL = '0') then
             go <= '0';
             STATE <= IDLE;
          else
            STATE <= STATE;
          end if;
          
       when FIFO_RESET =>
          f_reset <= '1';
          if (length_full = '1' and length_empty = '1') then
            STATE <= STATE;
          end if;           
       end case;
   end if;
  end process StateMachine;
  
  StateEncoder: process
  begin
    case STATE is 
      when IDLE =>
        FIFO_STATE <= b"100000";
      when OPERATING =>
        FIFO_STATE <= b"010000";
      when FULL =>
        FIFO_STATE <= b"001000";
      when WAITING_DONE =>
        FIFO_STATE <= b"000100";
      when FIFO_RESET =>
        FIFO_STATE <= b"000010";
      when WAITING_IRQ =>
        FIFO_STATE <= b"000001";
    end case;
  end process StateEncoder;
  
end Behavioral;
