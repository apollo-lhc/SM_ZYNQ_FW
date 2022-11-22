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
--! @file mgt_fixed_phase.vhd
--==============================================================================
--! Standard library
library ieee;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Specific packages
library UNISIM; 
use UNISIM.vcomponents.all;

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, HPTD
-- --
-------------------------------------------------------------------------------
--
-- unit name: Example design for fixed-phase MGT infrastructure with debugging options (mgt_fixed_phase)
--
--! @brief Example design for fixed-phase MGT infrastructure with debugging options
--!
--! @author Eduardo Brandao de Souza Mendes - eduardo.brandao.de.souza.mendes@cern.ch
--! @date 18\10\2019
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
--! Entity declaration for mgt_fixed_phase
--==============================================================================
entity mgt_fixed_phase is
    port (
        --***************************************************************
        --************************ USER PORTS ***************************
        --***************************************************************
		
        -----------------------------------------------------------------
        --------------------- System clock / resets ---------------------
        -----------------------------------------------------------------
        -- System clock (must come from a free-running source)
        clk_sys_i                       : in  std_logic;                     --! system clock input
        reset_i                         : in  std_logic;                     --! system clock reset / sync to clk_sys_i

        clk_txusr_i                     : in  std_logic;                     --! txusrclk from transceiver
        clk_rxusr_i                     : in  std_logic;                     --! rxusrclk from transceiver

        tx_ready_o                      : out std_logic;                     --! Tx is ready for data transmission (use as reset for tx logic) / sync to clk_sys_i
        rx_ready_o                      : out std_logic;                     --! Rx is ready for data transmission (use as reset for rx logic) / sync to clk_sys_i

        -----------------------------------------------------------------
        --------------- Low-level transceiver control/debug -------------
        -----------------------------------------------------------------
        -- Polarity control
        txpolarity_i                    : in std_logic;                      --! Tx serial data polarity inversion / sync to clk_sys_i
        rxpolarity_i                    : in std_logic;                      --! Rx serial data polarity inversion / sync to clk_sys_i

        -- Built-in PRBS testing structures
        txprbsforceerr_i                : in  std_logic;                     --! Tx prbs force errors  / sync to clk_sys_i
        txprbssel_i                     : in  std_logic_vector(3 downto 0);  --! Tx built-in data generator pattern selection  / sync to clk_sys_i
                                                                             --! 0000  = Normal operation
                                                                             --! 0001  = PRBS-7
                                                                             --! 0010  = PRBS-9
                                                                             --! 0011  = PRBS-15
                                                                             --! 0100  = PRBS-23
                                                                             --! 0101  = PRBS-31
                                                                             --! 1001  = Square wave with 2 UI  (alternating 0s/1s)
                                                                             --! 1010  = Square wave with 32 UI																			
                                                                             --! others = Reserved
                                                      
        rxprbscntreset_i                : in  std_logic;                     --! Rx prbs error counter reset  / sync to clk_sys_i
        rxprbssel_i                     : in  std_logic_vector(3 downto 0);  --! Rx built-in data checker pattern selection (same convention as txprbssel_i)  / sync to clk_sys_i
        rxprbserr_o                     : out std_logic;                     --! Rx built-in error detection flag  / sync to clk_sys_i
        rxprbslocked_o                  : out std_logic;                     --! Rx built-in prbs locked flag  / sync to clk_sys_i

        -----------------------------------------------------------------
        ----------------------------- DRP -------------------------------
        -----------------------------------------------------------------
        -- Dynamic reconfiguration port
        drpwe_i                         : in  std_logic;                     --! DRP write enable  / sync to clk_sys_i
        drpen_i                         : in  std_logic;                     --! DRP enable (a rising edge detector is included in mgt_fixed_phase to allow slow control)  / sync to clk_sys_i
        drpaddr_i                       : in  std_logic_vector(9 downto 0);  --! DRP address  / sync to clk_sys_i
        drpdi_i                         : in  std_logic_vector(15 downto 0); --! DRP Data In  / sync to clk_sys_i
        drprdy_latched_o                : out std_logic;                     --! DRP ready  (goes to 0 when drpen_i rising edge is detected, goes to 1 when transceiver drprdy issues a pulse)  / sync to clk_sys_i
        drpdo_o                         : out std_logic_vector(15 downto 0); --! DRP Data Out 

        -----------------------------------------------------------------
        ------------------- HPTD IP - Tx Phase Aligner ------------------
        -----------------------------------------------------------------
        -- Configuration
        tx_fifo_fill_pd_max_i           : in std_logic_vector(31 downto 0); --! Minimum 0x00400000 / sync to clk_sys_i  
        tx_pi_phase_calib_i             : in std_logic_vector(6 downto 0);  --! Connect to tx_pi_phase_o value after first reset / sync to clk_sys_i  
        tx_ui_align_calib_i             : in std_logic;                     --! Connect to 1 to freeze tx_pi_phase after first reset / sync to clk_sys_i    

        -- Tx PI phase value
        tx_pi_phase_o                   : out std_logic_vector(6 downto 0); --! Tx PI phase / sync to clk_sys_i    

        -- Tx fifo fill level phase detector                                   
        tx_fifo_fill_pd_o               : out std_logic_vector(31 downto 0); --! Tx PD value / sync to clk_sys_i    

        -- Fine Phase Shift Interface (only valid once transceiver is ready tx_ready_o=1)
        ps_strobe_i                     : in  std_logic; --! Shall be used only once tx_ready_o='1', moves tx phase / sync to clk_sys_i    
        ps_inc_ndec_i                   : in  std_logic; --! Increment or decrement phase / sync to clk_sys_i 
        ps_phase_step_i                 : in  std_logic_vector(3 downto 0); --! Step number in Tx PI units / sync to clk_sys_i   
        ps_done_latched_o               : out std_logic; --! Goes to 0 when ps_strobe_i rising edge is detected, goes to 1 when requested phase shift is performed (rising edge is detected in ps_strobe_i)  / sync to clk_sys_i   

        -----------------------------------------------------------------
        --------------------- Digital Monitor ---------------------------
        -----------------------------------------------------------------  
        dmonitor_o                      : out std_logic_vector (15 downto 0); --! Rx Digital Monitor / sync to clk_sys_i    

        --***************************************************************
        --************************* MGT PORTS ***************************
        --***************************************************************
        -- Status
        mgt_reset_tx_done_i                       : in  std_logic; --! MGT Tx reset is finished / sync to clk_txusr_i
        mgt_reset_rx_done_i                       : in  std_logic; --! MGT Rx reset is finished / sync to clk_rxusr_i

        -- DRP bus / sync to clk_sys_i    
        mgt_drpaddr_o                             : out std_logic_vector(9 downto 0);
        mgt_drpclk_o                              : out std_logic;
        mgt_drpdi_o                               : out std_logic_vector(15 downto 0);
        mgt_drpen_o                               : out std_logic;
        mgt_drpwe_o                               : out std_logic;
        mgt_drpdo_i                               : in  std_logic_vector(15 downto 0);
        mgt_drprdy_i                              : in  std_logic;		
		
        -- Digital Monitor / sync to clk_sys_i 
        mgt_dmonitorclk_o                         : out std_logic;
        mgt_dmonitorout_i                         : in  std_logic_vector(15 downto 0);
		
        -- Polarity
        mgt_txpolarity_o                          : out std_logic; --! sync to clk_txusr_i
        mgt_rxpolarity_o                          : out std_logic; --! sync to clk_rxusr_i
		
        -- Tx PRBS / sync to clk_txusr_i 
        mgt_txprbsforceerr_o                      : out std_logic;
        mgt_txprbssel_o                           : out std_logic_vector(3 downto 0);
		
        -- Rx PRBS / sync to clk_rxusr_i 
        mgt_rxprbserr_i                           : in  std_logic;
        mgt_rxprbslocked_i                        : in  std_logic;
        mgt_rxprbscntreset_o                      : out std_logic;
        mgt_rxprbssel_o                           : out std_logic_vector(3 downto 0);

        -- Tx PI + FIFO Fill level flag / sync to clk_txusr_i 
        mgt_txbufstatus_i                         : in  std_logic_vector(1 downto 0);
        mgt_txpippmen_o                           : out std_logic;
        mgt_txpippmovrden_o                       : out std_logic;
        mgt_txpippmpd_o                           : out std_logic;
        mgt_txpippmsel_o                          : out std_logic;
        mgt_txpippmstepsize_o                     : out std_logic_vector(4 downto 0)
	);
end entity mgt_fixed_phase;

--==============================================================================
-- architecture declaration
--==============================================================================

architecture rtl of mgt_fixed_phase is

  --! Function declaration

  --! Constant declaration
 
  --! Signal declaration    
  ------------------------- Auxiliar MGT interface ------------------------------
  signal tx_ready_async                     : std_logic;                    -- user ready status
  signal rx_ready_async                     : std_logic;                    -- user ready status
  signal mgt_rxprbserr_i_latched            : std_logic;                    -- latch mgt_rxprbserr_i flag   
  signal rxprbscntreset_s                   : std_logic;                    -- rx PRBS counter reset

  -------------------------------- DRP arbiter ----------------------------------
  constant c_NUM_DRP_MASTER                 : integer := 2;
  signal   master_drpwe                     : std_logic_vector(c_NUM_DRP_MASTER-1 downto 0);
  signal   master_drpen                     : std_logic_vector(c_NUM_DRP_MASTER-1 downto 0);
  signal   master_drpaddr                   : std_logic_vector(10*c_NUM_DRP_MASTER-1 downto 0);
  signal   master_drpdi                     : std_logic_vector(16*c_NUM_DRP_MASTER-1 downto 0);
  signal   master_drprdy                    : std_logic_vector(c_NUM_DRP_MASTER-1 downto 0);
  signal   master_drpdo                     : std_logic_vector(16*c_NUM_DRP_MASTER-1 downto 0);

  signal   drpen_r                          : std_logic;
  
  ------------------------- HPTD IP Core - Tx Phase Aligner ---------------------     
  signal tx_fifo_fill_level                 : std_logic;  
  signal tx_phase_aligner_reset_async       : std_logic;
  signal tx_phase_aligner_reset_syssync     : std_logic;  
  signal tx_aligned                         : std_logic;
  signal ps_strobe_r                        : std_logic;
  signal ps_done_hptd                       : std_logic;

  ------------------------------- Digital Monitor ---------------------------      
  signal dmonitorout_r                      : std_logic_vector (15 downto 0);
  signal dmonitorout_r2                     : std_logic_vector (15 downto 0);
  signal dmonitorout_latch                  : std_logic_vector (15 downto 0);
    
  --! Component declaration
  component reset_synchronizer
    port (
      clk_in  : in  std_logic;
      rst_in  : in  std_logic;
      rst_out : out std_logic
    );
  end component;

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

  component drp_arbiter is
    generic(
      g_NUM_MASTER : integer := 2
    );
    port (
      -- global input signals --
      clk_i   : in std_logic;
      reset_i : in std_logic;
      --------------------------

      -- Interface to user --
      master_drpwe_i   : in  std_logic_vector(g_NUM_MASTER-1 downto 0);
      master_drpen_i   : in  std_logic_vector(g_NUM_MASTER-1 downto 0);
      master_drpaddr_i : in  std_logic_vector(10*g_NUM_MASTER-1 downto 0);
      master_drpdi_i   : in  std_logic_vector(16*g_NUM_MASTER-1 downto 0);
      master_drprdy_o  : out std_logic_vector(g_NUM_MASTER-1 downto 0);
      master_drpdo_o   : out std_logic_vector(16*g_NUM_MASTER-1 downto 0);
      -------------------------------
  
      -- DRP connection to GTH/GTX --
      mgt_drpwe_o   : out std_logic;
      mgt_drpen_o   : out std_logic;
      mgt_drpaddr_o : out std_logic_vector(9 downto 0);
      mgt_drpdi_o   : out std_logic_vector(15 downto 0);
      mgt_drprdy_i  : in  std_logic;
      mgt_drpdo_i   : in  std_logic_vector(15 downto 0)
      -------------------------------
    );
  end component drp_arbiter;

  component tx_phase_aligner is
    generic(
      -- User choice of DRP control or port control
      g_DRP_NPORT_CTRL        : boolean                      := true; 
      g_DRP_ADDR_TXPI_PPM_CFG : std_logic_vector(8 downto 0) := ("010011010")  
    );                                                                      
    port (
      --==============================================================================
      --! User control/monitor ports
      --==============================================================================  
      -- Clock / reset                                                     
      clk_sys_i : in std_logic;      
      reset_i   : in std_logic;  
  
      -- Top level interface                                                 
      tx_aligned_o : out std_logic;  
  
      -- Config (for different flavours)
      tx_pi_phase_calib_i   : in std_logic_vector(6 downto 0); 
      tx_ui_align_calib_i   : in std_logic;  
      tx_fifo_fill_pd_max_i : in std_logic_vector(31 downto 0);  
      tx_fine_realign_i     : in std_logic;  
  
      ps_strobe_i     : in  std_logic;  
      ps_inc_ndec_i   : in  std_logic;  
      ps_phase_step_i : in  std_logic_vector(3 downto 0);  
      ps_done_o       : out std_logic;  
  
      -- Tx PI phase value
      tx_pi_phase_o : out std_logic_vector(6 downto 0);  
  
      -- Tx fifo fill level phase detector                                   
      tx_fifo_fill_pd_o : out std_logic_vector(31 downto 0);
  
      --==============================================================================
      --! MGT ports
      --==============================================================================
      clk_txusr_i          : in std_logic; 
    
      -- Tx fifo fill level
      tx_fifo_fill_level_i : in std_logic;
  
      -- Transmitter PI ports
      txpippmen_o       : out std_logic;  
      txpippmovrden_o   : out std_logic;  
      txpippmsel_o      : out std_logic;  
      txpippmpd_o       : out std_logic;  
      txpippmstepsize_o : out std_logic_vector(4 downto 0);  
  
      -- DRP interface
      drpaddr_o : out std_logic_vector(8 downto 0);   
      drpen_o   : out std_logic;                      
      drpdi_o   : out std_logic_vector(15 downto 0);  
      drprdy_i  : in  std_logic;                      
      drpdo_i   : in  std_logic_vector(15 downto 0);  
      drpwe_o   : out std_logic                       
    );
  end component tx_phase_aligner;
        
begin
  
  --============================================================================
  --! User Tx/Rx Ready
  --============================================================================
  tx_ready_async <= tx_aligned and mgt_reset_tx_done_i;
  cmp_tx_ready_bit_synchronizer : bit_synchronizer
    port map (
      clk_in  => clk_sys_i,
      i_in    => tx_ready_async,
      o_out   => tx_ready_o
  );  

  rx_ready_async <= mgt_reset_rx_done_i;
  cmp_rx_ready_bit_synchronizer : bit_synchronizer
    port map (
      clk_in  => clk_sys_i,
      i_in    => rx_ready_async,
      o_out   => rx_ready_o
  );

  --============================================================================
  --! Transceiver low-level control/testing features
  --============================================================================
  -- Polarity control
  txpolarity_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txpolarity_i,
      o_out  => mgt_txpolarity_o
  );

  rxpolarity_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxpolarity_i,
      o_out  => mgt_rxpolarity_o
  );  

  -- Built-in PRBS testing structures
  txprbsforceerr_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txprbsforceerr_i,
      o_out  => mgt_txprbsforceerr_o
  );  

  txprbssel0_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txprbssel_i(0),
      o_out  => mgt_txprbssel_o(0)
  );  
  txprbssel1_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txprbssel_i(1),
      o_out  => mgt_txprbssel_o(1)
  );  
  txprbssel2_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txprbssel_i(2),
      o_out  => mgt_txprbssel_o(2)
  );
  txprbssel3_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_txusr_i,
      i_in   => txprbssel_i(3),
      o_out  => mgt_txprbssel_o(3)
  );     
      
  rxprbscntreset_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxprbscntreset_i,
      o_out  => rxprbscntreset_s
  );
  mgt_rxprbscntreset_o <= rxprbscntreset_s;
		 
  rxprbssel0_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxprbssel_i(0),
      o_out  => mgt_rxprbssel_o(0)
  );   
  rxprbssel1_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxprbssel_i(1),
      o_out  => mgt_rxprbssel_o(1)
  );  
  rxprbssel2_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxprbssel_i(2),
      o_out  => mgt_rxprbssel_o(2)
  );  
  rxprbssel3_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_rxusr_i,
      i_in   => rxprbssel_i(3),
      o_out  => mgt_rxprbssel_o(3)
  );

  -- Latch error flag for software control
  p_rxprbserrlatched : process (clk_rxusr_i) is
  begin
    if clk_rxusr_i'event and clk_rxusr_i = '1' then
      if rxprbscntreset_s = '1' then
        mgt_rxprbserr_i_latched <= '0';
      else
        if(mgt_rxprbserr_i = '1') then
        mgt_rxprbserr_i_latched <= '1';
        end if;
      end if;
    end if;
  end process p_rxprbserrlatched;

  rxprbserr_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_sys_i,
      i_in   => mgt_rxprbserr_i_latched,
      o_out  => rxprbserr_o
  );

  rxprbslocked_bit_synchronizer : bit_synchronizer
    port map(
      clk_in => clk_sys_i,
      i_in   => mgt_rxprbslocked_i,
      o_out  => rxprbslocked_o
  );                     

  --============================================================================
  --! DRP arbiter
  --============================================================================      
  cmp_drp_arbiter : drp_arbiter
    generic map(
      g_NUM_MASTER => c_NUM_DRP_MASTER
      )
    port map(
      -- global input signals --
      clk_i   => clk_sys_i,
      reset_i => reset_i,
      --------------------------

      -- Interface to user --
      master_drpwe_i   => master_drpwe,
      master_drpen_i   => master_drpen,
      master_drpaddr_i => master_drpaddr,
      master_drpdi_i   => master_drpdi,
      master_drprdy_o  => master_drprdy,
      master_drpdo_o   => master_drpdo,
      -------------------------------

      -- DRP connection to GTH/GTX --
      mgt_drpwe_o   => mgt_drpwe_o,
      mgt_drpen_o   => mgt_drpen_o,
      mgt_drpaddr_o => mgt_drpaddr_o,
      mgt_drpdi_o   => mgt_drpdi_o,
      mgt_drprdy_i  => mgt_drprdy_i,
      mgt_drpdo_i   => mgt_drpdo_i
      -------------------------------
  );

  mgt_drpclk_o      <= clk_sys_i;

  --============================================================================
  --! DRP user control
  --============================================================================
  p_drp_user_access : process (clk_sys_i) is
  begin
    if clk_sys_i'event and clk_sys_i = '1' then
      if(reset_i='1') then
        drpen_r          <= '0';
        master_drpen(1)  <= '0';
        drprdy_latched_o <= '0';
        drpdo_o          <= (others => '0'); 
      else
        drpen_r  <= drpen_i;  
        if(drpen_i = '1' and drpen_r = '0') then -- detects rising edge of drpen_i signal
          master_drpen(1)  <= '1';
          drprdy_latched_o <= '0';
        else
          master_drpen(1)  <= '0';
          if(master_drprdy(1) = '1') then
            drpdo_o          <= master_drpdo(16*2-1 downto 16*1)  ;
            drprdy_latched_o <= '1';
          end if; 		  
        end if;	
      end if;	  
    end if;
  end process p_drp_user_access;  
  master_drpwe(1)                    <= drpwe_i                           ;
  master_drpaddr(10*2-1 downto 10*1) <= drpaddr_i                         ; 
  master_drpdi(16*2-1 downto 16*1)   <= drpdi_i                           ;  

  --============================================================================
  --! HPTD IP Core - Tx Phase Aligner
  --============================================================================
  -- Reset HPTD IP Core until transceiver is not ready
  tx_phase_aligner_reset_async <= not mgt_reset_tx_done_i;
  reset_synchronizer_tx_phase_aligner_inst : reset_synchronizer
    port map (
      clk_in  => clk_sys_i,
      rst_in  => tx_phase_aligner_reset_async,
      rst_out => tx_phase_aligner_reset_syssync
  );

  cmp_tx_phase_aligner : tx_phase_aligner
    generic map(
      -- User choice of DRP control or port control
      -- Recommended nowadays to use in DRP control as a strange behaviour was observed using the port in PI code stepping mode
      g_DRP_NPORT_CTRL        => true,
      g_DRP_ADDR_TXPI_PPM_CFG => "010011010"
      )                                                                 
    port map(
      --==============================================================================
      --! User control/monitor ports
      --==============================================================================  
      -- Clock / reset                                                     
      clk_sys_i             => clk_sys_i                     ,
      reset_i               => tx_phase_aligner_reset_syssync,

      -- Top level interface                                                 
      tx_aligned_o          => tx_aligned                    ,

      -- Config (for different flavours)
      tx_pi_phase_calib_i   => tx_pi_phase_calib_i           ,
      tx_ui_align_calib_i   => tx_ui_align_calib_i           ,
      tx_fifo_fill_pd_max_i => tx_fifo_fill_pd_max_i         ,


      tx_fine_realign_i     => '0'                           ,

      -- It is only valid to re-shift clock once aligned (tx_aligned_o = '1') 
      ps_strobe_i           => ps_strobe_i                   ,
      ps_inc_ndec_i         => ps_inc_ndec_i                 ,
      ps_phase_step_i       => ps_phase_step_i               ,
      ps_done_o             => ps_done_hptd                  ,

      -- Tx PI phase value
      tx_pi_phase_o         => tx_pi_phase_o                 ,

      -- Tx fifo fill level phase detector                                   
      tx_fifo_fill_pd_o     => tx_fifo_fill_pd_o             ,

      --==============================================================================
      --! MGT ports
      --==============================================================================
      clk_txusr_i           => clk_txusr_i               ,
                                                             
      -- Tx fifo fill level	                                 
      tx_fifo_fill_level_i  => tx_fifo_fill_level        ,

      -- Transmitter PI ports           
      txpippmen_o           => mgt_txpippmen_o               ,
      txpippmovrden_o       => mgt_txpippmovrden_o           ,
      txpippmsel_o          => mgt_txpippmsel_o              ,
      txpippmpd_o           => mgt_txpippmpd_o               ,
      txpippmstepsize_o     => mgt_txpippmstepsize_o            ,

      -- DRP interface         
      drpaddr_o             => master_drpaddr(10*1-2 downto 10*0) ,
      drpen_o               => master_drpen(0)                    ,
      drpdi_o               => master_drpdi(16*1-1 downto 16*0)   ,
      drprdy_i              => master_drprdy(0)                   ,
      drpdo_i               => master_drpdo(16*1-1 downto 16*0)   ,
      drpwe_o               => master_drpwe(0)

  );
  tx_fifo_fill_level <= mgt_txbufstatus_i(0) when rising_edge(clk_txusr_i);
  master_drpaddr(10*1-1) <= '0' ;

  --! Latch ps_done for slow control
  p_hptd_ps_done_latched : process (clk_sys_i) is
  begin
    if clk_sys_i'event and clk_sys_i = '1' then
      if(tx_phase_aligner_reset_syssync='1' or tx_aligned='0') then
        ps_strobe_r       <= '0';
        ps_done_latched_o <= '0';
      else
        ps_strobe_r  <= ps_strobe_i;  
        if(ps_strobe_i = '1' and ps_strobe_r = '0') then -- detects rising edge of ps_strobe_i signal
          ps_done_latched_o <= '0';
        else
          if(ps_done_hptd = '1') then
            ps_done_latched_o <= '1';
          end if; 		  
        end if;	
      end if;	  
    end if;
  end process p_hptd_ps_done_latched;  

  --============================================================================
  --! Receiver Equalizer Control
  --============================================================================               
  -- digital monitor			   
  mgt_dmonitorclk_o     <= clk_sys_i;

  -- Changes in dmonitorout port are slow compared to clk_sys_i
  -- Following process avoids metastability in dmonitorout_latch port  
  p_dmonitor : process (clk_sys_i) is
  begin
    if clk_sys_i'event and clk_sys_i = '1' then  
      dmonitorout_r  <= mgt_dmonitorout_i;
      dmonitorout_r2 <= dmonitorout_r;
      if(dmonitorout_r = dmonitorout_r2) then
        dmonitorout_latch <= dmonitorout_r2;
      else
        dmonitorout_latch <= dmonitorout_latch;
      end if;
    end if;
  end process p_dmonitor;

  dmonitor_o <= dmonitorout_latch;

end architecture rtl;
--==============================================================================
-- architecture end
--==============================================================================