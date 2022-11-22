library ieee;
use ieee.std_logic_1164.all;
 
package tclink_lpgbt_pkg is
  
  type t_EXAMPLE_PROTOCOL is (SYMMETRIC_10G, SYMMETRIC_5G, FPGA_ASSYMMETRIC_RX10G, FPGA_ASSYMMETRIC_RX5G);
  function fcn_protocol_mgt_data_rate(type_protocol : t_EXAMPLE_PROTOCOL) return integer;
  function fcn_protocol_tx_width(type_protocol : t_EXAMPLE_PROTOCOL) return integer;
  function fcn_protocol_rx_width(type_protocol : t_EXAMPLE_PROTOCOL) return integer;

  subtype t_tclink_channel_controller_state_vector is std_logic_vector(16 downto 0);

  type tr_core_control is     
  record

    -- System reset. NOTE: This signal is ignored (and replaced by
    -- channel_controller_reset) if channel_controller_enable is high.
    reset_all : std_logic;

    -- Control over the channel controller FSM.
    channel_controller_reset  : std_logic;
    channel_controller_enable : std_logic;
    channel_controller_gentle : std_logic;
  
    -- CDC 40 phase-fixed (ignore if phase-fixed not required)
    phase_cdc40_tx_calib    : std_logic_vector(9 downto 0); -- Set to phase measured in first reset
    phase_cdc40_tx_force    : std_logic;                    -- Force the phase to be the calibrated one
    phase_cdc40_rx_calib    : std_logic_vector(2 downto 0); -- Set to phase measured in first reset
    phase_cdc40_rx_force    : std_logic;                    -- Force the phase to be the calibrated one

    -- FEC corrected clear (clear rx_fec_corrected_latched status flag)
    rx_fec_corrected_clear : std_logic;

    -- MGT resets. Most of these are pass-through when the channel
    -- controller is not enabled.
    mgt_reset_all                 : std_logic;
    mgt_reset_tx_pll_and_datapath : std_logic;
    mgt_reset_rx_pll_and_datapath : std_logic;
    mgt_reset_tx_datapath         : std_logic;
    mgt_reset_rx_datapath         : std_logic;
	
    -- MGT polarity
    mgt_txpolarity           : std_logic;
    mgt_rxpolarity           : std_logic;

    -- MGT built-in PRBS testing structures   
    mgt_txprbsforceerr       : std_logic;                                              
    mgt_txprbssel            : std_logic_vector(3 downto 0);  -- 0000  = Normal operation  
                                                              -- 0001  = PRBS-7  
                                                              -- 0010  = PRBS-9  
                                                              -- 0011  = PRBS-15  
                                                              -- 0100  = PRBS-23  
                                                              -- 0101  = PRBS-31  
                                                              -- 1001  = Square wave with 2 UI  (alternating 0s/1s)  
                                                              -- 1010  = Square wave with 32 UI						  
                                                              -- others = Reserved  													
															  
    mgt_rxprbscntreset       : std_logic;                     
    mgt_rxprbssel            : std_logic_vector(3 downto 0);  -- Same convention as mgt_txprbssel
	
    -- Dynamic reconfiguration port	
    mgt_drpwe                : std_logic;                      
    mgt_drpen                : std_logic;                      
    mgt_drpaddr              : std_logic_vector(9 downto 0);   
    mgt_drpdi                : std_logic_vector(15 downto 0);  

    -- Rx equalizer (feedthrough)
    mgt_rxeq_rxlpmgcovrden    : std_logic;
    mgt_rxeq_rxlpmhfovrden    : std_logic;
    mgt_rxeq_rxlpmlfklovrden  : std_logic;
    mgt_rxeq_rxlpmosovrden    : std_logic;
    mgt_rxeq_rxdfeagcovrden   : std_logic; -- only for Ultrascale+
    mgt_rxeq_rxdfelfovrden    : std_logic;
    mgt_rxeq_rxdfelpmreset    : std_logic;
    mgt_rxeq_rxdfeutovrden    : std_logic;
    mgt_rxeq_rxdfevpovrden    : std_logic;
    mgt_rxeq_rxlpmen          : std_logic;   
    mgt_rxeq_rxosovrden       : std_logic;

    -- MGT loopback (feedthrough)
    mgt_loopback              : std_logic_vector(2 downto 0); -- 000    = Normal operation  
                                                              -- 001    = Near-End PCS Loopback  
                                                              -- 010    = Near-End PMA Loopback  
                                                              -- 100    = Far-End PMA Loopback  
                                                              -- 110    = Far-End PCS Loopback  
                                                              -- others = Reserved  

   ---- HPTD IP
   mgt_hptd_tx_pi_phase_calib   : std_logic_vector(6 downto 0); 
   mgt_hptd_tx_ui_align_calib   : std_logic;
   mgt_hptd_ps_strobe          : std_logic;
   mgt_hptd_ps_inc_ndec        : std_logic;  
   mgt_hptd_ps_phase_step      : std_logic_vector(3 downto 0);

   -- This signal was set to static value inside the core
   --mgt_hptd_tx_fifo_fill_pd_max : std_logic_vector(31 downto 0);

  end record;
  type tr_core_control_array is array(natural range <>) of tr_core_control;  
  
  type tr_core_status is     
  record  

	-- Channel controller status
    channel_controller_running : std_logic;
    channel_controller_state   : t_tclink_channel_controller_state_vector;
    channel_ready              : std_logic;

	-- MMCM locked
	mmcm_locked                : std_logic;
	
    -- CDC 40 phase-fixed (ignore if phase-fixed not required)
    phase_cdc40_rx          : std_logic_vector(2 downto 0); -- Phase measurement
    phase_cdc40_tx          : std_logic_vector(9 downto 0); -- Phase measurement

    -- CDC 40 status
    cdc_40_tx_ready         : std_logic;
    cdc_40_rx_ready         : std_logic;
	
    -- FEC performed a correction (this means the line is not error-free)
    rx_fec_corrected_latched : std_logic;

    -- User status
	-- These flags indicate to the user when data is ready to be transmitter and received by this core
    rx_user_data_ready                     : std_logic; -- AND of conditions (rx_frame_locked, cdc_40_rx_ready, rx_data_not_idle)	
    tx_user_data_ready                     : std_logic; -- AND of conditions (mgt_tx_ready, cdc_40_tx_ready)	

	-- Rx data is not idle (constant)
	-- This flag goes to '0' if more than 100 consecutive data from the MGT are equal
	-- This is useful for debugging a fake-lock condition when the MGT is not receiving anything but a constant pattern that locks lpgbt protocol stucks in mgt_rx_data port 
    rx_data_not_idle                       : std_logic;

    -- Rx frame is locked to incoming stream
    rx_frame_locked                        : std_logic; -- Rx lpGBT datapath is locked to the header of the uplink protocol
	
    -- MGT and core are ready  
    mgt_tx_ready                           : std_logic; -- MGT tx ready and HPTD IP core is ready / user can start transmission
    mgt_rx_ready                           : std_logic; -- MGT rx ready

    -- MGT built-in PRBS testing structures
    mgt_rxprbserr                          : std_logic;
    mgt_rxprbslocked                       : std_logic;

    -- Dynamic reconfiguration port
    mgt_drprdy_latched                     : std_logic;   
    mgt_drpdo                              : std_logic_vector(15 downto 0);

    -- Equalizer monitor
    mgt_rxeq_dmonitor                      : std_logic_vector (15 downto 0); --#

    -- Reset status
    mgt_txpll_lock                         : std_logic;        
    mgt_rxpll_lock                         : std_logic;                                             
    mgt_buffbypass_rx_done                 : std_logic;  
    mgt_buffbypass_rx_error                : std_logic;  
    mgt_reset_rx_cdr_stable                : std_logic; -- Not very stable flag, it is not recommended to do something based on this flag 
    mgt_reset_tx_done                      : std_logic;  
    mgt_reset_rx_done                      : std_logic;  
    mgt_rxpmaresetdone                     : std_logic;  
    mgt_txpmaresetdone                     : std_logic;

    mgt_powergood                          : std_logic;
	
    ---- HPTD IP
    mgt_hptd_tx_pi_phase                   : std_logic_vector(6 downto 0); 
    mgt_hptd_tx_fifo_fill_pd               : std_logic_vector(31 downto 0);
    mgt_hptd_ps_done_latched               : std_logic; 
  end record;
  type tr_core_status_array is array(natural range <>) of tr_core_status;  
  
  type tr_tclink_control is  
  record
   ---- TCLink
   tclink_close_loop             : std_logic;                           --! TClink close loop
   tclink_offset_error           : std_logic_vector(47 downto 0);       --! Error offset - This is a fractional signed number
   -- Signals below - encouraged to be set to static value				  										 		  
   tclink_metastability_deglitch : std_logic_vector(15 downto 0);       --! Metastability deglitch threshold
   tclink_phase_detector_navg    : std_logic_vector(11 downto 0);       --! Averaging for phase detector                          
   tclink_modulo_carrier_period  : std_logic_vector(47 downto 0);       --! Modulo of carrier period in DDMTD UNITS (unit is index 10)
   tclink_master_rx_ui_period    : std_logic_vector(47 downto 0);                                                     
   tclink_Aie                    : std_logic_vector(3 downto 0);        --! Integral coefficient
   tclink_Aie_enable             : std_logic;                           --! Enables usage of integral coefficient
   tclink_Ape                    : std_logic_vector(3 downto 0);        --! Proportional coefficient                                                          
   tclink_sigma_delta_clk_div    : std_logic_vector(15 downto 0);       --! Sigma-delta clock divider modulo (unsigned)                                                
   tclink_enable_mirror          : std_logic;                           --! Enable mirror compensation scheme (a part of phase variation is compensated using this scheme, otherwise a full compensation is performed)
   tclink_Adco                   : std_logic_vector(47 downto 0);       --! DCO coefficient for mirror compensation	
   -- Tester   
   tclink_debug_tester_enable_stimulis  : std_logic;                    --! enable stimulis for TCLink
   tclink_debug_tester_fcw              : std_logic_vector(9 downto 0); --! frequency control word for NCO (unsigned)
   tclink_debug_tester_nco_scale        : std_logic_vector(4 downto 0); --! scale NCO output   
   tclink_debug_tester_enable_stock_out : std_logic;                    --! enable output data stock
   tclink_debug_tester_addr_read        : std_logic_vector(9 downto 0); --! read address for reading stocked TCLink phase accumulated results

  end record;
  type tr_tclink_control_array is array(natural range <>) of tr_tclink_control;  
  
  type tr_tclink_status is  
  record
    tclink_loop_closed            : std_logic;                            --! TCLink loop is closed
    tclink_phase_detector         : std_logic_vector(31 downto 0);        --! Phase-detector output, unit is bit 0
    tclink_error_controller       : std_logic_vector(47 downto 0);        --! Error output from error processing block (should be between -1*modulo_carrier_period_i/2 and +1*modulo_carrier_period_i/2)                         
    tclink_phase_acc              : std_logic_vector(15 downto 0);        --! phase accumulated output (integrated output)                                                --! This is an integer signed number, the LSB is the bit                                          
    tclink_operation_error        : std_logic;                            --! error output indicating that a clk_en_i pulse has arrived before the done_i signal arrived from the previous strobe_o request
    tclink_debug_tester_data_read : std_logic_vector(15 downto 0);        --! data of stocked TCLink phase accumulated results
  end record;
  type tr_tclink_status_array is array(natural range <>) of tr_tclink_status;  
  
  type tr_mgt_to_core is
  record
    rxdata_out                    :  std_logic_vector(31 downto 0); --! 10G: 31 downto 0, 5G: use only 15 downto 0
    dmonitorout_out               :  std_logic_vector(15 downto 0);
    drpdo_out                     :  std_logic_vector(15 downto 0);
    drprdy_out                    :  std_logic_vector(0 downto 0); 
    rxprbserr_out                 :  std_logic_vector(0 downto 0); 
    rxprbslocked_out              :  std_logic_vector(0 downto 0); 
    txbufstatus_out               :  std_logic_vector(1 downto 0);
    txplllock_out                 : std_logic_vector(0 downto 0);
    rxplllock_out                 : std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_done_out  : std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_error_out : std_logic_vector(0 downto 0);
    gtwiz_reset_rx_cdr_stable_out : std_logic_vector(0 downto 0);		
    gtwiz_reset_tx_done_out       : std_logic_vector(0 downto 0);
    gtwiz_reset_rx_done_out       : std_logic_vector(0 downto 0);	
    txpmaresetdone_out            : std_logic_vector(0 downto 0);
    rxpmaresetdone_out            : std_logic_vector(0 downto 0);
    gtpowergood_out               : std_logic_vector(0 downto 0);
  end record;                
  type tr_mgt_to_core_array is array(natural range <>) of tr_mgt_to_core;

  type tr_core_to_mgt is     
  record        
    txdata_in                          :  std_logic_vector(31 downto 0); --! 10G: 31 downto 0, 5G: use only 15 downto 0
    rxslide_in                         :  std_logic_vector(0 downto 0);
    gtwiz_reset_all_in                 :  std_logic_vector(0 downto 0);
    gtwiz_reset_tx_pll_and_datapath_in :  std_logic_vector(0 downto 0);
    gtwiz_reset_rx_pll_and_datapath_in :  std_logic_vector(0 downto 0);
    gtwiz_reset_tx_datapath_in         :  std_logic_vector(0 downto 0);
    gtwiz_reset_rx_datapath_in         :  std_logic_vector(0 downto 0);
    drpaddr_in                         :  std_logic_vector(9 downto 0); 
    drpclk_in                          :  std_logic_vector(0 downto 0); 
    drpdi_in                           :  std_logic_vector(15 downto 0);
    drpen_in                           :  std_logic_vector(0 downto 0); 
    drpwe_in                           :  std_logic_vector(0 downto 0); 
    dmonitorclk_in                     :  std_logic_vector(0 downto 0);  	
    rxpolarity_in                      :  std_logic_vector(0 downto 0); 
    rxprbscntreset_in                  :  std_logic_vector(0 downto 0); 
    rxprbssel_in                       :  std_logic_vector(3 downto 0); 
    txpippmen_in                       :  std_logic_vector(0 downto 0); 
    txpippmovrden_in                   :  std_logic_vector(0 downto 0); 
    txpippmpd_in                       :  std_logic_vector(0 downto 0); 
    txpippmsel_in                      :  std_logic_vector(0 downto 0); 
    txpippmstepsize_in                 :  std_logic_vector(4 downto 0); 
    txpolarity_in                      :  std_logic_vector(0 downto 0); 
    txprbsforceerr_in                  :  std_logic_vector(0 downto 0); 
    txprbssel_in                       :  std_logic_vector(3 downto 0);
    loopback_in                        :  std_logic_vector(2 downto 0);
    rxdfeagcovrden_in                  :  std_logic_vector(0 downto 0);
    rxdfelfovrden_in                   :  std_logic_vector(0 downto 0);
    rxdfelpmreset_in                   :  std_logic_vector(0 downto 0);
    rxdfeutovrden_in                   :  std_logic_vector(0 downto 0);
    rxdfevpovrden_in                   :  std_logic_vector(0 downto 0);
    rxlpmen_in                         :  std_logic_vector(0 downto 0);
    rxlpmgcovrden_in                   :  std_logic_vector(0 downto 0);
    rxlpmhfovrden_in                   :  std_logic_vector(0 downto 0);
    rxlpmlfklovrden_in                 :  std_logic_vector(0 downto 0);
    rxlpmosovrden_in                   :  std_logic_vector(0 downto 0);
    rxosovrden_in                      :  std_logic_vector(0 downto 0);

    gtwiz_buffbypass_rx_reset_in       : std_logic_vector(0 downto 0);
    gtwiz_buffbypass_rx_start_user_in  : std_logic_vector(0 downto 0);
    gtwiz_userclk_tx_active_in         : std_logic_vector(0 downto 0);
    gtwiz_userclk_rx_active_in         : std_logic_vector(0 downto 0);

		
  end record; 
  type tr_core_to_mgt_array is array(natural range <>) of tr_core_to_mgt;

  type tr_mgt_to_clk is record
    txoutclk : std_logic;
    rxoutclk : std_logic;
  end record;
  type tr_mgt_to_clk_array is array(natural range <>) of tr_mgt_to_clk;

  type tr_clk_to_mgt is record
    txusrclk : std_logic;
    rxusrclk : std_logic;
  end record;
  type tr_clk_to_mgt_array is array(natural range <>) of tr_clk_to_mgt;

end package tclink_lpgbt_pkg;

package body tclink_lpgbt_pkg is

  function fcn_protocol_mgt_data_rate(type_protocol : t_EXAMPLE_PROTOCOL) return integer is 
    variable v_data_rate : integer;
    variable v_tx_user_width : integer;
    variable v_rx_user_width : integer;
  begin
    if (type_protocol = SYMMETRIC_10G) then
        v_data_rate     := 2;
    elsif (type_protocol = SYMMETRIC_5G) then
        v_data_rate     := 1;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX10G) then
        v_data_rate     := 2;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX5G) then
        v_data_rate     := 1;
    else
        v_data_rate     := 0;
    end if;
    return v_data_rate;
  end function ;
  
  function fcn_protocol_tx_width(type_protocol : t_EXAMPLE_PROTOCOL) return integer is 
    variable v_tx_user_width : integer;
  begin
    if (type_protocol = SYMMETRIC_10G) then
        v_tx_user_width := 234;
    elsif (type_protocol = SYMMETRIC_5G) then
        v_tx_user_width := 116;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX10G) then
        v_tx_user_width := 36;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX5G) then
        v_tx_user_width := 36;
    else
        v_tx_user_width := 0;
    end if;
    return v_tx_user_width;
  end function ;
  
  function fcn_protocol_rx_width(type_protocol : t_EXAMPLE_PROTOCOL) return integer is 
    variable v_rx_user_width : integer;
  begin
    if (type_protocol = SYMMETRIC_10G) then
        v_rx_user_width := 234;
    elsif (type_protocol = SYMMETRIC_5G) then
        v_rx_user_width := 116;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX10G) then
        v_rx_user_width := 234;
    elsif (type_protocol = FPGA_ASSYMMETRIC_RX5G) then
        v_rx_user_width := 116;
    else
        v_rx_user_width := 0;
    end if;
    return v_rx_user_width;
  end function ;

end package body tclink_lpgbt_pkg;
