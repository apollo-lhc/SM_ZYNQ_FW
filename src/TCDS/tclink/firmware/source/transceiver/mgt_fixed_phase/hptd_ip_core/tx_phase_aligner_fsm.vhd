--==============================================================================
-- © Copyright CERN for the benefit of the HPTD interest group 2018. All rights not
--   expressly granted are reserved.
--
--   This file is part of tx_phase_aligner.
--
-- tx_phase_aligner is free VHDL code: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- tx_phase_aligner is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with tx_phase_aligner.  If not, see <https://www.gnu.org/licenses/>.
--==============================================================================
--! @file tx_phase_aligner_fsm.vhd
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
-- unit name: Tx Phase Aligner FSM logic (tx_phase_aligner_fsm)
--
--! @brief Tx Phase Aligner FSM logic
--! - Implements control algorithm for transmitter phase alignment acting on tx_pi_ctrl and fifo_fill_level_acc
--! - Many algorithm flavour and alignment strategies are possible and those are further explained in the reference note containing this design
--! 
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 02\05\2018
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
--! 02\05\2018 - EBSM - Created\n
--! 13\09\2018 - EBSM - register tx_aligned_o output\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tx_phase_aligner_fsm
--==============================================================================
entity tx_phase_aligner_fsm is
  generic(
    g_SPEED_PD_FACTOR : integer range 0 to 19 := 10;  --! coarse alignment procedure takes tx_fifo_fill_pd_max_i/(2**g_SPEED_PD_FACTOR)

    g_PI_COARSE_STEP : integer range 0 to 15 := 8;  --! coarse PI steps

    g_PI_FINE_STEP : integer range 0 to 15 := 1  --! fine PI steps         
    );
  port (
    -- Clock / reset    
    clk_sys_i : in std_logic;                    --! system clock input
    reset_i   : in std_logic;                    --! active high sync. reset

    -- Top level interface
    tx_aligned_o : out std_logic;  --! Use it as a reset for the user transmitter logic

    -- Config (for different flavours)
    tx_pi_phase_calib_i   : in std_logic_vector(6 downto 0);  --! previous calibrated tx pi phase
    tx_ui_align_calib_i   : in std_logic;  --! align with previous calibrated tx pi phase
    tx_fifo_fill_pd_max_i : in std_logic_vector(31 downto 0);  --! phase detector accumulated max output, sets precision of phase detector
                                           --! this is supposedly a static signal, this block shall be reset whenever this signal changes
                                           --! the time for each phase detection after a clear is given by tx_fifo_fill_pd_max_i * PERIOD_clk_txusr_i
    tx_fine_realign_i     : in std_logic;  --! A rising edge will cause the Tx to perform a fine realignment to the half-response

    -- Tx pi controller interface - see user interface tx_pi_ctrl.vhd for more information
    tx_pi_strobe_o     : out std_logic;  --! see user interface tx_pi_ctrl.vhd for more information
    tx_pi_inc_ndec_o   : out std_logic;  --! see user interface tx_pi_ctrl.vhd for more information
    tx_pi_phase_step_o : out std_logic_vector(3 downto 0);  --! see user interface tx_pi_ctrl.vhd for more information
    tx_pi_done_i       : in  std_logic;  --! see user interface tx_pi_ctrl.vhd for more information
    tx_pi_phase_i      : in  std_logic_vector(6 downto 0);  --! see user interface tx_pi_ctrl.vhd for more information

    -- Tx fifo fill level phase detector interface - see user interface fifo_fill_level_acc.vhd for more information
    tx_fifo_fill_pd_clear_o : out std_logic;  --! see user interface fifo_fill_level_acc.vhd for more information
    tx_fifo_fill_pd_done_i  : in  std_logic;  --! see user interface fifo_fill_level_acc.vhd for more information
    tx_fifo_fill_pd_i       : in  std_logic_vector(31 downto 0);  --! see user interface fifo_fill_level_acc.vhd for more information
    tx_fifo_fill_pd_max_o   : out std_logic_vector(31 downto 0)  --! see user interface fifo_fill_level_acc.vhd for more information

    );
end tx_phase_aligner_fsm;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tx_phase_aligner_fsm is

  --! Function declaration
  function fcn_reduce_or(arg : std_logic_vector) return std_logic is
    variable result : std_logic;
  begin
    result := '0';
    for i in arg'range loop
      result := result or arg(i);
    end loop;
    return result;
  end;

  --! Constant declaration

  --! Signal declaration
  -- FSM to control the phase alignment
  -- The phase alignment is divided into four steps:
  --    COARSE   : Initial coarse and fast alignment to optimize time of routine, aligns to 1.0 as phase detector response
  --    FINE     : Fine alignment to find the ideal position where phase detector gives 0.5 as response
  --    UI_ALIGN : Fine UI alignment to ensure PI position is always the same
  --    ALIGNED  : Keeps checking phase detector response
  type t_PHASE_ALIGNER_FSM is (IDLE,                --  |
                                                    --  | 
                               COARSE_SET_CONFIG ,  --  |                                                         
                                                    --  v
                               COARSE_SHIFT_PI ,    --  | <--.
                                                    --  v    | 
                               COARSE_WAIT_PD ,     --  |    |
                                                    --  |----.                                                    
                                                    --  v
                               FINE_SET_CONFIG ,    --  | <----------------------------------------------------------.
                                                    --  v                                                            |
                               FINE_CHECK_DIRECTION,--  |                                                            |
                                                    --  v                                                            |
                               FINE_SHIFT_PI ,      --  |<---.                                                       |                                                                                          
                                                    --  v    |                                                       |
                               FINE_WAIT_PD ,       --  |----.                                                       |
                                                    --  v                                                            |
                               FINE_ALIGNED ,       --  |                                                            |
                                                    --  | ----------.                                                |
                                                    --  v           |                                                |                    
                               UI_SET_OFFSET ,      --  |           |                                                |
                                                    --  v           |                                                |               
                               UI_CHECK_SHIFT_PI ,  --  |-----------.                                                |
                                                    --  v  ^        |                                                |
                               UI_SHIFT_PI ,        --  ---|        |                                                |
                                                    --              |                                                |
                                                    --              |                                                |
                               ALIGNED_CLEAR_PD ,   -- <------------. - ALIGNED                                      |
                                                    -- |      ^                   ------------------------------------
                               ALIGNED_WAIT_PD      -- v------|       - ALIGNED 
                               );

  signal phase_aligner_state : t_PHASE_ALIGNER_FSM;

  -- Identify rising edge of 'tx_fine_realign_i' and realign (only capture if already aligned)
  signal tx_fine_realign_r : std_logic;

  -- Set configuration of PI and PD
  signal tx_pi_inc_ndec      : std_logic;
  signal tx_pi_phase_step    : std_logic_vector(tx_pi_phase_step_o'range);
  signal tx_fifo_fill_pd_max : std_logic_vector(tx_fifo_fill_pd_max_o'range);

  -- half_response is used to indicate whether the 
  signal half_response     : std_logic;
  signal half_response_mem : std_logic;

  -- UI algorithm math
  signal ref_dist_mod64 : unsigned(tx_pi_phase_i'left-1 downto 0);
  signal ui_align_cntr  : unsigned(tx_pi_phase_i'left-1 downto 0);


  -- Tx aligned combinatorial
  signal tx_aligned : std_logic;
begin

  --============================================================================
  -- Main FSM algorithm
  --============================================================================  
  --============================================================================
  -- Process p_phase_aligner_fsm
  --! Main FSM for the algorithm flow control
  --! read:  \n
  --! write: -\n
  --! r/w:   drp_tx_pi_state\n
  --============================================================================  
  p_phase_aligner_fsm : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1') then
        phase_aligner_state <= IDLE;
      else
        case phase_aligner_state is

          when IDLE =>
            phase_aligner_state <= COARSE_SET_CONFIG;

          when COARSE_SET_CONFIG =>
            phase_aligner_state <= COARSE_SHIFT_PI;
            
          when COARSE_SHIFT_PI =>
            if(tx_pi_done_i = '1') then
              phase_aligner_state <= COARSE_WAIT_PD;
            end if;
            
          when COARSE_WAIT_PD =>
            if(tx_fifo_fill_pd_done_i = '1') then
              if(tx_fifo_fill_pd_i(tx_fifo_fill_pd_i'left - g_SPEED_PD_FACTOR downto 0) = tx_fifo_fill_pd_max_i(tx_fifo_fill_pd_max_i'left downto g_SPEED_PD_FACTOR))then
                phase_aligner_state <= FINE_SET_CONFIG;  --reached full PD response (1.0)                
              else
                phase_aligner_state <= COARSE_SHIFT_PI;
              end if;
            end if;

          when FINE_SET_CONFIG =>
            phase_aligner_state <= FINE_CHECK_DIRECTION;

          when FINE_CHECK_DIRECTION =>
            if(tx_fifo_fill_pd_done_i = '1') then
              phase_aligner_state <= FINE_SHIFT_PI;
            end if;
            
          when FINE_SHIFT_PI =>
            if(tx_pi_done_i = '1') then
              phase_aligner_state <= FINE_WAIT_PD;
            end if;
            
          when FINE_WAIT_PD =>
            if(tx_fifo_fill_pd_done_i = '1') then
              if(half_response /= half_response_mem) then  --reached half PD response 0.5
                phase_aligner_state <= FINE_ALIGNED;
              else
                phase_aligner_state <= FINE_SHIFT_PI;
              end if;
            end if;
            
          when FINE_ALIGNED =>
            if(tx_ui_align_calib_i = '1') then  -- go to UI mod-shift if user wants this option                            
              phase_aligner_state <= UI_SET_OFFSET;
            else
              phase_aligner_state <= ALIGNED_CLEAR_PD;
            end if;
            
          when UI_SET_OFFSET =>
            phase_aligner_state <= UI_CHECK_SHIFT_PI;

          when UI_CHECK_SHIFT_PI =>
            if(to_integer(ui_align_cntr) /= 0) then
              phase_aligner_state <= UI_SHIFT_PI;
            else
              phase_aligner_state <= ALIGNED_CLEAR_PD;
            end if;
            
          when UI_SHIFT_PI =>
            if(tx_pi_done_i = '1') then
              phase_aligner_state <= UI_CHECK_SHIFT_PI;
            end if;

          when ALIGNED_CLEAR_PD =>
            if(tx_fine_realign_i = '1' and tx_fine_realign_r = '0') then
              phase_aligner_state <= FINE_SET_CONFIG;
            else
              phase_aligner_state <= ALIGNED_WAIT_PD;
            end if;
            
          when ALIGNED_WAIT_PD =>
            if(tx_fine_realign_i = '1' and tx_fine_realign_r = '0') then
              phase_aligner_state <= FINE_SET_CONFIG;
            elsif(tx_fifo_fill_pd_done_i = '1') then
              phase_aligner_state <= ALIGNED_CLEAR_PD;
            end if;

          when others =>
            phase_aligner_state <= IDLE;

        end case;
      end if;
    end if;
  end process p_phase_aligner_fsm;

  -- register for rising edge identification
  tx_fine_realign_r <= tx_fine_realign_i when rising_edge(clk_sys_i);

  --============================================================================
  -- PI and PD control
  --============================================================================  
  --============================================================================
  -- Process p_set_config
  --! Sets config for Tx PI and phase detector depending on part of algorithm
  --! read:  phase_aligner_state, tx_fifo_fill_pd_max_i, ref_dist_mod64\n
  --! write: \n
  --! r/w:   tx_pi_inc_ndec, tx_pi_phase_step, tx_fifo_fill_pd_max\n
  --============================================================================  
  p_set_config : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1') then
        tx_pi_inc_ndec      <= '0';
        tx_pi_phase_step    <= (others => '0');
        tx_fifo_fill_pd_max <= (others => '0');
      else
        case phase_aligner_state is
          when COARSE_SET_CONFIG =>
            tx_pi_inc_ndec                                                                                        <= '1';
            tx_pi_phase_step                                                                                      <= std_logic_vector(to_unsigned(g_PI_COARSE_STEP, tx_pi_phase_step'length));
            tx_fifo_fill_pd_max(tx_fifo_fill_pd_max_i'left-g_SPEED_PD_FACTOR downto 0)                            <= tx_fifo_fill_pd_max_i(tx_fifo_fill_pd_max_i'left downto g_SPEED_PD_FACTOR);
            tx_fifo_fill_pd_max(tx_fifo_fill_pd_max_i'left downto tx_fifo_fill_pd_max_i'left-g_SPEED_PD_FACTOR+1) <= (others => '0');

          when FINE_SET_CONFIG =>
            tx_pi_inc_ndec      <= tx_pi_inc_ndec;
            tx_pi_phase_step    <= std_logic_vector(to_unsigned(g_PI_FINE_STEP, tx_pi_phase_step'length));
            tx_fifo_fill_pd_max <= tx_fifo_fill_pd_max_i;

          when FINE_CHECK_DIRECTION =>
            tx_pi_inc_ndec      <= half_response;
            tx_pi_phase_step    <= tx_pi_phase_step;
            tx_fifo_fill_pd_max <= tx_fifo_fill_pd_max;

          when UI_SET_OFFSET =>
            tx_pi_inc_ndec      <= not ref_dist_mod64(ref_dist_mod64'left);  --not bigger than half UI
            tx_pi_phase_step    <= tx_pi_phase_step;
            tx_fifo_fill_pd_max <= tx_fifo_fill_pd_max;
            
          when others =>
            tx_pi_inc_ndec      <= tx_pi_inc_ndec;
            tx_pi_phase_step    <= tx_pi_phase_step;
            tx_fifo_fill_pd_max <= tx_fifo_fill_pd_max;
        end case;
      end if;
    end if;
  end process p_set_config;

  tx_pi_strobe_o     <= '1' when (phase_aligner_state = COARSE_SHIFT_PI or phase_aligner_state = FINE_SHIFT_PI or phase_aligner_state = UI_SHIFT_PI) else '0';
  tx_pi_inc_ndec_o   <= tx_pi_inc_ndec;
  tx_pi_phase_step_o <= tx_pi_phase_step;

  tx_fifo_fill_pd_clear_o <= '1' when (tx_pi_done_i = '1' or phase_aligner_state = ALIGNED_CLEAR_PD or phase_aligner_state = FINE_SET_CONFIG) else '0';
  tx_fifo_fill_pd_max_o   <= tx_fifo_fill_pd_max;

  --============================================================================
  -- Math
  --============================================================================  
  ref_dist_mod64 <= unsigned(tx_pi_phase_calib_i(tx_pi_phase_i'left-1 downto 0)) - unsigned(tx_pi_phase_i(tx_pi_phase_i'left-1 downto 0));

  --============================================================================
  -- Process p_half_response_mem
  --! Saves half response from PD
  --! read:  half_response\n
  --! write: half_response_mem\n
  --! r/w:   \n
  --============================================================================  
  half_response <= '1' when (unsigned(tx_fifo_fill_pd_i) <= unsigned('0'&tx_fifo_fill_pd_max_i(tx_fifo_fill_pd_max_i'left downto 1))) else '0';
  p_half_response_mem : process(clk_sys_i)
  begin
    if (rising_edge(clk_sys_i)) then
      if (tx_fifo_fill_pd_done_i = '1') then
        half_response_mem <= half_response;
      end if;
    end if;
  end process p_half_response_mem;

  --============================================================================
  -- Process p_ui_align_cntr
  --! Sets config for Tx PI and phase detector depending on part of algorithm
  --! read:  phase_aligner_state, ref_dist_mod64, tx_pi_done_i\n
  --! write: \n
  --! r/w:   ui_align_cntr\n
  --============================================================================  
  p_ui_align_cntr : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1') then
        ui_align_cntr <= (others => '0');
      else
        case phase_aligner_state is
          when UI_SET_OFFSET =>
            if(ref_dist_mod64(ref_dist_mod64'left) = '1') then  -- bigger than half-UI
              ui_align_cntr <= (not ref_dist_mod64) + to_unsigned(1, ref_dist_mod64'length);
            else
              ui_align_cntr <= ref_dist_mod64;
            end if;
          when UI_SHIFT_PI =>
            if(tx_pi_done_i = '1') then
              ui_align_cntr <= ui_align_cntr - 1;
            end if;
          when others =>
            ui_align_cntr <= ui_align_cntr;
        end case;
      end if;
    end if;
  end process p_ui_align_cntr;

  --============================================================================
  -- Alignment condition
  --============================================================================  
  tx_aligned   <= '1'        when (phase_aligner_state = ALIGNED_CLEAR_PD or phase_aligner_state = ALIGNED_WAIT_PD) else '0';
  tx_aligned_o <= tx_aligned when rising_edge(clk_sys_i);
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
