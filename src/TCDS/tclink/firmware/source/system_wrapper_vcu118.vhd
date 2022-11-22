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
--! @file system_wrapper_vcu118.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Specific packages
library UNISIM; 
use UNISIM.vcomponents.all;
use work.tclink_lpgbt_pkg.all;

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Example design of TCLink design containing two masters and a slave (system_wrapper_vcu118)
--
--! @brief Example design of TCLink for VCU118
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 03\02\2019
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
--! 18\10\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for system_wrapper_vcu118
--==============================================================================
entity system_wrapper_vcu118 is
    port (
        -----------------------------------------------------------------
        -------------------------- Common  -----------------------------
        -----------------------------------------------------------------
        -- System clock
        clk_sys_p_i  : in  std_logic;                  --! 125MHz system clock input, it this frequency is different, some tclink coefficients have to be recalculated, read user guide
        clk_sys_n_i  : in  std_logic;

        -- Bunch clock
        clk40_p_i  : in  std_logic;                    --! 40MHz user clock input sync to the reference clock and recovered clock
        clk40_n_i  : in  std_logic;  

        -----------------------------------------------------------------
        ------------------------ Master --------------------------------
        -----------------------------------------------------------------
		---------------------- clocks ----------------------
        -- MGT reference clocks                                              
        master_trxrefclk_p_i                    : in  std_logic_vector(0 downto 0); --! trx reference clock
        master_trxrefclk_n_i                    : in  std_logic_vector(0 downto 0);             
        
        ------------------ transceiver --------------------
        -- Serial Data
        master_rx_p_i                          : in  std_logic_vector(1 downto 0); --! rx serial data	
        master_rx_n_i                          : in  std_logic_vector(1 downto 0);
        master_tx_p_o                          : out std_logic_vector(1 downto 0); --! tx serial data	
        master_tx_n_o                          : out std_logic_vector(1 downto 0);
        
        ---------------------- SFP ------------------------
        master_sfp_tx_fault_i                 : in  std_logic_vector(1 downto 0);  --! SFP Tx fault
        master_sfp_los_i                      : in  std_logic_vector(1 downto 0);  --! SFP Rx Loss of signal
        master_sfp_mod_abs_i                  : in  std_logic_vector(1 downto 0);  --! SFP Module absent
        master_sfp_tx_dis_o                   : out std_logic_vector(1 downto 0);  --! SFP Tx disable
        master_sfp_rs0_o                      : out std_logic_vector(1 downto 0);  --! SFP Rate-select 0
        master_sfp_rs1_o                      : out std_logic_vector(1 downto 0);  --! SFP Rate-select 1

        -------------------------------------------------------------------
        -------------------------- Slave ---------------------------------
        -------------------------------------------------------------------
		------------------------ clocks ----------------------
        -- MGT reference clocks                                              
        slave_txrefclk_p_i                    : in  std_logic;                  --! tx reference clock
        slave_txrefclk_n_i                    : in  std_logic;                  
        
        slave_rxrefclk_p_i                    : in  std_logic;                  --! rx reference clock
        slave_rxrefclk_n_i                    : in  std_logic;                 
        
        -- Recovered clock                                                       
        slave_clk40_p_o                    : out std_logic;                     --! rx recovered 40MHz clock
        slave_clk40_n_o                    : out std_logic;
        
		-- Slave clk40 PLL locked
        -- slave_clk40_pll_locked_i        : in std_logic;                      --! PLL generating clk40 for slave is locked
                                                                                --!	In this example design, the slave clk40 is shared from the clk40_p_i
                                                                                --! For a user design, this clock typically comes from the same PLL generating the slave_txrefclk_p_i
                                                                                --! It is recommended to use the lock status of this PLL for the clock-domain-crossing inside the tclink_lpgbt core to know it is stable
        ------------------ transceiver --------------------
        -- Serial Data
        slave_rx_p_i                          : in  std_logic; --! rx serial data	
        slave_rx_n_i                          : in  std_logic;
        slave_tx_p_o                          : out std_logic; --! tx serial data	
        slave_tx_n_o                          : out std_logic;
        
        ---------------------- firefly ------------------------
        slave_firefly_modprs_b_i             : in  std_logic; --! Module Present
        slave_firefly_int_b_i                : in  std_logic; --! Interrupt
        slave_firefly_modsel_b_o             : out std_logic; --! Module Select
        slave_firefly_reset_b_o              : out std_logic  --! Reset

	);
end system_wrapper_vcu118;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of system_wrapper_vcu118 is

  attribute keep        : string;
  attribute mark_debug  : string;
  
  --! Signal declaration
  -------------------------------- Protocol ----------------------------------
  -------------------- !!! IMPORTANT!!!----------------------------
  -- Despite having an unconstrained array vector type,
  -- the ports tx_data_i and rx_data_o have a constrained length
  -- related to the protocol chosen (g_PROTOCOL). 
  -- Use the functions fcn_protocol_tx_width and fcn_protocol_rx_width.
  -----------------------------------------------------------------  
  constant c_PROTOCOL           : t_EXAMPLE_PROTOCOL := SYMMETRIC_10G              ;  
  constant c_DATARATE           : integer := fcn_protocol_mgt_data_rate(c_PROTOCOL);
  constant c_USER_TX_DATA_WIDTH : integer := fcn_protocol_tx_width(c_PROTOCOL);
  constant c_USER_RX_DATA_WIDTH : integer := fcn_protocol_rx_width(c_PROTOCOL);
  type user_tx_data_array is array(natural range <>) of std_logic_vector(c_USER_TX_DATA_WIDTH-1 downto 0);
  type user_rx_data_array is array(natural range <>) of std_logic_vector(c_USER_RX_DATA_WIDTH-1 downto 0);

  ---------------------------------- Common ----------------------------------
  signal clk_sys                                    : std_logic;
  signal clk40                                      : std_logic;
  
  ---------------------------------- Master ----------------------------------
  ------ Common
  signal master_clk_offset                          : std_logic; --! Clock offset for TCLink heterodyne phase measurement
  signal master_clk_offset_resetn                   : std_logic; --! Sentitive-low reset for master clock offset DDMTD (only connected to VIO of master channel 0 in the example design)
  signal master_clk_offset_locked_async             : std_logic; --! Clock offset is locked
  signal master_clk_offset_locked                   : std_logic; --! Clock offset is locked

  attribute keep of master_clk_offset_locked        : signal is "true";
  
  ------ Channels and quads
  -- Type definition for multilink implementation
  type integer_array is array(natural range <>) of integer;
  type boolean_array is array(natural range <>) of boolean;
  
  -- Definition of channels and quads for multilink implementation
  constant c_MASTER_NUMBER_QUADS                    : integer := 1;  
  constant c_MASTER_NUMBER_CHANNELS                 : integer := 2;
  -- c_MASTER_CHANNEL_QUADS associates each channel to a quad following the convention (CHANNEL_NUMBER => QUAD_NUMBER)
  constant c_MASTER_CHANNEL_QUADS                   : integer_array(c_MASTER_NUMBER_CHANNELS-1 downto 0) := (0 => 0, 1 => 0);
  -- c_MASTER_PLL_RESET_CHANNELS associates a 'master' channel to each quad for the common PLL reset following the convention (QUAD_NUMBER => CHANNEL_NUMBER)
  constant c_MASTER_PLL_RESET_CHANNELS              : integer_array(c_MASTER_NUMBER_QUADS-1 downto 0)    := (0 => 0);
  -- c_MASTER_RESET_CHANNEL indicates which are the master channels for the reset FSM
  -- In principle this can be derived from the two previous one but for the time being I put it manually
  constant c_MASTER_RESET_CHANNEL                   : boolean_array(c_MASTER_NUMBER_CHANNELS-1 downto 0) := (0 => True, 1 => False);
  
  signal master_trxrefclk                           : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_trxrefclk_odiv2                     : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_trxrefclk_fabric                    : std_logic;
  signal master_clk_offset_resetn_dummy             : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! Only connected to VIO of master channel 0 in the example design

  attribute keep of master_clk_offset_resetn_dummy : signal is "true";
  
  -- mgt_user_clock <-> MGT
  signal master_clk_ctrl                            : tr_mgt_to_clk_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_clk_stat                            : tr_clk_to_mgt_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);

  -- Common <-> MGT
  -- A dummy signal for the PLL reset is created for all channels (master_mgt_to_common_qpll0reset)
  -- Only the ones in c_MASTER_PLL_RESET_CHANNELS will be connected to the common via master_mgt_to_common_qpll0reset_common   
  signal master_mgt_to_common_qpll0reset            : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_mgt_to_common_qpll0reset_common     : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);  
  signal master_common_to_mgt_qpll0lock             : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_common_to_mgt_qpll0outclk           : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_common_to_mgt_qpll0outrefclk        : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_common_to_mgt_qpll1outclk           : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);
  signal master_common_to_mgt_qpll1outrefclk        : std_logic_vector(c_MASTER_NUMBER_QUADS-1 downto 0);

  -- Core control and status
  signal master_core_ctrl                           : tr_core_control_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_core_stat                           : tr_core_status_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_tclink_ctrl                         : tr_tclink_control_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_tclink_stat                         : tr_tclink_status_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);

  attribute keep of master_core_ctrl, master_core_stat, master_tclink_ctrl, master_tclink_stat : signal is "true";

  -- Core <-> MGT
  signal master_mgt_ctrl                            : tr_core_to_mgt_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal master_mgt_stat                            : tr_mgt_to_core_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);

  -- User logic (exdsg dependent)
  -- Frame parameters

  constant c_PRBS_GOOD_FRAME_TO_LOCK                : integer                       := 15         ;                             -- Number of correct frames predicted for PRBS to go locked
  constant c_PRBS_BAD_FRAME_TO_UNLOCK               : integer                       := 5          ;                             -- Number of wrong received frames for PRBS to go unlocked	
  constant c_PRBS_POLYNOMIAL                        : std_logic_vector(23 downto 0) := "100001000000000000000001";              -- Notation: x^23 + x^18 + 1 (PRBS-23)
  constant c_PRBS_SEED                              : std_logic_vector(c_PRBS_POLYNOMIAL'length-2 downto 0) := (others => '1'); -- Seed for polynomial   

  signal not_master_core_stat_tx_user_ready          : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbsgen_master_reset                       : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);                      
  signal prbsgen_master_en                          : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbsgen_master_load                        : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbsgen_master_frame                       : user_tx_data_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);  
  signal prbsgen_master_data_valid                  : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);

  attribute mark_debug of prbsgen_master_data_valid, prbsgen_master_frame : signal is "true";
  attribute keep of prbsgen_master_data_valid, prbsgen_master_frame : signal is "true";
  
  signal not_master_core_stat_rx_user_ready       : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbschk_master_reset                       : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbschk_master_frame                       : user_rx_data_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbschk_master_en                          : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbschk_master_gen                         : user_rx_data_array(c_MASTER_NUMBER_CHANNELS-1 downto 0);                                                                                                 
  signal prbschk_master_error                       : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);  
  signal prbschk_master_locked                      : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  signal prbschk_master_locked_sync                 : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0);
  attribute keep of prbschk_master_locked_sync      : signal is "true";
  
  attribute mark_debug of prbschk_master_reset, prbschk_master_frame, prbschk_master_error, prbschk_master_locked : signal is "true";
  attribute keep       of prbschk_master_reset, prbschk_master_frame, prbschk_master_error, prbschk_master_locked : signal is "true";
  
  -- Physical control (exdsg dependent)
  signal master_sfp_tx_fault_sync                   : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Tx fault
  signal master_sfp_los_sync                        : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Rx Loss of signal
  signal master_sfp_mod_abs_sync                    : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Module absent
  signal master_sfp_tx_dis                          : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Tx disable
  signal master_sfp_rs0                             : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Rate-select 0
  signal master_sfp_rs1                             : std_logic_vector(c_MASTER_NUMBER_CHANNELS-1 downto 0); --! SFP Rate-select 1
  attribute keep of master_sfp_tx_fault_sync, master_sfp_los_sync, master_sfp_mod_abs_sync, master_sfp_tx_dis, master_sfp_rs0, master_sfp_rs1 : signal is "true";

  ------------------------------------ Slave ----------------------------------
  signal slave_rxusrclk_mmcm                        : std_logic; -- slave clock 320MHz high-frequency cleaned via ODDR
  signal slave_mmcm_locked                          : std_logic; -- slave MMCM clock locked
  signal slave_mmcm_locked_sync                     : std_logic; -- slave MMCM clock locked
  attribute keep of slave_mmcm_locked_sync : signal is "true";
  
  signal slave_clk40_oddr_in                        : std_logic; -- slave recovered clock ODDR
  signal slave_clk40_oddr_r                         : std_logic; -- Add a register to improve timing
  signal slave_clk40_oddr_out                       : std_logic; -- slave recovered clock ODDR

  signal slave_txrefclk                             : std_logic; -- slave has two ref clocks
  signal slave_rxrefclk                             : std_logic; 
  
  constant c_SLAVE_CLK40_PLL_LOCK_TIMER_MAX         : integer := 2*125000000; -- 2s
  signal slave_clk40_pll_locked                     : std_logic;
  signal slave_clk40_pll_lock_timer                 : integer range 0 to c_SLAVE_CLK40_PLL_LOCK_TIMER_MAX;
  
  -- mgt_user_clock <-> MGT                               
  signal slave_clk_ctrl                             : tr_mgt_to_clk;
  signal slave_clk_stat                             : tr_clk_to_mgt;
  
  
  -- Core control and status
  signal slave_core_ctrl                            : tr_core_control  ;
  signal slave_core_stat                            : tr_core_status   ;
  signal slave_tclink_ctrl                          : tr_tclink_control; -- dummy just for connection
  
  attribute keep of slave_core_ctrl, slave_core_stat : signal is "true";
  
  -- Core <-> MGT
  signal slave_mgt_ctrl                             : tr_core_to_mgt;
  signal slave_mgt_stat                             : tr_mgt_to_core;

  -- User logic (exdsg dependent)
  -- Frame parameters
  -- Re-uses same constants from master
  signal not_slave_core_stat_tx_user_data_ready           : std_logic;
  signal prbsgen_slave_reset                        : std_logic;
  signal prbsgen_slave_en                           : std_logic;                                         --! enable input
  signal prbsgen_slave_load                         : std_logic;                                         --! Load seed	
  signal prbsgen_slave_frame                        : std_logic_vector(c_USER_TX_DATA_WIDTH-1 downto 0); --! PRBS output data
  signal prbsgen_slave_data_valid                   : std_logic;                                         --! PRBS data valid
  
  attribute mark_debug of prbsgen_slave_data_valid, prbsgen_slave_frame : signal is "true";
  attribute keep of prbsgen_slave_data_valid, prbsgen_slave_frame : signal is "true";
  
  signal not_slave_core_stat_rx_user_data_ready        : std_logic                                      ;  
  signal prbschk_slave_reset                        : std_logic                                      ;
  signal prbschk_slave_frame                        : std_logic_vector(c_USER_RX_DATA_WIDTH-1 downto 0);
  signal prbschk_slave_en                           : std_logic                                      ;  
  signal prbschk_slave_gen                          : std_logic_vector(c_USER_RX_DATA_WIDTH-1 downto 0);                                                                                                        
  signal prbschk_slave_error                        : std_logic                                      ;   
  signal prbschk_slave_locked                       : std_logic                                      ;
  signal prbschk_slave_locked_sync                  : std_logic;    
  
  attribute keep of prbschk_slave_locked_sync : signal is "true";
  
  attribute mark_debug of prbschk_slave_reset, prbschk_slave_frame, prbschk_slave_error, prbschk_slave_locked : signal is "true";
  attribute keep       of prbschk_slave_reset, prbschk_slave_frame, prbschk_slave_error, prbschk_slave_locked : signal is "true";
  
  -- Physical control (exdsg dependent)
  signal slave_firefly_modprs_b_sync                      : std_logic; 
  signal slave_firefly_int_b_sync                         : std_logic;
  signal slave_firefly_modsel_b                           : std_logic;
  signal slave_firefly_reset_b                            : std_logic;
  attribute keep of slave_firefly_modprs_b_sync, slave_firefly_int_b_sync, slave_firefly_modsel_b, slave_firefly_reset_b : signal is "true";

  --! Component declaration
  ---------------------------------- Common ----------------------------------
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
  
  component mgt_user_clock is
      generic(
  	    g_NUMBER_CHANNELS : integer := 1 --1,2,3,4
  	  );
      port (
          -- User clocks                                                       
          txusrclk_o                      : out std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);                               
          rxusrclk_o                      : out std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);
  
          --! User clock network		
          mgt_txoutclk_i                  : in  std_logic_vector(g_NUMBER_CHANNELS-1 downto 0);  --! Only channel 0 used, shared Tx clock    
          mgt_rxoutclk_i                  : in  std_logic_vector(g_NUMBER_CHANNELS-1 downto 0)
  	);
  end component mgt_user_clock;
  
  component tclink_lpgbt is
      generic(
        g_MASTER_NSLAVE               : boolean := True;
        g_QUAD_LEADER                 : boolean := True;  	    
        g_MASTER_TCLINK_TESTER_ENABLE : boolean :=False;
        g_PROTOCOL                    : t_EXAMPLE_PROTOCOL := SYMMETRIC_10G	
  	);
      port (
          -----------------------------------------------------------------
          --------------------- System clock / resets ---------------------
          -----------------------------------------------------------------
          -- System clock
          clk_sys_i           : in  std_logic; -- 125MHz free-running clock used for MGT
  		
          -----------------------------------------------------------------
          ------------------ Core control/status ------------------------
          -----------------------------------------------------------------
  		-- Interface synchronous to clk_sys_i
          core_ctrl_i         : in  tr_core_control;
          core_stat_o         : out tr_core_status ;
  		
          -- TCLink (not relevant for slave)	
          master_tclink_clk_offset_i  : in  std_logic;
          master_tclink_ctrl_i        : in  tr_tclink_control;
          master_tclink_stat_o        : out tr_tclink_status ;
  
          -----------------------------------------------------------------
          ------------------ Slave recovered clock ----------------------
          -----------------------------------------------------------------
          slave_clk40_oddr_o          : out std_logic;
  
          -----------------------------------------------------------------
          ------------------------ User data ----------------------------	
          -------------------- !!! IMPORTANT!!!----------------------------
          -- Despite having an unconstrained array vector type,
          -- the ports tx_data_i and rx_data_o have a constrained length
          -- related to the protocol chosen (g_PROTOCOL). 
          -- Use the functions fcn_protocol_tx_width and fcn_protocol_rx_width.
          -----------------------------------------------------------------  
          -- Connect it accordingly:
          -----------------------------------------------------------------  
          -- SYMMETRIC_10G:
          --     tx_data_i'length = 234;
          --     rx_data_o'length = 234;
          -- 
          -- SYMMETRIC_5G:
          --     tx_data_i'length = 116;
          --     rx_data_o'length = 116;
          -- 
          -- FPGA_ASSYMMETRIC_RX10G:
          --     tx_data_i'length = 36;
          --       - tx_data_i(31 downto 0)  = ELINK
          --       - tx_data_i(33 downto 32) = EC
          --       - tx_data_i(35 downto 34) = IC
          --     rx_data_o'length = 234;
          --       - rx_data_o(229 downto 0)   = ELINK
          --       - rx_data_o(231 downto 230) = EC
          --       - rx_data_o(233 downto 232) = IC		
          -- 
          -- FPGA_ASSYMMETRIC_RX5G:
          --     tx_data_i'length = 36;
          --       - tx_data_i(31 downto 0)    = ELINK
          --       - tx_data_i(33 downto 32)   = EC
          --       - tx_data_i(35 downto 34)   = IC		
          --     rx_data_o'length = 116;
          --       - rx_data_o(111 downto 0)   = ELINK
          --       - rx_data_o(113 downto 112) = EC
          --       - rx_data_o(115 downto 114) = IC	
          -----------------------------------------------------------------  
          tx_clk40_i          : in std_logic                      ;		
          tx_clk40_stable_i   : in std_logic                      ;
          tx_data_i           : in std_logic_vector               ;
                             
          rx_clk40_i          : in  std_logic                     ;
          rx_clk40_stable_i   : in std_logic                      ;		
          rx_data_o           : out std_logic_vector              ;
  
          -----------------------------------------------------------------
          ------------------------- MMCM ----------------------------------
          -----------------------------------------------------------------
          mmcm_locked_i : in std_logic;

          -----------------------------------------------------------------
          ------------------------ MGT  ---------------------------------
          -----------------------------------------------------------------
          mgt_txclk_i          : in   std_logic;
          mgt_rxclk_i          : in   std_logic;
          mgt_ctrl_o           : out  tr_core_to_mgt;
          mgt_stat_i           : in   tr_mgt_to_core
  
  	);
  end component tclink_lpgbt;

  component vio_control_vcu118
    port (
      clk         : in std_logic;
      probe_in0   : in std_logic_vector(0 downto 0);
      probe_in1   : in std_logic_vector(0 downto 0);
      probe_in2   : in std_logic_vector(0 downto 0);
      probe_in3   : in std_logic_vector(0 downto 0);
      probe_in4   : in std_logic_vector(0 downto 0);
      probe_in5   : in std_logic_vector(0 downto 0);
      probe_in6   : in std_logic_vector(0 downto 0);
      probe_in7   : in std_logic_vector(0 downto 0);
      probe_in8   : in std_logic_vector(0 downto 0);
      probe_in9   : in std_logic_vector(0 downto 0);
      probe_in10  : in std_logic_vector(0 downto 0);
      probe_in11  : in std_logic_vector(0 downto 0);
      probe_in12  : in std_logic_vector(0 downto 0);
      probe_in13  : in std_logic_vector(0 downto 0);
      probe_in14  : in std_logic_vector(0 downto 0);
      probe_in15  : in std_logic_vector(0 downto 0);
      probe_in16  : in std_logic_vector(0 downto 0);
      probe_in17  : in std_logic_vector(15 downto 0);
      probe_in18  : in std_logic_vector(6 downto 0);
      probe_in19  : in std_logic_vector(31 downto 0);
      probe_in20  : in std_logic_vector(0 downto 0);
      probe_in21  : in std_logic_vector(15 downto 0);
      probe_in22  : in std_logic_vector(0 downto 0);
      probe_in23  : in std_logic_vector(0 downto 0);
      probe_in24  : in std_logic_vector(31 downto 0);
      probe_in25  : in std_logic_vector(47 downto 0);
      probe_in26  : in std_logic_vector(15 downto 0);
      probe_in27  : in std_logic_vector(0 downto 0);
      probe_in28  : in std_logic_vector(15 downto 0);
	  probe_in29  : in std_logic_vector(0 downto 0);
	  probe_in30  : in std_logic_vector(0 downto 0);
	  probe_in31  : in std_logic_vector(2 downto 0);
	  probe_in32  : in std_logic_vector(9 downto 0);	  
      probe_in33  : in std_logic_vector(0 downto 0);
      probe_in34  : in std_logic_vector(16 downto 0);
      probe_in35  : in std_logic_vector(0 downto 0);
	  probe_in36  : in std_logic_vector(0 downto 0);
	  probe_in37  : in std_logic_vector(0 downto 0);
	  probe_in38  : in std_logic_vector(0 downto 0);
	  probe_in39  : in std_logic_vector(0 downto 0);
	  probe_in40  : in std_logic_vector(0 downto 0);	 
	  probe_in41  : in std_logic_vector(0 downto 0);	 
	  
      probe_out0  : out std_logic_vector(0 downto 0);
      probe_out1  : out std_logic_vector(0 downto 0);
      probe_out2  : out std_logic_vector(0 downto 0);
      probe_out3  : out std_logic_vector(0 downto 0);
      probe_out4  : out std_logic_vector(0 downto 0);
      probe_out5  : out std_logic_vector(0 downto 0);
      probe_out6  : out std_logic_vector(0 downto 0);
      probe_out7  : out std_logic_vector(0 downto 0);
      probe_out8  : out std_logic_vector(0 downto 0);
      probe_out9  : out std_logic_vector(2 downto 0);
      probe_out10 : out std_logic_vector(0 downto 0);
      probe_out11 : out std_logic_vector(3 downto 0);
      probe_out12 : out std_logic_vector(0 downto 0);
      probe_out13 : out std_logic_vector(3 downto 0);
      probe_out14 : out std_logic_vector(0 downto 0);
      probe_out15 : out std_logic_vector(0 downto 0);
      probe_out16 : out std_logic_vector(9 downto 0);
      probe_out17 : out std_logic_vector(15 downto 0);
      probe_out18 : out std_logic_vector(31 downto 0);
      probe_out19 : out std_logic_vector(6 downto 0);
      probe_out20 : out std_logic_vector(0 downto 0);
      probe_out21 : out std_logic_vector(0 downto 0);
      probe_out22 : out std_logic_vector(0 downto 0);
      probe_out23 : out std_logic_vector(3 downto 0);
      probe_out24 : out std_logic_vector(0 downto 0);
      probe_out25 : out std_logic_vector(0 downto 0);
      probe_out26 : out std_logic_vector(0 downto 0);
      probe_out27 : out std_logic_vector(0 downto 0);
      probe_out28 : out std_logic_vector(0 downto 0);
      probe_out29 : out std_logic_vector(0 downto 0);
      probe_out30 : out std_logic_vector(0 downto 0);
      probe_out31 : out std_logic_vector(47 downto 0);
      probe_out32 : out std_logic_vector(15 downto 0);
      probe_out33 : out std_logic_vector(11 downto 0);
      probe_out34 : out std_logic_vector(47 downto 0);
      probe_out35 : out std_logic_vector(3 downto 0);
      probe_out36 : out std_logic_vector(0 downto 0);
      probe_out37 : out std_logic_vector(3 downto 0);
      probe_out38 : out std_logic_vector(15 downto 0);
      probe_out39 : out std_logic_vector(0 downto 0);
      probe_out40 : out std_logic_vector(47 downto 0);
      probe_out41 : out std_logic_vector(0 downto 0);
      probe_out42 : out std_logic_vector(9 downto 0);
      probe_out43 : out std_logic_vector(4 downto 0);
      probe_out44 : out std_logic_vector(0 downto 0);
      probe_out45 : out std_logic_vector(9 downto 0);
	  probe_out46 : out std_logic_vector(0 downto 0);
	  probe_out47 : out std_logic_vector(47 downto 0);
	  probe_out48 : out std_logic_vector(0 downto 0);
	  probe_out49 : out std_logic_vector(0 downto 0);
	  probe_out50 : out std_logic_vector(0 downto 0);
	  probe_out51 : out std_logic_vector(0 downto 0);
	  probe_out52 : out std_logic_vector(0 downto 0);
	  probe_out53 : out std_logic_vector(0 downto 0);
	  probe_out54 : out std_logic_vector(0 downto 0);
	  probe_out55 : out std_logic_vector(0 downto 0);
	  probe_out56 : out std_logic_vector(2 downto 0);
	  probe_out57 : out std_logic_vector(0 downto 0);
	  probe_out58 : out std_logic_vector(9 downto 0);
      probe_out59 : out std_logic_vector(0 downto 0);
      probe_out60 : out std_logic_vector(0 downto 0);
      probe_out61 : out std_logic_vector(0 downto 0)
    );
  end component vio_control_vcu118;
  ----------------------------------------------------------------------------------
  
  ---------------------------------- Master ----------------------------------
  component mmcme4
  port
   (-- Clock in ports
    -- Clock out ports
    clk_out1          : out    std_logic;
    -- Status and control signals
    resetn             : in     std_logic;
    locked            : out    std_logic;
    clk_in1           : in     std_logic
   );
  end component;

  component gty_master_timing_gtye4_common_wrapper
  port (
    GTYE4_COMMON_BGBYPASSB             : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_BGMONITORENB          : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_BGPDB                 : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_BGRCALOVRD            : in std_logic_vector(4 downto 0) ;
    GTYE4_COMMON_BGRCALOVRDENB         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_DRPADDR               : in std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_DRPCLK                : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_DRPDI                 : in std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_DRPEN                 : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_DRPWE                 : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTGREFCLK0            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTGREFCLK1            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTNORTHREFCLK00       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTNORTHREFCLK01       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTNORTHREFCLK10       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTNORTHREFCLK11       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTREFCLK00            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTREFCLK01            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTREFCLK10            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTREFCLK11            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTSOUTHREFCLK00       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTSOUTHREFCLK01       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTSOUTHREFCLK10       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_GTSOUTHREFCLK11       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_PCIERATEQPLL0         : in std_logic_vector(2 downto 0) ;
    GTYE4_COMMON_PCIERATEQPLL1         : in std_logic_vector(2 downto 0) ;
    GTYE4_COMMON_PMARSVD0              : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_PMARSVD1              : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLL0CLKRSVD0         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0CLKRSVD1         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0FBDIV            : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLL0LOCKDETCLK       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0LOCKEN           : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0PD               : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0REFCLKSEL        : in std_logic_vector(2 downto 0) ;
    GTYE4_COMMON_QPLL0RESET            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1CLKRSVD0         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1CLKRSVD1         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1FBDIV            : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLL1LOCKDETCLK       : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1LOCKEN           : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1PD               : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1REFCLKSEL        : in std_logic_vector(2 downto 0) ;
    GTYE4_COMMON_QPLL1RESET            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLLRSVD1             : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLLRSVD2             : in std_logic_vector(4 downto 0) ;
    GTYE4_COMMON_QPLLRSVD3             : in std_logic_vector(4 downto 0) ;
    GTYE4_COMMON_QPLLRSVD4             : in std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_RCALENB               : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_SDM0DATA              : in std_logic_vector(24 downto 0) ;
    GTYE4_COMMON_SDM0RESET             : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_SDM0TOGGLE            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_SDM0WIDTH             : in std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_SDM1DATA              : in std_logic_vector(24 downto 0) ;
    GTYE4_COMMON_SDM1RESET             : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_SDM1TOGGLE            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_SDM1WIDTH             : in std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_UBCFGSTREAMEN         : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBDO                  : in std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_UBDRDY                : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBENABLE              : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBGPI                 : in std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_UBINTR                : in std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_UBIOLMBRST            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMBRST               : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMCAPTURE          : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMDBGRST           : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMDBGUPDATE        : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMREGEN            : in std_logic_vector(3 downto 0) ;
    GTYE4_COMMON_UBMDMSHIFT            : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMSYSRST           : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMTCK              : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMTDI              : in std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_DRPDO                 : out std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_DRPRDY                : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_PMARSVDOUT0           : out std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_PMARSVDOUT1           : out std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLL0FBCLKLOST        : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0LOCK             : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0OUTCLK           : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0OUTREFCLK        : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL0REFCLKLOST       : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1FBCLKLOST        : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1LOCK             : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1OUTCLK           : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1OUTREFCLK        : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLL1REFCLKLOST       : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_QPLLDMONITOR0         : out std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_QPLLDMONITOR1         : out std_logic_vector(7 downto 0) ;
    GTYE4_COMMON_REFCLKOUTMONITOR0     : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_REFCLKOUTMONITOR1     : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_RXRECCLK0SEL          : out std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_RXRECCLK1SEL          : out std_logic_vector(1 downto 0) ;
    GTYE4_COMMON_SDM0FINALOUT          : out std_logic_vector(3 downto 0) ;
    GTYE4_COMMON_SDM0TESTDATA          : out std_logic_vector(14 downto 0) ;
    GTYE4_COMMON_SDM1FINALOUT          : out std_logic_vector(3 downto 0) ;
    GTYE4_COMMON_SDM1TESTDATA          : out std_logic_vector(14 downto 0) ;
    GTYE4_COMMON_UBDADDR               : out std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_UBDEN                 : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBDI                  : out std_logic_vector(15 downto 0) ;
    GTYE4_COMMON_UBDWE                 : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBMDMTDO              : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBRSVDOUT             : out std_logic_vector(0 downto 0) ;
    GTYE4_COMMON_UBTXUART               : out std_logic_vector(0 downto 0) 
  );
  end component gty_master_timing_gtye4_common_wrapper;

  component gtye4_master_timing_10g
    port (
      gtwiz_userclk_tx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_reset_in       : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_start_user_in  : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                 : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_userdata_tx_in               : in std_logic_vector(31 downto 0); 
      gtwiz_userdata_rx_out              : out std_logic_vector(31 downto 0);
      gtwiz_reset_qpll0lock_in           : in std_logic_vector(0 downto 0); 
      gtwiz_reset_qpll0reset_out         : out std_logic_vector(0 downto 0);
      qpll0clk_in                        : in std_logic_vector(0 downto 0); 
      qpll0refclk_in                     : in std_logic_vector(0 downto 0); 
      qpll1clk_in                        : in std_logic_vector(0 downto 0); 
      qpll1refclk_in                     : in std_logic_vector(0 downto 0); 
      dmonitorclk_in                     : in std_logic_vector(0 downto 0);
      drpaddr_in                         : in std_logic_vector(9 downto 0);
      drpclk_in                          : in std_logic_vector(0 downto 0);
      drpdi_in                           : in std_logic_vector(15 downto 0);
      drpen_in                           : in std_logic_vector(0 downto 0);
      drpwe_in                           : in std_logic_vector(0 downto 0);
      gtyrxn_in                          : in std_logic_vector(0 downto 0);
      gtyrxp_in                          : in std_logic_vector(0 downto 0);
      loopback_in                        : in std_logic_vector(2 downto 0);
      rxdfeagcovrden_in                  : in std_logic_vector(0 downto 0);
      rxdfelfovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfelpmreset_in                   : in std_logic_vector(0 downto 0);
      rxdfeutovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfevpovrden_in                   : in std_logic_vector(0 downto 0); 
      rxlpmen_in                         : in std_logic_vector(0 downto 0);  
      rxlpmgcovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmhfovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmlfklovrden_in                 : in std_logic_vector(0 downto 0);
      rxlpmosovrden_in                   : in std_logic_vector(0 downto 0);
      rxosovrden_in                      : in std_logic_vector(0 downto 0);
      rxpolarity_in                      : in std_logic_vector(0 downto 0);
      rxprbscntreset_in                  : in std_logic_vector(0 downto 0);
      rxprbssel_in                       : in std_logic_vector(3 downto 0);
      rxslide_in                         : in std_logic_vector(0 downto 0);
      rxusrclk_in                        : in std_logic_vector(0 downto 0);
      rxusrclk2_in                       : in std_logic_vector(0 downto 0);
      txpippmen_in                       : in std_logic_vector(0 downto 0);
      txpippmovrden_in                   : in std_logic_vector(0 downto 0);
      txpippmpd_in                       : in std_logic_vector(0 downto 0);
      txpippmsel_in                      : in std_logic_vector(0 downto 0);
      txpippmstepsize_in                 : in std_logic_vector(4 downto 0);
      txpolarity_in                      : in std_logic_vector(0 downto 0);
      txprbsforceerr_in                  : in std_logic_vector(0 downto 0);
      txprbssel_in                       : in std_logic_vector(3 downto 0);
      txusrclk_in                        : in std_logic_vector(0 downto 0);
      txusrclk2_in                       : in std_logic_vector(0 downto 0);
      dmonitorout_out                    : out std_logic_vector(15 downto 0);
      drpdo_out                          : out std_logic_vector(15 downto 0);
      drprdy_out                         : out std_logic_vector(0 downto 0);
      gtpowergood_out                    : out std_logic_vector(0 downto 0);
      gtytxn_out                         : out std_logic_vector(0 downto 0);
      gtytxp_out                         : out std_logic_vector(0 downto 0);
      rxoutclk_out                       : out std_logic_vector(0 downto 0);
      rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
      rxprbserr_out                      : out std_logic_vector(0 downto 0);
      rxprbslocked_out                   : out std_logic_vector(0 downto 0);
      txbufstatus_out                    : out std_logic_vector(1 downto 0);
      txoutclk_out                       : out std_logic_vector(0 downto 0);
      txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
    );
  end component gtye4_master_timing_10g;
  
  component gtye4_master_timing_5g
    port (
      gtwiz_userclk_tx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_reset_in       : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_start_user_in  : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                 : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_userdata_tx_in               : in std_logic_vector(15 downto 0); 
      gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
      gtwiz_reset_qpll0lock_in           : in std_logic_vector(0 downto 0); 
      gtwiz_reset_qpll0reset_out         : out std_logic_vector(0 downto 0);
      qpll0clk_in                        : in std_logic_vector(0 downto 0); 
      qpll0refclk_in                     : in std_logic_vector(0 downto 0); 
      qpll1clk_in                        : in std_logic_vector(0 downto 0); 
      qpll1refclk_in                     : in std_logic_vector(0 downto 0); 
      dmonitorclk_in                     : in std_logic_vector(0 downto 0);
      drpaddr_in                         : in std_logic_vector(9 downto 0);
      drpclk_in                          : in std_logic_vector(0 downto 0);
      drpdi_in                           : in std_logic_vector(15 downto 0);
      drpen_in                           : in std_logic_vector(0 downto 0);
      drpwe_in                           : in std_logic_vector(0 downto 0);
      gtyrxn_in                          : in std_logic_vector(0 downto 0);
      gtyrxp_in                          : in std_logic_vector(0 downto 0);
      loopback_in                        : in std_logic_vector(2 downto 0);
      rxdfeagcovrden_in                  : in std_logic_vector(0 downto 0);
      rxdfelfovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfelpmreset_in                   : in std_logic_vector(0 downto 0);
      rxdfeutovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfevpovrden_in                   : in std_logic_vector(0 downto 0); 
      rxlpmen_in                         : in std_logic_vector(0 downto 0);  
      rxlpmgcovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmhfovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmlfklovrden_in                 : in std_logic_vector(0 downto 0);
      rxlpmosovrden_in                   : in std_logic_vector(0 downto 0);
      rxosovrden_in                      : in std_logic_vector(0 downto 0);
      rxpolarity_in                      : in std_logic_vector(0 downto 0);
      rxprbscntreset_in                  : in std_logic_vector(0 downto 0);
      rxprbssel_in                       : in std_logic_vector(3 downto 0);
      rxslide_in                         : in std_logic_vector(0 downto 0);
      rxusrclk_in                        : in std_logic_vector(0 downto 0);
      rxusrclk2_in                       : in std_logic_vector(0 downto 0);
      txpippmen_in                       : in std_logic_vector(0 downto 0);
      txpippmovrden_in                   : in std_logic_vector(0 downto 0);
      txpippmpd_in                       : in std_logic_vector(0 downto 0);
      txpippmsel_in                      : in std_logic_vector(0 downto 0);
      txpippmstepsize_in                 : in std_logic_vector(4 downto 0);
      txpolarity_in                      : in std_logic_vector(0 downto 0);
      txprbsforceerr_in                  : in std_logic_vector(0 downto 0);
      txprbssel_in                       : in std_logic_vector(3 downto 0);
      txusrclk_in                        : in std_logic_vector(0 downto 0);
      txusrclk2_in                       : in std_logic_vector(0 downto 0);
      dmonitorout_out                    : out std_logic_vector(15 downto 0);
      drpdo_out                          : out std_logic_vector(15 downto 0);
      drprdy_out                         : out std_logic_vector(0 downto 0);
      gtpowergood_out                    : out std_logic_vector(0 downto 0);
      gtytxn_out                         : out std_logic_vector(0 downto 0);
      gtytxp_out                         : out std_logic_vector(0 downto 0);
      rxoutclk_out                       : out std_logic_vector(0 downto 0);
      rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
      rxprbserr_out                      : out std_logic_vector(0 downto 0);
      rxprbslocked_out                   : out std_logic_vector(0 downto 0);
      txbufstatus_out                    : out std_logic_vector(1 downto 0);
      txoutclk_out                       : out std_logic_vector(0 downto 0);
      txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
    );
  end component gtye4_master_timing_5g;  
  ----------------------------------------------------------------------------------

  ----------------------------------- Slave -----------------------------------
  component mmcme4_slave
  port
   (-- Clock in ports
    -- Clock out ports
    clk_out1          : out    std_logic;
    -- Status and control signals
    resetn             : in     std_logic;
    locked            : out    std_logic;
    clk_in1           : in     std_logic
   );
  end component;
  
  component gtye4_slave_timing_10g
    port (
      gtwiz_userclk_tx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_reset_in       : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_start_user_in  : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                 : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_userdata_tx_in               : in std_logic_vector(31 downto 0);
      gtwiz_userdata_rx_out              : out std_logic_vector(31 downto 0);
      gtrefclk00_in                      : in std_logic_vector(0 downto 0);
      qpll1lock_out                      : out std_logic_vector(0 downto 0);
      qpll1outclk_out                    : out std_logic_vector(0 downto 0);
      qpll1outrefclk_out                 : out std_logic_vector(0 downto 0);
      qpll0lock_out                      : out std_logic_vector(0 downto 0);
      qpll0outclk_out                    : out std_logic_vector(0 downto 0);
      qpll0outrefclk_out                 : out std_logic_vector(0 downto 0);
      dmonitorclk_in                     : in std_logic_vector(0 downto 0);
      drpaddr_in                         : in std_logic_vector(9 downto 0);
      drpclk_in                          : in std_logic_vector(0 downto 0);
      drpdi_in                           : in std_logic_vector(15 downto 0);
      drpen_in                           : in std_logic_vector(0 downto 0);
      drpwe_in                           : in std_logic_vector(0 downto 0);
      gtrefclk01_in                      : in std_logic_vector(0 downto 0);
      gtyrxn_in                          : in std_logic_vector(0 downto 0);
      gtyrxp_in                          : in std_logic_vector(0 downto 0);
      loopback_in                        : in std_logic_vector(2 downto 0);
      rxdfeagcovrden_in                  : in std_logic_vector(0 downto 0);
      rxdfelfovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfelpmreset_in                   : in std_logic_vector(0 downto 0);
      rxdfeutovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfevpovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmen_in                         : in std_logic_vector(0 downto 0);  
      rxlpmgcovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmhfovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmlfklovrden_in                 : in std_logic_vector(0 downto 0);
      rxlpmosovrden_in                   : in std_logic_vector(0 downto 0);
      rxosovrden_in                      : in std_logic_vector(0 downto 0);
      rxpolarity_in                      : in std_logic_vector(0 downto 0);
      rxprbscntreset_in                  : in std_logic_vector(0 downto 0);
      rxprbssel_in                       : in std_logic_vector(3 downto 0);
      rxslide_in                         : in std_logic_vector(0 downto 0);
      rxusrclk_in                        : in std_logic_vector(0 downto 0);
      rxusrclk2_in                       : in std_logic_vector(0 downto 0);
      txpippmen_in                       : in std_logic_vector(0 downto 0);
      txpippmovrden_in                   : in std_logic_vector(0 downto 0);
      txpippmpd_in                       : in std_logic_vector(0 downto 0);
      txpippmsel_in                      : in std_logic_vector(0 downto 0);
      txpippmstepsize_in                 : in std_logic_vector(4 downto 0);
      txpolarity_in                      : in std_logic_vector(0 downto 0);
      txprbsforceerr_in                  : in std_logic_vector(0 downto 0);
      txprbssel_in                       : in std_logic_vector(3 downto 0);
      txusrclk_in                        : in std_logic_vector(0 downto 0);
      txusrclk2_in                       : in std_logic_vector(0 downto 0);
      dmonitorout_out                    : out std_logic_vector(15 downto 0);
      drpdo_out                          : out std_logic_vector(15 downto 0);
      drprdy_out                         : out std_logic_vector(0 downto 0);
      gtpowergood_out                    : out std_logic_vector(0 downto 0);
      gtytxn_out                         : out std_logic_vector(0 downto 0);
      gtytxp_out                         : out std_logic_vector(0 downto 0);
      rxoutclk_out                       : out std_logic_vector(0 downto 0);
      rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
      rxprbserr_out                      : out std_logic_vector(0 downto 0);
      rxprbslocked_out                   : out std_logic_vector(0 downto 0);
      txbufstatus_out                    : out std_logic_vector(1 downto 0);
      txoutclk_out                       : out std_logic_vector(0 downto 0);
      txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
    );
  end component gtye4_slave_timing_10g;   
  
  component gtye4_slave_timing_5g
    port (
      gtwiz_userclk_tx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_in         : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_reset_in       : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_start_user_in  : in std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
      gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                 : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in         : in std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
      gtwiz_userdata_tx_in               : in std_logic_vector(15 downto 0);
      gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
      gtrefclk00_in                      : in std_logic_vector(0 downto 0);
      qpll1lock_out                      : out std_logic_vector(0 downto 0);
      qpll1outclk_out                    : out std_logic_vector(0 downto 0);
      qpll1outrefclk_out                 : out std_logic_vector(0 downto 0);
      qpll0lock_out                      : out std_logic_vector(0 downto 0);
      qpll0outclk_out                    : out std_logic_vector(0 downto 0);
      qpll0outrefclk_out                 : out std_logic_vector(0 downto 0);
      dmonitorclk_in                     : in std_logic_vector(0 downto 0);
      drpaddr_in                         : in std_logic_vector(9 downto 0);
      drpclk_in                          : in std_logic_vector(0 downto 0);
      drpdi_in                           : in std_logic_vector(15 downto 0);
      drpen_in                           : in std_logic_vector(0 downto 0);
      drpwe_in                           : in std_logic_vector(0 downto 0);
      gtrefclk01_in                      : in std_logic_vector(0 downto 0);
      gtyrxn_in                          : in std_logic_vector(0 downto 0);
      gtyrxp_in                          : in std_logic_vector(0 downto 0);
      loopback_in                        : in std_logic_vector(2 downto 0);
      rxdfeagcovrden_in                  : in std_logic_vector(0 downto 0);
      rxdfelfovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfelpmreset_in                   : in std_logic_vector(0 downto 0);
      rxdfeutovrden_in                   : in std_logic_vector(0 downto 0);
      rxdfevpovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmen_in                         : in std_logic_vector(0 downto 0);  
      rxlpmgcovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmhfovrden_in                   : in std_logic_vector(0 downto 0);
      rxlpmlfklovrden_in                 : in std_logic_vector(0 downto 0);
      rxlpmosovrden_in                   : in std_logic_vector(0 downto 0);
      rxosovrden_in                      : in std_logic_vector(0 downto 0);
      rxpolarity_in                      : in std_logic_vector(0 downto 0);
      rxprbscntreset_in                  : in std_logic_vector(0 downto 0);
      rxprbssel_in                       : in std_logic_vector(3 downto 0);
      rxslide_in                         : in std_logic_vector(0 downto 0);
      rxusrclk_in                        : in std_logic_vector(0 downto 0);
      rxusrclk2_in                       : in std_logic_vector(0 downto 0);
      txpippmen_in                       : in std_logic_vector(0 downto 0);
      txpippmovrden_in                   : in std_logic_vector(0 downto 0);
      txpippmpd_in                       : in std_logic_vector(0 downto 0);
      txpippmsel_in                      : in std_logic_vector(0 downto 0);
      txpippmstepsize_in                 : in std_logic_vector(4 downto 0);
      txpolarity_in                      : in std_logic_vector(0 downto 0);
      txprbsforceerr_in                  : in std_logic_vector(0 downto 0);
      txprbssel_in                       : in std_logic_vector(3 downto 0);
      txusrclk_in                        : in std_logic_vector(0 downto 0);
      txusrclk2_in                       : in std_logic_vector(0 downto 0);
      dmonitorout_out                    : out std_logic_vector(15 downto 0);
      drpdo_out                          : out std_logic_vector(15 downto 0);
      drprdy_out                         : out std_logic_vector(0 downto 0);
      gtpowergood_out                    : out std_logic_vector(0 downto 0);
      gtytxn_out                         : out std_logic_vector(0 downto 0);
      gtytxp_out                         : out std_logic_vector(0 downto 0);
      rxoutclk_out                       : out std_logic_vector(0 downto 0);
      rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
      rxprbserr_out                      : out std_logic_vector(0 downto 0);
      rxprbslocked_out                   : out std_logic_vector(0 downto 0);
      txbufstatus_out                    : out std_logic_vector(1 downto 0);
      txoutclk_out                       : out std_logic_vector(0 downto 0);
      txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
    );
  end component gtye4_slave_timing_5g;   
  ----------------------------------------------------------------------------------

  ---------------------------------- Miscellaneous ----------------------------------
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
  -----------------------------------------------------------------------------------

begin

  ----------------------------------------------- Common -----------------------------------------------
  -- Differential input buffer for system clock
  cmp_clksys_IBUFDS : IBUFDS
    generic map(
      DQS_BIAS => "FALSE"
    )
    port map( 
      O     => clk_sys,
	  I     => clk_sys_p_i,
	  IB    => clk_sys_n_i
    );
	
  -- Differential input buffer for system clock
  cmp_clk40_IBUFDS : IBUFDS
    generic map(
      DQS_BIAS => "FALSE"
    )
    port map( 
      O     => clk40,
	  I     => clk40_p_i,
	  IB    => clk40_n_i
    );
  -------------------------------------------------------------------------------------------------------

  ----------------------------------------------- Master -----------------------------------------------
  -- ODIV2 user clock buffer (low-skew buffer resource contained within transceiver region)
  cmp_odiv2_bufg_gt : BUFG_GT 
    port map( 
      O       => master_trxrefclk_fabric,    -- 1-bit output: Buffer 
      CE      => '1',                          -- 1-bit input: Buffer enable 
      CEMASK  => '0',                          -- 1-bit input: CE Mask 
      CLR     => '0',                          -- 1-bit input: Asynchronous clear 
      CLRMASK => '0',                          -- 1-bit input: CLR Mask 
      DIV     => "000",                        -- 3-bit input: Dymanic divide Value  - 000=div by 1
      I       => master_trxrefclk_odiv2(0)             -- 1-bit input: Buffer 
  );
  -- MMCM for master TCLink heterodyne clock (shared for all masters)
  cmp_mmcme_master_tclink : mmcme4
  port map
   (-- Clock in ports
    -- Clock out ports
    clk_out1          => master_clk_offset,
    -- Status and control signals
    resetn            => master_clk_offset_resetn,
    locked            => master_clk_offset_locked_async,
    clk_in1           => master_trxrefclk_fabric       
   );
   master_clk_offset_resetn <= master_clk_offset_resetn_dummy(0);
   
  clk_offset_locked_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_sys    ,
      i_in   => master_clk_offset_locked_async,
      o_out  => master_clk_offset_locked
  ); 
  
  ---------- Master ----------

  gen_master_quads : for i in c_MASTER_NUMBER_QUADS-1 downto 0 generate  
    -- Transceiver input clock buffer
    cmp_master_trxrefclk_IBUFDS_GTE4 : IBUFDS_GTE4
      generic map( 
        REFCLK_EN_TX_PATH  => '0' ,
        REFCLK_HROW_CK_SEL => "00",
        REFCLK_ICNTL_RX    => "00"
      )
      port map( 
        O     => master_trxrefclk(i)    ,
        ODIV2 => master_trxrefclk_odiv2(i),
        CEB   => '0'                    ,
        I     => master_trxrefclk_p_i(i),
        IB    => master_trxrefclk_n_i(i)
    );


	  
    cmp_gty_master_timing_gtye4_common_wrapper : gty_master_timing_gtye4_common_wrapper 
    port map(
      GTYE4_COMMON_BGBYPASSB         => "1"                                      ,
      GTYE4_COMMON_BGMONITORENB      => "1"                                      ,
      GTYE4_COMMON_BGPDB             => "1"                                      ,
      GTYE4_COMMON_BGRCALOVRD        => "10000"                                  ,
      GTYE4_COMMON_BGRCALOVRDENB     => "1"                                      ,
      GTYE4_COMMON_DRPADDR           => "0000000000000000"                       ,
      GTYE4_COMMON_DRPCLK            => "0"                                      ,
      GTYE4_COMMON_DRPDI             => "0000000000000000"                       ,
      GTYE4_COMMON_DRPEN             => "0"                                      ,
      GTYE4_COMMON_DRPWE             => "0"                                      ,
      GTYE4_COMMON_GTGREFCLK0        => "0"                                      ,
      GTYE4_COMMON_GTGREFCLK1        => "0"                                      ,
      GTYE4_COMMON_GTNORTHREFCLK00   => "0"                                      ,
      GTYE4_COMMON_GTNORTHREFCLK01   => "0"                                      ,
      GTYE4_COMMON_GTNORTHREFCLK10   => "0"                                      ,
      GTYE4_COMMON_GTNORTHREFCLK11   => "0"                                      ,
      GTYE4_COMMON_GTREFCLK00(0)     => master_trxrefclk(i)                      ,
      GTYE4_COMMON_GTREFCLK01(0)     => master_trxrefclk(i)                      ,
      GTYE4_COMMON_GTREFCLK10        => "0"                                      ,
      GTYE4_COMMON_GTREFCLK11        => "0"                                      ,
      GTYE4_COMMON_GTSOUTHREFCLK00   => "0"                                      ,
      GTYE4_COMMON_GTSOUTHREFCLK01   => "0"                                      ,
      GTYE4_COMMON_GTSOUTHREFCLK10   => "0"                                      ,
      GTYE4_COMMON_GTSOUTHREFCLK11   => "0"                                      ,
      GTYE4_COMMON_PCIERATEQPLL0     => "000"                                    ,
      GTYE4_COMMON_PCIERATEQPLL1     => "000"                                    ,
      GTYE4_COMMON_PMARSVD0          => "00000000"                               ,
      GTYE4_COMMON_PMARSVD1          => "00000000"                               ,
      GTYE4_COMMON_QPLL0CLKRSVD0     => "0"                                      ,
      GTYE4_COMMON_QPLL0CLKRSVD1     => "0"                                      ,
      GTYE4_COMMON_QPLL0FBDIV        => "00000000"                               ,
      GTYE4_COMMON_QPLL0LOCKDETCLK   => "0"                                      ,
      GTYE4_COMMON_QPLL0LOCKEN       => "1"                                      ,
      GTYE4_COMMON_QPLL0PD           => "0"                                      ,
      GTYE4_COMMON_QPLL0REFCLKSEL    => "001"                                    ,
      GTYE4_COMMON_QPLL0RESET(0)     => master_mgt_to_common_qpll0reset_common(i),
      GTYE4_COMMON_QPLL1CLKRSVD0     => "0"                                      ,
      GTYE4_COMMON_QPLL1CLKRSVD1     => "0"                                      ,
      GTYE4_COMMON_QPLL1FBDIV        => "00000000"                               ,
      GTYE4_COMMON_QPLL1LOCKDETCLK   => "0"                                      ,
      GTYE4_COMMON_QPLL1LOCKEN       => "0"                                      ,
      GTYE4_COMMON_QPLL1PD           => "1"                                      ,
      GTYE4_COMMON_QPLL1REFCLKSEL    => "001"                                    ,
      GTYE4_COMMON_QPLL1RESET        => "0"                                      ,
      GTYE4_COMMON_QPLLRSVD1         => "00000000"                               ,
      GTYE4_COMMON_QPLLRSVD2         => "00000"                                  ,
      GTYE4_COMMON_QPLLRSVD3         => "00000"                                  ,
      GTYE4_COMMON_QPLLRSVD4         => "00000000"                               ,
      GTYE4_COMMON_RCALENB           => "1"                                      ,
      GTYE4_COMMON_SDM0DATA          => "0000000000000000000000000"              ,
      GTYE4_COMMON_SDM0RESET         => "0"                                      ,
      GTYE4_COMMON_SDM0TOGGLE        => "0"                                      ,
      GTYE4_COMMON_SDM0WIDTH         => "00"                                     ,
      GTYE4_COMMON_SDM1DATA          => "0000000000000000000000000"              ,
      GTYE4_COMMON_SDM1RESET         => "0"                                      ,
      GTYE4_COMMON_SDM1TOGGLE        => "0"                                      ,
      GTYE4_COMMON_SDM1WIDTH         => "00"                                     ,
      GTYE4_COMMON_UBCFGSTREAMEN     => "0"                                      ,
      GTYE4_COMMON_UBDO              => "0000000000000000"                       ,
      GTYE4_COMMON_UBDRDY            => "0"                                      ,
      GTYE4_COMMON_UBENABLE          => "0"                                      ,
      GTYE4_COMMON_UBGPI             => "00"                                     ,
      GTYE4_COMMON_UBINTR            => "00"                                     ,
      GTYE4_COMMON_UBIOLMBRST        => "0"                                      ,
      GTYE4_COMMON_UBMBRST           => "0"                                      ,
      GTYE4_COMMON_UBMDMCAPTURE      => "0"                                      ,
      GTYE4_COMMON_UBMDMDBGRST       => "0"                                      ,
      GTYE4_COMMON_UBMDMDBGUPDATE    => "0"                                      ,
      GTYE4_COMMON_UBMDMREGEN        => "0000"                                   ,
      GTYE4_COMMON_UBMDMSHIFT        => "0"                                      ,
      GTYE4_COMMON_UBMDMSYSRST       => "0"                                      ,
      GTYE4_COMMON_UBMDMTCK          => "0"                                      ,
      GTYE4_COMMON_UBMDMTDI          => "0"                                      ,
      GTYE4_COMMON_DRPDO             => open                                     ,
      GTYE4_COMMON_DRPRDY            => open                                     ,
      GTYE4_COMMON_PMARSVDOUT0       => open                                     ,
      GTYE4_COMMON_PMARSVDOUT1       => open                                     ,
      GTYE4_COMMON_QPLL0FBCLKLOST    => open                                     ,
      GTYE4_COMMON_QPLL0LOCK(0)      => master_common_to_mgt_qpll0lock(i)        ,
      GTYE4_COMMON_QPLL0OUTCLK(0)    => master_common_to_mgt_qpll0outclk(i)      ,
      GTYE4_COMMON_QPLL0OUTREFCLK(0) => master_common_to_mgt_qpll0outrefclk(i)   ,
      GTYE4_COMMON_QPLL0REFCLKLOST   => open                                     ,
      GTYE4_COMMON_QPLL1FBCLKLOST    => open                                     ,
      GTYE4_COMMON_QPLL1LOCK(0)      => open                                     ,
      GTYE4_COMMON_QPLL1OUTCLK(0)    => master_common_to_mgt_qpll1outclk(i)      ,
      GTYE4_COMMON_QPLL1OUTREFCLK(0) => master_common_to_mgt_qpll1outrefclk(i)   ,
      GTYE4_COMMON_QPLL1REFCLKLOST   => open                                     ,
      GTYE4_COMMON_QPLLDMONITOR0     => open                                     ,
      GTYE4_COMMON_QPLLDMONITOR1     => open                                     ,
      GTYE4_COMMON_REFCLKOUTMONITOR0 => open                                     ,
      GTYE4_COMMON_REFCLKOUTMONITOR1 => open                                     ,
      GTYE4_COMMON_RXRECCLK0SEL      => open                                     ,
      GTYE4_COMMON_RXRECCLK1SEL      => open                                     ,
      GTYE4_COMMON_SDM0FINALOUT      => open                                     ,
      GTYE4_COMMON_SDM0TESTDATA      => open                                     ,
      GTYE4_COMMON_SDM1FINALOUT      => open                                     ,
      GTYE4_COMMON_SDM1TESTDATA      => open                                     ,
      GTYE4_COMMON_UBDADDR           => open                                     ,
      GTYE4_COMMON_UBDEN             => open                                     ,
      GTYE4_COMMON_UBDI              => open                                     ,
      GTYE4_COMMON_UBDWE             => open                                     ,
      GTYE4_COMMON_UBMDMTDO          => open                                     ,
      GTYE4_COMMON_UBRSVDOUT         => open                                     ,
      GTYE4_COMMON_UBTXUART          => open                                  
    );
    master_mgt_to_common_qpll0reset_common(i) <= master_mgt_to_common_qpll0reset(c_MASTER_PLL_RESET_CHANNELS(i));
  
  end generate gen_master_quads;
	
  gen_master_channel : for i in c_MASTER_NUMBER_CHANNELS-1 downto 0 generate
  
    -- Master transceiver user clock network
	-- Not sharing BUF_GT for this implementation
    cmp_master_mgt_user_clock : mgt_user_clock
      generic map(
	      g_NUMBER_CHANNELS               => 1
	  )
      port map(
          -- User clocks                                                       
          txusrclk_o(0)                      => master_clk_stat(i).txusrclk,
          rxusrclk_o(0)                      => master_clk_stat(i).rxusrclk,
    
          --! User clock network		
          mgt_txoutclk_i(0)                  => master_clk_ctrl(i).txoutclk,
          mgt_rxoutclk_i(0)                  => master_clk_ctrl(i).rxoutclk
	  );
	  
    -- Master Transceiver MGT	  
    gen_master_10G: if c_DATARATE=2 generate -- 10G  
    cmp_gtye4_master_timing : gtye4_master_timing_10g
      port map(
        -- Directly connected to top-level
        gtwiz_reset_clk_freerun_in(0)         => clk_sys                                                            ,  
        gtwiz_reset_all_in                    => master_mgt_ctrl(i).gtwiz_reset_all_in                              , 
        gtwiz_reset_tx_pll_and_datapath_in    => master_mgt_ctrl(i).gtwiz_reset_tx_pll_and_datapath_in              , 
        gtwiz_reset_rx_pll_and_datapath_in    => master_mgt_ctrl(i).gtwiz_reset_rx_pll_and_datapath_in              , 	  
        gtwiz_reset_tx_datapath_in            => master_mgt_ctrl(i).gtwiz_reset_tx_datapath_in                      , 
        gtwiz_reset_rx_datapath_in            => master_mgt_ctrl(i).gtwiz_reset_rx_datapath_in                      , 
        gtwiz_reset_qpll0lock_in(0)           => master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(i))          ,
        gtwiz_reset_qpll0reset_out(0)         => master_mgt_to_common_qpll0reset(i)                                 ,
        qpll0clk_in(0)                        => master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(i))        ,
        qpll0refclk_in(0)                     => master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(i))     ,
        qpll1clk_in(0)                        => master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(i))        ,
        qpll1refclk_in(0)                     => master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(i))     ,
    
        -- User_clocking
        rxusrclk_in(0)                        => master_clk_stat(i).rxusrclk                                        ,
        rxusrclk2_in(0)                       => master_clk_stat(i).rxusrclk                                        ,
        txusrclk_in(0)                        => master_clk_stat(i).txusrclk                                        ,
        txusrclk2_in(0)                       => master_clk_stat(i).txusrclk                                        ,
        rxoutclk_out(0)                       => master_clk_ctrl(i).rxoutclk                                        ,
        txoutclk_out(0)                       => master_clk_ctrl(i).txoutclk                                        ,

        -- Channel                                                                                                  
        gtwiz_userclk_tx_active_in            => master_mgt_ctrl(i).gtwiz_userclk_tx_active_in                      ,    
        gtwiz_userclk_rx_active_in            => master_mgt_ctrl(i).gtwiz_userclk_rx_active_in                      ,
        gtwiz_buffbypass_rx_reset_in          => master_mgt_ctrl(i).gtwiz_buffbypass_rx_reset_in                    ,
        gtwiz_buffbypass_rx_start_user_in     => master_mgt_ctrl(i).gtwiz_buffbypass_rx_start_user_in               ,
        gtwiz_buffbypass_rx_done_out          => master_mgt_stat(i).gtwiz_buffbypass_rx_done_out                    , 
        gtwiz_buffbypass_rx_error_out         => master_mgt_stat(i).gtwiz_buffbypass_rx_error_out                   , 
        gtwiz_reset_rx_cdr_stable_out         => master_mgt_stat(i).gtwiz_reset_rx_cdr_stable_out                   , 
        gtwiz_reset_tx_done_out               => master_mgt_stat(i).gtwiz_reset_tx_done_out                         , 
        gtwiz_reset_rx_done_out               => master_mgt_stat(i).gtwiz_reset_rx_done_out                         ,  
        loopback_in                           => master_mgt_ctrl(i).loopback_in                                     , 
        rxdfeagcovrden_in                     => master_mgt_ctrl(i).rxdfeagcovrden_in                               ,
        rxdfelfovrden_in                      => master_mgt_ctrl(i).rxdfelfovrden_in                                ,  
        rxdfelpmreset_in                      => master_mgt_ctrl(i).rxdfelpmreset_in                                ,  
        rxdfeutovrden_in                      => master_mgt_ctrl(i).rxdfeutovrden_in                                ,  
        rxdfevpovrden_in                      => master_mgt_ctrl(i).rxdfevpovrden_in                                ,  
        rxlpmen_in                            => master_mgt_ctrl(i).rxlpmen_in                                      ,        
        rxosovrden_in                         => master_mgt_ctrl(i).rxosovrden_in                                   ,
        rxlpmgcovrden_in                      => master_mgt_ctrl(i).rxlpmgcovrden_in                                , 
        rxlpmhfovrden_in                      => master_mgt_ctrl(i).rxlpmhfovrden_in                                , 
        rxlpmlfklovrden_in                    => master_mgt_ctrl(i).rxlpmlfklovrden_in                              , 
        rxlpmosovrden_in                      => master_mgt_ctrl(i).rxlpmosovrden_in                                , 
        rxslide_in                            => master_mgt_ctrl(i).rxslide_in                                      , 
        dmonitorclk_in                        => master_mgt_ctrl(i).dmonitorclk_in                                  ,       
        drpaddr_in                            => master_mgt_ctrl(i).drpaddr_in                                      ,  
        drpclk_in                             => master_mgt_ctrl(i).drpclk_in                                       ,  
        drpdi_in                              => master_mgt_ctrl(i).drpdi_in                                        ,  
        drpen_in                              => master_mgt_ctrl(i).drpen_in                                        ,  
        drpwe_in                              => master_mgt_ctrl(i).drpwe_in                                        ,  
        rxpolarity_in                         => master_mgt_ctrl(i).rxpolarity_in                                   , 
        rxprbscntreset_in                     => master_mgt_ctrl(i).rxprbscntreset_in                               , 
        rxprbssel_in                          => master_mgt_ctrl(i).rxprbssel_in                                    , 
        txpippmen_in                          => master_mgt_ctrl(i).txpippmen_in                                    , 
        txpippmovrden_in                      => master_mgt_ctrl(i).txpippmovrden_in                                , 
        txpippmpd_in                          => master_mgt_ctrl(i).txpippmpd_in                                    , 
        txpippmsel_in                         => master_mgt_ctrl(i).txpippmsel_in                                   , 
        txpippmstepsize_in                    => master_mgt_ctrl(i).txpippmstepsize_in                              ,                                
        txpolarity_in                         => master_mgt_ctrl(i).txpolarity_in                                   , 
        txprbsforceerr_in                     => master_mgt_ctrl(i).txprbsforceerr_in                               , 
        txprbssel_in                          => master_mgt_ctrl(i).txprbssel_in                                    ,                                 
        dmonitorout_out                       => master_mgt_stat(i).dmonitorout_out                                 ,                                   
        drpdo_out                             => master_mgt_stat(i).drpdo_out                                       ,  
        drprdy_out                            => master_mgt_stat(i).drprdy_out                                      ,  
        rxprbserr_out                         => master_mgt_stat(i).rxprbserr_out                                   ,  
        rxprbslocked_out                      => master_mgt_stat(i).rxprbslocked_out                                ,  
        txbufstatus_out                       => master_mgt_stat(i).txbufstatus_out                                 ,  
        txpmaresetdone_out                    => master_mgt_stat(i).txpmaresetdone_out                              , 
        rxpmaresetdone_out                    => master_mgt_stat(i).rxpmaresetdone_out                              , 
        gtpowergood_out                       => master_mgt_stat(i).gtpowergood_out                                 ,               	  
        gtwiz_userdata_tx_in                  => master_mgt_ctrl(i).txdata_in                                       , 
        gtwiz_userdata_rx_out                 => master_mgt_stat(i).rxdata_out                                      , 
        gtyrxn_in(0)                          => master_rx_n_i(i)                                                   , 
        gtyrxp_in(0)                          => master_rx_p_i(i)                                                   , 
        gtytxn_out(0)                         => master_tx_n_o(i)                                                   , 
        gtytxp_out(0)                         => master_tx_p_o(i)                  
      );	
    end generate gen_master_10G;		
	
    -- Master Transceiver MGT	  
    gen_master_5G: if c_DATARATE=1 generate -- 5G
    cmp_gtye4_master_timing : gtye4_master_timing_5g
      port map(
        -- Directly connected to top-level
        gtwiz_reset_clk_freerun_in(0)         => clk_sys                                                            ,  
        gtwiz_reset_all_in                    => master_mgt_ctrl(i).gtwiz_reset_all_in                              , 
        gtwiz_reset_tx_pll_and_datapath_in    => master_mgt_ctrl(i).gtwiz_reset_tx_pll_and_datapath_in              , 
        gtwiz_reset_rx_pll_and_datapath_in    => master_mgt_ctrl(i).gtwiz_reset_rx_pll_and_datapath_in              , 	  
        gtwiz_reset_tx_datapath_in            => master_mgt_ctrl(i).gtwiz_reset_tx_datapath_in                      , 
        gtwiz_reset_rx_datapath_in            => master_mgt_ctrl(i).gtwiz_reset_rx_datapath_in                      , 
        gtwiz_reset_qpll0lock_in(0)           => master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(i))          ,
        gtwiz_reset_qpll0reset_out(0)         => master_mgt_to_common_qpll0reset(i)                                 ,
        qpll0clk_in(0)                        => master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(i))        ,
        qpll0refclk_in(0)                     => master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(i))     ,
        qpll1clk_in(0)                        => master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(i))        ,
        qpll1refclk_in(0)                     => master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(i))     ,
    
        -- User_clocking
        rxusrclk_in(0)                        => master_clk_stat(i).rxusrclk                                        ,
        rxusrclk2_in(0)                       => master_clk_stat(i).rxusrclk                                        ,
        txusrclk_in(0)                        => master_clk_stat(i).txusrclk                                        ,
        txusrclk2_in(0)                       => master_clk_stat(i).txusrclk                                        ,
        rxoutclk_out(0)                       => master_clk_ctrl(i).rxoutclk                                        ,
        txoutclk_out(0)                       => master_clk_ctrl(i).txoutclk                                        ,

        -- Channel                                                                                                  
        gtwiz_userclk_tx_active_in            => master_mgt_ctrl(i).gtwiz_userclk_tx_active_in                      ,    
        gtwiz_userclk_rx_active_in            => master_mgt_ctrl(i).gtwiz_userclk_rx_active_in                      ,
        gtwiz_buffbypass_rx_reset_in          => master_mgt_ctrl(i).gtwiz_buffbypass_rx_reset_in                    ,
        gtwiz_buffbypass_rx_start_user_in     => master_mgt_ctrl(i).gtwiz_buffbypass_rx_start_user_in               ,
        gtwiz_buffbypass_rx_done_out          => master_mgt_stat(i).gtwiz_buffbypass_rx_done_out                    , 
        gtwiz_buffbypass_rx_error_out         => master_mgt_stat(i).gtwiz_buffbypass_rx_error_out                   , 
        gtwiz_reset_rx_cdr_stable_out         => master_mgt_stat(i).gtwiz_reset_rx_cdr_stable_out                   , 
        gtwiz_reset_tx_done_out               => master_mgt_stat(i).gtwiz_reset_tx_done_out                         , 
        gtwiz_reset_rx_done_out               => master_mgt_stat(i).gtwiz_reset_rx_done_out                         ,  
        loopback_in                           => master_mgt_ctrl(i).loopback_in                                     , 
        rxdfeagcovrden_in                     => master_mgt_ctrl(i).rxdfeagcovrden_in                               ,
        rxdfelfovrden_in                      => master_mgt_ctrl(i).rxdfelfovrden_in                                ,  
        rxdfelpmreset_in                      => master_mgt_ctrl(i).rxdfelpmreset_in                                ,  
        rxdfeutovrden_in                      => master_mgt_ctrl(i).rxdfeutovrden_in                                ,  
        rxdfevpovrden_in                      => master_mgt_ctrl(i).rxdfevpovrden_in                                ,  
        rxlpmen_in                            => master_mgt_ctrl(i).rxlpmen_in                                      ,        
        rxosovrden_in                         => master_mgt_ctrl(i).rxosovrden_in                                   ,
        rxlpmgcovrden_in                      => master_mgt_ctrl(i).rxlpmgcovrden_in                                , 
        rxlpmhfovrden_in                      => master_mgt_ctrl(i).rxlpmhfovrden_in                                , 
        rxlpmlfklovrden_in                    => master_mgt_ctrl(i).rxlpmlfklovrden_in                              , 
        rxlpmosovrden_in                      => master_mgt_ctrl(i).rxlpmosovrden_in                                , 
        rxslide_in                            => master_mgt_ctrl(i).rxslide_in                                      , 
        dmonitorclk_in                        => master_mgt_ctrl(i).dmonitorclk_in                                  ,       
        drpaddr_in                            => master_mgt_ctrl(i).drpaddr_in                                      ,  
        drpclk_in                             => master_mgt_ctrl(i).drpclk_in                                       ,  
        drpdi_in                              => master_mgt_ctrl(i).drpdi_in                                        ,  
        drpen_in                              => master_mgt_ctrl(i).drpen_in                                        ,  
        drpwe_in                              => master_mgt_ctrl(i).drpwe_in                                        ,  
        rxpolarity_in                         => master_mgt_ctrl(i).rxpolarity_in                                   , 
        rxprbscntreset_in                     => master_mgt_ctrl(i).rxprbscntreset_in                               , 
        rxprbssel_in                          => master_mgt_ctrl(i).rxprbssel_in                                    , 
        txpippmen_in                          => master_mgt_ctrl(i).txpippmen_in                                    , 
        txpippmovrden_in                      => master_mgt_ctrl(i).txpippmovrden_in                                , 
        txpippmpd_in                          => master_mgt_ctrl(i).txpippmpd_in                                    , 
        txpippmsel_in                         => master_mgt_ctrl(i).txpippmsel_in                                   , 
        txpippmstepsize_in                    => master_mgt_ctrl(i).txpippmstepsize_in                              ,                                
        txpolarity_in                         => master_mgt_ctrl(i).txpolarity_in                                   , 
        txprbsforceerr_in                     => master_mgt_ctrl(i).txprbsforceerr_in                               , 
        txprbssel_in                          => master_mgt_ctrl(i).txprbssel_in                                    ,                                 
        dmonitorout_out                       => master_mgt_stat(i).dmonitorout_out                                 ,                                   
        drpdo_out                             => master_mgt_stat(i).drpdo_out                                       ,  
        drprdy_out                            => master_mgt_stat(i).drprdy_out                                      ,  
        rxprbserr_out                         => master_mgt_stat(i).rxprbserr_out                                   ,  
        rxprbslocked_out                      => master_mgt_stat(i).rxprbslocked_out                                ,  
        txbufstatus_out                       => master_mgt_stat(i).txbufstatus_out                                 ,  
        txpmaresetdone_out                    => master_mgt_stat(i).txpmaresetdone_out                              , 
        rxpmaresetdone_out                    => master_mgt_stat(i).rxpmaresetdone_out                              , 
        gtpowergood_out                       => master_mgt_stat(i).gtpowergood_out                                 ,               	  
        gtwiz_userdata_tx_in                  => master_mgt_ctrl(i).txdata_in(15 downto 0)                          , -- only 16-bits connected to 5G version 
        gtwiz_userdata_rx_out                 => master_mgt_stat(i).rxdata_out(15 downto 0)                         , -- only 16-bits connected to 5G version 
        gtyrxn_in(0)                          => master_rx_n_i(i)                                                   , 
        gtyrxp_in(0)                          => master_rx_p_i(i)                                                   , 
        gtytxn_out(0)                         => master_tx_n_o(i)                                                   , 
        gtytxp_out(0)                         => master_tx_p_o(i)                  
      );	
    end generate gen_master_5G;
	
    master_mgt_stat(i).txplllock_out(0) <= master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(i));
    master_mgt_stat(i).rxplllock_out(0) <= master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(i));
    
    -- Master cores
    cmp_master : tclink_lpgbt
        generic map(
    	  g_MASTER_NSLAVE               => True,
          g_QUAD_LEADER                 => c_MASTER_RESET_CHANNEL(i),	     	  
          g_MASTER_TCLINK_TESTER_ENABLE => True, -- saves logic if False, recommended to use False for a final user design
          g_PROTOCOL                    => c_PROTOCOL
    	)
        port map(
            -----------------------------------------------------------------
            --------------------- System clock / resets ---------------------
            -----------------------------------------------------------------
            -- System clock
            clk_sys_i                   => clk_sys                        ,
    		
            -----------------------------------------------------------------
            ------------------ Core control/status ------------------------
            -----------------------------------------------------------------
    		  -- Interface synchronous to clk_sys_i
            core_ctrl_i                 => master_core_ctrl(i)            ,
            core_stat_o                 => master_core_stat(i)            ,

            -- TCLink (not relevant for slave)	                          
            master_tclink_clk_offset_i  => master_clk_offset              ,
            master_tclink_ctrl_i        => master_tclink_ctrl(i)          ,
            master_tclink_stat_o        => master_tclink_stat(i)          ,
    
            -----------------------------------------------------------------
            ------------------ Slave recovered clock ----------------------
            -----------------------------------------------------------------
            slave_clk40_oddr_o          => open,
    
            -----------------------------------------------------------------
            ------------------------ User data ----------------------------
            -----------------------------------------------------------------
            tx_clk40_i          => clk40                                  ,
            tx_data_i           => prbsgen_master_frame(i)                ,
            tx_clk40_stable_i   => '1'                                    ,

            rx_clk40_i          => clk40,                                 
            rx_clk40_stable_i   => '1'                                    ,
            rx_data_o           => prbschk_master_frame(i)                ,
	  	
            -----------------------------------------------------------------
            ------------------------- MMCM ----------------------------------
            -----------------------------------------------------------------
            mmcm_locked_i => master_clk_offset_locked,

            -----------------------------------------------------------------
            ------------------------ MGT  ---------------------------------
            -----------------------------------------------------------------
            mgt_txclk_i          => master_clk_stat(i).txusrclk           ,
            mgt_rxclk_i          => master_clk_stat(i).rxusrclk           ,
            mgt_ctrl_o           => master_mgt_ctrl(i)                    ,
            mgt_stat_i           => master_mgt_stat(i)
    	);
    master_core_ctrl(i).mgt_reset_rx_pll_and_datapath <= '0';
    master_core_ctrl(i).reset_all <= master_core_ctrl(i).mgt_reset_tx_datapath;
    ------------------------------------------------------------  
  end generate gen_master_channel;
  
  gen_master_user : for i in c_MASTER_NUMBER_CHANNELS-1 downto 0 generate
    --------------------- PRBS generator Tx ---------------------
    not_master_core_stat_tx_user_ready(i)  <= not master_core_stat(i).tx_user_data_ready;  
    prbsgen_master_reset_bit_synchronizer  : bit_synchronizer
      port map(
        clk_in => clk40                               ,
        i_in   => not_master_core_stat_tx_user_ready(i),
        o_out  => prbsgen_master_reset(i)
    );   
    
    prbsgen_master_load(i) <=     prbsgen_master_reset(i) when rising_edge(clk40);
    prbsgen_master_en(i)   <= not prbsgen_master_reset(i) when rising_edge(clk40);
    cmp_master_prbs_gen : prbs_gen
      generic map(
        g_PARAL_FACTOR    => c_USER_TX_DATA_WIDTH,
        g_PRBS_POLYNOMIAL => c_PRBS_POLYNOMIAL
      )                                                           
      port map(                                                                          
        clk_i            => clk40                             ,
        en_i             => prbsgen_master_en(i)              ,
        reset_i          => prbsgen_master_reset(i)           ,
        seed_i           => c_PRBS_SEED                       ,
        load_i           => prbsgen_master_load(i)            ,
        data_o           => prbsgen_master_frame(i)           ,
        data_valid_o     => prbsgen_master_data_valid(i)
      );
    ------------------------------------------------------------
    
    --------------------- PRBS checker rx ---------------------
    not_master_core_stat_rx_user_ready(i)  <= not master_core_stat(i).rx_user_data_ready ;  
    prbschk_master_reset_bit_synchronizer  : bit_synchronizer
      port map(
        clk_in => clk40                                  ,
        i_in   => not_master_core_stat_rx_user_ready(i),
        o_out  => prbschk_master_reset(i)
    );   
    
    prbschk_master_en(i)   <= not prbschk_master_reset(i) when rising_edge(clk40);
    
    cmp_master_prbs_chk : prbs_chk
      generic map(
        g_GOOD_FRAME_TO_LOCK  => c_PRBS_GOOD_FRAME_TO_LOCK  ,
        g_BAD_FRAME_TO_UNLOCK => c_PRBS_BAD_FRAME_TO_UNLOCK ,
        g_PARAL_FACTOR        => c_USER_RX_DATA_WIDTH         ,
        g_PRBS_POLYNOMIAL     => c_PRBS_POLYNOMIAL
      )                                                                
      port map(                                                                          
        clk_i            => clk40                   ,
        reset_i          => prbschk_master_reset(i) ,
        en_i             => prbschk_master_en(i)    ,
        data_i           => prbschk_master_frame(i) ,
        data_o           => prbschk_master_gen(i)   ,
        error_o          => prbschk_master_error(i) ,
        locked_o         => prbschk_master_locked(i)
      ); 
    
    rx_master_prbs_locked_bit_synchronizer  : bit_synchronizer
      port map(
        clk_in => clk_sys                  ,
        i_in   => prbschk_master_locked(i) ,
        o_out  => prbschk_master_locked_sync(i)
    ); 
    ------------------------------------------------------------
    
    ------------------- Master VIO -------------------
    cmp_master_vio_control : vio_control_vcu118
      port map(
        clk            => clk_sys                                                    ,
        probe_in0(0)   => master_core_stat(i).rx_frame_locked                        ,         
        probe_in1(0)   => prbschk_master_locked_sync(i)                              ,         
        probe_in2(0)   => master_sfp_tx_fault_sync(i)                                ,
        probe_in3(0)   => master_core_stat(i).mgt_txpll_lock                         , 
        probe_in4(0)   => master_core_stat(i).mgt_rxpll_lock                         , 
        probe_in5(0)   => master_core_stat(i).mgt_buffbypass_rx_done                 , 
        probe_in6(0)   => master_core_stat(i).mgt_buffbypass_rx_error                , 
        probe_in7(0)   => master_core_stat(i).mgt_powergood                          ,              
        probe_in8(0)   => master_core_stat(i).mgt_reset_tx_done                      , 
        probe_in9(0)   => master_core_stat(i).mgt_reset_rx_done                      , 
        probe_in10(0)  => master_core_stat(i).mgt_txpmaresetdone                     , 
        probe_in11(0)  => master_core_stat(i).mgt_rxpmaresetdone                     , 
        probe_in12(0)  => master_core_stat(i).mgt_tx_ready                           , 
        probe_in13(0)  => master_core_stat(i).mgt_rx_ready                           , 
        probe_in14(0)  => master_core_stat(i).mgt_rxprbserr                          , 
        probe_in15(0)  => master_core_stat(i).mgt_rxprbslocked                       , 
        probe_in16(0)  => master_core_stat(i).mgt_drprdy_latched                     , 
        probe_in17     => master_core_stat(i).mgt_drpdo                              , 
        probe_in18     => master_core_stat(i).mgt_hptd_tx_pi_phase                   , 
        probe_in19     => master_core_stat(i).mgt_hptd_tx_fifo_fill_pd               ,
        probe_in20(0)  => master_core_stat(i).mgt_hptd_ps_done_latched               ,
        probe_in21     => master_core_stat(i).mgt_rxeq_dmonitor                      ,
        probe_in22(0)  => master_sfp_los_sync(i)                                     ,
        probe_in23(0)  => master_sfp_mod_abs_sync(i)                                 ,
        probe_in24     => master_tclink_stat(i).tclink_phase_detector                ,
        probe_in25     => master_tclink_stat(i).tclink_error_controller              ,
        probe_in26     => master_tclink_stat(i).tclink_phase_acc                     ,
        probe_in27(0)  => master_tclink_stat(i).tclink_operation_error               ,
        probe_in28     => master_tclink_stat(i).tclink_debug_tester_data_read        ,
	    probe_in29(0)  => master_clk_offset_locked                                   ,
	    probe_in30(0)  => master_core_stat(i).rx_fec_corrected_latched               ,
	    probe_in31     => master_core_stat(i).phase_cdc40_rx                         ,
	    probe_in32     => master_core_stat(i).phase_cdc40_tx                         ,		
        probe_in33(0)  => master_core_stat(i).channel_controller_running             ,
        probe_in34     => master_core_stat(i).channel_controller_state               ,
        probe_in35(0)  => master_core_stat(i).channel_ready                          ,
		probe_in36(0)  => master_tclink_stat(i).tclink_loop_closed                   ,
		probe_in37(0)  => master_core_stat(i).rx_user_data_ready                     ,
		probe_in38(0)  => master_core_stat(i).rx_data_not_idle                       ,
		probe_in39(0)  => master_core_stat(i).cdc_40_rx_ready                        ,
		probe_in40(0)  => master_core_stat(i).tx_user_data_ready                     ,
		probe_in41(0)  => master_core_stat(i).cdc_40_tx_ready                        ,  
        probe_out0(0)  => master_core_ctrl(i).rx_fec_corrected_clear                 ,
        probe_out1(0)  => master_clk_offset_resetn_dummy(i)                          , 
        probe_out2(0)  => master_core_ctrl(i).mgt_reset_all                          ,
        probe_out3(0)  => master_core_ctrl(i).mgt_reset_tx_pll_and_datapath          ,
        probe_out4(0)  => master_core_ctrl(i).mgt_reset_tx_datapath                  ,
        probe_out5(0)  => open                                                       ,
        probe_out6(0)  => master_core_ctrl(i).mgt_reset_rx_datapath                  ,
        probe_out7(0)  => master_core_ctrl(i).mgt_txpolarity                         ,
        probe_out8(0)  => master_core_ctrl(i).mgt_rxpolarity                         ,
        probe_out9     => master_core_ctrl(i).mgt_loopback                           ,
        probe_out10(0) => master_core_ctrl(i).mgt_txprbsforceerr                     ,
        probe_out11    => master_core_ctrl(i).mgt_txprbssel                          ,
        probe_out12(0) => master_core_ctrl(i).mgt_rxprbscntreset                     ,
        probe_out13    => master_core_ctrl(i).mgt_rxprbssel                          ,
        probe_out14(0) => master_core_ctrl(i).mgt_drpwe                              ,
        probe_out15(0) => master_core_ctrl(i).mgt_drpen                              ,
        probe_out16    => master_core_ctrl(i).mgt_drpaddr                            ,
        probe_out17    => master_core_ctrl(i).mgt_drpdi                              ,
        probe_out18    => open                                                       ,
        probe_out19    => master_core_ctrl(i).mgt_hptd_tx_pi_phase_calib             ,
        probe_out20(0) => master_core_ctrl(i).mgt_hptd_tx_ui_align_calib             ,
        probe_out21(0) => master_core_ctrl(i).mgt_hptd_ps_strobe                     ,
        probe_out22(0) => master_core_ctrl(i).mgt_hptd_ps_inc_ndec                   ,
        probe_out23    => master_core_ctrl(i).mgt_hptd_ps_phase_step                 ,
        probe_out24(0) => master_core_ctrl(i).mgt_rxeq_rxlpmgcovrden                 ,
        probe_out25(0) => master_core_ctrl(i).mgt_rxeq_rxlpmhfovrden                 ,
        probe_out26(0) => master_core_ctrl(i).mgt_rxeq_rxlpmlfklovrden               ,
        probe_out27(0) => master_core_ctrl(i).mgt_rxeq_rxlpmosovrden                 ,
        probe_out28(0) => master_sfp_rs0(i)                                          ,
        probe_out29(0) => master_sfp_rs1(i)                                          ,
        probe_out30(0) => master_tclink_ctrl(i).tclink_close_loop                    ,
        probe_out31    => master_tclink_ctrl(i).tclink_offset_error                  ,
        probe_out32    => master_tclink_ctrl(i).tclink_metastability_deglitch        ,
        probe_out33    => master_tclink_ctrl(i).tclink_phase_detector_navg           ,
        probe_out34    => master_tclink_ctrl(i).tclink_modulo_carrier_period         ,
        probe_out35    => master_tclink_ctrl(i).tclink_Aie                           ,
        probe_out36(0) => master_tclink_ctrl(i).tclink_Aie_enable                    ,
        probe_out37    => master_tclink_ctrl(i).tclink_Ape                           ,
        probe_out38    => master_tclink_ctrl(i).tclink_sigma_delta_clk_div           ,
        probe_out39(0) => master_tclink_ctrl(i).tclink_enable_mirror                 ,
        probe_out40    => master_tclink_ctrl(i).tclink_Adco                          ,
        probe_out41(0) => master_tclink_ctrl(i).tclink_debug_tester_enable_stimulis  ,
        probe_out42    => master_tclink_ctrl(i).tclink_debug_tester_fcw              ,
        probe_out43    => master_tclink_ctrl(i).tclink_debug_tester_nco_scale        ,
        probe_out44(0) => master_tclink_ctrl(i).tclink_debug_tester_enable_stock_out ,   
        probe_out45    => master_tclink_ctrl(i).tclink_debug_tester_addr_read        ,
        probe_out46(0) => master_sfp_tx_dis(i)                                       ,
        probe_out47    => master_tclink_ctrl(i).tclink_master_rx_ui_period           ,
	    probe_out48(0) => master_core_ctrl(i).mgt_rxeq_rxlpmen                       ,
	    probe_out49(0) => master_core_ctrl(i).mgt_rxeq_rxdfelfovrden                 ,  
	    probe_out50(0) => master_core_ctrl(i).mgt_rxeq_rxdfelpmreset                 ,  
	    probe_out51(0) => master_core_ctrl(i).mgt_rxeq_rxdfeutovrden                 ,  
	    probe_out52(0) => master_core_ctrl(i).mgt_rxeq_rxdfevpovrden                 ,  
	    probe_out53(0) => master_core_ctrl(i).mgt_rxeq_rxdfeagcovrden                ,  
	    probe_out54(0) => master_core_ctrl(i).mgt_rxeq_rxosovrden                    ,
	    probe_out55(0) => master_core_ctrl(i).phase_cdc40_rx_force                   ,  
	    probe_out56    => master_core_ctrl(i).phase_cdc40_rx_calib                   ,  
	    probe_out57(0) => master_core_ctrl(i).phase_cdc40_tx_force                   ,  
	    probe_out58    => master_core_ctrl(i).phase_cdc40_tx_calib                   ,
        probe_out59(0) => master_core_ctrl(i).channel_controller_reset,
        probe_out60(0) => master_core_ctrl(i).channel_controller_gentle,
        probe_out61(0) => master_core_ctrl(i).channel_controller_enable
      );
    ------------------------------------------------------------
    -- Signals below - encouraged to be set to static value for a final implementation			  										 		  
    --master_tclink_ctrl(i).tclink_metastability_deglitch <= x"0052"        ;
    --master_tclink_ctrl(i).tclink_phase_detector_navg    <= x"040"         ;
    --master_tclink_ctrl(i).tclink_modulo_carrier_period  <= x"00007ff48348";
    --master_tclink_ctrl(i).tclink_master_rx_ui_period    <= x"000003ffa41a";
    --master_tclink_ctrl(i).tclink_Aie                    <= x"0"           ;
    --master_tclink_ctrl(i).tclink_Aie_enable             <= '1'            ;
    --master_tclink_ctrl(i).tclink_Ape                    <= x"e"           ;
    --master_tclink_ctrl(i).tclink_sigma_delta_clk_div    <= x"0197"        ;
    --master_tclink_ctrl(i).tclink_enable_mirror          <= '1'            ;
    --master_tclink_ctrl(i).tclink_Adco                   <= x"0000000ffe90";
    
    master_sfp_tx_dis_o(i)   <= master_sfp_tx_dis(i);
    master_sfp_rs0_o(i)      <= master_sfp_rs0(i)   ;
    master_sfp_rs1_o(i)      <= master_sfp_rs1(i)   ;
          
    sfp_tx_fault_bit_synchronizer : bit_synchronizer
      port map(
        clk_in => clk_sys                  ,
        i_in   => master_sfp_tx_fault_i(i) ,
        o_out  => master_sfp_tx_fault_sync(i)
    );  
    
    sfp_los_bit_synchronizer : bit_synchronizer
      port map(
        clk_in => clk_sys             ,
        i_in   => master_sfp_los_i(i) ,
        o_out  => master_sfp_los_sync(i)
    );  
    
    sfp_mod_abs_bit_synchronizer : bit_synchronizer
      port map(
        clk_in => clk_sys                 ,
        i_in   => master_sfp_mod_abs_i(i) ,
        o_out  => master_sfp_mod_abs_sync(i)
    );   
    -------------------------------------------------------------------------------------------------------

  end generate gen_master_user;
  
 ---------------------------------- Slave ----------------------------------
 --
 -- Only one slave supported per quad
 --
 ---------- Slave ----------
 -- Recovered clock
 -- This MMCM is used simply to eliminate very high-frequency jitter from the fabric which can suffer from aliasing effect by external PLL divider
 -- There is a full study available in design_choice_documents/tclink_slave_rx_recovered_clock.pdf on its reason to be
  cmp_mmcme4_slave : mmcme4_slave
  port map
   (-- Clock in ports
    -- Clock out ports
    clk_out1          => slave_rxusrclk_mmcm,
    -- Status and control signals
    resetn            => slave_core_stat.rx_frame_locked,
    locked            => slave_mmcm_locked,
    clk_in1           => slave_clk_stat.rxusrclk
   );
  
  slave_mmcm_locked_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_sys                 ,
      i_in   => slave_mmcm_locked       ,
      o_out  => slave_mmcm_locked_sync
  );   
	
 slave_clk40_oddr_r <= 	slave_clk40_oddr_in when rising_edge(slave_rxusrclk_mmcm);
 cmp_slave_clk40_ODDRE1 : ODDRE1 
   generic map(
     IS_C_INVERTED  => '0',
     IS_D1_INVERTED => '0',
     IS_D2_INVERTED => '0',
     SRVAL          => '0'
   )
   port map( 
     Q  => slave_clk40_oddr_out,
     C  => slave_rxusrclk_mmcm,
     D1 => slave_clk40_oddr_r ,
     D2 => slave_clk40_oddr_r ,
     SR => '0'
   );  
 cmp_slave_clk40_OBUFDS : OBUFDS
   port map( 
     O  => slave_clk40_p_o,
     OB => slave_clk40_n_o,
     I  => slave_clk40_oddr_out
   );
 
 -- Transceiver input clock buffers
 cmp_slave_txrefclk_IBUFDS_GTE4 : IBUFDS_GTE4
   generic map( 
     REFCLK_EN_TX_PATH  => '0' ,
     REFCLK_HROW_CK_SEL => "00",
     REFCLK_ICNTL_RX    => "00"
   )
   port map( 
     O     => slave_txrefclk,
     ODIV2 => open              ,
     CEB   => '0'               ,
     I     => slave_txrefclk_p_i,
     IB    => slave_txrefclk_n_i
 );
 
 cmp_slave_rxrefclk_IBUFDS_GTE4 : IBUFDS_GTE4
   generic map( 
     REFCLK_EN_TX_PATH  => '0' ,
     REFCLK_HROW_CK_SEL => "00",
     REFCLK_ICNTL_RX    => "00"
   )
   port map( 
     O     => slave_rxrefclk,
     ODIV2 => open              ,
     CEB   => '0'               ,
     I     => slave_rxrefclk_p_i,
     IB    => slave_rxrefclk_n_i
    );
 
  -- Slave transceiver user clock network 
  cmp_slave_mgt_user_clock : mgt_user_clock
    generic map(
        g_NUMBER_CHANNELS               => 1
    )
    port map(
        -- User clocks                                                       
        txusrclk_o(0)                      => slave_clk_stat.txusrclk,
        rxusrclk_o(0)                      => slave_clk_stat.rxusrclk,
  
        --! User clock network		
        mgt_txoutclk_i(0)                  => slave_clk_ctrl.txoutclk,
        mgt_rxoutclk_i(0)                  => slave_clk_ctrl.rxoutclk
    );
	  
 -- Slave Transceiver MGT
 gen_slave_10G: if c_DATARATE=2 generate -- 10G 
 cmp_gtye4_slave_timing : gtye4_slave_timing_10g
   port map(
     -- Directly connected to top-level
     gtwiz_reset_clk_freerun_in(0)         => clk_sys                                          ,  
     gtwiz_reset_all_in                    => slave_mgt_ctrl.gtwiz_reset_all_in                 , 
     gtwiz_reset_tx_pll_and_datapath_in    => slave_mgt_ctrl.gtwiz_reset_tx_pll_and_datapath_in ,
     gtwiz_reset_rx_pll_and_datapath_in    => slave_mgt_ctrl.gtwiz_reset_rx_pll_and_datapath_in ,  -- diff master		 
     gtwiz_reset_tx_datapath_in            => slave_mgt_ctrl.gtwiz_reset_tx_datapath_in         , 
     gtwiz_reset_rx_datapath_in            => slave_mgt_ctrl.gtwiz_reset_rx_datapath_in         ,
     gtrefclk00_in(0)                      => slave_txrefclk                                   ,  -- diff master 
     gtrefclk01_in(0)                      => slave_rxrefclk                                   ,  -- diff master 	  
     qpll0outclk_out                       => open                                             ,  -- diff master 
     qpll0outrefclk_out                    => open                                             ,  -- diff master 
     qpll1outclk_out                       => open                                             ,  -- diff master 
     qpll1outrefclk_out                    => open                                             ,  -- diff master 
 
     -- User_clocking
     rxusrclk_in(0)                        => slave_clk_stat.rxusrclk                          ,
     rxusrclk2_in(0)                       => slave_clk_stat.rxusrclk                          ,
     txusrclk_in(0)                        => slave_clk_stat.txusrclk                          ,
     txusrclk2_in(0)                       => slave_clk_stat.txusrclk                          ,
     rxoutclk_out(0)                       => slave_clk_ctrl.rxoutclk                          ,
     txoutclk_out(0)                       => slave_clk_ctrl.txoutclk                          ,

     -- Channel
     gtwiz_userclk_tx_active_in            => slave_mgt_ctrl.gtwiz_userclk_tx_active_in        ,    
     gtwiz_userclk_rx_active_in            => slave_mgt_ctrl.gtwiz_userclk_rx_active_in        ,
     gtwiz_buffbypass_rx_reset_in          => slave_mgt_ctrl.gtwiz_buffbypass_rx_reset_in      ,
     gtwiz_buffbypass_rx_start_user_in     => slave_mgt_ctrl.gtwiz_buffbypass_rx_start_user_in ,
     gtwiz_buffbypass_rx_done_out          => slave_mgt_stat.gtwiz_buffbypass_rx_done_out      , 
     gtwiz_buffbypass_rx_error_out         => slave_mgt_stat.gtwiz_buffbypass_rx_error_out     , 
     gtwiz_reset_rx_cdr_stable_out         => slave_mgt_stat.gtwiz_reset_rx_cdr_stable_out     , 
     gtwiz_reset_tx_done_out               => slave_mgt_stat.gtwiz_reset_tx_done_out           , 
     gtwiz_reset_rx_done_out               => slave_mgt_stat.gtwiz_reset_rx_done_out           , 
     qpll0lock_out                         => slave_mgt_stat.txplllock_out    	               ,
     qpll1lock_out                         => slave_mgt_stat.rxplllock_out      	           ,  -- diff master 
     loopback_in                           => slave_mgt_ctrl.loopback_in                       , 
     rxdfeagcovrden_in                     => slave_mgt_ctrl.rxdfeagcovrden_in                 ,
     rxdfelfovrden_in                      => slave_mgt_ctrl.rxdfelfovrden_in                  ,  
     rxdfelpmreset_in                      => slave_mgt_ctrl.rxdfelpmreset_in                  ,  
     rxdfeutovrden_in                      => slave_mgt_ctrl.rxdfeutovrden_in                  ,  
     rxdfevpovrden_in                      => slave_mgt_ctrl.rxdfevpovrden_in                  ,  
     rxlpmen_in                            => slave_mgt_ctrl.rxlpmen_in                        ,        
     rxosovrden_in                         => slave_mgt_ctrl.rxosovrden_in                     ,
     rxlpmgcovrden_in                      => slave_mgt_ctrl.rxlpmgcovrden_in                  , 
     rxlpmhfovrden_in                      => slave_mgt_ctrl.rxlpmhfovrden_in                  , 
     rxlpmlfklovrden_in                    => slave_mgt_ctrl.rxlpmlfklovrden_in                , 
     rxlpmosovrden_in                      => slave_mgt_ctrl.rxlpmosovrden_in                  , 
     rxslide_in                            => slave_mgt_ctrl.rxslide_in                        ,                    
     dmonitorclk_in                        => slave_mgt_ctrl.dmonitorclk_in                    ,       
     drpaddr_in                            => slave_mgt_ctrl.drpaddr_in                        ,  
     drpclk_in                             => slave_mgt_ctrl.drpclk_in                         ,  
     drpdi_in                              => slave_mgt_ctrl.drpdi_in                          ,  
     drpen_in                              => slave_mgt_ctrl.drpen_in                          ,  
     drpwe_in                              => slave_mgt_ctrl.drpwe_in                          ,  
     rxpolarity_in                         => slave_mgt_ctrl.rxpolarity_in                     , 
     rxprbscntreset_in                     => slave_mgt_ctrl.rxprbscntreset_in                 , 
     rxprbssel_in                          => slave_mgt_ctrl.rxprbssel_in                      , 
     txpippmen_in                          => slave_mgt_ctrl.txpippmen_in                      , 
     txpippmovrden_in                      => slave_mgt_ctrl.txpippmovrden_in                  , 
     txpippmpd_in                          => slave_mgt_ctrl.txpippmpd_in                      , 
     txpippmsel_in                         => slave_mgt_ctrl.txpippmsel_in                     , 
     txpippmstepsize_in                    => slave_mgt_ctrl.txpippmstepsize_in                ,                                
     txpolarity_in                         => slave_mgt_ctrl.txpolarity_in                     , 
     txprbsforceerr_in                     => slave_mgt_ctrl.txprbsforceerr_in                 , 
     txprbssel_in                          => slave_mgt_ctrl.txprbssel_in                      ,                                 
     dmonitorout_out                       => slave_mgt_stat.dmonitorout_out                   ,                                   
     drpdo_out                             => slave_mgt_stat.drpdo_out                         ,  
     drprdy_out                            => slave_mgt_stat.drprdy_out                        ,  
     rxprbserr_out                         => slave_mgt_stat.rxprbserr_out                     ,  
     rxprbslocked_out                      => slave_mgt_stat.rxprbslocked_out                  ,  
     txbufstatus_out                       => slave_mgt_stat.txbufstatus_out                   , 
     txpmaresetdone_out                    => slave_mgt_stat.txpmaresetdone_out                , 
     rxpmaresetdone_out                    => slave_mgt_stat.rxpmaresetdone_out                ,
     gtpowergood_out                       => slave_mgt_stat.gtpowergood_out                   ,  	 
     gtwiz_userdata_tx_in                  => slave_mgt_ctrl.txdata_in                         , 
     gtwiz_userdata_rx_out                 => slave_mgt_stat.rxdata_out                        , 
     gtyrxn_in(0)                          => slave_rx_n_i                                     , 
     gtyrxp_in(0)                          => slave_rx_p_i                                     , 
     gtytxn_out(0)                         => slave_tx_n_o                                     , 
     gtytxp_out(0)                         => slave_tx_p_o                     
   );	
 end generate gen_slave_10G;
 
 gen_slave_5G: if c_DATARATE=1 generate -- 5G 
 cmp_gtye4_slave_timing : gtye4_slave_timing_5g
   port map(
     -- Directly connected to top-level
     gtwiz_reset_clk_freerun_in(0)         => clk_sys                                          ,  
     gtwiz_reset_all_in                    => slave_mgt_ctrl.gtwiz_reset_all_in                 , 
     gtwiz_reset_tx_pll_and_datapath_in    => slave_mgt_ctrl.gtwiz_reset_tx_pll_and_datapath_in ,
     gtwiz_reset_rx_pll_and_datapath_in    => slave_mgt_ctrl.gtwiz_reset_rx_pll_and_datapath_in ,  -- diff master		 
     gtwiz_reset_tx_datapath_in            => slave_mgt_ctrl.gtwiz_reset_tx_datapath_in         , 
     gtwiz_reset_rx_datapath_in            => slave_mgt_ctrl.gtwiz_reset_rx_datapath_in         ,
     gtrefclk00_in(0)                      => slave_txrefclk                                   ,  -- diff master 
     gtrefclk01_in(0)                      => slave_rxrefclk                                   ,  -- diff master 	  
     qpll0outclk_out                       => open                                             ,  -- diff master 
     qpll0outrefclk_out                    => open                                             ,  -- diff master 
     qpll1outclk_out                       => open                                             ,  -- diff master 
     qpll1outrefclk_out                    => open                                             ,  -- diff master 
 
     -- User_clocking
     rxusrclk_in(0)                        => slave_clk_stat.rxusrclk                          ,
     rxusrclk2_in(0)                       => slave_clk_stat.rxusrclk                          ,
     txusrclk_in(0)                        => slave_clk_stat.txusrclk                          ,
     txusrclk2_in(0)                       => slave_clk_stat.txusrclk                          ,
     rxoutclk_out(0)                       => slave_clk_ctrl.rxoutclk                          ,
     txoutclk_out(0)                       => slave_clk_ctrl.txoutclk                          ,

     -- Channel
     gtwiz_userclk_tx_active_in            => slave_mgt_ctrl.gtwiz_userclk_tx_active_in        ,    
     gtwiz_userclk_rx_active_in            => slave_mgt_ctrl.gtwiz_userclk_rx_active_in        ,
     gtwiz_buffbypass_rx_reset_in          => slave_mgt_ctrl.gtwiz_buffbypass_rx_reset_in      ,
     gtwiz_buffbypass_rx_start_user_in     => slave_mgt_ctrl.gtwiz_buffbypass_rx_start_user_in ,
     gtwiz_buffbypass_rx_done_out          => slave_mgt_stat.gtwiz_buffbypass_rx_done_out      , 
     gtwiz_buffbypass_rx_error_out         => slave_mgt_stat.gtwiz_buffbypass_rx_error_out     , 
     gtwiz_reset_rx_cdr_stable_out         => slave_mgt_stat.gtwiz_reset_rx_cdr_stable_out     , 
     gtwiz_reset_tx_done_out               => slave_mgt_stat.gtwiz_reset_tx_done_out           , 
     gtwiz_reset_rx_done_out               => slave_mgt_stat.gtwiz_reset_rx_done_out           , 
     qpll0lock_out                         => slave_mgt_stat.txplllock_out    	               ,
     qpll1lock_out                         => slave_mgt_stat.rxplllock_out      	           ,  -- diff master 
     loopback_in                           => slave_mgt_ctrl.loopback_in                       , 
     rxdfeagcovrden_in                     => slave_mgt_ctrl.rxdfeagcovrden_in                 ,
     rxdfelfovrden_in                      => slave_mgt_ctrl.rxdfelfovrden_in                  ,  
     rxdfelpmreset_in                      => slave_mgt_ctrl.rxdfelpmreset_in                  ,  
     rxdfeutovrden_in                      => slave_mgt_ctrl.rxdfeutovrden_in                  ,  
     rxdfevpovrden_in                      => slave_mgt_ctrl.rxdfevpovrden_in                  ,  
     rxlpmen_in                            => slave_mgt_ctrl.rxlpmen_in                        ,        
     rxosovrden_in                         => slave_mgt_ctrl.rxosovrden_in                     ,
     rxlpmgcovrden_in                      => slave_mgt_ctrl.rxlpmgcovrden_in                  , 
     rxlpmhfovrden_in                      => slave_mgt_ctrl.rxlpmhfovrden_in                  , 
     rxlpmlfklovrden_in                    => slave_mgt_ctrl.rxlpmlfklovrden_in                , 
     rxlpmosovrden_in                      => slave_mgt_ctrl.rxlpmosovrden_in                  , 
     rxslide_in                            => slave_mgt_ctrl.rxslide_in                        ,                    
     dmonitorclk_in                        => slave_mgt_ctrl.dmonitorclk_in                    ,       
     drpaddr_in                            => slave_mgt_ctrl.drpaddr_in                        ,  
     drpclk_in                             => slave_mgt_ctrl.drpclk_in                         ,  
     drpdi_in                              => slave_mgt_ctrl.drpdi_in                          ,  
     drpen_in                              => slave_mgt_ctrl.drpen_in                          ,  
     drpwe_in                              => slave_mgt_ctrl.drpwe_in                          ,  
     rxpolarity_in                         => slave_mgt_ctrl.rxpolarity_in                     , 
     rxprbscntreset_in                     => slave_mgt_ctrl.rxprbscntreset_in                 , 
     rxprbssel_in                          => slave_mgt_ctrl.rxprbssel_in                      , 
     txpippmen_in                          => slave_mgt_ctrl.txpippmen_in                      , 
     txpippmovrden_in                      => slave_mgt_ctrl.txpippmovrden_in                  , 
     txpippmpd_in                          => slave_mgt_ctrl.txpippmpd_in                      , 
     txpippmsel_in                         => slave_mgt_ctrl.txpippmsel_in                     , 
     txpippmstepsize_in                    => slave_mgt_ctrl.txpippmstepsize_in                ,                                
     txpolarity_in                         => slave_mgt_ctrl.txpolarity_in                     , 
     txprbsforceerr_in                     => slave_mgt_ctrl.txprbsforceerr_in                 , 
     txprbssel_in                          => slave_mgt_ctrl.txprbssel_in                      ,                                 
     dmonitorout_out                       => slave_mgt_stat.dmonitorout_out                   ,                                   
     drpdo_out                             => slave_mgt_stat.drpdo_out                         ,  
     drprdy_out                            => slave_mgt_stat.drprdy_out                        ,  
     rxprbserr_out                         => slave_mgt_stat.rxprbserr_out                     ,  
     rxprbslocked_out                      => slave_mgt_stat.rxprbslocked_out                  ,  
     txbufstatus_out                       => slave_mgt_stat.txbufstatus_out                   , 
     txpmaresetdone_out                    => slave_mgt_stat.txpmaresetdone_out                , 
     rxpmaresetdone_out                    => slave_mgt_stat.rxpmaresetdone_out                ,
     gtpowergood_out                       => slave_mgt_stat.gtpowergood_out                   ,  	 
     gtwiz_userdata_tx_in                  => slave_mgt_ctrl.txdata_in(15 downto 0)            , -- only 16-bits connected to 5G version 
     gtwiz_userdata_rx_out                 => slave_mgt_stat.rxdata_out(15 downto 0)           , -- only 16-bits connected to 5G version 
     gtyrxn_in(0)                          => slave_rx_n_i                                     , 
     gtyrxp_in(0)                          => slave_rx_p_i                                     , 
     gtytxn_out(0)                         => slave_tx_n_o                                     , 
     gtytxp_out(0)                         => slave_tx_p_o                     
   );	
 end generate gen_slave_5G;

 -- Slave cores
 cmp_slave : tclink_lpgbt
     generic map(
       g_MASTER_NSLAVE               => False,
       g_QUAD_LEADER                 => True,	   
       g_MASTER_TCLINK_TESTER_ENABLE => False, -- saves logic if False, recommended to use False for a final user design
       g_PROTOCOL                    => c_PROTOCOL   
 	)
     port map(
         -----------------------------------------------------------------
         --------------------- System clock / resets ---------------------
         -----------------------------------------------------------------
         -- System clock
         clk_sys_i                   => clk_sys                             ,
 		
         -----------------------------------------------------------------
         ------------------ Core control/status ------------------------
         -----------------------------------------------------------------
 		  -- Interface synchronous to clk_sys_i
         core_ctrl_i                 => slave_core_ctrl                     ,
         core_stat_o                 => slave_core_stat                     ,

         -- TCLink (not relevant for slave)	                                
         master_tclink_clk_offset_i  => '0'                                 ,
         master_tclink_ctrl_i        => slave_tclink_ctrl                   ,
         master_tclink_stat_o        => open,
 
         -----------------------------------------------------------------
         ------------------ Slave recovered clock ----------------------
         -----------------------------------------------------------------
         slave_clk40_oddr_o          => slave_clk40_oddr_in                 ,
 
         -----------------------------------------------------------------
         ------------------------ User data ----------------------------
         -----------------------------------------------------------------
         tx_clk40_i                  => clk40                               ,
         tx_data_i                   => prbsgen_slave_frame                 ,
         tx_clk40_stable_i           => slave_clk40_pll_locked              ,

         rx_clk40_i                  => clk40,                              
         rx_clk40_stable_i           => slave_clk40_pll_locked              ,
         rx_data_o                   => prbschk_slave_frame                 ,

         -----------------------------------------------------------------
         ------------------------- MMCM ----------------------------------
         -----------------------------------------------------------------
         mmcm_locked_i => '1',

         -----------------------------------------------------------------
         ------------------------ MGT  ---------------------------------
         -----------------------------------------------------------------
         mgt_txclk_i          => slave_clk_stat.txusrclk                    ,
         mgt_rxclk_i          => slave_clk_stat.rxusrclk                    ,
         mgt_ctrl_o           => slave_mgt_ctrl                             ,
         mgt_stat_i           => slave_mgt_stat
 	);

  slave_core_ctrl.reset_all <= slave_core_ctrl.mgt_reset_rx_pll_and_datapath;
  
  -- If the user has available the slave external PLL lock signal, this shall be used to drive the signals tx_clk40_stable_i and rx_clk40_stable_i for the slave
  -- In this example design, this PLL comes from an external board and therefore I do not monitor the status in the firmware
  -- Therefore, here we use a timer after the slave frame-locking procedure is finished to assert this status  
   p_slave_clk40_pll_locked : process(clk_sys)
  begin
    if(rising_edge(clk_sys)) then
      if(slave_mmcm_locked_sync = '0') then
        slave_clk40_pll_locked     <= '0';
        slave_clk40_pll_lock_timer <= 0;
      else
	    if(slave_clk40_pll_lock_timer < c_SLAVE_CLK40_PLL_LOCK_TIMER_MAX) then
           slave_clk40_pll_locked     <= '0';
           slave_clk40_pll_lock_timer <= slave_clk40_pll_lock_timer + 1;
		else
           slave_clk40_pll_locked     <= '1';
           slave_clk40_pll_lock_timer <= slave_clk40_pll_lock_timer;
		end if;
      end if;
    end if;
  end process p_slave_clk40_pll_locked;

 ----------------------------------------------------------  
 
 --------------------- PRBS generator Tx ---------------------
 not_slave_core_stat_tx_user_data_ready  <= not slave_core_stat.tx_user_data_ready;  
 prbsgen_slave_reset_bit_synchronizer  : bit_synchronizer
   port map(
     clk_in => clk40                            ,
     i_in   => not_slave_core_stat_tx_user_data_ready ,
     o_out  => prbsgen_slave_reset
 );   
 
 prbsgen_slave_load <=     prbsgen_slave_reset when rising_edge(clk40);
 prbsgen_slave_en   <= not prbsgen_slave_reset when rising_edge(clk40);                          
 
 cmp_slave_prbs_gen : prbs_gen
   generic map(
     g_PARAL_FACTOR    => c_USER_TX_DATA_WIDTH,
     g_PRBS_POLYNOMIAL => c_PRBS_POLYNOMIAL
   )                                                           
   port map(                                                                          
     clk_i            => clk40               ,
     en_i             => prbsgen_slave_en    ,
     reset_i          => prbsgen_slave_reset ,
     seed_i           => c_PRBS_SEED         ,
     load_i           => prbsgen_slave_load  ,
     data_o           => prbsgen_slave_frame ,
     data_valid_o     => prbsgen_slave_data_valid
   );
 ------------------------------------------------------------
 
 --------------------- PRBS checker rx ---------------------
 not_slave_core_stat_rx_user_data_ready  <= not slave_core_stat.rx_user_data_ready;  
 prbschk_slave_reset_bit_synchronizer  : bit_synchronizer
   port map(
     clk_in => clk40                               ,
     i_in   => not_slave_core_stat_rx_user_data_ready ,
     o_out  => prbschk_slave_reset
 );   
 
 prbschk_slave_en   <= not prbschk_slave_reset when rising_edge(clk40);
 
 cmp_slave_prbs_chk : prbs_chk
   generic map(
     g_GOOD_FRAME_TO_LOCK  => c_PRBS_GOOD_FRAME_TO_LOCK  ,
     g_BAD_FRAME_TO_UNLOCK => c_PRBS_BAD_FRAME_TO_UNLOCK ,
     g_PARAL_FACTOR        => c_USER_RX_DATA_WIDTH         ,
     g_PRBS_POLYNOMIAL     => c_PRBS_POLYNOMIAL
   )                                                                
   port map(                                                                          
     clk_i            => clk40               ,
     reset_i          => prbschk_slave_reset ,
     en_i             => prbschk_slave_en    ,
     data_i           => prbschk_slave_frame ,
     data_o           => prbschk_slave_gen   ,
     error_o          => prbschk_slave_error ,
     locked_o         => prbschk_slave_locked
   ); 
 
 rx_slave_prbs_locked_bit_synchronizer  : bit_synchronizer
   port map(
     clk_in => clk_sys                   ,
     i_in   => prbschk_slave_locked      ,
     o_out  => prbschk_slave_locked_sync
 ); 
 ----------------------------------------------------------
 
 ------------------- Slave VIO -------------------
 cmp_slave_vio_control : vio_control_vcu118
   port map(
     clk            => clk_sys                                    ,
     probe_in0(0)   => slave_core_stat.rx_frame_locked            ,         
     probe_in1(0)   => prbschk_slave_locked_sync                  ,         
     probe_in2(0)   => '0'                                        ,
     probe_in3(0)   => slave_core_stat.mgt_txpll_lock             , 
     probe_in4(0)   => slave_core_stat.mgt_rxpll_lock             , 
     probe_in5(0)   => slave_core_stat.mgt_buffbypass_rx_done     , 
     probe_in6(0)   => slave_core_stat.mgt_buffbypass_rx_error    , 
     probe_in7(0)   => slave_core_stat.mgt_powergood              ,
     probe_in8(0)   => slave_core_stat.mgt_reset_tx_done          , 
     probe_in9(0)   => slave_core_stat.mgt_reset_rx_done          , 
     probe_in10(0)  => slave_core_stat.mgt_rxpmaresetdone         , 
     probe_in11(0)  => slave_core_stat.mgt_txpmaresetdone         , 
     probe_in12(0)  => slave_core_stat.mgt_tx_ready               , 
     probe_in13(0)  => slave_core_stat.mgt_rx_ready               , 
     probe_in14(0)  => slave_core_stat.mgt_rxprbserr              , 
     probe_in15(0)  => slave_core_stat.mgt_rxprbslocked           , 
     probe_in16(0)  => slave_core_stat.mgt_drprdy_latched         , 
     probe_in17     => slave_core_stat.mgt_drpdo                  , 
     probe_in18     => slave_core_stat.mgt_hptd_tx_pi_phase       , 
     probe_in19     => slave_core_stat.mgt_hptd_tx_fifo_fill_pd   ,
     probe_in20(0)  => slave_core_stat.mgt_hptd_ps_done_latched   ,
     probe_in21     => slave_core_stat.mgt_rxeq_dmonitor          ,
     probe_in22(0)  => slave_firefly_int_b_sync                   ,
     probe_in23(0)  => slave_firefly_modprs_b_sync                ,
     probe_in24     => (others => '0')                            ,
     probe_in25     => (others => '0')                            ,
     probe_in26     => (others => '0')                            ,
     probe_in27(0)  => '0'                                        ,
     probe_in28     => (others => '0')                            ,
     probe_in29(0)  => '0'                                        ,
     probe_in30(0)  => slave_core_stat.rx_fec_corrected_latched   ,
     probe_in31     => slave_core_stat.phase_cdc40_rx             ,
     probe_in32     => slave_core_stat.phase_cdc40_tx             ,	 
     probe_in33(0)  => slave_core_stat.channel_controller_running ,
     probe_in34     => slave_core_stat.channel_controller_state   ,
     probe_in35(0)  => slave_core_stat.channel_ready              ,
	 probe_in36(0)  => slave_mmcm_locked_sync                     ,
     probe_in37(0)  => slave_core_stat.rx_user_data_ready         ,
     probe_in38(0)  => slave_core_stat.rx_data_not_idle           ,
     probe_in39(0)  => slave_core_stat.cdc_40_rx_ready            ,
     probe_in40(0)  => slave_core_stat.tx_user_data_ready         ,
     probe_in41(0)  => slave_core_stat.cdc_40_tx_ready            ,  	 
     probe_out0(0)  => slave_core_ctrl.rx_fec_corrected_clear     ,
     probe_out1(0)  => open                                       , 
     probe_out2(0)  => slave_core_ctrl.mgt_reset_all              ,
     probe_out3(0)  => slave_core_ctrl.mgt_reset_tx_pll_and_datapath,
     probe_out4(0)  => slave_core_ctrl.mgt_reset_tx_datapath        ,
     probe_out5(0)  => slave_core_ctrl.mgt_reset_rx_pll_and_datapath,
     probe_out6(0)  => slave_core_ctrl.mgt_reset_rx_datapath        ,
     probe_out7(0)  => slave_core_ctrl.mgt_txpolarity             ,
     probe_out8(0)  => slave_core_ctrl.mgt_rxpolarity             ,
     probe_out9     => slave_core_ctrl.mgt_loopback               ,
     probe_out10(0) => slave_core_ctrl.mgt_txprbsforceerr         ,
     probe_out11    => slave_core_ctrl.mgt_txprbssel              ,
     probe_out12(0) => slave_core_ctrl.mgt_rxprbscntreset         ,
     probe_out13    => slave_core_ctrl.mgt_rxprbssel              ,
     probe_out14(0) => slave_core_ctrl.mgt_drpwe                  ,
     probe_out15(0) => slave_core_ctrl.mgt_drpen                  ,
     probe_out16    => slave_core_ctrl.mgt_drpaddr                ,
     probe_out17    => slave_core_ctrl.mgt_drpdi                  ,
     probe_out18    => open                                       ,
     probe_out19    => slave_core_ctrl.mgt_hptd_tx_pi_phase_calib ,
     probe_out20(0) => slave_core_ctrl.mgt_hptd_tx_ui_align_calib ,
     probe_out21(0) => slave_core_ctrl.mgt_hptd_ps_strobe         ,
     probe_out22(0) => slave_core_ctrl.mgt_hptd_ps_inc_ndec       ,
     probe_out23    => slave_core_ctrl.mgt_hptd_ps_phase_step     ,
     probe_out24(0) => slave_core_ctrl.mgt_rxeq_rxlpmgcovrden     ,
     probe_out25(0) => slave_core_ctrl.mgt_rxeq_rxlpmhfovrden     ,
     probe_out26(0) => slave_core_ctrl.mgt_rxeq_rxlpmlfklovrden   ,
     probe_out27(0) => slave_core_ctrl.mgt_rxeq_rxlpmosovrden     ,
     probe_out28(0) => slave_firefly_modsel_b                     ,
     probe_out29(0) => slave_firefly_reset_b                      ,
     probe_out30(0) => open                                       ,
     probe_out31    => open                                       ,
     probe_out32    => open                                       ,
     probe_out33    => open                                       ,
     probe_out34    => open                                       ,
     probe_out35    => open                                       ,
     probe_out36(0) => open                                       ,
     probe_out37    => open                                       ,
     probe_out38    => open                                       ,
     probe_out39(0) => open                                       ,
     probe_out40    => open                                       ,
     probe_out41(0) => open                                       ,
     probe_out42    => open                                       ,
     probe_out43    => open                                       ,
     probe_out44(0) => open                                       ,   
     probe_out45    => open                                       ,
     probe_out46(0) => open                                       ,
     probe_out47    => open                                       ,
     probe_out48(0) => slave_core_ctrl.mgt_rxeq_rxlpmen           ,
     probe_out49(0) => slave_core_ctrl.mgt_rxeq_rxdfelfovrden     ,  
     probe_out50(0) => slave_core_ctrl.mgt_rxeq_rxdfelpmreset     ,  
     probe_out51(0) => slave_core_ctrl.mgt_rxeq_rxdfeutovrden     ,  
     probe_out52(0) => slave_core_ctrl.mgt_rxeq_rxdfevpovrden     ,  
     probe_out53(0) => slave_core_ctrl.mgt_rxeq_rxdfeagcovrden    ,  
     probe_out54(0) => slave_core_ctrl.mgt_rxeq_rxosovrden        ,
	 probe_out55(0) => slave_core_ctrl.phase_cdc40_rx_force       ,  
	 probe_out56    => slave_core_ctrl.phase_cdc40_rx_calib       ,  
	 probe_out57(0) => slave_core_ctrl.phase_cdc40_tx_force       ,  
	 probe_out58    => slave_core_ctrl.phase_cdc40_tx_calib       ,
     probe_out59(0) => slave_core_ctrl.channel_controller_reset,
     probe_out60(0) => slave_core_ctrl.channel_controller_gentle,
     probe_out61(0) => slave_core_ctrl.channel_controller_enable
   );
 ------------------------------------------------------------
 
 slave_tclink_ctrl.tclink_close_loop                    <= '0'            ;
 slave_tclink_ctrl.tclink_offset_error                  <= (others => '0');
 slave_tclink_ctrl.tclink_metastability_deglitch        <= (others => '0');
 slave_tclink_ctrl.tclink_phase_detector_navg           <= (others => '0');
 slave_tclink_ctrl.tclink_modulo_carrier_period         <= (others => '0');
 slave_tclink_ctrl.tclink_Aie                           <= (others => '0');
 slave_tclink_ctrl.tclink_Aie_enable                    <= '0'            ;
 slave_tclink_ctrl.tclink_Ape                           <= (others => '0');
 slave_tclink_ctrl.tclink_sigma_delta_clk_div           <= (others => '0');
 slave_tclink_ctrl.tclink_enable_mirror                 <= '0'            ;
 slave_tclink_ctrl.tclink_Adco                          <= (others => '0');
 slave_tclink_ctrl.tclink_debug_tester_enable_stimulis  <= '0'            ;
 slave_tclink_ctrl.tclink_debug_tester_fcw              <= (others => '0');
 slave_tclink_ctrl.tclink_debug_tester_nco_scale        <= (others => '0');
 slave_tclink_ctrl.tclink_debug_tester_enable_stock_out <= '0'            ;
 slave_tclink_ctrl.tclink_debug_tester_addr_read        <= (others => '0');
 slave_tclink_ctrl.tclink_master_rx_ui_period           <= (others => '0');
 
 slave_firefly_modsel_b_o <= slave_firefly_modsel_b;
 slave_firefly_reset_b_o  <= slave_firefly_reset_b ;
 
 slave_firefly_modprs_b_bit_synchronizer : bit_synchronizer
   port map(
     clk_in => clk_sys                  ,
     i_in   => slave_firefly_modprs_b_i ,
     o_out  => slave_firefly_modprs_b_sync
 );  
 
 slave_firefly_int_b_bit_synchronizer : bit_synchronizer
   port map(
     clk_in => clk_sys               ,
     i_in   => slave_firefly_int_b_i ,
     o_out  => slave_firefly_int_b_sync
 );    
 
 -------------------------------------------------------------------------------------------------------  

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================
