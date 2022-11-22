--==============================================================================
--! @file lpgbt_fe_tx.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
--! Specific packages

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: lpGBT-FE Tx uplink protocol (lpgbt_fe_tx_tx)
--
--! @brief lpGBT-FE Tx
--!
--! @author Csaba Soos                      - csaba.soos@cern.ch
--!         Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
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
--! 15\03\2018 -  CS  - Created lpgbt_ul_tx.vhd \n
--! 27\01\2019 - EBSM - Created from Csaba's original file and modified to give users the dummy bits of lpGBT protocol  \n
--!                   - Removed also bit synchronizers from this block \n
--!                   - Added comments and moved data-rate/fec selection as a generic to be more similar to lpGBT FPGA\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo - \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

entity lpgbt_fe_tx is
    generic(
      g_MGT_WORD_WIDTH     : integer := 32; -- Word width of MGT
	  g_DATA_RATE          : integer := 2;  -- 2=10G , 1=5G
	  g_FEC                : integer := 1   -- 1=FEC5, 2=FEC12
	);
    -- all ports are synchronous to mgt_clock_i
    port (
	  -- Clock / reset
      reset_i              : in  std_logic                      ; --! active high sync input
      mgt_clock_i          : in  std_logic                      ; --! mgt clock (320MHz)

	  -- User data         
	                                                              --!                        <--- 1-high / n-1 low --->
                                                                  --!                        ___                       ___                 ___    
      tx_strobe_i          : in  std_logic                      ; --!                    ___/   \_____________________/   \_______________/   \_______________
	  tx_data_i            : in  std_logic_vector(229 downto 0) ; --! User frame input      X         FRAME0          X         FRAME1    X         FRAME2                  
                                                                  --! datarate/FEC configuration:
                                                                  --! FEC5  /  5.12 Gbps => 112bit
                                                                  --! FEC12 /  5.12 Gbps => 98bit
                                                                  --! FEC5  / 10.24 Gbps => 230bit
                                                                  --! FEC12 / 10.24 Gbps => 202bit
      tx_ec_i              : in  std_logic_vector(1 downto 0)   ;
      tx_ic_i              : in  std_logic_vector(1 downto 0)   ;

	  -- MGT               
      tx_word_o            : out std_logic_vector(g_MGT_WORD_WIDTH-1 downto 0)  ;

	  -- Debugging         
	  scrambler_bypass_i   : in  std_logic;                       --! scrambler bypass
      interleaver_bypass_i : in  std_logic;                       --! interleaver bypass
	  tx_error_i           : in  std_logic_vector(255 downto 0)   --! Debug error injection port

    ); 
end entity lpgbt_fe_tx;

architecture rtl of lpgbt_fe_tx is
	
    component upLinkTxDataPath is
        port (
            clk                 : in  std_logic;
            dataEnable          : in  std_logic;
            txDataFrame         : in  std_logic_vector(229 downto 0);
            txIC                : in  std_logic_vector(1 downto 0);
            txEC                : in  std_logic_vector(1 downto 0);
            scramblerBypass     : in  std_logic;
            interleaverBypass   : in  std_logic;
            fecMode             : in  std_logic;
            txDataRate          : in  std_logic;
            scramblerReset      : in  std_logic;
            upLinkFrame         : out std_logic_vector(255 downto 0)
        );
    end component upLinkTxDataPath;
    
    component upLinkTxGearBox is
	    generic(
		    g_WORD_WIDTH      : integer := 32;
			g_DATA_RATE       : integer := 2 
		);
        port (
            clock           : in  std_logic;
            reset           : in  std_logic;
            dataStrobe      : in  std_logic;
            dataFrame       : in  std_logic_vector(255 downto 0);
            errorFrame      : in  std_logic_vector(255 downto 0);
            dataWord        : out std_logic_vector(g_WORD_WIDTH-1 downto 0)
        );
    end component upLinkTxGearBox;

	-- datapath <-> gearbox                 
    signal tx_frame_data    : std_logic_vector(255 downto 0);

    -- aux for config datapath which are pins in the ASIC
    signal fec_mode         : std_logic ; --! 0=FEC5, 1=FEC12
    signal data_rate        : std_logic ; --! 0=5G  , 1=10G  
	  
begin  -- architecture rtl

    -- FEC
    gen_FEC5: if g_FEC=1 generate
      fec_mode <= '0';
    end generate gen_FEC5;
    gen_FEC12: if g_FEC=2 generate
      fec_mode <= '1';
    end generate gen_FEC12;

	-- Data-rate
    gen_5G: if g_DATA_RATE=1 generate
      data_rate <= '0';
    end generate gen_5G;
    gen_10G: if g_DATA_RATE=2 generate
      data_rate <= '1';
    end generate gen_10G;

    txdatapath_inst : upLinkTxDataPath
        port map (
            clk                 => mgt_clock_i         ,
            dataEnable          => tx_strobe_i         ,
            txDataFrame         => tx_data_i           ,
            txIC                => tx_ic_i             ,
            txEC                => tx_ec_i             ,
            scramblerBypass     => scrambler_bypass_i  ,
            interleaverBypass   => interleaver_bypass_i,
            fecMode             => fec_mode            ,
            txDataRate          => data_rate           ,
            scramblerReset      => reset_i             ,
            upLinkFrame         => tx_frame_data
        );

    txgearbox_inst : upLinkTxGearBox
	    generic map(
		    g_WORD_WIDTH => g_MGT_WORD_WIDTH,
			g_DATA_RATE  => g_DATA_RATE
		)
        port map (
            clock           => mgt_clock_i   ,
            reset           => reset_i       ,
            dataStrobe      => tx_strobe_i   ,
            dataFrame       => tx_frame_data ,
            errorFrame      => tx_error_i    ,
            dataWord        => tx_word_o
        );

end architecture rtl;
