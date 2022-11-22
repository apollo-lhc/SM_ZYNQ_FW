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
--! @file tclink.vhd
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
-- unit name: TCLink (tclink)
--
--! @brief TClink top-level design
--! Instantiates Phase detector and TCLink controller (both which are generic VHDL code)
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 03\12\2019
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
--! 03\12\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tclink
--==============================================================================
entity tclink is
  generic(
    g_ENABLE_TESTER_IMPLEMENTATION : boolean :=False;
	g_MASTER_RX_MGT_WORD_WIDTH     : integer := 32
  );
  port (
    -----------------------------------------------------------------
    --------------------- System clock / resets ---------------------
    -----------------------------------------------------------------
    clk_sys_i                : in  std_logic;                                 --! system clock input
    tx_ready_i               : in  std_logic;                                 --! clk_tx_i is ready (used as reset)
    rx_ready_i               : in  std_logic;                                 --! clk_rx_i is ready and link is locked (used as reset)

    -----------------------------------------------------------------
    ------------------------- Phase-detector ------------------------
    ----------------------------------------------------------------- 
    ---- clocks	             
    clk_tx_i                 : in  std_logic;                                 --! Transmitter clock
    clk_rx_i                 : in  std_logic;                                 --! Receiver clock
    clk_offset_i             : in  std_logic;                                 --! Heterodyne conversion clock

    ---- configuration (PSEUDO-STATIC)
    metastability_deglitch_i : in std_logic_vector(15 downto 0);              --! Metastability deglitch threshold
    phase_detector_navg_i    : in std_logic_vector(11 downto 0);              --! Averaging for phase detector

    ---- status
    phase_detector_o         : out std_logic_vector(31 downto 0);             --! Phase-detector output, unit is bit 0

    -----------------------------------------------------------------
    ----------------------- TCLink Controller -----------------------
    ----------------------------------------------------------------- 
    ---- error-processing configuration (Read user guide on how to deal with these signals)         
    modulo_carrier_period_i  : in  std_logic_vector(47 downto 0);             --! Modulo of carrier period in DDMTD UNITS (unit is index 16)
    offset_error_i           : in std_logic_vector(47 downto 0);              --! Error offset
                                                                              --! This is a fractional signed number
                                                                              --! The unit bit is the index 16

    -- RX SLIDE compensation for non-fixed latency master Rx  
    -- config : pseudo_static	
    master_rx_slide_mode_i   : in std_logic;                                       --! Slide mode / 0=PMA, 1=PCS
    master_rx_ui_period_i    : in std_logic_vector(47 downto 0);                   --! UI period in DDMTD UNITS (unit is index 16)                                                         
    master_rx_slide_clk_i    : in std_logic;                                       --! Clock used by master Rx to generate rxslide pulses
    master_mgt_rx_ready_i    : in  std_logic;                                      --! MGT rx is ready (used as reset)
    master_rx_slide_i        : in std_logic;                                       --! Master Rx slide
        

    error_controller_o       : out std_logic_vector(47 downto 0);             --!  Error output from error processing block (should be between -1*modulo_carrier_period_i/2 and +1*modulo_carrier_period_i/2)
                                                                              --! This is a fractional signed number
                                                                              --! The unit bit is the index 16
    
    ---- Controller dynamics (Read user guide on how to deal with this signal)                                                    
    close_loop_i             : in  std_logic;                                 --! Close the loop (a rising edge close the loop, a low-level opens the loop)
	                                                                          --! Only close the loop when tx_ready_i and rx_ready_i are equal to '1'
                                                                              --! If any of these signals (close_loop_i, tx_ready_i, rx_ready_i) is '0' the loop is opened - the loop status can be monitored through loop_closed_o
    loop_closed_o            : out  std_logic;                                --! TCLink loop is closed
	
    -- Loop controller (PSEUDO-STATIC)	                                                      
    Aie_i                    : in  std_logic_vector(3 downto 0);              --! Integral coefficient
    Aie_enable_i             : in  std_logic;                                 --! Enables usage of integral coefficient
    Ape_i                    : in  std_logic_vector(3 downto 0);              --! Proportional coefficient

    -- Sigma-delta (PSEUDO-STATIC)           
    sigma_delta_clk_div_i    : in  std_logic_vector(15 downto 0);             --! Sigma-delta clock divider modulo (unsigned)

    -- Mirror compensation (PSEUDO-STATIC)                                                    
    enable_mirror_i          : in  std_logic;                                 --! Enable mirror compensation scheme (a part of phase variation is compensated using this scheme, otherwise a full compensation is performed)
    Adco_i                   : in  std_logic_vector(47 downto 0);             --! DCO coefficient for mirror compensation	

    -----------------------------------------------------------------
    ------------------------- DCO Interface -------------------------
    ----------------------------------------------------------------- 
    -- Phase accumulated (debugging)                           
    phase_acc_o              : out std_logic_vector(15 downto 0);             --! phase accumulated output (integrated output)
                                                                              --! This is an integer signed number, the LSB is the bit 0

    -- Operation error                                          
    operation_error_o        : out std_logic;                                 --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request 
                                                                              --! this is mainly useful for debugging purposes, for the final user this can be removed if the user is sure about all the operational parameters of the TCLink loop control

    -- DCO interface                                                          
    strobe_o                 : out  std_logic;                                --! pulse synchronous to clk_sys_i to activate a shift in the DCO (only captured rising edge, so a signal larger than a pulse is also fine)
    inc_ndec_o               : out  std_logic;                                --! 1 increments, 0 decrements (modulated output)
    phase_step_o             : out  std_logic;                                --! number of units to shift the DCO    
    done_i                   : in   std_logic;                                --! pulse synchronous to clk_sys_i to indicate a DCO shift was performed

    -----------------------------------------------------------------
    ------------------- TCLink tester signals -----------------------
    ----------------------------------------------------------------- 
    debug_tester_enable_stimulis_i  : in  std_logic;                          --! enable stimulis for TCLink
    debug_tester_fcw_i              : in  std_logic_vector(9 downto 0);       --! frequency control word for NCO (unsigned)
    debug_tester_nco_scale_i        : in  std_logic_vector(4 downto 0);       --! scale NCO output   
    debug_tester_enable_stock_out_i : in  std_logic;                          --! enable output data stock
    debug_tester_addr_read_i        : in  std_logic_vector(9 downto 0);       --! read address for reading stocked TCLink phase accumulated results
    debug_tester_data_read_o        : out std_logic_vector(15 downto 0)       --! data of stocked TCLink phase accumulated results

    );
end tclink;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tclink is

  --! Attribute declaration

  --! Constant declaration
  constant c_CONTROLLER_DATA_WIDTH     : integer := 48;
  constant c_CONTROLLER_FIXEDPOINT_BIT : integer := 16;
  constant c_CONTROLLER_COEFF_SIZE     : integer := 4 ;

  --! Signal declaration 
  signal rx_ready_sync              : std_logic;
  signal tx_ready_sync              : std_logic;

  signal tclink_offset_error        : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);

  signal tclink_controller_reset    : std_logic;
  signal tclink_close_loop_r        : std_logic;
  signal tclink_close_loop_latch    : std_logic;
  
  signal tclink_clken_sigmadelta    : std_logic;
  signal cntr_sigmadelta            : unsigned(sigma_delta_clk_div_i'range);

  signal phase_acc                  : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);

  signal ddmtd_p                    : std_logic;
  signal ddmtd                      : std_logic_vector(31 downto 0);

  signal ddmtd_scaled_to_controller : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);
  signal ddmtd_reset_n              : std_logic;
  signal ddmtd_reset_dmtd_n         : std_logic;
  signal ddmtd_enable               : std_logic;

  signal master_rx_offset                            : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);
  signal ddmtd_scaled_to_controller_master_rx_offset : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);
  
  signal tester_nco                 : std_logic_vector(31 downto 0);
  signal tester_nco_scale           : std_logic_vector(c_CONTROLLER_DATA_WIDTH-1 downto 0);

  --! Component declaration
  component master_rx_slide_compensation is
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
  end component master_rx_slide_compensation;

  component tclink_controller is
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
  end component tclink_controller;

  component dmtd_phase_meas is
    generic (
      -- Phase tag counter size (see dmtd_with_deglitcher.vhd for explanation)
      g_counter_bits        : integer := 20);
    port (
      -- resets
      rst_sys_n_i  : in std_logic;
      rst_dmtd_n_i : in std_logic;
  
      -- system clock 
      clk_sys_i  : in std_logic;
      -- Input clocks
      clk_a_i    : in std_logic;
      clk_b_i    : in std_logic;
      clk_dmtd_i : in std_logic;
  
  
      deglitch_threshold_i : in  std_logic_vector(15 downto 0);
      en_i : in std_logic;
  
      navg_i         : in  std_logic_vector(11 downto 0);
      phase_meas_o   : out std_logic_vector(31 downto 0);
      phase_meas_p_o : out std_logic
      );
  
  end component dmtd_phase_meas;

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

  component tclink_tester_unit is
    port (
      -- Clock/reset   
      clk_sys_i          : in  std_logic;                                   --! system clock input
      clk_en_i           : in  std_logic;                                   --! loop sampling clock enable for TCLink
      reset_i            : in  std_logic;                                   --! active high sync. reset
  				
      -- Stimulis				
      enable_stimulis_i  : in  std_logic;                                   --! enable stimulis for TCLink
      fcw_i              : in  std_logic_vector(9 downto 0);                --! frequency control word for NCO (unsigned)
      nco_o              : out std_logic_vector(31 downto 0);               --! NCO output (sinus with amplitude 2**47/2**nco_scale) 
      nco_scale_i        : in  std_logic_vector(4 downto 0);                --! scale NCO output   
  
      -- TCLink response
      tclink_phase_i     : in  std_logic_vector(15 downto 0);               --! TCLink phase accumulated output
      enable_stock_out_i : in  std_logic;                                   --! enable output data stock
      addr_read_i        : in  std_logic_vector(9 downto 0);                --! read address for reading stocked TCLink phase accumulated results
      data_read_o        : out std_logic_vector(15 downto 0)                --! data of stocked TCLink phase accumulated results
  
      );
  end component tclink_tester_unit;
  
begin

    tx_ready_bit_synchronizer : bit_synchronizer
      port map(
        clk_in => clk_sys_i      ,
        i_in   => tx_ready_i     ,
        o_out  => tx_ready_sync
    ); 
    
    rx_ready_bit_synchronizer : bit_synchronizer
      port map(
        clk_in => clk_sys_i      ,
        i_in   => rx_ready_i     ,
        o_out  => rx_ready_sync
    ); 

    --============================================================================
    -- Phase-detector
    --============================================================================ 
    cmp_dmtd_phase_meas : dmtd_phase_meas
      generic map(g_counter_bits => (c_CONTROLLER_DATA_WIDTH-c_CONTROLLER_FIXEDPOINT_BIT))
      port map(
        -- resets
        rst_sys_n_i  => ddmtd_reset_n,
        rst_dmtd_n_i => ddmtd_reset_dmtd_n,
    
        -- system clock 
        clk_sys_i    => clk_sys_i,
        -- Input clocks
        clk_a_i      => clk_tx_i,
        clk_b_i      => clk_rx_i,
        clk_dmtd_i   => clk_offset_i,
    
    
        deglitch_threshold_i => metastability_deglitch_i,
        en_i                 => ddmtd_enable,
    
        navg_i          => phase_detector_navg_i,
        phase_meas_o    => ddmtd,
        phase_meas_p_o  => ddmtd_p
        );

    phase_detector_o <= ddmtd(c_CONTROLLER_DATA_WIDTH-c_CONTROLLER_FIXEDPOINT_BIT-1 downto 0);

    --============================================================================
    -- Auxiliary for Phase-detector
    --============================================================================ 
    ddmtd_scaled_to_controller(c_CONTROLLER_DATA_WIDTH-1 downto c_CONTROLLER_FIXEDPOINT_BIT) <= ddmtd(c_CONTROLLER_DATA_WIDTH-1-c_CONTROLLER_FIXEDPOINT_BIT downto 0);
    ddmtd_scaled_to_controller(c_CONTROLLER_FIXEDPOINT_BIT-1 downto 0)                       <= (others => '0');
    ddmtd_enable                                                                             <= '1';
    ddmtd_reset_n                                                                            <= '0' when (tx_ready_sync='0' or rx_ready_sync='0') else '1';

  ddmtd_reset_dmtd_n_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_offset_i      ,
      i_in   => ddmtd_reset_n     ,
      o_out  => ddmtd_reset_dmtd_n
  ); 
  
    --============================================================================
    -- Rx slide compensation
    --============================================================================ 
  cmp_master_rx_slide_compensation : master_rx_slide_compensation
    generic map(
      g_DATA_WIDTH               => c_CONTROLLER_DATA_WIDTH,
      g_FIXEDPOINT_BIT           => c_CONTROLLER_FIXEDPOINT_BIT,
  	  g_MASTER_RX_MGT_WORD_WIDTH => g_MASTER_RX_MGT_WORD_WIDTH
    )
    port map(
      -- User Interface   
      clk_sys_i                => clk_sys_i,
      reset_i                  => tclink_controller_reset,
  
      -- RX SLIDE compensation for non-fixed latency master Rx  
      -- config : pseudo_static	
      master_rx_slide_mode_i   => master_rx_slide_mode_i,   
      master_rx_ui_period_i    => master_rx_ui_period_i ,                          
      master_rx_slide_clk_i    => master_rx_slide_clk_i ,   
      master_mgt_rx_ready_i    => master_mgt_rx_ready_i ,   
      master_rx_slide_i        => master_rx_slide_i     ,   
                                                                                     
      -- Control interface                                                           
      master_offset_o         => master_rx_offset 
  
      );

  ddmtd_scaled_to_controller_master_rx_offset <= std_logic_vector(signed(ddmtd_scaled_to_controller) + signed(master_rx_offset)) ;
  
    --============================================================================
    -- TCLink controller
    --============================================================================ 
    cmp_tclink_controller : tclink_controller
      generic map(
        g_DATA_WIDTH     => c_CONTROLLER_DATA_WIDTH,            
        g_FIXEDPOINT_BIT => c_CONTROLLER_FIXEDPOINT_BIT,
        g_COEFF_SIZE     => c_CONTROLLER_COEFF_SIZE		
      )
      port map(
        -- User Interface   
        clk_sys_i               => clk_sys_i,
        reset_i                 => tclink_controller_reset,
    
        -- Phase detector input error to be corrected by controller
        clk_en_error_i          => ddmtd_p            ,               
        error_i                 => ddmtd_scaled_to_controller_master_rx_offset ,                 
                                
    
        offset_error_i          => tclink_offset_error,
    
        modulo_carrier_period_i => modulo_carrier_period_i,

        error_processed_o       => error_controller_o     ,
    
        -- User interface                                                        
        close_loop_i            => tclink_close_loop_latch,
    
        -- Loop controller	                                                     
        Aie_i                   => Aie_i       ,
        Aie_enable_i            => Aie_enable_i,
        Ape_i                   => Ape_i       ,
    
        -- Sigma-delta                                                           
        clk_en_sigma_delta_i    => tclink_clken_sigmadelta,
    
        -- Mirror compensation                                                   
        enable_mirror_i         => enable_mirror_i,
        Adco_i                  => Adco_i,
    
        -- Phase accumulated (debugging)                           
        phase_acc_o             => phase_acc,
    
        -- Operation error                                         
        operation_error_o       => operation_error_o,
    
        -- DCO interface                                                         
        strobe_o                => strobe_o    ,    
        inc_ndec_o              => inc_ndec_o  ,
        phase_step_o            => phase_step_o,
        done_i                  => done_i      
        );

    phase_acc_o <= phase_acc(phase_acc_o'range);

    --============================================================================
    -- Auxiliary for TCLink controller
    --============================================================================ 
    tclink_controller_reset <= '1' when tx_ready_sync='0' else '0';         

    -- An additional protection is implemented for closing the loop
    -- (1) the loop is only closed when both Tx is aligned and Rx is locked
    -- (2) the loop is unlocked automatically when not locked and to relock the user has to issue another rising edge in close_loop_i
    tclink_close_loop_r <= close_loop_i when rising_edge(clk_sys_i);
    p_tclink_close_loop_protection : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if(close_loop_i='0' or tx_ready_i='0' or rx_ready_i='0') then	
	      tclink_close_loop_latch    <= '0';
	    else
          if(close_loop_i='1' and tclink_close_loop_r='0') then
	        tclink_close_loop_latch    <= '1';
          else
	        tclink_close_loop_latch    <= tclink_close_loop_latch;
		  end if;
        end if;		  
      end if;
    end process;
  loop_closed_o <= tclink_close_loop_latch;
  
    p_sigmadelta_clken : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if(tclink_controller_reset='1') then	
	      cntr_sigmadelta            <= to_unsigned(0, cntr_sigmadelta'length);
	      tclink_clken_sigmadelta    <= '0';
	    else
	      if(cntr_sigmadelta < unsigned(sigma_delta_clk_div_i)) then
	        cntr_sigmadelta            <= cntr_sigmadelta + 1;
	        tclink_clken_sigmadelta    <= '0';
	      else
	        cntr_sigmadelta            <= to_unsigned(0, cntr_sigmadelta'length);
	        tclink_clken_sigmadelta    <= '1';
	      end if;
        end if;		  
      end if;
    end process;

  gen_no_tester: if not g_ENABLE_TESTER_IMPLEMENTATION generate
    tclink_offset_error <= offset_error_i;
  end generate gen_no_tester;
	

	
  gen_tester: if g_ENABLE_TESTER_IMPLEMENTATION generate
    tclink_offset_error <= std_logic_vector(signed(offset_error_i) - signed(tester_nco_scale));

    tester_nco_scale(tester_nco_scale'left downto tester_nco_scale'left-tester_nco'length+1) <= tester_nco;
    tester_nco_scale(tester_nco_scale'left-tester_nco'length downto 0)                       <= (others => '0');

  --============================================================================
  -- TCLink tester unit
  --============================================================================ 
  cmp_tclink_tester_unit : tclink_tester_unit
    port map(
      -- Clock/reset   
      clk_sys_i          => clk_sys_i                      ,
      clk_en_i           => ddmtd_p                        ,
      reset_i            => tclink_controller_reset        ,
  				
      -- Stimulis				
      enable_stimulis_i  => debug_tester_enable_stimulis_i ,
      fcw_i              => debug_tester_fcw_i             ,
      nco_o              => tester_nco                     ,
      nco_scale_i        => debug_tester_nco_scale_i       ,
  
      -- TCLink response
      tclink_phase_i     => phase_acc(15 downto 0)         ,
      enable_stock_out_i => debug_tester_enable_stock_out_i,
      addr_read_i        => debug_tester_addr_read_i       ,
      data_read_o        => debug_tester_data_read_o       
    );
  end generate gen_tester;
  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
