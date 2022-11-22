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
--! @file master_rx_slide_compensation.vhd
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
-- unit name: Master Rx slide compensation (master_rx_slide_compensation)
--
--! @Master Rx slide compensation for non-fixed latency master Rx MGT
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 31\01\2020
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
--! 31\01\2020 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for master_rx_slide_compensation
--==============================================================================
entity master_rx_slide_compensation is
  generic(
    g_DATA_WIDTH               : integer := 32;
    g_FIXEDPOINT_BIT           : integer := 10;
	g_MASTER_RX_MGT_WORD_WIDTH : integer := 32
  );
  port (
    -- User Interface   
    clk_sys_i                : in  std_logic;                                      --! system clock input
    reset_i                  : in  std_logic;                                      --! active high sync. reset

    -- RX SLIDE compensation for non-fixed latency master Rx  
    -- config : pseudo_static	
    master_rx_slide_mode_i   : in std_logic;                                       --! Slide mode / 0=PMA, 1=PCS
    master_rx_ui_period_i    : in std_logic_vector(g_DATA_WIDTH-1 downto 0);       --! UI period in DDMTD UNITS (unit is index 16)                                                         
    master_rx_slide_clk_i    : in std_logic;                                       --! Clock used by master Rx to generate rxslide pulses
    master_mgt_rx_ready_i    : in  std_logic;                                      --! MGT rx is ready (used as reset)
    master_rx_slide_i        : in std_logic;                                       --! Master Rx slide
                                                                                   
    -- Control interface                                                           
    master_offset_o          : out  std_logic_vector(g_DATA_WIDTH-1 downto 0)      --! This is a fractional signed number
                                                                                   --! The unit bit is the index g_FIXEDPOINT_BIT

    );
end master_rx_slide_compensation;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of master_rx_slide_compensation is

  --! Attribute declaration

  --! Constant declaration
  
  --! Signal declaration 
  signal error_offset           : signed(master_offset_o'range);                           --! Error offset for Rx SLIDE
 
  signal rxslide_r, rxslide_r2  : std_logic;
  signal rxslide_cntr           : integer range 0 to g_MASTER_RX_MGT_WORD_WIDTH-1;         --! Rx slide counter
  
  -- sync to master_rx_slide_clk_i
  signal master_mgt_rx_ready_sync   : std_logic;
  signal master_rx_nfixed_sync      : std_logic;   
  signal master_rx_slide_mode_sync  : std_logic;                                            
  
  signal rx_slide_toggle        : std_logic := '0';
  
  -- sync to clk_sys_i
  signal rx_slide_toggle_sync   : std_logic := '0';
  signal rx_slide_toggle_sync_r : std_logic := '0';
  signal rx_slide_toggle_xor    : std_logic := '0';
  
  --! Function declaration 
  
  --! Component declaration
  component bit_synchronizer is
    generic (
      INITIALIZE : std_logic_vector(4 downto 0) := "00000"
    );
    port (
      clk_in : in  std_logic;
      i_in   : in  std_logic;
      o_out  : out std_logic
    );
  end component;
  
begin
	
  -- rx slide pulse detection
  rxslide_r  <= master_rx_slide_i when rising_edge(master_rx_slide_clk_i);
  rxslide_r2 <= rxslide_r         when rising_edge(master_rx_slide_clk_i);

  --============================================================================
  -- FSM to calculate modulo of error
  --!  Error FSM
  --============================================================================  
  p_rxslide_toggle : process(master_rx_slide_clk_i)
  begin
    if(rising_edge(master_rx_slide_clk_i)) then
      if(rxslide_r2 = '0' and rxslide_r = '1') then
		rx_slide_toggle <= not rx_slide_toggle;
      end if;
    end if;
  end process p_rxslide_toggle;

  -- sync.
  rx_slide_toggle_bit_synchronizer: bit_synchronizer
    port map(
      clk_in => clk_sys_i       ,
      i_in   => rx_slide_toggle ,
      o_out  => rx_slide_toggle_sync
    );
	
	
  rx_slide_toggle_sync_r <= rx_slide_toggle_sync when rising_edge(clk_sys_i);
  rx_slide_toggle_xor    <= rx_slide_toggle_sync_r xor rx_slide_toggle_sync;
  
  --============================================================================
  -- Offset error calculation
  --!  p_offset
  --============================================================================  
  p_offset : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(master_mgt_rx_ready_i = '0') then
	    rxslide_cntr <= 0;
	    error_offset <= (others => '0');
      else
	      if(rx_slide_toggle_xor = '1') then
		    if((rxslide_cntr = 1 and master_rx_slide_mode_i='0') or (rxslide_cntr = g_MASTER_RX_MGT_WORD_WIDTH-1 and master_rx_slide_mode_i='1')) then
			  rxslide_cntr <= 0;
			  error_offset <= (others => '0');
			else
			  rxslide_cntr <= rxslide_cntr + 1;
			  error_offset <= error_offset + signed(master_rx_ui_period_i);
			end if;
           end if;
      end if;
    end if;
  end process p_offset;
  
  master_offset_o <= std_logic_vector(error_offset);

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
