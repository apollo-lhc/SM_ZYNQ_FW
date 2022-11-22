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
--! @file mgt_user_clock.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Specific packages
library UNISIM; 
use UNISIM.vcomponents.all;

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Example design for MGT clocking scheme (mgt_user_clock)
--
--! @brief MGT clock for TCLink
--! - This is an example design created for a symmetric 10.24Gbps transceiver for GTY Ultrascale+ to be used for a TClink implementation
--! - This transceiver can be used to implement lpGBT-like links if working in a bit-folding downlink (x4) and 10.24Gbps uplink
--! - This implementation uses two PLLs: one for Tx and one for Rx. This is the typical case for a bidirectional link where the downlink is receiving timing and the uplink has to use the recovered clock for transmission
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 18\10\2019
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
--! 18\10\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for mgt_user_clock
--==============================================================================
entity mgt_user_clock is
    generic(
	    g_NUMBER_CHANNELS : integer := 1 --1,2,3,4
	);
    port (
        -- User clocks                                                       
        txusrclk_o                      : out std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);                               
        rxusrclk_o                      : out std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);

        --! User clock network		
        mgt_txoutclk_i                  : in  std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);  --! Only channel 0 used, shared Tx clock    
        mgt_rxoutclk_i                  : in  std_logic_vector(g_NUMBER_CHANNELS-1 downto 0)
	);
end mgt_user_clock;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of mgt_user_clock is

  --! Function declaration

  --! Constant declaration
 
  --! Signal declaration  
  ------------------------- Auxiliar MGT interface ------------------------------
  signal txusrclk                           : std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);
  signal rxusrclk                           : std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);

  --! Component declaration   
  
begin

  --============================================================================
  --! User clock network
  --============================================================================
  --! ------------ Transmitter network ------------
  -- cmp_tx_bufg_gt : Transmitter user clock buffer (low-skew buffer resource contained within transceiver region)
  cmp_tx_bufg_gt : BUFG_GT 
    port map( 
      O       => txusrclk(0),                  -- 1-bit output: Buffer 
      CE      => '1',                          -- 1-bit input: Buffer enable 
      CEMASK  => '0',                          -- 1-bit input: CE Mask 
      CLR     => '0',                          -- 1-bit input: Asynchronous clear 
      CLRMASK => '0',                          -- 1-bit input: CLR Mask 
      DIV     => "000",                        -- 3-bit input: Dymanic divide Value  - 000=div by 1
      I       => mgt_txoutclk_i(0)             -- 1-bit input: Buffer 
  );

  txusrclk_o <= (others => txusrclk(0));

  --! ------------ Receiver network ------------
  gen_channel_rxusrclk : for i in g_NUMBER_CHANNELS-1 downto 0 generate
     -- cmp_rx_bufg_gt : Receiver user clock buffer (low-skew buffer resource contained within transceiver region)
     cmp_rx_bufg_gt : BUFG_GT 
       port map( 
         O       => rxusrclk(i),                  -- 1-bit output: Buffer 
         CE      => '1',                          -- 1-bit input: Buffer enable 
         CEMASK  => '0',                          -- 1-bit input: CE Mask 
         CLR     => '0',                          -- 1-bit input: Asynchronous clear 
         CLRMASK => '0',                          -- 1-bit input: CLR Mask 
         DIV     => "000",                        -- 3-bit input: Dymanic divide Value  - 000=div by 1
         I       => mgt_rxoutclk_i(i)             -- 1-bit input: Buffer 
     );
  end generate gen_channel_rxusrclk;  
  rxusrclk_o <= rxusrclk;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================