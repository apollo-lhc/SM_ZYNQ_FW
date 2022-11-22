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
--! @file tx_pi_ctrl.vhd
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
-- unit name: Tx Phase Interpolator Controller (tx_pi_ctrl)
--
--! @brief Transmitter phase interpolator controller for GTH/GTY (Ultrascale/Ultrascale plus - UG576 and UG578) and GTH (7-series - UG476)
--! - This block provides a simple interface for controlling the phase interpolator of Xilinx devices
--! - The control can be made via DRP or via PORT (selectable through attribute g_DRP_NPORT_CTRL)
--!   g_DRP_NPORT_CONTROL = true uses DRP control
--!   g_DRP_NPORT_CONTROL = false uses port control (a unexpected behaviour was observed in a GTH Ultrascale plus when using port control, this is the reason why the default is DRP control)
--! - The address of DRP control is different for Ultrascale/Ultrascale plus (0x009A) and 7-series devices (0x0095) 
--!   Default is the address of Ultrascale as this is what was tested
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
--! Entity declaration for tx_pi_ctrl
--==============================================================================
entity tx_pi_ctrl is
  generic(
    -- User choice of DRP control or port control
    -- Recommended nowadays to use in DRP control as a strange behaviour was observed using the port in PI code stepping mode
    g_DRP_NPORT_CTRL        : boolean                      := true;  --! Uses DRP control of port control for the transmitter PI
    g_DRP_ADDR_TXPI_PPM_CFG : std_logic_vector(8 downto 0) := ("010011010")  --! Check the transceiver user guide of your device for this address
    );
  port (
    -- User Interface   
    clk_sys_i    : in  std_logic;       --! system clock input
    reset_i      : in  std_logic;       --! active high sync. reset
    strobe_i     : in  std_logic;  --! pulse synchronous to clk_sys_i to activate a shift in the transmitter phase (only captured rising edge, so a signal larger than a pulse is also fine)
    inc_ndec_i   : in  std_logic;  --! 1 increments tx phase by phase_step_i units, 0 decrements tx phase by phase_step_i units
    phase_step_i : in  std_logic_vector(3 downto 0);  --! number of units to shift the phase of the transmitter (see Xilinx transceiver User Guide to convert units in time)          
    done_o       : out std_logic;  --! pulse synchronous to clk_sys_i to indicate a transmitter phase shift was performed
    phase_o      : out std_logic_vector(6 downto 0);  --! phase shift accumulated

    -- MGT interface                                      
    -- Transmitter PI ports - see Xilinx transceiver User Guide for more information
    -- obs1: all txpi ports shall be connected to the transceiver even when using this block in DRP-mode                
    clk_txusr_i       : in  std_logic;  --! txusr2clk
    txpippmen_o       : out std_logic;  --! enable tx phase interpolator controller
    txpippmovrden_o   : out std_logic;  --! enable DRP control of tx phase interpolator
    txpippmsel_o      : out std_logic;  --! set to 1 when using tx pi ppm controler
    txpippmpd_o       : out std_logic;  --! power down transmitter phase interpolator 
    txpippmstepsize_o : out std_logic_vector(4 downto 0);  --! sets step size and direction of phase shift with port control PI code stepping mode

    -- DRP interface - see Xilinx transceiver User Guide for more information
    -- obs2: connect clk_sys_i to drpclk
    -- obs3: if using this block in port-mode, DRP output can be left floating and input connected to '0'               
    drpaddr_o : out std_logic_vector(8 downto 0);  --! For devices with a 10-bit DRP address interface, connect MSB to '0'
    drpen_o   : out std_logic;          --! DRP enable transaction
    drpdi_o   : out std_logic_vector(15 downto 0);  --! DRP data write
    drprdy_i  : in  std_logic;          --! DRP finished transaction
    drpdo_i   : in  std_logic_vector(15 downto 0);  --! DRP data read; not used nowadays, write only interface
    drpwe_o   : out std_logic           --! DRP write enable
    );
end tx_pi_ctrl;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tx_pi_ctrl is

  --! Attribute declaration
  attribute async_reg : string;

  --! Constant declaration

  --! Signal declaration

  -- ==============================================================================
  -- ======================== Common: PORT/DRP interface ==========================
  -- ==============================================================================
  -- phase accumulator
  signal phase_acc : unsigned(phase_o'range);
  signal strobe_r  : std_logic;         --rising edge detector for strobe

  -- ==============================================================================
  -- ======================== Interface 1: DRP interface ==========================
  -- ==============================================================================
  -- FSM to control Tx PI via DRP control
  -- obs: Two write a new phase value for the transmitter PI via DRP:
  --        The bits 6:0 of the corresponding DRP register have to be asserted
  --        The bit 7 has to be asserted high (REGISTER_1PHASE_DRP) and then low (REGISTER_0PHASE_DRP)
  type   t_DRP_TX_PI_FSM is (IDLE, PHASE_ACCU, PRE_REGISTER_0PHASE_DRP, WAIT_PRE_REGISTER_0PHASE_DRP, REGISTER_1PHASE_DRP, WAIT_REGISTER_1PHASE_DRP, REGISTER_0PHASE_DRP, WAIT_REGISTER_0PHASE_DRP, DONE_DRP);
  signal drp_tx_pi_state : t_DRP_TX_PI_FSM;

  -- ==============================================================================
  -- ======================== Interface 2: PORT interface =========================
  -- ==============================================================================
  -- Closed-loop strobe_toggle strategy  
  -- sync to clk_sys_i
  signal strobe_toggle : std_logic := '0';

  -- sync to clk_txusr_i
  signal strobe_toggle_txusr_meta                                                                : std_logic;
  signal strobe_toggle_txusr_r                                                                   : std_logic;
  signal strobe_toggle_txusr_r2                                                                  : std_logic;
  attribute async_reg of strobe_toggle_txusr_meta, strobe_toggle_txusr_r, strobe_toggle_txusr_r2 : signal is "true";

  signal strobe_txusr        : std_logic;
  signal strobe_txusr_r      : std_logic;
  signal strobe_txusr_extend : std_logic;
  signal done_toggle         : std_logic := '0';

  -- sync to clk_sys_i
  signal done_toggle_sys_meta                                                        : std_logic;
  signal done_toggle_sys_r                                                           : std_logic;
  signal done_toggle_sys_r2                                                          : std_logic;
  attribute async_reg of done_toggle_sys_meta, done_toggle_sys_r, done_toggle_sys_r2 : signal is "true";

  signal done : std_logic;

begin

  -- ==============================================================================
  -- ======================== Interface 1: DRP interface ==========================
  -- ==============================================================================
  -- Only generated if user chooses to use port control  
  gen_drp_interface : if g_DRP_NPORT_CTRL generate

    -- Tie Tx PI port signals
    txpippmen_o                   <= '0';
    txpippmovrden_o               <= '1';
    txpippmsel_o                  <= '1';
    txpippmpd_o                   <= '0';
    txpippmstepsize_o(4 downto 0) <= (others => '0');

    --============================================================================
    -- Process p_strobe_r
    --!  Delays strobe
    --! read:  strobe_i\n
    --! write: strobe_r\n
    --! r/w:   \n
    --============================================================================  
    p_strobe_r : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        strobe_r <= strobe_i;
      end if;
    end process p_strobe_r;

    --============================================================================
    -- Process p_drp_tx_pi_fsm
    --! FSM for Tx PI control via DRP
    --! read:  strobe_i, drprdy_i\n
    --! write: -\n
    --! r/w:   drp_tx_pi_state\n
    --============================================================================  
    p_drp_tx_pi_fsm : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          drp_tx_pi_state <= IDLE;
        else
          case drp_tx_pi_state is
            when IDLE =>
              if(strobe_i = '1' and strobe_r = '0') then
                drp_tx_pi_state <= PHASE_ACCU;
              end if;
            when PHASE_ACCU =>
              drp_tx_pi_state <= PRE_REGISTER_0PHASE_DRP;
            when PRE_REGISTER_0PHASE_DRP =>
              drp_tx_pi_state <= WAIT_PRE_REGISTER_0PHASE_DRP;
            when WAIT_PRE_REGISTER_0PHASE_DRP =>
              if(drprdy_i = '1') then
                drp_tx_pi_state <= REGISTER_1PHASE_DRP;
              end if;
            when REGISTER_1PHASE_DRP =>
              drp_tx_pi_state <= WAIT_REGISTER_1PHASE_DRP;
            when WAIT_REGISTER_1PHASE_DRP =>
              if(drprdy_i = '1') then
                drp_tx_pi_state <= REGISTER_0PHASE_DRP;
              end if;
            when REGISTER_0PHASE_DRP =>
              drp_tx_pi_state <= WAIT_REGISTER_0PHASE_DRP;
            when WAIT_REGISTER_0PHASE_DRP =>
              if(drprdy_i = '1') then
                drp_tx_pi_state <= DONE_DRP;
              end if;
            when DONE_DRP =>
              drp_tx_pi_state <= IDLE;
            when others => drp_tx_pi_state <= IDLE;
          end case;
        end if;
      end if;
    end process p_drp_tx_pi_fsm;

    -- Tie static DRP signals
    drpaddr_o            <= g_DRP_ADDR_TXPI_PPM_CFG;
    drpdi_o(15 downto 8) <= (others => '0');

    -- DRP signals controlled via FSM
    drpdi_o(7)          <= '1' when drp_tx_pi_state = REGISTER_1PHASE_DRP                                                                                         else '0';
    drpdi_o(6 downto 0) <= std_logic_vector(phase_acc);
    drpen_o             <= '1' when (drp_tx_pi_state = REGISTER_1PHASE_DRP or drp_tx_pi_state = REGISTER_0PHASE_DRP or drp_tx_pi_state = PRE_REGISTER_0PHASE_DRP) else '0';
    drpwe_o             <= '1' when (drp_tx_pi_state = REGISTER_1PHASE_DRP or drp_tx_pi_state = REGISTER_0PHASE_DRP or drp_tx_pi_state = PRE_REGISTER_0PHASE_DRP) else '0';

    --============================================================================
    -- Process p_phase_acc
    --!  Increments or decrements phase accumulator
    --! read:  drp_tx_pi_state, inc_ndec_i, phase_step_i\n
    --! write: \n
    --! r/w:   phase_acc\n
    --============================================================================  
    p_phase_acc : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          phase_acc <= to_unsigned(0, phase_acc'length);
        else
          if(drp_tx_pi_state = PHASE_ACCU) then
            if(inc_ndec_i = '1') then
              phase_acc <= phase_acc + unsigned(phase_step_i);
            else
              phase_acc <= phase_acc - unsigned(phase_step_i);
            end if;
          else
            phase_acc <= phase_acc;
          end if;
        end if;
      end if;
    end process p_phase_acc;

    phase_o <= std_logic_vector(phase_acc);
    done_o  <= '1' when (drp_tx_pi_state = DONE_DRP) else '0';

  end generate gen_drp_interface;


  -- ==============================================================================
  -- ======================== Interface 2: PORT interface =========================
  -- ==============================================================================
  -- Only generated if user chooses to use port control  
  gen_port_interface : if not g_DRP_NPORT_CTRL generate
    -- Tie to zero unused DRP signals 
    drpaddr_o <= (others => '0');
    drpen_o   <= '0';
    drpdi_o   <= (others => '0');
    drpwe_o   <= '0';


    -- Closed-loop clock-domain crossing strategy for strobe pulse and done as acknowledgment
    --============================================================================
    -- Process p_strobe_toggle
    --!  Creates strobe toggle register with rising edge of strobe
    --! read:  strobe_i\n
    --! write: -\n
    --! r/w:   strobe_r, strobe_toggle\n
    --============================================================================  
    p_strobe_toggle : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        strobe_r <= strobe_i;
        if(strobe_i = '1' and strobe_r = '0') then
          strobe_toggle <= not strobe_toggle;
        end if;
      end if;
    end process p_strobe_toggle;

    --============================================================================
    -- Process p_strobe_toggle_txusrsync
    --!  Creates a rising edge sync to clk_txusr_i when strobe_toggle changes level and generates acknowledgment
    --! read:  strobe_toggle\n
    --! write: done_toggle\n
    --! r/w:   strobe_txusr_r, strobe_txusr, strobe_toggle_txusr_r2, strobe_toggle_txusr_r, strobe_toggle_txusr_meta\n
    --============================================================================  
    p_strobe_toggle_txusrsync : process(clk_txusr_i)
    begin
      if(rising_edge(clk_txusr_i)) then
        -- capture strobe
        strobe_toggle_txusr_meta <= strobe_toggle;
        strobe_toggle_txusr_r    <= strobe_toggle_txusr_meta;
        strobe_toggle_txusr_r2   <= strobe_toggle_txusr_r;
        strobe_txusr             <= strobe_toggle_txusr_r2 xor strobe_toggle_txusr_r;
        strobe_txusr_r           <= strobe_txusr;
        strobe_txusr_extend      <= strobe_txusr or strobe_txusr_r;

        -- acknowledgment (done)
        if(strobe_txusr_r = '1') then
          done_toggle <= not done_toggle;
        end if;
      end if;
    end process p_strobe_toggle_txusrsync;

    -- Pulses txpippmen for two clock cycles - see Xilinx transceiver User Guide (reason for extension of strobe pulse in txusr domain)
    txpippmen_o <= strobe_txusr_extend;

    -- Tie other signals 
    txpippmovrden_o               <= '0';
    txpippmsel_o                  <= '1';
    txpippmpd_o                   <= '0';
    txpippmstepsize_o(4)          <= inc_ndec_i;  -- obs: those signals should be stable between strobe->done, the latency of the closed-loop CDC ensures a proper capture
    txpippmstepsize_o(3 downto 0) <= phase_step_i;  -- obs: those signals should be stable between strobe->done, the latency of the closed-loop CDC ensures a proper capture

    --============================================================================
    -- Process p_done_toggle_syssync
    --!  Creates a rising edge sync to clk_sys_i when done_toggle changes level
    --! read:  done_toggle\n
    --! write: done_toggle_sys_r2\n
    --! r/w:   done_toggle_sys_meta, done_toggle_sys_r\n
    --============================================================================  
    p_done_toggle_syssync : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        done_toggle_sys_meta <= done_toggle;
        done_toggle_sys_r    <= done_toggle_sys_meta;
        done_toggle_sys_r2   <= done_toggle_sys_r;
      end if;
    end process p_done_toggle_syssync;
    done <= done_toggle_sys_r2 xor done_toggle_sys_r;

    --============================================================================
    -- Process p_phase_acc
    --!  Increments or decrements phase accumulator
    --! read:  done, inc_ndec_i, phase_step_i\n
    --! write: done_o\n
    --! r/w:   phase_acc\n
    --============================================================================  
    p_phase_acc : process(clk_sys_i)
    begin
      if(rising_edge(clk_sys_i)) then
        if(reset_i = '1') then
          phase_acc <= to_unsigned(0, phase_acc'length);
          done_o    <= '0';
        else
          if(done = '1') then
            if(inc_ndec_i = '1') then
              phase_acc <= phase_acc + unsigned(phase_step_i);
            else
              phase_acc <= phase_acc - unsigned(phase_step_i);
            end if;
            done_o <= '1';
          else
            phase_acc <= phase_acc;
            done_o    <= '0';
          end if;
        end if;
      end if;
    end process p_phase_acc;
    phase_o <= std_logic_vector(phase_acc);
    
  end generate gen_port_interface;


end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
