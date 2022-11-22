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
--! @file prbs_chk.vhd
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
-- unit name: PRBS-checker (prbs_chk)
--
--! @brief parallel unfolded PRBS-checker with clock enable signal
--! Frame PRBS checker
--! Convention: LSB first received
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 22\10\2019
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
--! 22\10\2019 - EBSM - Created\n
--! 14\07\2020 - EBSM - Reset error and locked flag, check if pattern is not constant before locking\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! Add error counting \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for prbs_chk
--==============================================================================
entity prbs_chk is
  generic (
    g_GOOD_FRAME_TO_LOCK  : integer          := 15         ;                      --! Number of correct frames predicted for PRBS to go locked (g_GOOD_FRAME_TO_LOCK+2)
    g_BAD_FRAME_TO_UNLOCK : integer          := 5          ;                      --! Number of wrong received frames for PRBS to go unlocked  (g_BAD_FRAME_TO_UNLOCK+2)
    g_PARAL_FACTOR        : integer          := 254        ;                      --! Size of parallel bus: it is assumed in this implementation that the size of the parallel bus is bigger than the length of the polynomial
    g_PRBS_POLYNOMIAL     : std_logic_vector :=	"11000001"                        --! Notation: x^7 + x^6 + 1 (PRBS-7)
  );                                                                              
  port (                                                                          
    clk_i            : in  std_logic;                                             --! clock input
    reset_i          : in  std_logic;                                             --! active high sync. reset     <--- N --->       ____       ____       ____       ____
    en_i             : in  std_logic;                                             --! enable input                ______/    \_____/    \_____/    \_____/    \_____/    \_____/ 
    data_i           : in  std_logic_vector(g_PARAL_FACTOR-1 downto 0);           --! Input data                  X     D1   X     D2   X     D3   X D4-error X     D5   X     
    data_o           : out std_logic_vector(g_PARAL_FACTOR-1 downto 0);           --! PRBS output expected data              X     D0   X     D1   X     D2   X     D3   X     D4____X____   - Latency is 2N cycles
    error_o          : out std_logic;                                             --! PRBS Frame error                   ______________________________________________________/          \  - Kept to one for the whole duration; Latency is 2N+1 cycles
    locked_o         : out std_logic                                              --! PRBS locked                 <-------- 2N --------->                                <-+1-> 
  );
end prbs_chk;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of prbs_chk is

  --! Function declaration
  function fcn_max(arg1 : integer; arg2 : integer) return integer is
  begin
    if(arg1 > arg2) then
      return arg1;
	else
      return arg2;	
	end if;
  end fcn_max;
  
  --! Constant declaration  

  --! Signal declaration
  signal seed               : std_logic_vector(g_PRBS_POLYNOMIAL'length-2 downto 0); --! Seed for polynomial
  signal load               : std_logic;                                             --! Load seed when not locked
  signal error              : std_logic;                                             --! PRBS error
  signal data_notzero       : std_logic;                                             --! Check if data is not always 0 before locking
  signal data_chk           : std_logic_vector(g_PARAL_FACTOR-1 downto 0);           --! PRBS output data

  --------------------------------------------------------------------------------------------------------------
  -- FSM PRBS-locking
  -- principle:
  -- HUNT            : received a correct frame                       -> GOING_LOCK
  --                   received a wrong frame                         -> HUNT
  -- GOING_LOCK      : received a consecutive number of correct frame -> LOCK
  --                   received a wrong frame                         -> HUNT   
  -- LOCK            : received a wrong frame                         -> GOING_HUNT
  -- GOING_HUNT      : received a consecutive number of wrong frame   -> HUNT
  --                   received a correct frame                       -> LOCK
  type   t_PRBS_LOCK_STATE is (HUNT, GOING_LOCK, LOCK, GOING_HUNT);
  signal prbs_lock_state : t_PRBS_LOCK_STATE;

  signal frame_cntr : integer range 0 to fcn_max(g_BAD_FRAME_TO_UNLOCK, g_GOOD_FRAME_TO_LOCK);  
  --------------------------------------------------------------------------------------------------------------

  signal data_r  : std_logic_vector(data_i'range);
  signal data_r2 : std_logic_vector(data_i'range);

  --! Component declaration
  component prbs_gen is
    generic (
      g_PARAL_FACTOR    : integer          := 254        ;                          --! Size of parallel bus
      g_PRBS_POLYNOMIAL : std_logic_vector :=	"11000001"                          --! Notation: x^7 + x^6 + 1 (PRBS-7)
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
  end component prbs_gen;

begin

  --! Seed is retrieved from the input data
  seed <= data_i(seed'range);

  --! Component declaration of prbs generator
  cmp_prbs_gen : prbs_gen
    generic map(
      g_PARAL_FACTOR    => g_PARAL_FACTOR,
      g_PRBS_POLYNOMIAL => g_PRBS_POLYNOMIAL
    )                                                                              
    port map(                                                                          
      clk_i            => clk_i  ,
      en_i             => en_i   ,
      reset_i          => reset_i,
      seed_i           => seed   ,
      load_i           => load   ,
      data_o           => data_chk,
      data_valid_o     => open
    );
  
  --============================================================================
  -- Process p_prbs_lock_fsm
  --============================================================================  
  p_prbs_lock_fsm : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(reset_i = '1') then
        prbs_lock_state <= HUNT;
      else
        if(en_i='1') then
            case prbs_lock_state is
              when HUNT =>
                  if(error='0') then
                      prbs_lock_state <= GOING_LOCK;
                  end if;
              when GOING_LOCK =>
                  if(error='1') then
                      prbs_lock_state <= HUNT;
                  elsif(frame_cntr >= g_GOOD_FRAME_TO_LOCK) then
                    if(data_notzero='1') then				  
                      prbs_lock_state <= LOCK;
                    else
                      prbs_lock_state <= HUNT;
                    end if;					
                  end if;
              when LOCK =>
                  if(error='1') then
                      prbs_lock_state <= GOING_HUNT;
                  end if;
              when GOING_HUNT =>
                  if(error='0') then
                      prbs_lock_state <= LOCK;
                  elsif(frame_cntr >= g_BAD_FRAME_TO_UNLOCK) then
                      prbs_lock_state <= HUNT;
                  end if;
              when others => prbs_lock_state <= HUNT;
            end case;
        end if;
      end if;
    end if;
  end process p_prbs_lock_fsm;

  --============================================================================
  -- Process p_frame_cntr
  --============================================================================  
  p_frame_cntr : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(reset_i = '1') then
        frame_cntr <= 0;
      else
        if(en_i='1') then
            if(prbs_lock_state = GOING_LOCK or prbs_lock_state=GOING_HUNT) then
                if(frame_cntr < fcn_max(g_BAD_FRAME_TO_UNLOCK, g_GOOD_FRAME_TO_LOCK)) then
                  frame_cntr <= frame_cntr + 1;
                else
                  frame_cntr <= 0;
                end if;				  
            else
              frame_cntr <= 0;			 
            end if;
        end if;
      end if;
    end if;
  end process p_frame_cntr;

  --============================================================================
  -- Process p_data_r
  --============================================================================  
  p_data_r : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(en_i='1') then
        data_r  <= data_i;
        data_r2 <= data_r;		
      end if;
    end if;
  end process p_data_r;

  --============================================================================
  -- Process p_status_out
  --============================================================================  
  load     <= '1' when prbs_lock_state = HUNT or prbs_lock_state = GOING_LOCK else '0';
  error    <= '1' when data_chk /= data_r2 else '0';
  p_status_out : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(reset_i='1') then 
        locked_o <= '0';
        error_o  <= '0';	  
      else
        locked_o <= (not load);
        error_o  <= error;	  
      end if;
    end if;
  end process p_status_out;  
  data_o   <= data_chk;

  --============================================================================
  -- Process p_data_notzero - used to check if data it not always zero before locking
  --============================================================================  
  p_data_notzero : process(clk_i)
  begin
    if(clk_i'event and clk_i = '1') then
      if(prbs_lock_state = HUNT) then
        data_notzero  <= '0';
      elsif(prbs_lock_state = GOING_LOCK) then
        if(to_integer(unsigned(data_r2)) /= 0 ) then
          data_notzero  <= '1';
		end if;
      end if;
    end if;
  end process p_data_notzero;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================