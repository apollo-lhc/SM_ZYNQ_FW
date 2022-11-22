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
--! @file scaler.vhd
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
-- unit name: 2**X scaler (scaler)
--
--! @scaler used in TCLink PI design
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
--! Entity declaration for scaler
--==============================================================================
entity scaler is
  generic(
    g_DATA_WIDTH    : integer := 32;
	g_COEFF_SIZE    : integer := 4;
    g_PRESCALE_MULT : integer range 0 to 31 := 0 --! multiplication by 2 
  );
  port (
    -- User Interface   
    input_i      : in std_logic_vector(g_DATA_WIDTH-1 downto 0);     --! Input to be scaled (signed)

    -- Loop dynamics interface
    scale_div_i  : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Scaling coefficient division by 2 (unsigned)
    scaled_o     : out std_logic_vector(g_DATA_WIDTH-1 downto 0)     --! Scaled output (signed)

    );
end scaler;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of scaler is

  --! Attribute declaration

  --! Constant declaration
  constant c_MSB          : integer := input_i'left;
  constant c_MAX_PRESCALE : integer := 2**g_COEFF_SIZE ;
  
  --! Signal declaration 
  -- Pre-scaling coefficient
  signal prescale     : signed(c_MSB+c_MAX_PRESCALE downto 0);

begin


    --============================================================================
    -- Process p_multiplicative
    --============================================================================  
    p_multiplicative : process(input_i)
    begin
        prescale(c_MSB+c_MAX_PRESCALE  downto c_MSB+g_PRESCALE_MULT+1) <= (others => input_i(c_MSB));	 -- keep signal of input
        prescale(c_MSB+g_PRESCALE_MULT downto g_PRESCALE_MULT)         <= signed(input_i);               -- multiplied input
	    prescale(g_PRESCALE_MULT-1 downto 0)                           <= (others => '0');               -- add zeros for the non-multiplied
    end process p_multiplicative;

    --============================================================================
    -- Process p_divider
    --!  Pre-scaler is a combinatorial process increasing the precision of the integer part of the input_i
    --============================================================================  
    p_division : process(prescale, scale_div_i)
    begin
        scaled_o(c_MSB downto 0) <= std_logic_vector(prescale(c_MSB+to_integer(unsigned(scale_div_i)) downto to_integer(unsigned(scale_div_i))));
    end process p_division;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
