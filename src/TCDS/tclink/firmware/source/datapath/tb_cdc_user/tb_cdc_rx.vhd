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
--! @file tb_cdc_rx.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;
use ieee.math_real.floor;

--! Specific packages

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: mesochronous CDC test-bench (tb_cdc_rx)
--
--! @brief Mesochronous CDC test-bench
--! Very simple test bench only to check briefly the operation of circuitry
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 30\06\2020
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
--! 30\06\2020 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! Extensive verification \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tb_cdc_rx
--==============================================================================
entity tb_cdc_rx is
  generic(
   g_CLOCK_A_RATIO        : integer := 8;
   g_CLOCK_B_RATIO        : integer := 1
  );
end tb_cdc_rx;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture tb of tb_cdc_rx is

  --! Function declaration

  --! Constant declaration  
  constant c_STROBE_PERIOD   : time := 25.2  ns;                 
  constant c_PRBS_POLYNOMIAL : std_logic_vector(23 downto 0) := (23 => '1', 18=> '1', 0 => '1', others => '0'); -- PRBS-23 testing (x^7 + x^6 + 1)
  
  --! Signal declaration    
  signal clk_a              : std_logic;
  signal clk_b              : std_logic;

  -- CLK_A
  signal prbsgen_en         : std_logic;                       
  signal prbsgen_reset      : std_logic;                       
  signal prbsgen_seed       : std_logic_vector(c_PRBS_POLYNOMIAL'length-2 downto 0) := (others => '1');
  signal prbsgen_load       : std_logic;                       
  signal prbsgen_data       : std_logic_vector(254-1 downto 0);
  signal prbsgen_data_valid : std_logic;   

  signal reset_a            :  std_logic;   
  signal data_a             :  std_logic_vector(254-1 downto 0);
  signal strobe_a           :  std_logic;  
  signal data_b             :  std_logic_vector(254-1 downto 0);
  signal strobe_b           :  std_logic;
  signal ready_b            :  std_logic;

  -- CLK_B
  signal prbschk_reset      : std_logic;                        
  signal prbschk_error      : std_logic;                        
  signal prbschk_locked     : std_logic;
  signal prbschk_data_chk   : std_logic_vector(254-1 downto 0); 

  -- Phase
  signal phase              : std_logic_vector(2 downto 0);  
  signal phase_calib        : std_logic_vector(2 downto 0); --! Phase measured in first reset
  signal phase_force        : std_logic;                    --! Force the phase to be the calibrated one
  	  
  -- Aux test-bench
  signal save_file          : std_logic := '0';
  
  --! Component declaration
  component cdc_rx is
    generic (
      g_CLOCK_A_RATIO : integer := 8; --! Frequency ratio between slow and fast frequencies (>4)
      g_PHASE_SIZE    : integer := 3  --! log2(g_CLOCK_A_RATIO)
    );
    port (
      -- Interface A (latch - from where data comes)
      reset_a_i        : in   std_logic;                                 --! reset (only de-assert when all clocks and strobes are stable)		
      clk_a_i          : in   std_logic;                                 --! clock A
      data_a_i         : in   std_logic_vector;                          --! data A
      strobe_a_i       : in   std_logic;                                 --! strobe A
  
      -- Interface B (capture_a - to where data goes) 
      clk_b_i          : in   std_logic;                                 --! clock B
      data_b_o         : out  std_logic_vector;                          --! data B (connected to vector of same size as data_a_i)
      strobe_b_i       : in   std_logic;                                 --! strobe B
      ready_b_o        : out  std_logic;                                 --! Inteface is ready 

      -- Only relevant for fixed-phase operation
      phase_o          : out  std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase to check fixed-phase
      phase_calib_i    : in   std_logic_vector(g_PHASE_SIZE-1 downto 0); --! Phase measured in first reset
      phase_force_i    : in   std_logic                                  --! Force the phase to be the calibrated one
  
    );
  end component cdc_rx;


  component prbs_gen is
    generic (
      g_PARAL_FACTOR    : integer          := 254        ;                          --! Size of parallel bus
      g_PRBS_POLYNOMIAL : std_logic_vector :=	"11000001"                            --! Notation: x^7 + x^6 + 1 (PRBS-7)
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
  
  component prbs_chk is
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
  end component prbs_chk;
  
begin

  --! ----------------------------------- Clock process -----------------------------------  
  p_clk_a : process
  begin
      clk_a <= '0';
	  wait for (c_STROBE_PERIOD/g_CLOCK_A_RATIO)/2;
	  clk_a <= '1';
	  wait for (c_STROBE_PERIOD/g_CLOCK_A_RATIO)/2;
  end process;

  p_clk_b : process
  begin
      clk_b <= '0';
	  wait for (c_STROBE_PERIOD/g_CLOCK_B_RATIO)/2;
	  clk_b <= '1';
	  wait for (c_STROBE_PERIOD/g_CLOCK_B_RATIO)/2;
  end process;
  -----------------------------------------------------------------------------------------

  --! ------------------------------------ Components ------------------------------------
  p_strobe_a : process
  begin
    prbsgen_en <= '1';
    wait until rising_edge(clk_a);
    for i in 0 to g_CLOCK_A_RATIO-2 loop
      prbsgen_en <= '0';
      wait until rising_edge(clk_a);
    end loop;	  
  end process p_strobe_a;

  p_strobe_b : process
  begin
    strobe_b <= '1';
    wait until rising_edge(clk_b);
    for i in 0 to g_CLOCK_B_RATIO-2 loop
      strobe_b <= '0';
      wait until rising_edge(clk_b);
    end loop;	  
  end process p_strobe_b;

  cmp_prbs_gen : prbs_gen
    generic map(
      g_PARAL_FACTOR    => 254         ,    
      g_PRBS_POLYNOMIAL =>c_PRBS_POLYNOMIAL
    )                                                                         
    port map(                                                                          
      clk_i        => clk_a        ,            
      en_i         => prbsgen_en   ,           
      reset_i      => prbsgen_reset,          
      seed_i       => prbsgen_seed ,           
      load_i       => prbsgen_load ,           
      data_o       => prbsgen_data ,           
      data_valid_o => prbsgen_data_valid    
    );
  
  -- DUT
  data_a   <= prbsgen_data;
  strobe_a <= prbsgen_data_valid;  
  cmp_cdc_rx : cdc_rx
    generic map(
      g_CLOCK_A_RATIO => g_CLOCK_A_RATIO    ,
      g_PHASE_SIZE    => phase'length
    )
    port map(
      -- Interface A (latch - from where data comes)
      reset_a_i        => reset_a      ,
      clk_a_i          => clk_a        ,
      data_a_i         => data_a       ,
      strobe_a_i       => strobe_a     ,
  	                                                                   
      -- Interface B (capture - to where data goes)                                                 
      clk_b_i          => clk_b        ,
      data_b_o         => data_b       ,
      strobe_b_i       => strobe_b     ,
      ready_b_o        => ready_b      ,

      -- Only relevant for fixed-phase operation
      phase_o          => phase        ,
      phase_calib_i    => phase_calib  ,
      phase_force_i    => phase_force  
    );

  cmp_prbs_chk : prbs_chk
    generic map(
      g_GOOD_FRAME_TO_LOCK  => 15 ,
      g_BAD_FRAME_TO_UNLOCK => 5  ,
      g_PARAL_FACTOR        => 254,
      g_PRBS_POLYNOMIAL     => c_PRBS_POLYNOMIAL
    )                                                                              
    port map(                                                                          
      clk_i      => clk_b             , 
      reset_i    => prbschk_reset     ,  
      en_i       => strobe_b          ,       
      data_i     => data_b            ,     
      data_o     => prbschk_data_chk  ,     
      error_o    => prbschk_error     ,    
      locked_o   => prbschk_locked   
    );
  -----------------------------------------------------------------------------------------

  --! -------------------------------------- Stimulis -------------------------------------
  p_stimulis : process is
  begin
      --! Basic test bench to observe waveforms
      -- No Force
      prbsgen_reset <= '1';
	  prbsgen_load  <= '1';
      prbschk_reset <= '1';
      reset_a       <= '1';	  
      phase_calib   <= (others=>'0');
      phase_force   <= '0';

	  wait for 10*c_STROBE_PERIOD;
	  wait until rising_edge(clk_a);
      prbsgen_reset <= '0';

	  wait until rising_edge(clk_a);
	  prbsgen_load  <= '0';

	  wait for 10*c_STROBE_PERIOD;
      wait until rising_edge(clk_a);  
      reset_a       <= '0';	  
	  wait for 10*c_STROBE_PERIOD;
      wait until rising_edge(clk_b);  
	  
      prbschk_reset <= '0';

	  wait for 100*c_STROBE_PERIOD;

      save_file <= '1';
      wait until rising_edge(clk_a);
      save_file <= '0';
      wait until rising_edge(clk_a);
	  
      -- Force
      for i in 0 to g_CLOCK_A_RATIO-1 loop
        reset_a       <= '1';	 		
        prbschk_reset <= '1';
        
        phase_calib   <= std_logic_vector(to_unsigned(i, phase'length));
        phase_force   <= '1';
        
	    wait for 10*c_STROBE_PERIOD;
	    wait until rising_edge(clk_a);

        
	    wait for 10*c_STROBE_PERIOD;
        wait until rising_edge(clk_a);  
        reset_a       <= '0';	  
	    wait for 10*c_STROBE_PERIOD;
        wait until rising_edge(clk_b);  	  
        prbschk_reset <= '0';
        
	    wait for 100*c_STROBE_PERIOD;

        save_file <= '1';
        wait until rising_edge(clk_a);
        save_file <= '0';
        wait until rising_edge(clk_a);
		
      end loop;

      wait;

  end process p_stimulis;  
  ------------------------------------------------------------------------------

  --! ------------------------------ Save output -------------------------------
  p_save  : process
    file f_handler   : text open write_mode is "out_tb_cdc_rx_clock_A_"&integer'image(g_CLOCK_A_RATIO)&"_clock_B_"&integer'image(g_CLOCK_B_RATIO)&".txt";
    variable row     : line;
  begin
    wait until rising_edge(save_file);
    WRITE(row,phase_calib, right, 15);	
    WRITE(row,phase, right, 15);	
    WRITE(row,prbschk_locked, right, 15);	
    WRITE(row,prbschk_error, right, 15);		
    WRITE(row,ready_b, right, 15);		
    WRITELINE(f_handler,row);
    wait until rising_edge(clk_a);
  end process p_save;
  ------------------------------------------------------------------------------

end architecture tb;
--==============================================================================
-- architecture end
--==============================================================================

