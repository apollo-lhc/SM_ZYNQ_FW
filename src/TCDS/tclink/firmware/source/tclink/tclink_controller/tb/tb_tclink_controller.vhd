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
--! @file tb_tclink_controller.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;
use ieee.math_real.floor;
use ieee.math_real.sin;
use ieee.math_real.MATH_PI;
use ieee.math_real.SQRT;
use ieee.math_real.LOG10;

--! Specific packages
-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Simple test-bench for TCLink controller (tb_tclink_controller)
--
--! @brief Test bench for the 1st order sigma delta modulator used in TCLink control loop design
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
--! Entity declaration for tb_tclink_controller
--==============================================================================
entity tb_tclink_controller is
  generic(
    -- Controller width parameters
    DATA_WIDTH                   : integer := 32;
    FIXEDPOINT_BIT               : integer := 10;
    COEFF_SIZE                   : integer := 4 ;

    -- TCLink port parameters
    modulo_carrier_period        : integer ;  
    Adco                         : integer ;  
    enable_mirror                : integer ;
    Aie                          : integer ;
    Aie_enable                   : integer ;  
    Ape                          : integer ;
	
	-- Auxiliar
	sigma_delta_osr              : integer
	
  );
  port(
    TEST_BENCH_STATUS : out string(1 to 15) := "     IDLE      "
  );
end tb_tclink_controller;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of tb_tclink_controller is

  --! Attribute declaration

  --! Constant declaration
  constant c_PERIOD_SYSCLK      : time := 10.0 ns;
  constant c_PERIOD_ERROR       : integer := 2560; -- In order to speed-up simulation: the simulation uses a loop sampling frequency higher than in the high-level model
  
  -- For all config:
  constant Kdcoplant            : integer := Adco;   
  constant c_PERIOD_SIGMA_DELTA : integer := c_PERIOD_ERROR/(2**sigma_delta_osr);  
  
  --! Signal declaration 
  -------------------------------- TEST-BENCH related ----------------------------------------
  signal reference_signal       : signed(DATA_WIDTH-1 downto 0) := (others => '0'); -- reference to be followed
  signal output_signal          : signed(DATA_WIDTH-1 downto 0) := (others => '0'); -- output signal
  signal error_signal           : signed(DATA_WIDTH-1 downto 0) := (others => '0'); -- error signal
  signal error_beat             : std_logic;
  signal error_cntr             : integer range 0 to c_PERIOD_ERROR;
  signal sigma_delta_beat       : std_logic;
  signal sigma_delta_cntr       : integer range 0 to c_PERIOD_SIGMA_DELTA;
  signal test_finished          : boolean := False;
  --------------------------------------------------------------------------------------------

  ----------------------- Signals connected to TCLink Controller (DUT) -----------------------
  -- User Interface
  signal clk_sys_i            : std_logic;                                                    --! system clock input
  signal reset_i              : std_logic;                                                    --! active high sync. reset

  -- Phase detector input error to be corrected by controller
  signal clk_en_error_i       : std_logic;                                                    --! clock enable for sampling loop	
  signal error_i              : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');   --! Error input from phase detector
                                                                                              --! The unit bit is the index 32

  signal offset_error_i       : std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0');    --! Error offset
                                                                                              --! This is a fractional signed number
                                                                                              --! The unit bit is the index 32
                                                                                              
  signal modulo_carrier_period_i : std_logic_vector(DATA_WIDTH-1 downto 0);                 --! Modulo of carrier period in DDMTD UNITS
  signal error_processed_o       : std_logic_vector(DATA_WIDTH-1 downto 0);                 --! Error output from error processing block (should be between -1*modulo_carrier_period_i/2 and +1*modulo_carrier_period_i/2)
                                                                                              --! This is a fractional signed number
                                                                                              --! The unit bit is the index 32
                                                                                              
  -- User interface													                          
  signal close_loop_i         : std_logic;                                                    --! enable closed loop
  signal Aie_i                : std_logic_vector(COEFF_SIZE-1 downto 0);                                 --! Integral coefficient
  signal Aie_enable_i         : std_logic;                                                    --! Enables usage of integral coefficient
  signal Ape_i                : std_logic_vector(COEFF_SIZE-1 downto 0);                                 --! Proportional coefficient
                                                                                              
  signal clk_en_sigma_delta_i : std_logic;                                                    --! clock enable for sigma delta modulation
	                                                                                          
  signal enable_mirror_i      : std_logic;                                                    --! Enable mirror compensation scheme (half of phase variation is compensated using this scheme, otherwise a full compensation is performed)
  signal Adco_i               : std_logic_vector(DATA_WIDTH-1 downto 0);                      --! DCO coefficient for mirror compensation	
                                                                                              
  signal phase_acc_o          : std_logic_vector(DATA_WIDTH-1 downto 0);                      --! phase accumulated output (integrated output)
                                                                                              --! This is an integer signed number, the LSB is the bit 0
                                                                                              
  signal operation_error_o    : std_logic;                                                    --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request 
                                                                                              --! this is mainly useful for debugging purposes, for the final user this can be removed if the user is sure about all the operational parameters of the TCLink loop control
  -- DCO interface (fast output)                                                              
  signal strobe_o             : std_logic;                                                    --! pulse synchronous to clk_sys_i to activate a shiftthe DCO (only captured rising edge, so a signal larger than a pulse is also fine)
  signal inc_ndec_o           : std_logic;                                                    --! 1 increments, 0 decrements (modulated output)
  signal phase_step_o         : std_logic;                                                    --! number of units to shift the DCO    
  signal done_i               : std_logic;                                                    --! pulse synchronous to clk_sys_i to indicate a DCO shift was performed
  --------------------------------------------------------------------------------------------

  --! Component declaration
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

begin

  -- DUT
  cmp_tclink_controller : tclink_controller
    generic map(
      g_DATA_WIDTH            => DATA_WIDTH,
      g_FIXEDPOINT_BIT        => FIXEDPOINT_BIT,
      g_COEFF_SIZE            => COEFF_SIZE
    )
    port map(
      -- User Interface   
      clk_sys_i               => clk_sys_i           , 
      reset_i                 => reset_i             , 

      -- Phase detector input error to be corrected by controller
      clk_en_error_i          => clk_en_error_i      ,
      error_i                 => error_i             ,       

      offset_error_i          => offset_error_i      ,

      modulo_carrier_period_i => modulo_carrier_period_i,
      error_processed_o       => error_processed_o      ,

      close_loop_i            => close_loop_i        , 

      -- User interface		   											 
      Aie_i                   => Aie_i               , 
      Aie_enable_i            => Aie_enable_i        , 
      Ape_i                   => Ape_i               , 

      clk_en_sigma_delta_i    => clk_en_sigma_delta_i,

      enable_mirror_i         => enable_mirror_i     ,
      Adco_i                  => Adco_i              ,
      phase_acc_o             => phase_acc_o         ,

      operation_error_o       => operation_error_o   ,

      -- DCO interface (fast output)
      strobe_o                => strobe_o            ,   
      inc_ndec_o              => inc_ndec_o          ,
      phase_step_o            => phase_step_o        ,
      done_i                  => done_i              
    );

  -- emulate acknowledgment from DCO 	
  done_i <= strobe_o when rising_edge(clk_sys_i);

  -- Clock process
  clk_process : process
  begin
      if(not test_finished) then
        clk_sys_i <= '0';
	    wait for c_PERIOD_SYSCLK/2;
	    clk_sys_i <= '1';
	    wait for c_PERIOD_SYSCLK/2;
      else
	    wait;
	  end if;
  end process;
  
  -- Clock enable processes
  divider_counters : process
  begin
      if(not test_finished) then
        wait until rising_edge(clk_sys_i);
	    if(error_cntr < c_PERIOD_ERROR) then
	      error_cntr <= error_cntr + 1;
		  error_beat <= '0';
          error_i    <= error_i;  
		else
		  error_cntr <= 0;
		  error_beat <= '1';
          error_i <= std_logic_vector(error_signal);
		end if;
        
	    if(sigma_delta_cntr < c_PERIOD_SIGMA_DELTA) then
	      sigma_delta_cntr <= sigma_delta_cntr + 1;
		  sigma_delta_beat    <= '0';
		else
		  sigma_delta_cntr <= 0;
		  sigma_delta_beat <= '1';
		end if;		

	  else
	    wait;
      end if;
  end process;
  clk_en_sigma_delta_i <= sigma_delta_beat;
  clk_en_error_i       <= error_beat;

  -- Stimulis
  stimulis : process is
    variable seed1   : positive;
    variable seed2   : positive;
    variable x       : real;
    variable y       : integer;
    variable mean_in  : real;
    variable mean_out : real;
    variable rms_in  : real;	
    variable rms_out : real;
    variable gain    : real;

    procedure SINUS_EMULATION(fn : real) is
    begin
      mean_in  := 0.0;
      mean_out := 0.0;
      rms_in   := 0.0;
      rms_out  := 0.0;	  
      for i in 0 to 10000 loop	  
	    wait until rising_edge(error_beat);
	    wait until rising_edge(clk_sys_i);
        y := integer(100.0*real(Kdcoplant)*sin(2.0*MATH_PI*fn*real(i)));
        reference_signal(DATA_WIDTH-1 downto 0) <= to_signed(y, DATA_WIDTH);
        output_signal     <= to_signed(Kdcoplant*to_integer(signed(phase_acc_o)), output_signal'length);
        error_signal <= reference_signal - output_signal;
        mean_in  := mean_in  + (1.0/(10001.0))*real(to_integer(reference_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)));
        mean_out := mean_out + (1.0/(10001.0))*real(to_integer(output_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)));
        rms_in   := rms_in   + (1.0/(10001.0))*real(to_integer(reference_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)))*real(to_integer(reference_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)));
        rms_out  := rms_out  + (1.0/(10001.0))*real(to_integer(output_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)))*real(to_integer(output_signal(DATA_WIDTH-1 downto FIXEDPOINT_BIT)));
      end loop;
      rms_in  := SQRT(rms_in  - mean_in*mean_in);
      rms_out := SQRT(rms_out - mean_out*mean_out);
      gain    := 20.0*LOG10(rms_out/rms_in);
      report "Gain for fn=" & real'image(fn) & ": " & real'image(gain) & " dB";
    end procedure SINUS_EMULATION;

    procedure STEP_EMULATION(an : real) is
    begin  
      for i in 0 to 10000 loop	  
	    wait until rising_edge(error_beat);
	    wait until rising_edge(clk_sys_i);
        y := integer(an*real(Kdcoplant));
        reference_signal(DATA_WIDTH-1 downto 0) <= to_signed(y, DATA_WIDTH);
        output_signal     <= to_signed(Kdcoplant*to_integer(signed(phase_acc_o)), output_signal'length);
        error_signal <= reference_signal - output_signal;
      end loop;
    end procedure STEP_EMULATION;

  begin

      -- Reset
      reset_i                 <= '1';
      close_loop_i            <= '0';
      Aie_enable_i            <= '0';
      enable_mirror_i         <= '0';
      Adco_i                  <= std_logic_vector(to_signed(0,Adco_i'length));
      Aie_i                   <= std_logic_vector(to_unsigned(0,Aie_i'length));
      Ape_i                   <= std_logic_vector(to_unsigned(0,Ape_i'length));
      modulo_carrier_period_i <= (others => '0');

	  wait for 10*c_PERIOD_SYSCLK;
	  wait until rising_edge(clk_sys_i);
      reset_i              <= '0';
	  wait until rising_edge(clk_sys_i);

      -- Follow some reference
      -- load coefficients
      modulo_carrier_period_i <= std_logic_vector(to_signed(modulo_carrier_period, DATA_WIDTH));
      Ape_i                   <= std_logic_vector(to_unsigned(Ape,Aie_i'length));
      Aie_i                   <= std_logic_vector(to_unsigned(Aie,Aie_i'length));
      Adco_i                  <= std_logic_vector(to_signed(Adco,Adco_i'length));
      wait until rising_edge(clk_sys_i);
      wait until rising_edge(clk_sys_i);

      -- enable controllers	  
      close_loop_i  <= '1';
      if(Aie_enable>0) then
        Aie_enable_i    <= '1';
      end if;

      if(enable_mirror>0) then
        enable_mirror_i <= '1';
      end if;

      -- Transfer-function simulation
      TEST_BENCH_STATUS    <= "fn=1e-4, A=100 ";	  
      SINUS_EMULATION(0.0001);	  

      TEST_BENCH_STATUS    <= "fn=1e-3, A=100 ";	  
      SINUS_EMULATION(0.001);	 
	  
      TEST_BENCH_STATUS    <= "fn=1e-2, A=100 ";	  
      SINUS_EMULATION(0.01);	  
	  
      TEST_BENCH_STATUS    <= "fn=1e-1, A=100 ";	  
      SINUS_EMULATION(0.1);	   
	  
      TEST_BENCH_STATUS    <= "fn=3e-1, A=100 ";	  
      SINUS_EMULATION(0.3);	   

	  TEST_BENCH_STATUS    <= "     QUIET     ";	  
      STEP_EMULATION(0.0); 

      TEST_BENCH_STATUS    <= "  step, A=100  ";	  
      STEP_EMULATION(100.0);	 

      TEST_BENCH_STATUS    <= "  step, A=-100 ";	  
      STEP_EMULATION(-100.0);

	  TEST_BENCH_STATUS    <= "     QUIET     ";	  
      STEP_EMULATION(0.0); 
	  
	  test_finished <= True;
	  
      wait;

  end process;


  
end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
