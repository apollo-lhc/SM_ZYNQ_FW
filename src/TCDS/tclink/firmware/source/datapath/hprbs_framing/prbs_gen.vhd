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
--! @file prbs_gen.vhd
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
-- unit name: PRBS-generator (prbs_gen)
--
--! @brief parallel unfolded PRBS-generator with clock enable signal
--! Convention: LSB first transmitted
--! A multicycle path timing constraint might be applied from node_ff to node_ff register and from node_ff to data_o register
--! The number of cycles allowed for this operation is equal to the PERIOD of en_i
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 21\10\2019
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
--! 21\10\2019 - EBSM - Created\n
--! 11\06\2020 - EBSM - Data valid output\n
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for prbs_gen
--==============================================================================
entity prbs_gen is
  generic (
    g_PARAL_FACTOR    : integer          := 254        ;                          --! Size of parallel bus
    g_PRBS_POLYNOMIAL : std_logic_vector :=	"11000001"                            --! Notation: x^7 + x^6 + 1 (PRBS-7)
  );                                                                              
  port (                                                                          
    clk_i            : in  std_logic;                                             --! clock input
    en_i             : in  std_logic;                                             --! enable input
    reset_i          : in  std_logic;                                             --! active high sync. reset
    seed_i           : in  std_logic_vector(g_PRBS_POLYNOMIAL'length-2 downto 0); --! Seed for polynomial
    load_i           : in  std_logic;                                             --! Load seed	
    data_o           : out std_logic_vector(g_PARAL_FACTOR-1 downto 0);           --! PRBS output data
    data_valid_o     : out std_logic                                              --! PRBS data valid output	
  );
end prbs_gen;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of prbs_gen is

  --! Function declaration
  function fcn_xor_reduce(arg1 : std_logic_vector; arg_mask : std_logic_vector) return std_logic is
    variable result : std_logic := '0';
  begin
    for i in arg1'range loop
      result := result xor (arg1(i) and arg_mask(i));
    end loop;

    return result;
  end fcn_xor_reduce;

  --! Constant declaration  

  --! Signal declaration   
  type   t_node_array is array (g_PARAL_FACTOR-1 downto 0) of std_logic_vector(g_PRBS_POLYNOMIAL'length-2 downto 0);
  signal node_array : t_node_array;

  signal parallel_data : std_logic_vector(g_PARAL_FACTOR-1 downto 0);
  signal node_ff       : std_logic_vector(g_PRBS_POLYNOMIAL'length-2 downto 0);

begin

  -----------------------------------------------------------------------------------------------------------
  --! Generates all LFSR states in an unfolded fashion                                                     --
  --! Ex. for PRBS-7 (x^7 + x^6 + 1) unfolded n times                                                      --
  --! -------------------------------------------------------------------------------------------------------
  --!      lin-j)                                                                                          --
  --! col-k) Ekj represent the node_array points                                                           --
  --!   En0_r xor En6_r -> E06     E05     E04     E03     E02     E01     E00  -> Parallel data(MSB)      --
  --!                            \       \       \       \       \       \                                 --
  --!     E00 xor E06   -> E16     E15     E14     E13     E12     E11     E10  -> Parallel data           --
  --!                            \       \       \       \       \       \                                 --
  --!                                         ...                                                          --
  --!                            \       \       \       \       \       \                                 --
  --!   En-10 xor En-16 -> En6     En5     En4     En3     En2     En1     En0 -> Parallel data (LSB)      --     
  --! -------------------------------------------------------------------------------------------------------
  --! Last column is then registered to node_ff N and it is used to feed column 0                          --
  -----------------------------------------------------------------------------------------------------------
  gen_shift_lsfr : for k in 0 to (g_PARAL_FACTOR-1) generate
    
    gen_first_state : if k = 0 generate
      node_array(k)                                <= node_ff;
    end generate gen_first_state;

    gen_other_states : if (k > 0) generate
      node_array(k)(node_array(k)'left-1 downto 0) <= node_array(k-1)(node_array(k-1)'left downto 1);
      node_array(k)(node_array(k)'left)            <= fcn_xor_reduce(node_array(k-1), g_PRBS_POLYNOMIAL(g_PRBS_POLYNOMIAL'left-1 downto 0));
    end generate gen_other_states;

    parallel_data(k)                               <= node_array(k)(0); 

  end generate gen_shift_lsfr;

  --! p_node_ff generates the FF memory feedback for the prbs generator
  p_node_ff : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(reset_i = '1') then
        node_ff <= seed_i;
      else
        if(en_i = '1') then
          if(load_i='0') then  		
            node_ff(node_ff'left-1 downto 0)  <= node_array(g_PARAL_FACTOR-1)(node_array(g_PARAL_FACTOR-1)'left downto 1);
            node_ff(node_ff'left)             <= fcn_xor_reduce(node_array(g_PARAL_FACTOR-1), g_PRBS_POLYNOMIAL(g_PRBS_POLYNOMIAL'left-1 downto 0));
          else
            node_ff <= seed_i;
          end if;
        end if;
      end if;
    end if;
  end process p_node_ff;
  
  --! p_data_o generates the output data
  p_data_o : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(reset_i = '1') then
        data_o       <= (others => '0');
		data_valid_o <= '0';

      else

        if(en_i = '1') then
          data_o       <= parallel_data;
        end if;

        if(en_i = '1') then
          data_valid_o <= '1';
        else
          data_valid_o <= '0';		
        end if;

      end if;
    end if;
  end process p_data_o;

		  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================

