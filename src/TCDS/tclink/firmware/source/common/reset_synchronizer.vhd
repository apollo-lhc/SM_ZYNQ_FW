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
--! @file reset_synchronizer.vhd
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
-- unit name: Reset synchronizer (reset_synchronizer)
--
--! @brief Reset synchronizer
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
--! Entity declaration for reset_synchronizer
--============================================================================
entity reset_synchronizer is
  port (clk_in  : in  std_logic;
        rst_in  : in  std_logic;
        rst_out : out std_logic);
end reset_synchronizer;

--============================================================================
--! Architecture declaration for reset_synchronizer
--============================================================================
architecture rtl of reset_synchronizer is

  attribute ASYNC_REG : string;

  signal rst_in_meta                                                                       : std_logic;
  signal rst_in_sync1                                                                      : std_logic;
  signal rst_in_sync2                                                                      : std_logic;
  signal rst_in_sync3                                                                      : std_logic;
  signal rst_in_out                                                                        : std_logic;
  attribute ASYNC_REG of rst_in_meta, rst_in_sync1, rst_in_sync2, rst_in_sync3, rst_in_out : signal is "TRUE";

--============================================================================
--! Architecture begin for reset_synchronizer
--============================================================================
begin

  process (clk_in, rst_in) is
  begin
    if (rst_in = '1') then
      rst_in_meta  <= '1';
      rst_in_sync1 <= '1';
      rst_in_sync2 <= '1';
      rst_in_sync3 <= '1';
      rst_in_out   <= '1';
    elsif rising_edge(clk_in) then
      rst_in_meta  <= rst_in;
      rst_in_sync1 <= rst_in_meta;
      rst_in_sync2 <= rst_in_sync1;
      rst_in_sync3 <= rst_in_sync2;
      rst_in_out   <= rst_in_sync3;
    end if;
  end process;
  rst_out <= rst_in_out;
end rtl;
