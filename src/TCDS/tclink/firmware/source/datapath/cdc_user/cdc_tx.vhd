--==============================================================================
-- © Copyright CERN for the benefit of the HPTD interest group 2019. All rights not
--   expressly granted are reserved.
--
--   This file is part of TClink.
--
-- TClink is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- TClink is distributed in the hope that it will be useful,
-- but WITHout ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with TClink.  If not, see <https://www.gnu.org/licenses/>.
--==============================================================================
--! @file cdc_tx.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Specific packages

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Tx mesochronous fixed-phase clock-domain crossing
--
--! @brief Mesochronous fixed-phase CDC for Transmitter
--! - This Clock-domain crossing requires that the clk_a_i and clk_b_i are an integer related of each other
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 30\06\2020
--! @version 1.0
--! @details
--!
--! <b>Dependencies:</b>\n
--! <Entity Name,...>
--!
--! <b>References:</b>\n
--! <reference one> \n
--! <reference two>
--!
--! <b>Modified by:</b>\n
--! Author: Eduardo Brandao de Souza Mendes
-------------------------------------------------------------------------------
--! \n\n<b>Last changes:</b>\n
--! 30\06\2020 - EBSM - Created\n
--! 15\07\2020 - EBSM - Support for fixed-latency operation\n
-------------------------------------------------------------------------------
--! @todo - \n
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for cdc_tx
--==============================================================================
entity cdc_tx is
  generic (
    g_CLOCK_A_RATIO : integer := 1    ; --! Ratio between strobe period and clock A period
    g_CLOCK_B_RATIO : integer := 8    ; --! Ratio between strobe period and clock B period (>=4)
    g_ACC_PHASE     : integer := 125*8; --! Phase accumulator number - only relevant for fixed phase operation
    g_PHASE_SIZE    : integer := 10     --! ceil(log2(g_ACC_PHASE))
  );
  port (
    -- Interface A (latch - from where data comes)
    reset_a_i        : in   std_logic;                                 --! reset (only de-assert when all clocks and strobe A are stable)	
    clk_a_i          : in   std_logic;                                 --! clock A
    data_a_i         : in   std_logic_vector;                          --! data A
    strobe_a_i       : in   std_logic;                                 --! strobe A
	                                                                   
    -- Interface B (capture - to where data goes)                                                 
    clk_b_i          : in   std_logic;                                 --! clock B
    data_b_o         : out  std_logic_vector;                          --! data B (connected to vector of same size as data_a_i)
    strobe_b_o       : out  std_logic;                                 --! strobe B
    ready_b_o        : out  std_logic;                                 --! ready B (CDC is operating)

    -- Only relevant for fixed-phase operation
    clk_freerun_i    : in   std_logic;                                 --! Free-running clock (125MHz)	
    phase_o          : out  std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase to check fixed-phase
    phase_calib_i    : in   std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase measured in first reset
    phase_force_i    : in   std_logic                                  --! Force the phase to be the calibrated one

  );
end cdc_tx;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of cdc_tx is

  attribute keep : string;
  
  --! Function declaration

  --! Constant declaration  

  --! Signal declaration
  --===== Ensuring a safe data-transfer =====  
  -- CLK_A domain  
  signal data_a_reg          : std_logic_vector(data_a_i'range);  
  signal strobe_a_reg        : std_logic := '0';

  -- CLK_A -> CLK_B domain
  signal reset_a_strobe_sync : std_logic; -- reset_a falling-edge re-sampled with strobe_a to ensure a fixed-phase deactivation  
  signal reset_b_meta        : std_logic; -- reset re-sampled to clock B domain (2-FF sync)
  signal reset_b_sync        : std_logic;

  -- CLK_B domain
  signal ce_cntr_b           : integer range 0 to g_CLOCK_B_RATIO;
  signal strobe_b_reg        : std_logic;
  signal data_b_reg          : std_logic_vector(data_b_o'range);  
  signal ready_b_meta        : std_logic;
  signal ready_b_sync        : std_logic;
  --=========================================
  
  --===== Deterministic phase operation =====
  -- reset sync  (2-FF sync)
  signal reset_freerun_meta  : std_logic;
  signal reset_freerun_sync  : std_logic;

  -- phase-measurement 
  signal strobeclk_a         : std_logic_vector(g_CLOCK_A_RATIO-1 downto 0);    
  signal strobeclk_b         : std_logic_vector(g_CLOCK_B_RATIO-1 downto 0);     
  signal xormeas_meta        : std_logic; -- strobeclk_b('left) XOR strobeclk_a('left) (2-FF sync)
  signal xormeas_sync        : std_logic;
  
  -- phase control
  signal advance_toggle        : std_logic := '0';
  signal retard_toggle         : std_logic := '0';
  signal advance_toggle_meta   : std_logic;
  signal retard_toggle_meta    : std_logic;
  signal advance_toggle_sync   : std_logic;
  signal retard_toggle_sync    : std_logic;
  signal advance_toggle_sync_r : std_logic;
  signal retard_toggle_sync_r  : std_logic;

  -- phase alignment FSM
  signal phase_acc           : integer range 0 to g_ACC_PHASE; -- Phase accumulator
  signal events_acc          : integer range 0 to g_ACC_PHASE; -- Total events accumulator
  type t_ALIGNMENT_FSM is (IDLE, RESET_CNTR, PHASE_SACC, COMPARE, ADVANCE, RETARD, ALIGNED);
  signal alignment_state     : t_ALIGNMENT_FSM;
  signal cdc_ready           : std_logic;  
  --=========================================

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of xormeas_meta, reset_freerun_meta, advance_toggle_meta, retard_toggle_meta: signal is "TRUE"; 

begin

  --===== Ensuring a safe data-transfer =====
  --=== CLK_A
  strobe_a_reg   <= strobe_a_i when rising_edge(clk_a_i);
  data_a_reg     <= data_a_i   when rising_edge(clk_a_i);

  --=== CLK_A -> CLK_B
  -- This process is intended to ensure reset_a is de-asserted with a fixed-phase w.r.t. strobe A  
  p_reset_a_strobe_sync : process(clk_a_i)
  begin
    if (rising_edge(clk_a_i)) then
      if (reset_a_i='1') then
          reset_a_strobe_sync <= '1';      
      elsif(strobe_a_i='1') then
          reset_a_strobe_sync <= '0';  
      end if;
    end if;
  end process p_reset_a_strobe_sync;
  
  -- 2-FF sync.
  reset_b_meta          <= reset_a_strobe_sync   when rising_edge(clk_b_i);
  reset_b_sync          <= reset_b_meta          when rising_edge(clk_b_i);

  ready_b_meta          <= cdc_ready             when rising_edge(clk_b_i);
  ready_b_sync          <= ready_b_meta          when rising_edge(clk_b_i);
  ready_b_o             <= ready_b_sync                                   ;

  --=== CLK_B
  -- counter with advance/retard capability  
  p_ce_cntr_b : process(clk_b_i)
  begin
    if(rising_edge(clk_b_i)) then
      if (reset_b_sync = '1') then
        ce_cntr_b <= 0;	
      else		
        if (advance_toggle_sync_r/=advance_toggle_sync) then    -- advance counter
          if (ce_cntr_b = g_CLOCK_B_RATIO-1) then
            ce_cntr_b <= 1;
          elsif (ce_cntr_b = g_CLOCK_B_RATIO-2) then
            ce_cntr_b <= 0;
          else
            ce_cntr_b <= ce_cntr_b + 2;
          end if;
        elsif (retard_toggle_sync_r = retard_toggle_sync) then  -- normal counter
          if (ce_cntr_b = g_CLOCK_B_RATIO-1) then
            ce_cntr_b <= 0;
          else
            ce_cntr_b <= ce_cntr_b + 1;
          end if;
        else                                                    -- retard counter
          ce_cntr_b <= ce_cntr_b;
        end if;
      end if;		
    end if;
  end process p_ce_cntr_b;

  p_strobe_b : process(clk_b_i)
  begin
    if(rising_edge(clk_b_i)) then
      if (reset_b_sync = '1') then
        strobe_b_reg <= '0';
      else
        if ((ce_cntr_b = 0 and (retard_toggle_sync_r = retard_toggle_sync) ) or (ce_cntr_b=g_CLOCK_B_RATIO-1 and advance_toggle_sync_r/=advance_toggle_sync)) then
          strobe_b_reg <= '1';		  
        else
          strobe_b_reg <= '0';
        end if;
      end if;
    end if;
  end process p_strobe_b;
  
  p_data_b : process(clk_b_i)
  begin
    if(rising_edge(clk_b_i)) then
      if (ce_cntr_b = 0) then
        data_b_reg <= data_a_reg;		  
      else
        data_b_reg <= data_b_reg;		 
      end if;
    end if;
  end process p_data_b;

  strobe_b_o <= strobe_b_reg;
  data_b_o   <= data_b_reg  ;
  --=========================================

  --===== Deterministic phase operation =====
  --=== CLK_A
  p_strobeclk_a : process(clk_a_i)
  begin
    if(rising_edge(clk_a_i)) then
      if (reset_a_strobe_sync = '1') then
        strobeclk_a <= (others => '0');
      else		
        if (strobe_a_reg = '1') then
          strobeclk_a(0) <= not strobeclk_a(0);
        end if;
        strobeclk_a(strobeclk_a'left downto 1) <= strobeclk_a(strobeclk_a'left-1 downto 0);			
      end if;		  
    end if;
  end process p_strobeclk_a;
  
  --=== CLK_B
  p_strobeclk_b : process(clk_b_i)
  begin
    if(rising_edge(clk_b_i)) then
      if (reset_b_sync='1') then
        strobeclk_b <= (others => '0');
      else
        if(strobe_b_reg = '1') then
          strobeclk_b(0) <= not strobeclk_b(0);
        end if;
        strobeclk_b(strobeclk_b'left downto 1) <= strobeclk_b(strobeclk_b'left-1 downto 0);		
      end if;
    end if;
  end process p_strobeclk_b;

  
  --=== Phase-measurement and adjustment (CLK_FREE-RUN)  
  -- synchronization
  reset_freerun_meta    <= reset_a_strobe_sync when rising_edge(clk_freerun_i);
  reset_freerun_sync    <= reset_freerun_meta  when rising_edge(clk_freerun_i);

  advance_toggle_meta   <= advance_toggle      when rising_edge(clk_b_i);
  advance_toggle_sync   <= advance_toggle_meta when rising_edge(clk_b_i);
  advance_toggle_sync_r <= advance_toggle_sync when rising_edge(clk_b_i);
                        
  retard_toggle_meta    <= retard_toggle       when rising_edge(clk_b_i);
  retard_toggle_sync    <= retard_toggle_meta  when rising_edge(clk_b_i);  
  retard_toggle_sync_r  <= retard_toggle_sync  when rising_edge(clk_b_i);

  -- Phase measurement and adjustment
  xormeas_meta <= strobeclk_a(strobeclk_a'left) xor strobeclk_b(strobeclk_b'left) when rising_edge(clk_freerun_i);
  xormeas_sync <= xormeas_meta                when rising_edge(clk_freerun_i);

  p_phase_measurement : process(clk_freerun_i)
  begin
    if(rising_edge(clk_freerun_i)) then
      if(alignment_state = IDLE) then
	    phase_acc      <= 0;
        events_acc     <= 0;
        phase_o        <= (others => '0');
      else
        if(alignment_state = RESET_CNTR)then
	      phase_acc  <= 0;
          events_acc <= 0;
        elsif(alignment_state = PHASE_SACC) then
          if(events_acc < g_ACC_PHASE) then
            if(xormeas_sync = '1') then  		  
	          phase_acc  <= phase_acc  + 1;
            end if;
            events_acc <= events_acc + 1;	
          end if;		   
        end if;
        if(alignment_state = ALIGNED) then
          phase_o    <= std_logic_vector(to_unsigned(phase_acc,phase_o'length));
        end if;
      end if;
    end if;
  end process p_phase_measurement;

  p_phase_control : process(clk_freerun_i)
  begin
    if(rising_edge(clk_freerun_i)) then
      if(alignment_state = IDLE) then
        advance_toggle <= '0';
        retard_toggle  <= '0';
      else
        if(alignment_state = ADVANCE) then
          advance_toggle <= not advance_toggle;
        end if;
        if(alignment_state = RETARD) then
          retard_toggle <= not retard_toggle;
        end if;
      end if;
    end if;
  end process p_phase_control;

  p_alignment_fsm : process(clk_freerun_i)
  begin
    if(rising_edge(clk_freerun_i)) then
      if(reset_freerun_sync = '1') then
	    alignment_state  <= IDLE;
      else
          case alignment_state is
            when IDLE =>
	          alignment_state  <= RESET_CNTR;
            when RESET_CNTR =>
	          alignment_state  <= PHASE_SACC;	          
            when PHASE_SACC =>
              if(events_acc = g_ACC_PHASE) then			
	            alignment_state  <= COMPARE;
              end if;
            when COMPARE =>
              if(phase_force_i='0' or cdc_ready='1') then
	            alignment_state  <= ALIGNED;	
              else
                if   (phase_acc > (to_integer(unsigned(phase_calib_i)) + (g_ACC_PHASE/g_CLOCK_B_RATIO)/2)) then
	              alignment_state  <= ADVANCE;	
                elsif(phase_acc < (to_integer(unsigned(phase_calib_i)) - (g_ACC_PHASE/g_CLOCK_B_RATIO)/2)) then
	              alignment_state  <= RETARD;	
				else
	              alignment_state  <= ALIGNED;	
				end if;
              end if;
            when ADVANCE =>
	          alignment_state  <= RESET_CNTR;
            when RETARD =>
	          alignment_state  <= RESET_CNTR;
            when ALIGNED =>
	          alignment_state  <= RESET_CNTR;
			when others =>
	          alignment_state  <= IDLE;
          end case;
      end if;
    end if;
  end process p_alignment_fsm;
  
  p_cdc_ready : process(clk_freerun_i)
  begin
    if(rising_edge(clk_freerun_i)) then
      if(reset_freerun_sync = '1') then
	    cdc_ready  <= '0';
      else
          if(alignment_state = ALIGNED) then
              cdc_ready <= '1';		  
		  end if;
      end if;
    end if;
  end process p_cdc_ready;
  --=========================================

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================