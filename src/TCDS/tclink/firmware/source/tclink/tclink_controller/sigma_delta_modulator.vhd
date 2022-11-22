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
--! @file sigma_delta_modulator.vhd
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
-- unit name: Sigma delta modulator (sigma_delta_modulator)
--
--! @brief 1st order sigma delta modulator used in TCLink control loop design
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
--! Entity declaration for sigma_delta_modulator
--==============================================================================
entity sigma_delta_modulator is
  generic(
    g_DATA_WIDTH            : integer := 32;
    g_FIXEDPOINT_BIT        : integer := 10
  );
  port (
    -- User Interface   
    clk_sys_i    : in  std_logic; --! system clock input
    clk_en_i     : in  std_logic; --! clock enable for sigma delta modulator	
    reset_i      : in  std_logic; --! active high sync. reset

    -- Input data to be modulated
    slow_input_i : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! slow input to be modulated
                                                                  --! This is a fractional signed number
                                                                  --! The unit bit is the index g_FIXEDPOINT_BIT

    -- Control interface
    sigma_delta_ctrl_o     : out std_logic --! 1 is positive, 0 is negative

    );
end sigma_delta_modulator;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of sigma_delta_modulator is

  --! Attribute declaration

  --! Constant declaration

  --! Signal declaration 
  -- ==============================================================================
  -- ============================= Sigma delta signals ============================
  -- ==============================================================================
  -- delta-sigma
  signal slow_input_mod : unsigned(g_FIXEDPOINT_BIT+1 downto 0);  
  signal sigma          : unsigned(g_FIXEDPOINT_BIT downto 0);
  signal sigma_next     : unsigned(g_FIXEDPOINT_BIT+1 downto 0);
  
  -- quantizer
  signal quantizer  : std_logic;

  -- ==============================================================================
  -- =============================== Accessory signals ============================
  -- ==============================================================================
  -- input register
  signal slow_input_r : signed(slow_input_i'range); --! slow input to be modulated


begin
    -- sample input
    slow_input_mod(g_FIXEDPOINT_BIT+1)          <= '0';
    slow_input_mod(g_FIXEDPOINT_BIT)            <= not slow_input_i(slow_input_i'left);
    slow_input_mod(g_FIXEDPOINT_BIT-1 downto 0) <= unsigned(slow_input_i(g_FIXEDPOINT_BIT-1 downto 0));

    --============================================================================
    -- Process p_sigma
    --!  Sigma process
    --============================================================================  
    sigma_next <= sigma + slow_input_mod;
    p_sigma : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          sigma   <= (others => '0');
        else
          if(clk_en_i='1') then
		    sigma <= sigma_next(sigma'range);
		  end if;
        end if;
      end if;
    end process p_sigma;

    --============================================================================
    -- Process p_quantizer
    --!  Quantizer process
    --============================================================================  
    p_quantizer : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          quantizer   <= '0';
        else
          if(clk_en_i='1') then
		    quantizer <= sigma_next(sigma_next'left);
		  end if;
        end if;
      end if;
    end process p_quantizer;

    sigma_delta_ctrl_o <= quantizer;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
