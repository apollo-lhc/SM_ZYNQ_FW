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
--! @file tclink_controller.vhd
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
-- unit name: TCLink controller (tclink_controller)
--
--! @brief TClink controller
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 07\08\2019
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
--! 07\08\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tclink_controller
--==============================================================================
entity tclink_controller is
  generic(
    g_DATA_WIDTH            : integer := 32;                                 --! The data for tclink_controller is defined as XXXXXXXXXX.YYYYYYYYY
    g_FIXEDPOINT_BIT        : integer := 10;                                 --!                                              <-------->.<------->
                                                                             --!                                                A bits     B bits
                                                                             --! B corresponds to g_FIXEDPOINT_BIT and A+B corresponds to g_DATA_WIDTH	
    g_COEFF_SIZE            : integer := 4                                   --! Size for PI coefficients
																			 
  );
  port (
    -- User Interface   
    clk_sys_i               : in  std_logic;                                 --! system clock input
    reset_i                 : in  std_logic;                                 --! active high sync. reset

    -- Phase detector input error to be corrected by controller
    clk_en_error_i          : in  std_logic;                                 --! clock enable for sampling loop
    error_i                 : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! Error input from phase detector
                                                                             --! This is a fractional signed number
                                                                             --! The unit bit is the index g_FIXEDPOINT_BIT

    offset_error_i          : in std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Error offset
                                                                             --! This is a fractional signed number
                                                                             --! The unit bit is the index g_FIXEDPOINT_BIT

    modulo_carrier_period_i : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! Modulo of carrier period in DDMTD UNITS
    error_processed_o       : out std_logic_vector(g_DATA_WIDTH-1 downto 0); --! Error output from error processing block (should be between -1*modulo_carrier_period_i/2 and +1*modulo_carrier_period_i/2)
                                                                             --! This is a fractional signed number
                                                                             --! The unit bit is the index g_FIXEDPOINT_BIT

    -- User interface                                                        
    close_loop_i            : in  std_logic;                                 --! Loop is closed

    -- Loop controller	                                                     
    Aie_i                   : in  std_logic_vector(g_COEFF_SIZE-1 downto 0); --! Integral coefficient
    Aie_enable_i            : in  std_logic;                                 --! Enables usage of integral coefficient
    Ape_i                   : in  std_logic_vector(g_COEFF_SIZE-1 downto 0); --! Proportional coefficient

    -- Sigma-delta                                                           
    clk_en_sigma_delta_i    : in  std_logic;                                 --! clock enable for sigma delta modulation

    -- Mirror compensation                                                   
    enable_mirror_i         : in  std_logic;                                 --! Enable mirror compensation scheme (a part of phase variation is compensated using this scheme, otherwise a full compensation is performed)
    Adco_i                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! DCO coefficient for mirror compensation	

    -- Phase accumulated (debugging)                           
    phase_acc_o             : out std_logic_vector(g_DATA_WIDTH-1 downto 0); --! phase accumulated output (integrated output)
                                                                             --! This is an integer signed number, the LSB is the bit 0

    -- Operation error                                         
    operation_error_o       : out std_logic;                                 --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request 
                                                                             --! this is mainly useful for debugging purposes, for the final user this can be removed if the user is sure about all the operational parameters of the TCLink loop control

    -- DCO interface                                                         
    strobe_o                : out  std_logic;                                --! pulse synchronous to clk_sys_i to activate a shift in the DCO (only captured rising edge, so a signal larger than a pulse is also fine)
    inc_ndec_o              : out  std_logic;                                --! 1 increments, 0 decrements (modulated output)
    phase_step_o            : out  std_logic;                                --! number of units to shift the DCO    
    done_i                  : in   std_logic                                 --! pulse synchronous to clk_sys_i to indicate a DCO shift was performed

    );
end tclink_controller;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tclink_controller is

  --! Attribute declaration

  --! Constant declaration

  --! Signal declaration 
  -- Error processing
  signal error_processed        : std_logic_vector(error_i'range); --! Error processed after offset removal, modulo operation and DCO mirror compensation
  signal error_processed_p      : std_logic;                       --! Error processed pulse to indicate that a new error value was processed
  signal error_tocontroller_p   : std_logic;                       --! Error processed pulse to indicate that a new error value was processed

  -- PI Controller
  signal pi_ctrl                : std_logic_vector(error_i'range); --! Control from PI controller

  -- Sigma delta
  signal clk_en_sigma_delta     : std_logic;                       --! Clock enable for sigma-delta operation                                
  signal sigma_delta_ctrl       : std_logic;                       --! Control from Sigma delta modulator

  -- Mirror
  signal dco_mirror              : std_logic_vector(error_i'range); --! DCO Mirror Phase accumulated

  -- Avoid DCO step when not closed-loop
  signal strobe_aux : std_logic;
  
  --! Component declaration
  component phase_offset_removal is
    generic(
      g_DATA_WIDTH            : integer := 32;
      g_FIXEDPOINT_BIT        : integer := 10
    );
    port (
      -- User Interface   
      clk_sys_i            : in  std_logic;                                  --! system clock input
      clk_en_i             : in  std_logic;                                  --! clock enable for error_i
      reset_i              : in  std_logic;                                  --! active high sync. reset
  
      -- Error interface                                         
      error_i              : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Error input from DDMTD
                                                                             --! This is a fractional signed number
                                                                             --! The unit bit is the index g_FIXEDPOINT_BIT
  
      -- Offset control				  
      offset_error_i       : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Phase offset 
  
      -- Modulo operation, used to select right phase from DDMTD
      enable_modulo_i      : in  std_logic;                                  --! Enable modulo operation
      modulo_error_i       : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! Modulo in which error signal shall stay within	
  
      -- Mirror compensation
      dco_mirror_i         : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);  --! DCO phase accumulator multiplied by Kdco*beta
      enable_mirror_i      : in  std_logic;                                                   --! Enable mirror compensation scheme (a part of phase variation is compensated using this scheme, otherwise a full compensation is performed)
  
  
      -- Control interface
      error_o              : out  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! This is a fractional signed number
                                                                             --! The unit bit is the index g_FIXEDPOINT_BIT
      error_p_o            : out std_logic                                   --! Pulse indicating a new error was calculated
  
      );
  end component phase_offset_removal;

  component pi_controller is
    generic(
      g_DATA_WIDTH            : integer := 32;
      g_PROPORTIONAL_PRESCALE : integer := 0;
      g_INTEGRAL_PRESCALE     : integer := 0;
      g_COEFF_SIZE            : integer := 4
    );
    port (
      -- User Interface   
      clk_sys_i    : in  std_logic;                                    --! system clock input
      clk_en_i     : in  std_logic;                                    --! clock enable for pi controller
      reset_i      : in  std_logic;                                    --! active high sync. reset
  
      -- Loop dynamics interface
      error_i      : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);    --! Error input to be corrected (signed)
  
  
      Aie_i        : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Integral coefficient
      Aie_enable_i : in  std_logic;                                    --! Enables usage of integral coefficient
  
      Ape_i        : in  std_logic_vector(g_COEFF_SIZE-1 downto 0);    --! Proportional coefficient
  
      -- Control interface
      pi_ctrl_o    : out  std_logic_vector(g_DATA_WIDTH-1 downto 0)    --! PI controller response (signed)
  
      );
  end component pi_controller;
  
  component sigma_delta_modulator is
    generic(
      g_DATA_WIDTH            : integer := 32;
      g_FIXEDPOINT_BIT        : integer := 10
    );
    port (
      -- User Interface   
      clk_sys_i    : in  std_logic; --! system clock input
      clk_en_i     : in  std_logic; --! clock enable for sigma delta modulator	
      reset_i      : in  std_logic; --! active high sync. reset
  
      -- Input data to be modulated
      slow_input_i : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! slow input to be modulated
                                                        --! This is a fractional signed number
                                                        --! The unit bit is the index g_FIXEDPOINT_BIT
  
      -- Control interface
      sigma_delta_ctrl_o     : out std_logic --! 0 is positive, 1 is negative
  
      );
  end component sigma_delta_modulator;

  component dco_controller is
    generic(
      g_DATA_WIDTH : integer := 32
    );
    port (
      -- User Interface   
      clk_sys_i         : in  std_logic;                        --! system clock input
      clk_en_i          : in  std_logic;                        --! clock enable for sigma delta modulator	
      reset_i           : in  std_logic;                        --! active high sync. reset
  
      ctrl_i            : in std_logic;                         --! Input data to increment/decrement DCO phase
                                                                --! 0 -> +1 shift DCO
                                                                --! 1 -> -1 shift DCO
  
      -- User interface
      phase_acc_o       : out std_logic_vector(g_DATA_WIDTH-1 downto 0); --! DCO phase accumulated
      dco_mirror_o      : out std_logic_vector(g_DATA_WIDTH-1 downto 0); --! DCO mirror output (integrated output)
                                                                         --! This is an integer signed number, the LSB is the bit 0
      Adco_i            : in  std_logic_vector(g_DATA_WIDTH-1 downto 0); --! DCO coefficient for mirror compensation	
  	
      operation_error_o : out std_logic;                        --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request 
                                                                --! this is mainly useful for debugging purposes, for the final user this can be removed if the user is sure about all the operational parameters of the TCLink loop control
      -- DCO interface (fast output)
      strobe_o          : out  std_logic;                       --! pulse synchronous to clk_sys_i to activate a shift in the DCO (only captured rising edge, so a signal larger than a pulse is also fine)
      inc_ndec_o        : out  std_logic;                       --! 1 increments, 0 decrements (modulated output)
      phase_step_o      : out  std_logic;                       --! number of units to shift the DCO    
      done_i            : in   std_logic                        --! pulse synchronous to clk_sys_i to indicate a DCO shift was performed
  
      );
  end component dco_controller;

begin

  cmp_phase_offset_removal : phase_offset_removal
    generic map(
      g_DATA_WIDTH         => g_DATA_WIDTH,
      g_FIXEDPOINT_BIT     => g_FIXEDPOINT_BIT
    )
    port map(
      -- User Interface   
      clk_sys_i            => clk_sys_i     ,
      clk_en_i             => clk_en_error_i,
      reset_i              => reset_i       ,
  
      -- Error interface                                         
      error_i              => error_i,

      -- Offset control				  
      offset_error_i       => offset_error_i     ,
  
      -- Modulo operation, used to select right phase from DDMTD
      enable_modulo_i      => '1'                    ,
      modulo_error_i       => modulo_carrier_period_i,
  
      -- Mirror compensation
      -- Mirror compensation
      dco_mirror_i         => dco_mirror,
      enable_mirror_i      => enable_mirror_i,
  
      -- Control interface
      error_o              => error_processed    ,
      error_p_o            => error_processed_p
      );

  error_processed_o    <= error_processed;

  --! Disable controller and sigma-delta whenever loop is opened
  error_tocontroller_p <= error_processed_p    when close_loop_i='1' else '0'; 
  clk_en_sigma_delta   <= clk_en_sigma_delta_i when close_loop_i='1' else '0';

  cmp_pi_controller : pi_controller
    generic map(
      g_DATA_WIDTH            => g_DATA_WIDTH,
      g_PROPORTIONAL_PRESCALE => 0           ,
      g_INTEGRAL_PRESCALE     => 0           ,
      g_COEFF_SIZE            => g_COEFF_SIZE
    )
    port map(
      -- User Interface   
      clk_sys_i    => clk_sys_i            ,
      clk_en_i     => error_tocontroller_p ,
      reset_i      => reset_i              ,

      -- Loop dynamics interface
      error_i      => error_processed      ,

      Aie_i        => Aie_i                ,    
      Aie_enable_i => Aie_enable_i         ,
      Ape_i        => Ape_i                ,

      -- Control interface
      pi_ctrl_o    => pi_ctrl
      );

  cmp_sigma_delta_modulator : sigma_delta_modulator
    generic map(
      g_DATA_WIDTH     => g_DATA_WIDTH,
      g_FIXEDPOINT_BIT => g_FIXEDPOINT_BIT
    )
    port map(
      -- User Interface   
      clk_sys_i    => clk_sys_i,
      clk_en_i     => clk_en_sigma_delta,
      reset_i      => reset_i,

      -- Input data to be modulated
      slow_input_i => pi_ctrl,

      -- Control interface
      sigma_delta_ctrl_o   => sigma_delta_ctrl
      );

  cmp_dco_controller : dco_controller
    generic map(
      g_DATA_WIDTH => g_DATA_WIDTH
    )
    port map(
      -- User Interface   
      clk_sys_i    => clk_sys_i,
      clk_en_i     => clk_en_sigma_delta,
      reset_i      => reset_i,
  
      -- Input data to be quantized
      -- positive -> +1 shift DCO
      -- negative -> -1 shift DCO
      ctrl_i       => sigma_delta_ctrl,
  
      -- User interface
      phase_acc_o       => phase_acc_o,
      dco_mirror_o      => dco_mirror,
      Adco_i            => Adco_i,

      operation_error_o => operation_error_o,

      -- DCO interface (fast output)
      strobe_o     => strobe_aux,     
      inc_ndec_o   => inc_ndec_o,   
      phase_step_o => phase_step_o, 
      done_i       => done_i         
      );

    strobe_o <= strobe_aux when close_loop_i = '1' else '0';

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
