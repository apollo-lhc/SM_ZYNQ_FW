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
--! @file phase_offset_removal.vhd
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
-- unit name: PI controller (phase_offset_removal)
--
--! @phase offset removal and modulo operation based on max. likelihood hypothesis
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
--! Entity declaration for phase_offset_removal
--==============================================================================
entity phase_offset_removal is
  generic(
    g_DATA_WIDTH            : integer := 32;
    g_FIXEDPOINT_BIT        : integer := 10
  );
  port (
    -- User Interface   
    clk_sys_i            : in  std_logic;                                  --! system clock input
    clk_en_i             : in  std_logic;                                  --! clock enable for error_i
    reset_i              : in  std_logic;                                  --! active high sync. reset

    -- Error interface                                         
    error_i              : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Error input from DDMTD
                                                                           --! This is a fractional signed number
                                                                           --! The unit bit is the index g_FIXEDPOINT_BIT

    -- Offset control				  
    offset_error_i       : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Phase offset 

    -- Modulo operation, used to select right phase from DDMTD
    enable_modulo_i      : in  std_logic;                                  --! Enable modulo operation
    modulo_error_i       : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Modulo in which error signal shall stay within	

    -- Mirror compensation
    dco_mirror_i         : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! DCO phase accumulator multiplied by Kdco*beta
    enable_mirror_i      : in  std_logic;                                                   --! Enable mirror compensation scheme (a part of phase variation is compensated using this scheme, otherwise a full compensation is performed)


    -- Control interface
    error_o              : out  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! This is a fractional signed number
                                                                           --! The unit bit is the index g_FIXEDPOINT_BIT
    error_p_o            : out std_logic                                   --! Pulse indicating a new error was calculated

    );
end phase_offset_removal;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of phase_offset_removal is

  --! Attribute declaration

  --! Constant declaration
  
  --! Signal declaration 
  signal error_r                : std_logic_vector(error_i'range);        --! Input register
         
  signal error_moffset          : signed(error_i'range);                  --! Input error minus error offset register

  signal error_mirror           : signed(error_i'range);                  --! Error mirror compensation
  signal error_modulo           : signed(error_i'range);                  --! Register for error modulo

  -- modulo operation
  type t_MODULO_FSM is (IDLE, CHECK_ABS, CHECK_SIGN, ADD_MODULO, SUB_MODULO, DONE);
  signal modulo_state : t_MODULO_FSM;
 
  --! Function declaration 
  
  --! Component declaration

begin

  --============================================================================
  -- Calculate Error minus Offset
  --============================================================================  
  error_r        <= error_i                                   when rising_edge(clk_sys_i);
  error_moffset  <= signed(error_r) - signed(offset_error_i)  when rising_edge(clk_sys_i);

  --============================================================================
  -- Calculate Error minus Offset minus Mirror phase
  --============================================================================  
  error_mirror   <= error_moffset - signed(dco_mirror_i) when enable_mirror_i='1' else error_moffset;

  --============================================================================
  -- FSM to calculate modulo of error
  --!  Error FSM
  --============================================================================  
  p_error_modulo_fsm : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1') then
        modulo_state <= IDLE;
        error_modulo <= (others => '0');
        error_p_o    <= '0';
        error_o      <= (others => '0');
      else
        if(enable_modulo_i='1') then
          error_p_o    <= '0';
          case modulo_state is
          
            when IDLE =>
              if(clk_en_i='1') then
    	  	   modulo_state <= CHECK_ABS;
                 error_modulo <= error_mirror;
    	  	  end if;
          
            when CHECK_ABS => -- Check if it is bigger than modulo_error_i/2
              if(abs(error_modulo) > signed('0'&modulo_error_i(modulo_error_i'left downto 1)) ) then
    	  	    modulo_state <= CHECK_SIGN;
    	  	  else
    	  	    modulo_state <= DONE;
    	  	  end if;
          
            when CHECK_SIGN =>
              if(error_modulo(error_modulo'left) = '1') then
    	  	    modulo_state <= ADD_MODULO;
    	  	  else
    	  	    modulo_state <= SUB_MODULO;
    	  	  end if;
          
            when ADD_MODULO =>
              error_modulo <= error_modulo + signed(modulo_error_i);
    	  	  modulo_state <= CHECK_ABS;
          
            when SUB_MODULO =>
              error_modulo <= error_modulo - signed(modulo_error_i);
    	  	  modulo_state <= CHECK_ABS;
          
            when DONE =>
    	  	  modulo_state <= IDLE;
              error_o      <= std_logic_vector(error_modulo);
              error_p_o    <= '1';

            when others =>
              modulo_state <= IDLE;
          
          end case;

        else
          modulo_state <= IDLE;
          error_modulo <= (others => '0');
          error_p_o    <= clk_en_i;
          error_o      <= std_logic_vector(error_mirror);
        end if;
      end if;
    end if;
  end process p_error_modulo_fsm;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
