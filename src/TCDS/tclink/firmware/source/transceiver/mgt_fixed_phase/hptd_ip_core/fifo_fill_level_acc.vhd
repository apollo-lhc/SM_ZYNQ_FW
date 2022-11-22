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
--! @file fifo_fill_level_acc.vhd
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
-- unit name: Transmitter FIFO filling level phase detector (fifo_fill_level_acc)
--
--! @brief Transmitter FIFO filling level phase detector based on the address difference of read and write pointers
--! This block accumulates the FIFO filling level flag in order to obtain a high precision phase detector 
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
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for fifo_fill_level_acc
--==============================================================================
entity fifo_fill_level_acc is
  port (
    -- User Interface   
    clk_sys_i            : in  std_logic;  --! system clock input
    reset_i              : in  std_logic;  --! actived on rising edge sync. reset
    done_o               : out std_logic;  --! latched to '1' to indicate accumulated value was reached, cleared only with clear/reset
    phase_detector_o     : out std_logic_vector(31 downto 0);  --! phase detector accumulated output (increments for each pulse in which txfifofilllevel is 1)
    phase_detector_max_i : in  std_logic_vector(31 downto 0);  --! phase detector accumulated max output, sets precision of phase detector
                                           --! this is supposedly a static signal, this block shall be reset whenever this signal changes
                                           --! the time for each phase detection after a clear is given by phase_detector_max_i * PERIOD_clk_txusr_i
    -- MGT interface                                      
    -- Tx fifo fill level - see Xilinx transceiver User Guide for more information      
    clk_txusr_i          : in  std_logic;  --! txusr2clk
    tx_fifo_fill_level_i : in  std_logic   --! connect to txbufstatus[0]
    );
end fifo_fill_level_acc;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of fifo_fill_level_acc is

  --! Attribute declaration
  attribute async_reg : string;

  --! Constant declaration

  --! Signal declaration
  -- clear synchronizer to txusr clk using closed loop technique with synchronizer
  -- reset synchronizer using simple 2-FF
  -- clk_sys  
  signal reset_r      : std_logic;
  signal reset_toggle : std_logic := '0';

  -- clk_txusr
  signal reset_toggle_txusr_meta                                                              : std_logic;
  signal reset_toggle_txusr_r                                                                 : std_logic;
  signal reset_toggle_txusr_r2                                                                : std_logic;
  attribute async_reg of reset_toggle_txusr_meta, reset_toggle_txusr_r, reset_toggle_txusr_r2 : signal is "true";
  signal reset_txusr                                                                          : std_logic;

  -- phase detector 
  signal phase_detector_acc : unsigned(phase_detector_o'range);
  signal hits_acc           : unsigned(phase_detector_max_i'range);
  signal done               : std_logic;

  -- sync for done
  signal done_sys_meta                                          : std_logic;
  signal done_sys_r                                             : std_logic;
  signal done_sys_r2                                            : std_logic;
  attribute async_reg of done_sys_meta, done_sys_r, done_sys_r2 : signal is "true";

  
begin

  --============================================================================
  -- Process p_reset_toggle
  --!  Creates a toggle for the reset when rising edge is detected
  --! read: reset_i\n
  --! write: \n
  --! r/w: reset_toggle\n
  --============================================================================  
  p_reset_toggle : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      reset_r <= reset_i;
      if(reset_r = '0' and reset_i = '1') then
        reset_toggle <= not reset_toggle;
      end if;
    end if;
  end process p_reset_toggle;

  --============================================================================
  -- Process p_reset_toggle_txusrsync
  --!  Creates a toggle for the reset when rising edge is detected
  --! read: reset_toggle\n
  --! write: reset_txusr\n
  --! r/w: reset_toggle_txusr_meta, reset_toggle_txusr_r, reset_toggle_txusr_r2\n
  --============================================================================  
  p_reset_toggle_txusrsync : process(clk_txusr_i)
  begin
    if(rising_edge(clk_txusr_i)) then
      reset_toggle_txusr_meta <= reset_toggle;
      reset_toggle_txusr_r    <= reset_toggle_txusr_meta;
      reset_toggle_txusr_r2   <= reset_toggle_txusr_r;
      reset_txusr             <= reset_toggle_txusr_r2 xor reset_toggle_txusr_r;
    end if;
  end process p_reset_toggle_txusrsync;

  --============================================================================
  -- Process p_phase_detector
  --!  Creates reset toggle register with rising edge of reset
  --! read:  reset_txusr\n
  --! write: done\n
  --! r/w:   hits_acc, phase_detector_acc\n
  --============================================================================  
  p_phase_detector : process(clk_txusr_i)
  begin
    if(rising_edge(clk_txusr_i)) then
      if (reset_txusr = '1') then
        phase_detector_acc <= to_unsigned(0, phase_detector_acc'length);
        hits_acc           <= to_unsigned(0, hits_acc'length);
        done               <= '0';
      else
        if(hits_acc < unsigned(phase_detector_max_i)) then
          hits_acc <= hits_acc + to_unsigned(1, hits_acc'length);
          if(tx_fifo_fill_level_i = '1') then
            phase_detector_acc <= phase_detector_acc + to_unsigned(1, phase_detector_acc'length);
          end if;
          done <= '0';
        else
          done <= '1';
        end if;
      end if;
    end if;
  end process p_phase_detector;

  --============================================================================
  -- Process p_sys_sync
  --!  System clock output synchronizer
  --! read:  done\n
  --! write: done_sys_r2\n
  --! r/w:   done_sys_meta, done_sys_r\n
  --============================================================================  
  p_sys_sync : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      done_sys_meta <= done;
      done_sys_r    <= done_sys_meta;
      done_sys_r2   <= done_sys_r;
    end if;
  end process p_sys_sync;

  --============================================================================
  -- Process p_done_out
  --! Output of done bit
  --! read:  done_sys_r2, done_sys_r\n
  --! write: done_o\n
  --! r/w:   -\n
  --============================================================================  
  p_done_out : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(reset_i = '1') then
        done_o <= '0';
      else
        if(done_sys_r2 = '0' and done_sys_r = '1') then
          done_o <= '1';
        end if;
      end if;
    end if;
  end process p_done_out;

  --============================================================================
  -- Process p_pd_out
  --! Output of phase detector
  --! read:  done_sys_r2, done_sys_r, phase_detector_acc\n
  --! write: phase_detector_o\n
  --! r/w:   -\n
  --============================================================================  
  p_pd_out : process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(done_sys_r2 = '0' and done_sys_r = '1') then
        phase_detector_o <= std_logic_vector(phase_detector_acc);
      end if;
    end if;
  end process p_pd_out;
  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
