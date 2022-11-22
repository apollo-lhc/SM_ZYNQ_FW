--==============================================================================
-- © Copyright CERN for the benefit of the HPTD interest group 2019. All rights not
--   expressly granted are reserved.
--
--   This file is part of TCLink.
--
-- TCLink is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- TCLink is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with TCLink.  If not, see <https://www.gnu.org/licenses/>.
--==============================================================================
--! @file dco_controller.vhd
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
-- unit name: Controller with phase accumulator (dco_controller)
--
--! @brief DCO controller
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 07\08\2019
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
--! 07\08\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for dco_controller
--==============================================================================
entity dco_controller is
  generic(
    g_DATA_WIDTH : integer := 32
  );
  port (
    -- User Interface   
    clk_sys_i         : in  std_logic;                        --! system clock input
    clk_en_i          : in  std_logic;                        --! clock enable for sigma delta modulator	
    reset_i           : in  std_logic;                        --! active high sync. reset

    ctrl_i            : in std_logic;                         --! Input data to increment/decrement DCO phase
                                                              --! 1 -> +1 shift DCO
                                                              --! 0 -> -1 shift DCO

    -- User interface
    phase_acc_o       : out std_logic_vector(g_DATA_WIDTH-1 downto 0); --! DCO phase accumulated
    dco_mirror_o      : out std_logic_vector(g_DATA_WIDTH-1 downto 0);    --! DCO mirror output (integrated output)
                                                              --! This is an integer signed number, the LSB is the bit 0
    Adco_i                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);              --! DCO coefficient for mirror compensation	
	
    operation_error_o : out std_logic;                        --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request 
                                                              --! this is mainly useful for debugging purposes, for the final user this can be removed if the user is sure about all the operational parameters of the TCLink loop control
    -- DCO interface (fast output)
    strobe_o          : out  std_logic;                       --! pulse synchronous to clk_sys_i to activate a shift in the DCO (only captured rising edge, so a signal larger than a pulse is also fine)
    inc_ndec_o        : out  std_logic;                       --! 1 increments, 0 decrements (modulated output)
    phase_step_o      : out  std_logic;                       --! number of units to shift the DCO    
    done_i            : in   std_logic                        --! pulse synchronous to clk_sys_i to indicate a DCO shift was performed

    );
end dco_controller;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of dco_controller is

  --! Attribute declaration

  --! Constant declaration

  --! Signal declaration 
  -- ==============================================================================
  -- ============================== Controller signals =============================
  -- ==============================================================================
  signal inc_ndec            : std_logic;
  signal strobe              : std_logic;
  signal done_r              : std_logic;

  -- ==============================================================================
  -- =============================== Accessory signals ============================
  -- ==============================================================================
  -- phase accumulator
  signal phase_acc : signed(dco_mirror_o'range);
  signal dco_mirror : signed(dco_mirror_o'range);
  
  -- error detection
  type   t_ERROR_FSM is (IDLE, WAIT_DONE, ERROR);
  signal error_state : t_ERROR_FSM;
  
begin
    done_r <= done_i when rising_edge(clk_sys_i);

    --============================================================================
    -- Process p_dco_controller
    --!  Controller process
    --============================================================================  
    p_dco_controller : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          inc_ndec    <= '0';
          strobe       <= '0';
          phase_step_o <= '0';
		  phase_acc    <= (others => '0');
		  dco_mirror    <= (others => '0');
        else
          if(clk_en_i='1') then
		    strobe       <= '1';
			phase_step_o <= '1';
			inc_ndec     <= ctrl_i;
          else
            strobe      <= '0';
            inc_ndec    <= inc_ndec;
			phase_acc   <= phase_acc;
			dco_mirror   <= dco_mirror;
		  end if;

          if(done_i='1' and done_r='0') then
		    if(inc_ndec='0') then
				phase_acc <= phase_acc - 1;
				dco_mirror <= dco_mirror - signed(Adco_i);
			else
				phase_acc <= phase_acc + 1;
				dco_mirror <= dco_mirror + signed(Adco_i);
			end if;
		  end if;

        end if;
      end if;
    end process p_dco_controller;
    inc_ndec_o   <= inc_ndec;
	strobe_o     <= strobe;
    dco_mirror_o <= std_logic_vector(dco_mirror);
    phase_acc_o  <= std_logic_vector(phase_acc);

    --============================================================================
    -- Detects error in the DCO communication
    --!  Error FSM
    --============================================================================  
    p_error_fsm : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          error_state <= IDLE;
          operation_error_o     <= '0';
        else
          case error_state is
            when IDLE =>
              if(strobe='1') then
	  		   error_state <= WAIT_DONE;
	  		   operation_error_o     <= '0';
	  		end if;
            when WAIT_DONE =>
              if(strobe='1') then
	  		    error_state <= ERROR;
	  			operation_error_o     <= '0';
	  		elsif(done_i='1') then
	  		    error_state <= IDLE;
	  			operation_error_o     <= '0';
	  		end if;
            when ERROR =>
              error_state <= ERROR; --only a reset can remove this state
	  		operation_error_o     <= '1';
            when others =>
              error_state <= ERROR;
          end case;
        end if;
      end if;
    end process p_error_fsm;
  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
