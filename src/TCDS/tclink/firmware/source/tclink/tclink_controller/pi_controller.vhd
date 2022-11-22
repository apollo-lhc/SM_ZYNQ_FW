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
--! @file pi_controller.vhd
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
-- unit name: PI controller (pi_controller)
--
--! @brief PI controller used in TCLink control loop design
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
--! Entity declaration for pi_controller
--==============================================================================
entity pi_controller is
  generic(
    g_DATA_WIDTH            : integer := 32;
    g_PROPORTIONAL_PRESCALE : integer := 0;
    g_INTEGRAL_PRESCALE     : integer := 0;
    g_COEFF_SIZE            : integer := 4
  );
  port (
    -- User Interface   
    clk_sys_i    : in  std_logic;                                    --! system clock input
    clk_en_i     : in  std_logic;                                    --! clock enable for pi controller
    reset_i      : in  std_logic;                                    --! active high sync. reset

    -- Loop dynamics interface
    error_i      : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);    --! Error input to be corrected (signed)


    Aie_i        : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Integral coefficient
    Aie_enable_i : in  std_logic;                                    --! Enables usage of integral coefficient

    Ape_i        : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Proportional coefficient

    -- Control interface
    pi_ctrl_o    : out  std_logic_vector(g_DATA_WIDTH-1 downto 0)    --! PI controller response (signed)

    );
end pi_controller;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of pi_controller is

  --! Attribute declaration

  --! Constant declaration
  constant MSB : integer := error_i'left;
  
  --! Signal declaration 
  -- ==============================================================================
  -- ================================ PI Controller ===============================
  -- ==============================================================================
  -- PI controller multiplicative coefficients
  signal proportional_scaled   : std_logic_vector(error_i'range);
  signal integral_scaled       : std_logic_vector(error_i'range);
  signal proportional          : signed(error_i'range);
  signal integral              : signed(error_i'range);
  signal integral_acc          : signed(error_i'range);

  signal pi_ctrl               : signed(error_i'range);

  component scaler is
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
  end component scaler;

begin

    -- Multiplicative coefficients of PI
    cmp_scaler_proportional : scaler
      generic map(
        g_DATA_WIDTH    => g_DATA_WIDTH,
        g_PRESCALE_MULT => g_PROPORTIONAL_PRESCALE,
		g_COEFF_SIZE    => g_COEFF_SIZE
      )
      port map(
        -- User Interface   
        input_i      => error_i,
    
        -- Loop dynamics interface
        scale_div_i  => Ape_i,
        scaled_o     => proportional_scaled
     );
    proportional <= signed(proportional_scaled);

    cmp_scaler_integral : scaler
      generic map(
        g_DATA_WIDTH    => g_DATA_WIDTH,
        g_PRESCALE_MULT => g_INTEGRAL_PRESCALE,
		g_COEFF_SIZE    => g_COEFF_SIZE
      )
      port map(
        -- User Interface   
        input_i      => error_i,
    
        -- Loop dynamics interface
        scale_div_i  => Aie_i,
        scaled_o     => integral_scaled
     );
    integral <= signed(integral_scaled);
	
    --============================================================================
    -- Process p_pi_controller
    --!  Integral accumulator and PI sum
    --============================================================================  
    p_pi_controller : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          integral_acc <= (others => '0');
          pi_ctrl      <= (others => '0');		  
        else
          if(clk_en_i='1') then	  
            if(Aie_enable_i = '1') then 			
                pi_ctrl      <= integral_acc + proportional;
		        integral_acc <= integral_acc + integral;
			else
                pi_ctrl  <= proportional;
                integral_acc <= (others => '0');
            end if;				
		  end if;
        end if;
      end if;
    end process p_pi_controller;

    pi_ctrl_o <= std_logic_vector(pi_ctrl);

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
