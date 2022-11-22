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
--! @file tb_lpgbt_symmetric.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;
use ieee.math_real.floor;

--! Specific packages
--! Include the LpGBT-FPGA specific package
use work.lpgbtfpga_package.all;

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: lpGBT10G uplink protocol test-bench (tb_lpgbt_symmetric)
--
--! @brief lpGBT10G protocol test-bench
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 27\01\2019
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
--! 27\01\2019 - EBSM - Created\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

--==============================================================================
--! Entity declaration for tb_lpgbt_symmetric
--==============================================================================
entity tb_lpgbt_symmetric is
  generic(
    g_DATARATE          : integer RANGE 0 to 2 := DATARATE_10G24           ; --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
    g_FEC               : integer RANGE 0 to 2 := FEC5                     ; --! FEC selection can be: FEC5 or FEC12
    g_PAYLOAD_LENGTH    : integer              := 230                        --! User payload length (depends on FEC and DATARATE)
                                                                             --!   * *FEC5 / 5.12 Gbps*: 112bit  
                                                                             --!   * *FEC12 / 5.12 Gbps*: 98bit  
                                                                             --!   * *FEC5 / 10.24 Gbps*: 230bit  
                                                                             --!   * *FEC12 / 10.24 Gbps*: 202bit    
  );
  port(
    TEST_BENCH_STATUS_O : out string(1 to 25)  := "          RESET          ";	
    FECMONITOR_O        : out integer                                        ;
    PRBSMONITOR_O       : out integer	
  );
end tb_lpgbt_symmetric;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture tb of tb_lpgbt_symmetric is

  --! Function declaration

  --! Constant declaration  
  constant c_CLOCK_SYS_PERIOD        : time    := 10.0  ns;
  constant c_CLOCK_MGT_PERIOD        : time    := 3.125 ns;
 
  -- PRBS gen/chk  
  constant c_PRBS_FRAME_WIDTH        : integer := g_PAYLOAD_LENGTH + 4; -- +4 comes from EC and IC fields
  constant c_PRBS_POLYNOMIAL         : std_logic_vector(23 downto 0) := (23 => '1', 18=> '1', 0 => '1', others => '0'); -- PRBS-23 testing (x^7 + x^6 + 1)

  -- lpGBT-FPGA expert parameters (values extracted from example design for KCU105)
  constant c_multicyleDelay          : integer := 3 ;
  constant c_clockRatio              : integer := 8 ;                   
  constant c_mgtWordWidth            : integer := 32;                    
  constant c_allowedFalseHeader      : integer := 5 ;                 
  constant c_allowedFalseHeaderOverN : integer := 64;                  
  constant c_requiredTrueHeader      : integer := 32;                  
  constant c_bitslip_mindly          : integer := 2 ;            
  constant c_bitslip_waitdly         : integer := 40;  
		
  --! Signal declaration           

  -------------------------------------------------- Common --------------------------------------------------                       
  signal common_clk_sys              : std_logic;                                                
  signal common_clk_mgt              : std_logic;   
  -------------------------------------------------------------------------------------------------------------

  ---------------------------------------------- PRBS generator -----------------------------------------------
  signal prbsgen_strobe_cntr : integer range 0 to 7;
  signal prbsgen_strobe      : std_logic;                                                                --! enable input
  signal prbsgen_reset       : std_logic;                                                                --! active high sync. reset
  signal prbsgen_seed        : std_logic_vector(c_PRBS_POLYNOMIAL'length-2 downto 0) := (others => '1'); --! Seed for polynomial
  signal prbsgen_load        : std_logic;                                                                --! Load seed	
  signal prbsgen_frame       : std_logic_vector(c_PRBS_FRAME_WIDTH-1 downto 0);                          --! PRBS output data
  signal prbsgen_data_valid  : std_logic;                                                                --! PRBS data valid
  -------------------------------------------------------------------------------------------------------------

  ------------------------------------------------ lpGBT-FE Tx ------------------------------------------------ 
  signal Tx_reset              : std_logic                                        ;  
  signal Tx_tx_strobe          : std_logic                                        ;
  signal Tx_tx_data            : std_logic_vector(229 downto 0) := (others => '0');
  signal Tx_tx_ec              : std_logic_vector(1 downto 0)                     ;
  signal Tx_tx_ic              : std_logic_vector(1 downto 0)                     ;
  signal Tx_tx_word            : std_logic_vector(c_mgtWordWidth-1 downto 0)      ;
  signal Tx_scrambler_bypass   : std_logic := '0'                                 ;
  signal Tx_interleaver_bypass : std_logic := '0'                                 ;
  signal Tx_tx_error           : std_logic_vector(255 downto 0) := (others => '0');
  -------------------------------------------------------------------------------------------------------------

  --------------------------------- MGT Rx (High-level modelling for testing) ---------------------------------
  signal channel_reset                : std_logic;
  signal channel_ready                : std_logic;
  signal channel_rx_data              : std_logic_vector(2*c_mgtWordWidth-1 downto 0) := (others => '0'); 
  signal channel_data                 : std_logic_vector(c_mgtWordWidth-1 downto 0)   := (others => '0'); 
  signal channel_bitslide_r           : std_logic; 
  signal channel_bitslip_position     : integer range 0 to c_mgtWordWidth-1 := 0;
  signal channel_rx_frame_reset_phy   : std_logic;
  signal channel_rx_frame_reset_phy_r : std_logic;
  -------------------------------------------------------------------------------------------------------------

  ---------------------------------------------- lpGBT-FPGA Rx ----------------------------------------------
  -- Clock and reset
  signal Rx_uplinkClkOutEn                : std_logic;                                      --! Clock enable to be USEd in the USEr's logic  
  signal Rx_uplinkRst_n                   : std_logic;                                      --! Uplink reset SIGNAL (Rx ready from the transceiver)  

  -- Input                               
  signal Rx_mgt_word                      : std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT  

  -- Data                                
  signal Rx_USErData                      : std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depENDing on the  
                                                                                              --! datarate/FEC configuration:  
                                                                                              --!     * *FEC5 / 5.12 Gbps*: 112bit  
                                                                                              --!     * *FEC12 / 5.12 Gbps*: 98bit  
                                                                                              --!     * *FEC5 / 10.24 Gbps*: 230bit  
                                                                                              --!     * *FEC12 / 10.24 Gbps*: 202bit  
  signal Rx_EcData                        : std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT  
  signal Rx_IcData                        : std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT  

  -- Control                                                                                  
  signal Rx_bypassInterleaver             : std_logic := '0';                               --! Bypass uplink interleaver (test purpose only)  
  signal Rx_bypassFECEncoder              : std_logic := '0';                               --! Bypass uplink FEC (test purpose only)  
  signal Rx_bypassScrambler               : std_logic := '0';                               --! Bypass uplink scrambler (test purpose only)  

  -- Transceiver control                                                                      
  signal Rx_mgt_bitslipCtrl               : std_logic;                                      --! Control the Bitslib/RxSlide PORT of the Mgt  


  -- Status                                                                                   
  signal Rx_dataCorrected                 : std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC  
  signal Rx_IcCorrected                   : std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC  
  signal Rx_EcCorrected                   : std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC  
  signal Rx_rdy                           : std_logic;                                      --! Ready SIGNAL from the uplink decoder  
  -------------------------------------------------------------------------------------------------------------
  
  ---------------------------------------------- PRBS checker -----------------------------------------------
  signal prbschk_reset             : std_logic                                      ;
  signal prbschk_frame             : std_logic_vector(c_PRBS_FRAME_WIDTH-1 downto 0);
  signal prbschk_strobe            : std_logic                                      ;  
  signal prbschk_gen               : std_logic_vector(c_PRBS_FRAME_WIDTH-1 downto 0);                                                                                                        
  signal prbschk_error             : std_logic                                      ;   
  signal prbschk_locked            : std_logic                                      ;       
  -------------------------------------------------------------------------------------------------------------

  -- Test bench status and checkers
  signal TEST_BENCH_STATUS         : string(1 to 25) := "          RESET          ";

  --! Component declaration
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
  
  component lpgbt_fe_tx is
      generic(
        g_MGT_WORD_WIDTH     : integer := 32; -- Word width of MGT
	    g_DATA_RATE          : integer := 2;  -- 2=10G , 1=5G
	    g_FEC                : integer := 1   -- 1=FEC5, 2=FEC12
	  );
      -- all ports are synchronous to mgt_clock_i
      port (
  	    -- Clock / reset
        reset_i             : in  std_logic                      ; --! active high sync input
        mgt_clock_i         : in  std_logic                      ; --! mgt clock (320MHz)
  	  
  	    -- User data
  	                                                               --!                        ___    1-high / 7-low     ___    
        tx_strobe_i         : in  std_logic                      ; --!                    ___/   \_____________________/   \_______________
  	    tx_data_i           : in  std_logic_vector(229 downto 0) ; --! User frame input      X         FRAME0          X         FRAME1                  
                                                                   --! datarate/FEC configuration:
                                                                   --! FEC5  /  5.12 Gbps => 112bit
                                                                   --! FEC12 /  5.12 Gbps => 98bit
                                                                   --! FEC5  / 10.24 Gbps => 230bit
                                                                   --! FEC12 / 10.24 Gbps => 202bit
        tx_ec_i             : in  std_logic_vector(1 downto 0)   ;
        tx_ic_i             : in  std_logic_vector(1 downto 0)   ;
  	  
	    -- MGT
        tx_word_o           : out std_logic_vector(g_MGT_WORD_WIDTH-1 downto 0)  ;
	    
	    -- Debugging         
	    scrambler_bypass_i   : in  std_logic;                       --! scrambler bypass
        interleaver_bypass_i : in  std_logic;                       --! interleaver bypass
	    tx_error_i           : in  std_logic_vector(255 downto 0)   --! Debug error injection port
      ); 
  end component lpgbt_fe_tx;


  component lpgbtfpga_uplink IS
     GENERIC(
          -- General configuration
          DATARATE                        : integer RANGE 0 to 2;                               --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
          FEC                             : integer RANGE 0 to 2;                               --! FEC selection can be: FEC5 or FEC12
  
          -- Expert parameters
          c_multicyleDelay                : integer RANGE 0 to 7 := 3;                          --! Multicycle delay: Used to relax the timing constraints
          c_clockRatio                    : integer;                                            --! Clock ratio is mgt_Userclk / 40 (shall be an integer)
          c_mgtWordWidth                  : integer;                                            --! Bus size of the input word (typically 32 bits)
          c_allowedFalseHeader            : integer;                                            --! Number of false header allowed (among c_allowedFalseHeaderOverN) to avoid unlock on frame error
          c_allowedFalseHeaderOverN       : integer;                                            --! Number of header checked to know wether the lock is lost or not
          c_requiredTrueHeader            : integer;                                            --! Number of consecutive correct header required to go in locked state
          c_bitslip_mindly                : integer := 1;                                       --! Number of clock cycle required when asserting the bitslip signal
          c_bitslip_waitdly               : integer := 40                                       --! Number of clock cycle required before being back in a stable state
     );
     PORT (
          -- Clock and reset
          uplinkClk_i                     : in  std_logic;                                      --! Uplink datapath clock (Transceiver Rx User clock, typically 320MHz)
          uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable indicating a new data is valid
          uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset signal (Rx ready from the transceiver)
  
          -- Input
          mgt_word_i                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
  
          -- Data
          userData_o                      : out std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depending on the
                                                                                                --! datarate/FEC configuration:
                                                                                                --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                                --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                                --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                                --!     * *FEC12 / 10.24 Gbps*: 202bit
          EcData_o                        : out std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT
          IcData_o                        : out std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT
  
          -- Control
          bypassInterleaver_i             : in  std_logic;                                      --! Bypass uplink interleaver (test purpose only)
          bypassFECEncoder_i              : in  std_logic;                                      --! Bypass uplink FEC (test purpose only)
          bypassScrambler_i               : in  std_logic;                                      --! Bypass uplink scrambler (test purpose only)
  
          -- Transceiver control
          mgt_bitslipCtrl_o               : out std_logic;                                      --! Control the Bitslip/RxSlide port of the Mgt
  
          -- Status
          dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
          IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
          EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
          rdy_o                           : out std_logic;                                      --! Ready SIGNAL from the uplink decoder
          frameAlignerEven_o              : out std_logic                                       --! Number of bit slip is even (required only for advanced applications)
  
     );
  END component lpgbtfpga_uplink;

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
  p_clk_sys : process
  begin
    while (TEST_BENCH_STATUS /= "         FINISHED        ") loop  
      common_clk_sys <= '0';
	  wait for c_CLOCK_SYS_PERIOD/2;
	  common_clk_sys <= '1';
	  wait for c_CLOCK_SYS_PERIOD/2;
    end loop;
    wait;	 
  end process;

  p_clk_mgt : process
  begin
    while (TEST_BENCH_STATUS /= "         FINISHED        ") loop  
      common_clk_mgt <= '0';
	  wait for c_CLOCK_MGT_PERIOD/2;
	  common_clk_mgt <= '1';
	  wait for c_CLOCK_MGT_PERIOD/2;
    end loop;
    wait;	 
  end process;
  -----------------------------------------------------------------------------------------

  --! --------------------------------- PRBS generator Tx ---------------------------------  
  p_prbsgen_strobe : process(common_clk_mgt)
  begin
    if(rising_edge(common_clk_mgt)) then  
      if(prbsgen_reset = '1') then
        prbsgen_strobe_cntr <= 0;
        prbsgen_strobe      <= '0';
		prbsgen_load        <= '1';
      else
		prbsgen_load        <= '0';		
        if(prbsgen_strobe_cntr = c_clockRatio-1) then
          prbsgen_strobe_cntr <= 0;
          prbsgen_strobe      <= '1';
		else
          prbsgen_strobe_cntr <= prbsgen_strobe_cntr+1;
          prbsgen_strobe      <= '0';
		end if;
      end if;
    end if;
  end process;

  cmp_prbs_gen : prbs_gen
    generic map(
      g_PARAL_FACTOR    => c_PRBS_FRAME_WIDTH,
      g_PRBS_POLYNOMIAL => c_PRBS_POLYNOMIAL
    )                                                           
    port map(                                                                          
      clk_i            => common_clk_mgt,
      en_i             => prbsgen_strobe,
      reset_i          => prbsgen_reset ,
      seed_i           => prbsgen_seed  ,
      load_i           => prbsgen_load  ,
      data_o           => prbsgen_frame ,
      data_valid_o     => prbsgen_data_valid
    );
  -----------------------------------------------------------------------------------------

  --! ------------------------------------ lpGBT-FE Tx ------------------------------------
  Tx_reset                                              <= prbsgen_reset;
  Tx_tx_strobe                                          <= prbsgen_data_valid;
  --Tx_tx_data(Tx_tx_data'left downto g_PAYLOAD_LENGTH) <= (others => '0');
  Tx_tx_data(g_PAYLOAD_LENGTH-1 downto 0)               <= prbsgen_frame(g_PAYLOAD_LENGTH-1 downto 0);
  Tx_tx_ec                                              <= prbsgen_frame(g_PAYLOAD_LENGTH+1 downto g_PAYLOAD_LENGTH);
  Tx_tx_ic                                              <= prbsgen_frame(g_PAYLOAD_LENGTH+3 downto g_PAYLOAD_LENGTH+2);

  cmp_lpgbt_fe_tx : lpgbt_fe_tx 
    generic map(
	  g_MGT_WORD_WIDTH => c_mgtWordWidth,
	  g_DATA_RATE      => g_DATARATE    ,
	  g_FEC            => g_FEC         
	)
    port map(
      reset_i              => Tx_reset             ,
      mgt_clock_i          => common_clk_mgt         ,
      tx_strobe_i          => Tx_tx_strobe         ,
      tx_data_i            => Tx_tx_data           ,
      tx_ec_i              => Tx_tx_ec             ,
      tx_ic_i              => Tx_tx_ic             ,
      tx_word_o            => Tx_tx_word           ,
	  scrambler_bypass_i   => Tx_scrambler_bypass  ,
      interleaver_bypass_i => Tx_interleaver_bypass,
	  tx_error_i           => Tx_tx_error     
  ); 
  -----------------------------------------------------------------------------------------

  --! ------------------------ Rx MGT high-level model for testing -------------------------
  channel_rx_data(2*c_mgtWordWidth-1 downto c_mgtWordWidth) <= Tx_tx_word(c_mgtWordWidth-1 downto 0)             when rising_edge(common_clk_mgt);
  channel_rx_data(c_mgtWordWidth-1 downto 0)          <= channel_rx_data(2*c_mgtWordWidth-1 downto c_mgtWordWidth) when rising_edge(common_clk_mgt);
  channel_bitslide_r                                  <= Rx_mgt_bitslipCtrl                                      when rising_edge(common_clk_mgt);
  channel_rx_frame_reset_phy                          <= '0'; --rx_reset_on_even                                        when rising_edge(common_clk_mgt);
  channel_rx_frame_reset_phy_r                        <= channel_rx_frame_reset_phy                                when rising_edge(common_clk_mgt);
  p_rxslide : process is
    variable seed1 : positive;
    variable seed2 : positive;
    variable x : real;
  begin
      while (TEST_BENCH_STATUS /= "         FINISHED        ") loop  
	    wait until rising_edge(common_clk_mgt);
        if(channel_reset='1' or channel_rx_frame_reset_phy='1') then
          uniform(seed1, seed2, x);
          channel_ready    <= '0';
          channel_bitslip_position <= integer(floor(real(c_mgtWordWidth)*x));
        elsif(channel_bitslide_r='0' and Rx_mgt_bitslipCtrl='1') then
          channel_ready    <= '1';
          channel_bitslip_position <= (channel_bitslip_position+1) mod c_mgtWordWidth;
        else
          channel_ready <= '1';
        end if;
        end loop;
      wait;
  end process;
  channel_data <= channel_rx_data(c_mgtWordWidth-1 + channel_bitslip_position downto channel_bitslip_position) when rising_edge(common_clk_mgt);
  -----------------------------------------------------------------------------------------

  --! ----------------------------------- lpGBT-FPGA Rx -----------------------------------
  Rx_uplinkRst_n       <= channel_ready;
  Rx_mgt_word          <= channel_data ;

  cmp_lpgbtfpga_uplink : lpgbtfpga_uplink
     generic map(
          -- General configuration
          DATARATE                        => g_DATARATE               , 
          FEC                             => g_FEC                    ,        
  
          -- Expert parameters
          c_multicyleDelay                => c_multicyleDelay         ,                
          c_clockRatio                    => c_clockRatio             ,             
          c_mgtWordWidth                  => c_mgtWordWidth           ,             
          c_allowedFalseHeader            => c_allowedFalseHeader     ,            
          c_allowedFalseHeaderOverN       => c_allowedFalseHeaderOverN,       
          c_requiredTrueHeader            => c_requiredTrueHeader     ,       
          c_bitslip_mindly                => c_bitslip_mindly         ,       
          c_bitslip_waitdly               => c_bitslip_waitdly        
     )
     port map(
          -- Clock and reset
          uplinkClk_i                     => common_clk_mgt        ,
          uplinkClkOutEn_o                => Rx_uplinkClkOutEn   ,     
          uplinkRst_n_i                   => Rx_uplinkRst_n      ,

          -- Input
          mgt_word_i                      => Rx_mgt_word         ,
                                                                   
          -- Data
          userData_o                      => Rx_USErData         ,

          EcData_o                        => Rx_EcData           ,
          IcData_o                        => Rx_IcData           ,

          -- Control
          bypassInterleaver_i             => Rx_bypassInterleaver,
          bypassFECEncoder_i              => Rx_bypassFECEncoder ,
          bypassScrambler_i               => Rx_bypassScrambler  ,

          -- Transceiver control
          mgt_bitslipCtrl_o               => Rx_mgt_bitslipCtrl  ,
		
          -- Status
          dataCorrected_o                 => Rx_dataCorrected    ,
          IcCorrected_o                   => Rx_IcCorrected      ,
          EcCorrected_o                   => Rx_EcCorrected      ,
          rdy_o                           => Rx_rdy              ,
          frameAlignerEven_o              => open
     );
  -----------------------------------------------------------------------------------------
  
  --! ---------------------------------- PRBS checker Rx ----------------------------------  
  prbschk_reset  <= not Rx_rdy                                                           ;
  prbschk_strobe <= Rx_uplinkClkOutEn                                                    ;
  prbschk_frame  <= Rx_IcData & Rx_EcData & Rx_USErData(g_PAYLOAD_LENGTH-1 downto 0) ;

  cmp_prbs_chk : prbs_chk
    generic map(
      g_GOOD_FRAME_TO_LOCK  => 15                ,
      g_BAD_FRAME_TO_UNLOCK => 20                ,
      g_PARAL_FACTOR        => c_PRBS_FRAME_WIDTH,
      g_PRBS_POLYNOMIAL     => c_PRBS_POLYNOMIAL
    )                                                                
    port map(                                                                          
      clk_i            => common_clk_mgt,
      reset_i          => prbschk_reset ,
      en_i             => prbschk_strobe,
      data_i           => prbschk_frame ,
      data_o           => prbschk_gen   ,
      error_o          => prbschk_error ,
      locked_o         => prbschk_locked
    );
  ----------------------------------------------------------------------------------------- 

  --! Stimulis -----------------------------------------------------------------
  p_stimulis : process is
  
    -- Inject burst error
    procedure INJECT_BURST_ERROR(size_burst : integer) is  
	  variable v_frame_width : integer := Tx_tx_error'length;
    begin
      if(g_DATARATE = DATARATE_10G24) then
	    v_frame_width := Tx_tx_error'length;
	  else
	    v_frame_width := Tx_tx_error'length/2;
	  end if;
	  
      for i in 0 to v_frame_width-size_burst loop
	    wait until rising_edge(Tx_tx_strobe);
		Tx_tx_error <= (size_burst - 1 + i downto i => '1', others => '0');
		wait until rising_edge(common_clk_mgt);
	    wait until rising_edge(Tx_tx_strobe);
		Tx_tx_error <= (others => '0');
		wait until rising_edge(common_clk_mgt);
	    wait until rising_edge(Tx_tx_strobe);
		wait until rising_edge(common_clk_mgt);
      end loop;
	  wait until rising_edge(Tx_tx_strobe);
	  Tx_tx_error <= (others => '0');
	  wait until rising_edge(common_clk_mgt);
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
    end INJECT_BURST_ERROR;

    procedure RESET_TEST(number_resets : integer; wait_locked_cycles : integer) is
      variable seed1      : positive;
      variable seed2      : positive;
      variable x          : real;
      variable reset_wait : integer;	  
    begin
      for i in 0 to number_resets-1 loop
	    wait until rising_edge(common_clk_mgt);	  
        uniform(seed1, seed2, x);
        reset_wait := (integer(floor(real(c_mgtWordWidth)*x)) + 1);
        channel_reset           <= '1';
	    wait for reset_wait*c_CLOCK_SYS_PERIOD;
	    wait until rising_edge(common_clk_mgt);
        -- Channel Reset release
        channel_reset           <= '0';
        wait until rising_edge(prbschk_locked);
	    wait for wait_locked_cycles*c_CLOCK_SYS_PERIOD;
	    wait until rising_edge(common_clk_mgt);
        channel_reset           <= '1';
        wait until falling_edge(prbschk_locked);
      end loop;
    end RESET_TEST;

  begin
      --! Basic test bench to observe waveforms  
      TEST_BENCH_STATUS         <= "         RESET           "; 

      -- Tx reset and channel reset
      prbsgen_reset <= '1';
      channel_reset <= '1';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

      -- Tx reset release
      prbsgen_reset <= '0';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
	  
      -- Channel Reset release      
      channel_reset <= '0';
      wait until rising_edge(prbschk_locked);
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

      -- Inject some errors which should be always correctable for FEC5-10G (burst of 6 consecutive bits)
      TEST_BENCH_STATUS         <= " INJECT CORRECTABLE ERROR"; 
	  INJECT_BURST_ERROR(6);
      TEST_BENCH_STATUS         <= "  RESET ERROR COUNTERS   "; 
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

      -- Inject some errors which should not be always correctable for FEC5-10G (7 consecutive bits)
      TEST_BENCH_STATUS         <= "INJECT NCORRECTABLE ERROR"; 
	  INJECT_BURST_ERROR(7);
      TEST_BENCH_STATUS         <= "  RESET ERROR COUNTERS   "; 
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
	  
	  -- Bypass FEC and check
      Tx_scrambler_bypass   <= '0';
      Tx_interleaver_bypass <= '0';   
      Rx_bypassInterleaver  <= '0';
      Rx_bypassFECEncoder   <= '1';
      Rx_bypassScrambler    <= '0';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
      TEST_BENCH_STATUS         <= "       FEC BYPASS        "; 
	  INJECT_BURST_ERROR(1);
      TEST_BENCH_STATUS         <= "  RESET ERROR COUNTERS   "; 
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

	  -- Bypass Scrambler
      Tx_scrambler_bypass   <= '1';
      Tx_interleaver_bypass <= '0';   
      Rx_bypassInterleaver  <= '0';
      Rx_bypassFECEncoder   <= '0';
      Rx_bypassScrambler    <= '1';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
      TEST_BENCH_STATUS         <= "    SCRAMBLER BYPASS     "; 
	  INJECT_BURST_ERROR(1);
      TEST_BENCH_STATUS         <= "  RESET ERROR COUNTERS   "; 
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

	  -- Bypass Interleaver
      Tx_scrambler_bypass   <= '0';
      Tx_interleaver_bypass <= '1';   
      Rx_bypassInterleaver  <= '1';
      Rx_bypassFECEncoder   <= '0';
      Rx_bypassScrambler    <= '0';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
      TEST_BENCH_STATUS         <= "   INTERLEAVER BYPASS    "; 
	  INJECT_BURST_ERROR(1);
      TEST_BENCH_STATUS         <= "  RESET ERROR COUNTERS   "; 
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);

      Tx_scrambler_bypass   <= '0';
      Tx_interleaver_bypass <= '0';   
      Rx_bypassInterleaver  <= '0';
      Rx_bypassFECEncoder   <= '0';
      Rx_bypassScrambler    <= '0';
	  wait for 100*c_CLOCK_MGT_PERIOD;
	  wait until rising_edge(common_clk_mgt);
	  
	  -- Reset test
      TEST_BENCH_STATUS         <= "       RESET TEST        "; 
	  RESET_TEST(5, 1000);
	  
      TEST_BENCH_STATUS         <= "         FINISHED        "; 

      wait;
  end process;
  TEST_BENCH_STATUS_O       <= TEST_BENCH_STATUS;
  ------------------------------------------------------------------------------
  
  --! Test Monitor -------------------------------------------------------------
  p_monitor : process is
    variable v_monitor_fec_corrected_cntr : integer;
    variable v_monitor_prbs_error_cntr    : integer;
  begin
    while(TEST_BENCH_STATUS /= "         FINISHED        ") loop
      wait until rising_edge(common_clk_mgt);	  
      if(TEST_BENCH_STATUS /= "  RESET ERROR COUNTERS   " and TEST_BENCH_STATUS /= "         RESET           ") then
	    if(prbschk_strobe='1' and prbschk_error='1') then
	      v_monitor_prbs_error_cntr    := v_monitor_prbs_error_cntr+1; -- frame errors
        end if;
	    if(Rx_uplinkClkOutEn='1') then
		  for i in 0 to g_PAYLOAD_LENGTH-1 loop
		    if(Rx_dataCorrected(i)='1') then
	          v_monitor_fec_corrected_cntr := v_monitor_fec_corrected_cntr+1;
			end if;
		  end loop;
		  for i in 0 to Rx_EcCorrected'left loop
		    if(Rx_EcCorrected(i)='1') then
	          v_monitor_fec_corrected_cntr := v_monitor_fec_corrected_cntr+1;
			end if;
		  end loop;
		  for i in 0 to Rx_IcCorrected'left loop
		    if(Rx_IcCorrected(i)='1') then
	          v_monitor_fec_corrected_cntr := v_monitor_fec_corrected_cntr+1;
			end if;
		  end loop;
        end if;
      else
        v_monitor_prbs_error_cntr    := 0;
        v_monitor_fec_corrected_cntr := 0;
      end if;
      FECMONITOR_O  <= v_monitor_fec_corrected_cntr;
      PRBSMONITOR_O <= v_monitor_prbs_error_cntr   ;
    end loop;
    wait;
  end process;
  ------------------------------------------------------------------------------
  
end architecture tb;
--==============================================================================
-- architecture end
--==============================================================================

