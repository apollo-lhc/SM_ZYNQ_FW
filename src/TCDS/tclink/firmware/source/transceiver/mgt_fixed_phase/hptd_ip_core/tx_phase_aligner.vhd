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
--! @file tx_phase_aligner.vhd
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
-- unit name: Tx Phase Aligner for usage when elastic buffer is enabled (tx_phase_aligner)
--
--! @brief Tx Phase Aligner for usage when elastic buffer is enabled
--! - Implements tx phase alignment procedure
--! - It is recommended to keep this block in a reset state ('reset_i' = 1) until the transceiver reset procedure is completed
--! - It is also recommended to keep the transmitter user logic in a reset state while the alignment procedure is not finished ('tx_aligned_o' = 0)
--! Different flavours are possible:
--! 1) At each reset, re-align transmitter with fine PI step:
--!    - When is it recommended?
--!        a) applications not requiring a perfect phase determinism (~5-10 ps variation) with resets
--!        b) applications using this block only as a CDC strategy with minimal latency variation
--!    - How to use design?
--!    - Config ports:
--!        Tie   tx_pi_phase_calib_i   to all '0'
--!        Tie   tx_ui_align_calib_i   to '0'
--!
--! 2) At each reset, re-align the transmitter PI to a calibrated value
--!    - When is it recommended?
--!        a) applications requiring a perfect phase determinism (~1 ps variation) with resets
--!        b) applications where the board FPGA is not subject to large temperature variations
--!    - What does it cost?
--!        a) Requires a initial calibration (automatically done by block) during first reset
--!        b) Monitor the tx_fifo_fill_pd_o and perform re-calibration whenever it is all zeros or all ones
--!
--!    - How to use design?
--!    - Config ports:
--!
--!        a) during first reset:
--!           Tie   tx_pi_phase_calib_i   to all X (dont care)
--!           Tie   tx_ui_align_calib_i   to '0'
--!
--!        b) during other resets:
--!           Tie   tx_pi_phase_calib_i   to the value of 'tx_pi_phase_o' after the first reset
--!           Tie   tx_ui_align_calib_i   to '1'
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 03\05\2018
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
--! 03\05\2018 - EBSM - Created\n
--! 13\09\2018 - EBSM - Remove unused ports\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tx_phase_aligner
--==============================================================================
entity tx_phase_aligner is
  generic(
    -- User choice of DRP control or port control
    -- Recommended nowadays to use in DRP control as a strange behaviour was observed using the port in PI code stepping mode
    g_DRP_NPORT_CTRL        : boolean                      := true;  --! Uses DRP control of port control for the transmitter PI
    g_DRP_ADDR_TXPI_PPM_CFG : std_logic_vector(8 downto 0) := ("010011010")  --! Check the transceiver user guide of your device for this address               
    );                                                                      
  port (
    --==============================================================================
    --! User control/monitor ports
    --==============================================================================    
    -- Clock / reset                                                       
    clk_sys_i : in std_logic;           --! system clock input
    reset_i   : in std_logic;  --! active high sync. reset (recommended to keep reset_i=1 while transceiver reset initialization is being performed)

    -- Top level interface                                                 
    tx_aligned_o : out std_logic;  --! Use it as a reset for the user transmitter logic

    -- Config (for different flavours)
    tx_pi_phase_calib_i   : in std_logic_vector(6 downto 0);  --! previous calibrated tx pi phase (tx_pi_phase_o after first reset calibration)
    tx_ui_align_calib_i   : in std_logic;  --! align with previous calibrated tx pi phase
    tx_fifo_fill_pd_max_i : in std_logic_vector(31 downto 0);  --! phase detector accumulated max output, sets precision of phase detector
                                           --! this is supposedly a static signal, this block shall be reset whenever this signal changes
                                           --! the time for each phase detection after a clear is given by tx_fifo_fill_pd_max_i * PERIOD_clk_txusr_i
    tx_fine_realign_i     : in std_logic;  --! A rising edge will cause the Tx to perform a fine realignment to the half-response

    -- It is only valid to re-shift clock once aligned (tx_aligned_o = '1') 
    ps_strobe_i     : in  std_logic;  --! pulse synchronous to clk_sys_i to activate a shift in the phase (only captured rising edge, so a signal larger than a pulse is also fine)
    ps_inc_ndec_i   : in  std_logic;  --! 1 increments phase by phase_step_i units, 0 decrements phase by phase_step_i units
    ps_phase_step_i : in  std_logic_vector(3 downto 0);  --! number of units to shift the phase of the receiver clock (see Xilinx transceiver User Guide to convert units in time)       
    ps_done_o       : out std_logic;  --! pulse synchronous to clk_sys_i to indicate a phase shift was performed

    -- Tx PI phase value
    tx_pi_phase_o : out std_logic_vector(6 downto 0);  --! phase shift accumulated

    -- Tx fifo fill level phase detector                                   
    tx_fifo_fill_pd_o : out std_logic_vector(31 downto 0);  --! phase detector output, when aligned this value should be close to (0x2_0000)

    --==============================================================================
    --! MGT ports
    --==============================================================================
    clk_txusr_i          : in std_logic;  --! txusr2clk                
    -- Tx fifo fill level - see Xilinx transceiver User Guide for more information      
    tx_fifo_fill_level_i : in std_logic;  --! connect to txbufstatus[0]

    -- Transmitter PI ports - see Xilinx transceiver User Guide for more information
    -- obs1: all txpi ports shall be connected to the transceiver even when using this block in DRP-mode                
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
end tx_phase_aligner;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tx_phase_aligner is

  --! Function declaration

  --! Constant declaration  
  constant c_SPEED_PD_FACTOR : integer range 0 to 19 := 7;
  constant c_PI_COARSE_STEP  : integer range 0 to 15 := 8;
  constant c_PI_FINE_STEP    : integer range 0 to 15 := 1;

  --! Signal declaration
  -- tx_pi_ctrl <-> tx_phase_aligner_fsm
  signal tx_aligner_tx_pi_strobe     : std_logic;
  signal tx_aligner_tx_pi_inc_ndec   : std_logic;
  signal tx_aligner_tx_pi_phase_step : std_logic_vector(3 downto 0);
  signal tx_aligner_tx_pi_done       : std_logic;

  signal tx_pi_strobe     : std_logic;
  signal tx_pi_inc_ndec   : std_logic;
  signal tx_pi_phase_step : std_logic_vector(3 downto 0);
  signal tx_pi_done       : std_logic;

  signal tx_pi_phase : std_logic_vector(6 downto 0);

  -- tx_fifo_fill_level_acc <-> tx_phase_aligner_fsm  
  signal tx_fifo_fill_pd_clear : std_logic;
  signal tx_fifo_fill_pd_done  : std_logic;
  signal tx_fifo_fill_pd       : std_logic_vector(31 downto 0);
  signal tx_fifo_fill_pd_max   : std_logic_vector(31 downto 0);

  signal reset_fifo_fill_level_acc : std_logic;

  signal tx_aligned : std_logic;

  --! Component declaration
  component tx_phase_aligner_fsm is
    generic(
      g_SPEED_PD_FACTOR : integer range 0 to 19 := 10;  --! coarse alignment procedure takes g_TX_FIFO_FILL_PD_MAX/(2**g_SPEED_PD_FACTOR)

      g_PI_COARSE_STEP : integer range 0 to 15 := 8;  --! coarse PI steps

      g_PI_FINE_STEP : integer range 0 to 15 := 1  --! fine PI steps               
      );
    port (
      -- Clock / reset  
      clk_sys_i : in std_logic;         --! system clock input
      reset_i   : in std_logic;         --! active high sync. reset

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
      tx_fifo_fill_pd_max_o   : out std_logic_vector(31 downto 0)   --! see user interface fifo_fill_level_acc.vhd for more information

      );
  end component tx_phase_aligner_fsm;

  component tx_pi_ctrl is
    generic(
      -- User choice of DRP control or port control
      -- Recommended nowadays to use in DRP control as a strange behaviour was observed using the port in PI code stepping mode
      g_DRP_NPORT_CTRL        : boolean                      := true;  --! Uses DRP control of port control for the transmitter PI
      g_DRP_ADDR_TXPI_PPM_CFG : std_logic_vector(8 downto 0) := ("010011010")  --! Check the transceiver user guide of your device for this address
      );
    port (
      -- User Interface 
      clk_sys_i    : in  std_logic;     --! system clock input
      reset_i      : in  std_logic;     --! active high sync. reset
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
      drpen_o   : out std_logic;        --! DRP enable transaction
      drpdi_o   : out std_logic_vector(15 downto 0);  --! DRP data write
      drprdy_i  : in  std_logic;        --! DRP finished transaction
      drpdo_i   : in  std_logic_vector(15 downto 0);  --! DRP data read; not used nowadays, write only interface
      drpwe_o   : out std_logic         --! DRP write enable
      );
  end component tx_pi_ctrl;

  component fifo_fill_level_acc is
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
  end component fifo_fill_level_acc;

begin

  cmp_tx_phase_aligner_fsm : tx_phase_aligner_fsm
    generic map(
      g_SPEED_PD_FACTOR => c_SPEED_PD_FACTOR ,
      g_PI_COARSE_STEP  => c_PI_COARSE_STEP ,
      g_PI_FINE_STEP    => c_PI_FINE_STEP
      )
    port map(
      -- Clock / reset  
      clk_sys_i => clk_sys_i,
      reset_i   => reset_i ,

      -- Top level interface
      tx_aligned_o => tx_aligned ,

      -- Config (for different flavours)
      tx_pi_phase_calib_i   => tx_pi_phase_calib_i,
      tx_ui_align_calib_i   => tx_ui_align_calib_i,
      tx_fifo_fill_pd_max_i => tx_fifo_fill_pd_max_i,
      tx_fine_realign_i     => tx_fine_realign_i,

      -- Tx pi controller interface - see user interface tx_pi_ctrl.vhd for more information
      tx_pi_strobe_o     => tx_aligner_tx_pi_strobe,
      tx_pi_inc_ndec_o   => tx_aligner_tx_pi_inc_ndec,
      tx_pi_phase_step_o => tx_aligner_tx_pi_phase_step,
      tx_pi_done_i       => tx_aligner_tx_pi_done,
      tx_pi_phase_i      => tx_pi_phase,

      -- Tx fifo fill level phase detector interface - see user interface fifo_fill_level_acc.vhd for more information
      tx_fifo_fill_pd_clear_o => tx_fifo_fill_pd_clear,
      tx_fifo_fill_pd_done_i  => tx_fifo_fill_pd_done,
      tx_fifo_fill_pd_i       => tx_fifo_fill_pd,
      tx_fifo_fill_pd_max_o   => tx_fifo_fill_pd_max
      );

  cmp_tx_pi_ctrl : tx_pi_ctrl
    generic map(
      -- User choice of DRP control or port control
      -- Recommended nowadays to use in DRP control as a strange behaviour was observed using the port in PI code stepping mode
      g_DRP_NPORT_CTRL        => g_DRP_NPORT_CTRL,
      g_DRP_ADDR_TXPI_PPM_CFG => g_DRP_ADDR_TXPI_PPM_CFG
      )
    port map(
      -- User Interface 
      clk_sys_i    => clk_sys_i,
      reset_i      => reset_i ,
      strobe_i     => tx_pi_strobe,
      inc_ndec_i   => tx_pi_inc_ndec,
      phase_step_i => tx_pi_phase_step,
      done_o       => tx_pi_done,
      phase_o      => tx_pi_phase,

      -- MGT interface                                      
      -- Transmitter PI ports - see Xilinx transceiver User Guide for more information
      -- obs1: all txpi ports shall be connected to the transceiver even when using this block in DRP-mode              
      clk_txusr_i       => clk_txusr_i,
      txpippmen_o       => txpippmen_o,
      txpippmovrden_o   => txpippmovrden_o,
      txpippmsel_o      => txpippmsel_o,
      txpippmpd_o       => txpippmpd_o,
      txpippmstepsize_o => txpippmstepsize_o,

      -- DRP interface - see Xilinx transceiver User Guide for more information
      -- obs2: connect clk_sys_i to drpclk
      -- obs3: if using this block in port-mode, DRP output can be left floating and input connected to '0'             
      drpaddr_o => drpaddr_o,
      drpen_o   => drpen_o,
      drpdi_o   => drpdi_o,
      drprdy_i  => drprdy_i,
      drpdo_i   => drpdo_i,
      drpwe_o   => drpwe_o
      );

  tx_pi_phase_o <= tx_pi_phase;

  tx_aligned_o          <= tx_aligned;
  tx_pi_strobe          <= ps_strobe_i     when tx_aligned = '1' else tx_aligner_tx_pi_strobe;
  tx_pi_inc_ndec        <= ps_inc_ndec_i   when tx_aligned = '1' else tx_aligner_tx_pi_inc_ndec;
  tx_pi_phase_step      <= ps_phase_step_i when tx_aligned = '1' else tx_aligner_tx_pi_phase_step;
  ps_done_o             <= tx_pi_done      when tx_aligned = '1' else '0';
  tx_aligner_tx_pi_done <= tx_pi_done      when tx_aligned = '0' else '0';

  cmp_fifo_fill_level_acc : fifo_fill_level_acc
    port map(
      -- User Interface 
      clk_sys_i            => clk_sys_i,
      reset_i              => reset_fifo_fill_level_acc,
      done_o               => tx_fifo_fill_pd_done,
      phase_detector_o     => tx_fifo_fill_pd,
      phase_detector_max_i => tx_fifo_fill_pd_max,

      -- MGT interface                                      
      -- Tx fifo fill level - see Xilinx transceiver User Guide for more information    
      clk_txusr_i          => clk_txusr_i,
      tx_fifo_fill_level_i => tx_fifo_fill_level_i
      );
  reset_fifo_fill_level_acc <= reset_i or tx_fifo_fill_pd_clear;

  tx_fifo_fill_pd_o <= tx_fifo_fill_pd;
  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
