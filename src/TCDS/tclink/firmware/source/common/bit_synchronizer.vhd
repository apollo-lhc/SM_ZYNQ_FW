--==============================================================================
-- © Copyright CERN for the benefit of the TTC-PON project. All rights not
--   expressly granted are reserved.
--
--   This file is part of ttc_pon.
--
-- ttc_pon is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- ttc_pon is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with ttc_pon.  If not, see <https://www.gnu.org/licenses/>.
--=============================================================================
--! @file bit_synchronizer.vhd
--=============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
--! Specific packages
-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, TTC-PON
-- --
-------------------------------------------------------------------------------
--
-- unit name: Bit synchronizer (bit_synchronizer)
--
--! @brief Bit synchronizer using 4 cascaded FFs
--! <further description>
--!
--! @author Csaba Soos - csaba.soos@cern.ch
--! @date 10\02\2016
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
--! Author: Csaba Soos
-------------------------------------------------------------------------------
--! \n\n<b>Last changes:</b>\n
--! 10\02\2016 - CS - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--============================================================================
--! Entity declaration for bit_synchronizer
--============================================================================
entity bit_synchronizer is
  generic (INITIALIZE : std_logic_vector(4 downto 0) := "00000");
  port (clk_in : in  std_logic;
        i_in   : in  std_logic;
        o_out  : out std_logic);
end bit_synchronizer;

--============================================================================
--! Architecture declaration for bit_synchronizer
--============================================================================
architecture rtl of bit_synchronizer is

  attribute ASYNC_REG : string;

  signal i_in_meta                                                               : std_logic := INITIALIZE(0);
  signal i_in_sync1                                                              : std_logic := INITIALIZE(1);
  signal i_in_sync2                                                              : std_logic := INITIALIZE(2);
  signal i_in_sync3                                                              : std_logic := INITIALIZE(3);
  signal i_in_out                                                                : std_logic := INITIALIZE(4);
  attribute ASYNC_REG of i_in_meta, i_in_sync1, i_in_sync2, i_in_sync3, i_in_out : signal is "TRUE";

--============================================================================
--! Architecture begin for bit_synchronizer
--============================================================================
begin

  process (clk_in) is
  begin
    if rising_edge(clk_in) then
      i_in_meta  <= i_in;
      i_in_sync1 <= i_in_meta;
      i_in_sync2 <= i_in_sync1;
      i_in_sync3 <= i_in_sync2;
      i_in_out   <= i_in_sync3;
    end if;
  end process;
  o_out <= i_in_out;
  
end rtl;
