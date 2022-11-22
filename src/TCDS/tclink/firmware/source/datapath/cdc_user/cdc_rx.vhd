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
--! @file cdc_rx.vhd
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
-- unit name: Rx mesochronous fixed-phase clock-domain crossing
--
--! @brief Mesochronous fixed-phase CDC for Receiver
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
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for cdc_rx
--==============================================================================
entity cdc_rx is
  generic (
    g_CLOCK_A_RATIO : integer := 8; --! Frequency ratio between slow and fast frequencies (>4)
    g_PHASE_SIZE    : integer := 3  --! log2(g_CLOCK_A_RATIO)
  );
  port (
    -- Interface A (latch - from where data comes)
    reset_a_i        : in   std_logic;                                 --! reset (only de-assert when all clocks and strobes are stable)		
    clk_a_i          : in   std_logic;                                 --! clock A
    data_a_i         : in   std_logic_vector;                          --! data A
    strobe_a_i       : in   std_logic;                                 --! strobe A

    -- Interface B (capture_a - to where data goes) 
    clk_b_i          : in   std_logic;                                 --! clock B
    data_b_o         : out  std_logic_vector;                          --! data B (connected to vector of same size as data_a_i)
    strobe_b_i       : in   std_logic;                                 --! strobe B
    ready_b_o        : out  std_logic;                                 --! Inteface is ready 

    -- Only relevant for fixed-phase operation
    phase_o          : out  std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase to check fixed-phase
    phase_calib_i    : in   std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase measured in first reset
    phase_force_i    : in   std_logic                                  --! Force the phase to be the calibrated one

  );
end cdc_rx;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of cdc_rx is

  --! Function declaration

  --! Constant declaration  

  --! Signal declaration 
  -- CLK_A domain 
  signal data_a_reg           : std_logic_vector(data_a_i'range);
  signal ce_cntr_a            : integer range 0 to g_CLOCK_A_RATIO-1;
  signal capture_a            : std_logic;
  signal strobe_a_r           : std_logic;
  signal phase_calib_a        : std_logic_vector(g_PHASE_SIZE-1 downto 0);
  signal phase_force_a        : std_logic;    
  
  -- CLK_B -> CLK_A domain   
  signal strobe_b_toggle        : std_logic := '0';
  signal strobe_b_toggle_meta   : std_logic;
  signal strobe_b_toggle_sync   : std_logic;
  signal strobe_b_toggle_sync_r : std_logic;  
  signal reset_a_strobe_sync    : std_logic;  
  
  -- CLK_B domain    
  signal data_b_reg           : std_logic_vector(data_a_i'range);
                              
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of strobe_b_toggle_meta : signal is "TRUE";
  attribute ASYNC_REG of phase_calib_a        : signal is "TRUE";
  attribute ASYNC_REG of phase_force_a        : signal is "TRUE";
  attribute ASYNC_REG of phase_o              : signal is "TRUE";
  
begin
  
  --=== CLK_B -> CLK_A
  p_strobe_b_toggle : process(clk_b_i)
  begin
    if (rising_edge(clk_b_i)) then
      if (strobe_b_i='1') then
        strobe_b_toggle        <= not strobe_b_toggle;
      end if;
    end if;
  end process p_strobe_b_toggle;

  strobe_b_toggle_meta   <= strobe_b_toggle      when rising_edge(clk_a_i);
  strobe_b_toggle_sync   <= strobe_b_toggle_meta when rising_edge(clk_a_i);
  strobe_b_toggle_sync_r <= strobe_b_toggle_sync when rising_edge(clk_a_i);

  -- This process is intended to ensure reset_a is de-asserted with a fixed-phase w.r.t. strobe B 
  p_reset_a_strobe_sync : process(clk_a_i)
  begin
    if (rising_edge(clk_a_i)) then
      if (reset_a_i='1') then
          reset_a_strobe_sync <= '1';      
      elsif(strobe_b_toggle_sync_r/=strobe_b_toggle_sync) then
          reset_a_strobe_sync <= '0';  
      end if;
    end if;
  end process p_reset_a_strobe_sync;

  --=== CLK_A
  phase_calib_a        <= phase_calib_i when rising_edge(clk_a_i);
  phase_force_a        <= phase_force_i when rising_edge(clk_a_i);
  p_clock_enable : process(clk_a_i)
  begin
    if(rising_edge(clk_a_i)) then
      if(reset_a_strobe_sync='1') then  
	      ce_cntr_a   <= 0;
		  capture_a   <= '0';
      else
          if(phase_force_a='1' and strobe_a_i='1') then
             ce_cntr_a <= to_integer(unsigned(phase_calib_a));		  
	      elsif(ce_cntr_a = g_CLOCK_A_RATIO-1) then
		     ce_cntr_a <= 0;
		  else
		     ce_cntr_a <= ce_cntr_a + 1;
		  end if;
		  if (ce_cntr_a = g_CLOCK_A_RATIO-1) then
            capture_a  <= '1';			
		  else
            capture_a  <= '0';
		  end if;
      end if;
    end if;
  end process p_clock_enable;

  --============================================================================
  -- Phase measurement
  --============================================================================  
  strobe_a_r <= strobe_a_i when rising_edge(clk_a_i); 
  
  p_phase : process(clk_a_i)
  begin
    if(rising_edge(clk_a_i)) then
      if(reset_a_strobe_sync = '1') then
	    phase_o   <= (others => '0');	
        ready_b_o <= '0';
      else
	      if(strobe_a_r = '1') then
		     phase_o   <= std_logic_vector(to_unsigned(ce_cntr_a, phase_o'length));
             ready_b_o <= '1';
		  end if;
      end if;
    end if;
  end process p_phase;
  
  --============================================================================
  -- Data intermediary
  --============================================================================  
  p_data_int : process(clk_a_i) -- do not reset to avoid unecessarily large fan-out of reset_a_strobe_sync signal
  begin
    if(rising_edge(clk_a_i)) then
      if (capture_a = '1') then
         data_a_reg <= data_a_i;
      else
         data_a_reg <= data_a_reg;
      end if;
    end if;
  end process p_data_int;

  --============================================================================
  -- Data out
  --============================================================================  
  p_data_out : process(clk_b_i)
  begin
    if(rising_edge(clk_b_i)) then
      if(strobe_b_i='1') then	
        data_b_reg <= data_a_reg;
      end if;
    end if;
  end process p_data_out;
  data_b_o <= data_b_reg;



end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================