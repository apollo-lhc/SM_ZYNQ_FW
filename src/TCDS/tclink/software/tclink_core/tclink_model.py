#!/usr/bin/env python

#==============================================================================
# C Copyright CERN for the benefit of the HPTD interest group 2019. All rights not
#   expressly granted are reserved.
#
#   This file is part of TCLink.
#
# TCLink is free VHDL code: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# TCLink is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with TCLink.  If not, see <https://www.gnu.org/licenses/>.
#==============================================================================
# Author: EBSM - CERN EP/ESE
# Date: 14/11/2019
#==============================================================================

#-----------------------------------------------------------------
#---                  Python Native Packages                   ---
#-----------------------------------------------------------------
import math

# -------------------------------------------------------------
#  -------------- Class TCLink (low-layer) ------------
# -------------------------------------------------------------
class TCLinkModel():

    # --------------- Constructor ---------------
    def __init__(self, filename='default'):
        # Fixed-values which are firmware revision-dependent
        self.CONTROLLER_DATA_WIDTH     = 48
        self.CONTROLLER_FIXEDPOINT_BIT = 16
        self.COEFF_SIZE                = 4
        self.TESTER_LENGTH_NCO_ROM     = 1024
        self.TESTER_AMPLITUDE_NCO      = (2**31-1)*(2**16)
        self.CONFIGURATION_NAME = None
        self.user_config = {}
        self.model       = {}
        self.vhdl        = {}
        self.probes      = {}
        self.load_configuration(filename)

    #-----------------------------------------------------------------
    #---                 Load user parameters                      ---
    #--- Also calculates model parameters and VHDL parameters      ---
    #-----------------------------------------------------------------
    def load_configuration(self, filename):
        self.CONFIGURATION_NAME = filename
        with open('./config/' + filename + '.csv','r') as f:
            data = f.read()
            data = data.split('\n')
            for i in data:
                i = i.strip(' ')
                # Check if data is a comment
                if(len(i)>0):
                    if(i[0]!='#'):
                        i = i.split(',')
                        if(len(i) == 2):
                            self.user_config[i[0].strip(' ')] = float(i[1])
        self.calculate_model_parameters()
        self.calculate_vhdl_parameters()

    #-----------------------------------------------------------------
    #---               High-level model parameters                 ---
    #-----------------------------------------------------------------
    def calculate_model_parameters(self):
        #-----------------------------------------------------------------
        #---                     Transmitter PI                        ---
        #-----------------------------------------------------------------
        # Transmitter Phase-Interpolator bin-size in ps
        self.model['dco_step']   = (1e12/self.user_config['tx_datarate'])*(1.0/(64.0*self.user_config['txoutdiv']))  

        #-----------------------------------------------------------------
        #---                     Phase-detector                        ---
        #-----------------------------------------------------------------
        # Main carrier frequency.
        carrier_freq = 1.*self.user_config['carrier_freq']
        # Offset frequency used for the DDMTD.
        ddmtd_offset_freq = 1.*self.user_config['ddmtd_offset_freq']
        # The resulting DDMTD beat frequency.
        ddmtd_beat_freq = carrier_freq - ddmtd_offset_freq
        self.model['ddmtd_beat_freq'] = ddmtd_beat_freq
        # Loop sampling frequency in Hz
        self.model['loop_sample_freq'] = ddmtd_beat_freq/(self.user_config['ddmtd_avg']+1);    

        # DDMTD common-clock frequency in Hz        
        self.model['ddmtd_freq'] = ddmtd_offset_freq

        # DDMTD bin-size in ps        
        self.model['ddmtd_step'] = 1e12*ddmtd_beat_freq/(carrier_freq*ddmtd_offset_freq)

        #-----------------------------------------------------------------
        #---                    Mirror compensation                    ---
        #-----------------------------------------------------------------
        # Beta coefficient        
        self.model['beta']       = (1-self.user_config['alpha'])/self.user_config['alpha']  
        
        # self.model['Kdco'] constant for the plant - unit is DDMTD_UNIT/(cycle*PI_CTRL_UNIT)             
        self.model['Kdcoplant']  = self.model['dco_step']/(self.model['ddmtd_step']/self.user_config['ddmtd_avg']);                                                                                      

        # self.model['Kdco'] constant for the mirror - unit is DDMTD_UNIT/(cycle*PI_CTRL_UNIT)   
        self.model['Kdcomirror']       = (self.model['beta']*self.model['dco_step']/(self.model['ddmtd_step']/self.user_config['ddmtd_avg']));

        if(self.user_config['enable_mirror']) : self.model['Kdco'] = self.model['Kdcomirror'] + self.model['Kdcoplant']
        else                                  : self.model['Kdco'] = self.model['Kdcoplant']
		
        #-----------------------------------------------------------------
        #---                      Loop dynamics                        ---
        #-----------------------------------------------------------------
        self.model['sigma_delta_osr']       = math.log2(self.user_config['SD_OSR'])

        # Loop natural requency relative to loop sampling frequency
        self.model['fn'] = self.user_config['natural_freq']/self.model['loop_sample_freq'];                          

        if(self.user_config['enable_Ki']):
            # Integral part
            self.model['Ki']      = 2**round(math.log2((self.model['fn']*self.model['fn']*(2*math.pi)*(2*math.pi))/(self.model['Kdco'])))                  
            # Proportional part
            self.model['Kp']      = 2**round(math.log2(2*self.user_config['damping']*math.sqrt(self.model['Ki']/(self.model['Kdco'])))) 
            # Calculate real parameters (simplification from log2 operation in self.model['Kp'], self.model['Ki'])
            self.model['fn_real'] = math.sqrt(self.model['Ki']*self.model['Kdco'])/(2*math.pi)
            self.model['damping_real'] = self.model['Kp']/(2*math.sqrt(self.model['Ki']/(self.model['Kdco'])))
        else:
            # Integral part
            self.model['Ki']            = 0                                                    
            # Proportional part
            self.model['Kp']            = 2**round(math.log2((2*math.pi*self.model['fn']/self.model['Kdco'])))             
            # Calculate real parameters (simplification from log2 operation in self.model['Kp'])
            self.model['fn_real']       = self.model['Kp']*self.model['Kdco']/(2*math.pi)

        # Calculate the real natural frequency
        self.model['natural_freq_real'] = self.model['fn_real']*self.model['loop_sample_freq']

        #-----------------------------------------------------------------
        #--- TCLink Tester
        #-----------------------------------------------------------------
        self.model['tester_nco_scale'] = -1*round(math.log2((self.user_config['amplitude_sinus']/self.model['ddmtd_step'])*self.user_config['ddmtd_avg']/((self.TESTER_AMPLITUDE_NCO)/2**self.CONTROLLER_FIXEDPOINT_BIT)));
        self.model['tester_fcw']       = round(self.user_config['frequency_sinus']/(self.model['loop_sample_freq']/self.TESTER_LENGTH_NCO_ROM));
        self.model['amplitude_sinus_real'] = (self.TESTER_AMPLITUDE_NCO/2**self.CONTROLLER_FIXEDPOINT_BIT)*(2**(-1*self.model['tester_nco_scale']))*(self.model['ddmtd_step']/self.user_config['ddmtd_avg'])
        self.model['frequency_sinus_real'] = self.model['tester_fcw']*(self.model['loop_sample_freq']/self.TESTER_LENGTH_NCO_ROM)

    #-----------------------------------------------------------------
    #---                    VHDL port values                       ---
    #-----------------------------------------------------------------
    def calculate_vhdl_parameters(self):
        #-----------------------------------------------------------------
        #--- Phase-detector
        #-----------------------------------------------------------------
        # metastability
        self.vhdl['metastability_deglitch'] = round(500.0/self.model['ddmtd_step']) # 500ps given for metastability resolution	

        # modulo carrier period
        self.vhdl['phase_detector_navg']    = int(self.user_config['ddmtd_avg'])

        #-----------------------------------------------------------------
        #--- TCLink Controller
        #-----------------------------------------------------------------
        # PI coefficients
        if(self.user_config['enable_Ki']) : self.vhdl['Aie']   = int(-1*math.log2(self.model['Ki']) + self.model['sigma_delta_osr'])
        else          : self.vhdl['Aie']   = 0
        self.vhdl['Aie_enable'] = int(self.user_config['enable_Ki'])
        self.vhdl['Ape']        = int(-1*math.log2(self.model['Kp']) + self.model['sigma_delta_osr'])
        
        # DCO mirror
        self.vhdl['Adco']       = round((2**self.CONTROLLER_FIXEDPOINT_BIT)*self.model['Kdcomirror'])
        self.vhdl['enable_mirror'] = int(self.user_config['enable_mirror'])

        # modulo carrier period
        self.vhdl['modulo_carrier_period'] = round((2**self.CONTROLLER_FIXEDPOINT_BIT)*(1e12/self.user_config['carrier_freq'])/(self.model['ddmtd_step']/self.user_config['ddmtd_avg']))	

        # modulo carrier period
        self.vhdl['master_rx_ui_period'] = round((2**self.CONTROLLER_FIXEDPOINT_BIT)*(1e12/self.user_config['carrier_freq'])*(1.0/self.user_config['rx_word_width'])/(self.model['ddmtd_step']/self.user_config['ddmtd_avg']))	
        
        # clock-divider for sigma-delta
        self.vhdl['sigma_delta_clk_div']   = round(self.user_config['clk_sys_freq']/(self.model['loop_sample_freq']*self.user_config['SD_OSR']))

        #-----------------------------------------------------------------
        #--- TCLink Tester
        #-----------------------------------------------------------------
        self.vhdl['tclink_debug_tester_nco_scale'] = int(self.model['tester_nco_scale'])
        self.vhdl['tclink_debug_tester_fcw']       = int(self.model['tester_fcw'])

        #-----------------------------------------------------------------
        #--- Consistency checking
        #-----------------------------------------------------------------
        # Consistency checking for VHDL values
        if(self.vhdl['metastability_deglitch'] > 2**16-1                 or self.vhdl['metastability_deglitch']<0) : print('WARNING (calculate_vhdl_parameters): metastability_deglitch value ('+str(tclink_self.vhdl['metastability_deglitch'])+') not consistent')
        if(self.vhdl['phase_detector_navg'] > 2**12-1                    or self.vhdl['phase_detector_navg']<0)    : print('WARNING (calculate_vhdl_parameters): phase_detector_navg value ('+str(tclink_self.vhdl['phase_detector_navg'])+') not consistent')
                                                                                         
        if(self.vhdl['Aie']  > 2**(self.COEFF_SIZE)-1                                    or self.vhdl['Aie'] < 0)                  : print('WARNING (calculate_vhdl_parameters): Aie value ('+str(self.vhdl['Aie'])+') not consistent')
        if(self.vhdl['Ape']  > 2**(self.COEFF_SIZE)-1                                    or self.vhdl['Ape'] < 0)                  : print('WARNING (calculate_vhdl_parameters): Ape value ('+str(self.vhdl['Ape'])+') not consistent')
        if(self.vhdl['Adco'] > 2**(self.CONTROLLER_DATA_WIDTH-1)-1                       or self.vhdl['Adco']<0)                   : print('WARNING (calculate_vhdl_parameters): Adco value ('+str(self.vhdl['Adco'])+') not consistent')
        if(self.vhdl['modulo_carrier_period'] > 2**(self.CONTROLLER_DATA_WIDTH-1)-1      or self.vhdl['modulo_carrier_period']<0)  : print('WARNING (calculate_vhdl_parameters): modulo_carrier_period value ('+str(self.vhdl['modulo_carrier_period'])+') not consistent')
        if(self.vhdl['master_rx_ui_period'] > 2**(self.CONTROLLER_DATA_WIDTH-1)-1      or self.vhdl['master_rx_ui_period']<0)  : print('WARNING (calculate_vhdl_parameters): master_rx_ui_period value ('+str(self.vhdl['master_rx_ui_period'])+') not consistent')
                                                      
        if(self.vhdl['tclink_debug_tester_nco_scale'] > 2**5-1 or self.vhdl['tclink_debug_tester_nco_scale']<0)    : print('WARNING (calculate_vhdl_parameters): tclink_debug_tester_nco_scale value ('+str(self.vhdl['tclink_debug_tester_nco_scale'])+') not consistent')
        if(self.vhdl['tclink_debug_tester_fcw'] > 2**10-1 or self.vhdl['tclink_debug_tester_fcw']<0)               : print('WARNING (calculate_vhdl_parameters): tclink_debug_tester_fcw value ('+str(self.vhdl['tclink_debug_tester_fcw'])+') not consistent')

    #-----------------------------------------------------------------
    #---                       Write Model                         ---
    #-----------------------------------------------------------------
    def print_tclink_model(self):
        str_print = ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|'+ '-' * 35 + ('%17s' % 'TCLINK PARAMETERS') + '-' * 35+ '|\n')
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|%40s | %43s |\n' % ('TCLINK MODEL PROPERTY', 'VALUE'))
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|%40s | %43s |\n' % ('Line rate '                           , ('%.3fGb/s' % (self.user_config['tx_datarate'] / 1.e9) )))
        str_print = str_print + ('|%40s | %43s |\n' % ('MGT reference clock '                 , ('%.3fMHz'  % (self.user_config['carrier_freq'] / 1.e6) )))
		
		# The corresponding bunch clock is a notion that is very specific to the lpGBT10G protocol and therefore it can be misleading for other users
        #str_print = str_print + ('|%40s | %43s |\n' % ('Corresponding bunch clock '           , ('%.3fMHz'  % (self.user_config['carrier_freq'] / 1.e6 / 8) )))
		
        str_print = str_print + ('|%40s | %43s |\n' % ('DDMTD offset clock '                  , ('%.3fMHz'  % (self.user_config['ddmtd_offset_freq'] / 1.e6) )))
        str_print = str_print + ('|%40s | %43s |\n' % ('DDMTD beat frequency '                , ('%.3fkHz'  % (self.model['ddmtd_beat_freq'] / 1.e3) )))
        str_print = str_print + ('|%40s | %43s |\n' % ('DDMTD number of measurements '        , ('%d'       % self.user_config['ddmtd_avg'] )))
        str_print = str_print + ('|%40s | %43s |\n' % ('DCO step'                             , ('%.3fps'   % self.model['dco_step'] )))
        str_print = str_print + ('|%40s | %43s |\n' % ('DDMTD resolution (single measurement)', ('%.3fps'   % self.model['ddmtd_step'] )))
        str_print = str_print + ('|%40s | %43s |\n' % ('DDMTD resolution (averaged)'          , ('%.3fps'   % (self.model['ddmtd_step'] / math.sqrt(self.vhdl['phase_detector_navg']) ))))
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|%40s | %20s | %20s |\n' % ('USER PROPERTY', 'USER VALUE', 'REAL VALUE'))
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|%40s | %20s | %20s |\n' % ('natural_freq'   , ('%15.3fHz' % (self.user_config['natural_freq'])), ('%15.3fHz' % (self.model['natural_freq_real']))))
        if(self.user_config['enable_Ki']) : str_print = str_print + ('|%40s | %20s | %20s |\n' % ('damping'        , ('%15.2f' % (self.user_config['damping'])), ('%15.2f' % (self.model['damping_real']))))
        str_print = str_print + ('|%40s | %20s | %20s |\n' % ('amplitude_sinus - tester'   , ('%15.3fps' % (self.user_config['amplitude_sinus'])), ('%15.3fps' % (self.model['amplitude_sinus_real']))))
        str_print = str_print + ('|%40s | %20s | %20s |\n' % ('frequency_sinus - tester'   , ('%15.3fHz' % (self.user_config['frequency_sinus'])), ('%15.3fHz' % (self.model['frequency_sinus_real']))))
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|%40s | %43s |\n' % ('VHDL CORE PROPERTY', 'PORT VALUE'))
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
        str_print = str_print + ('|'+ '-' * 35 + ('%17s' % 'Phase Detector') + '-' * 35+ '|\n')
        str_print = str_print + ('|%40s | %43s |\n' % ('metastability_deglitch'        , ('0x%04x'  % self.vhdl['metastability_deglitch'] )))
        str_print = str_print + ('|%40s | %43s |\n' % ('phase_detector_navg'           , ('0x%03x'  % self.vhdl['phase_detector_navg']    )))
        str_print = str_print + ('|'+ '-' * 35 + ('%17s' % '   Controller   ') + '-' * 35+ '|\n')
        str_print = str_print + ('|%40s | %43s |\n' % ('modulo_carrier_period'         , ('0x%012x'  % self.vhdl['modulo_carrier_period']  )))
        str_print = str_print + ('|%40s | %43s |\n' % ('master_rx_ui_period'           , ('0x%012x'  % self.vhdl['master_rx_ui_period']  )))
        str_print = str_print + ('|%40s | %43s |\n' % ('Aie'                           , ('0x%1x'   % self.vhdl['Aie']                    )))
        str_print = str_print + ('|%40s | %43s |\n' % ('Aie_enable'                    , ('0x%1x'   % self.vhdl['Aie_enable']             )))
        str_print = str_print + ('|%40s | %43s |\n' % ('Ape'                           , ('0x%1x'   % self.vhdl['Ape']                    )))
        str_print = str_print + ('|%40s | %43s |\n' % ('sigma_delta_clk_div'           , ('0x%1x'   % self.vhdl['sigma_delta_clk_div']    )))
        str_print = str_print + ('|%40s | %43s |\n' % ('enable_mirror'                 , ('0x%1x'   % self.vhdl['enable_mirror']          )))
        str_print = str_print + ('|%40s | %43s |\n' % ('Adco'                          , ('0x%012x'  % self.vhdl['Adco']                   )))
        str_print = str_print + ('|%40s | %43s |\n' % ('tclink_debug_tester_nco_scale' , ('0x%02x'  % self.vhdl['tclink_debug_tester_nco_scale'] )))
        str_print = str_print + ('|%40s | %43s |\n' % ('tclink_debug_tester_fcw'       , ('0x%03x'  % self.vhdl['tclink_debug_tester_fcw'] )))    
        str_print = str_print + ('|'+ '-' * 87 + '|\n')
    
        print(str_print)
  
    def write_modelsimdo_file(self):
        with open('./../firmware/source/tclink/tclink_controller/tb/run_sim_' + self.CONFIGURATION_NAME + '.do', 'w') as f:
            f.write('vlib work\n\n## Compile files\n# Source files\nvcom -explicit  -93 "./../scaler.vhd"\nvcom -explicit  -93 "./../dco_controller.vhd"\nvcom -explicit  -93 "./../phase_offset_removal.vhd"\nvcom -explicit  -93 "./../pi_controller.vhd"\nvcom -explicit  -93 "./../sigma_delta_modulator.vhd"\nvcom -explicit  -93 "./../tclink_controller.vhd"\n\n## Test bench file\nvcom -explicit  -93 "./tb_tclink_controller.vhd"\n\n# Start simulation\nvsim -gui  work.tb_tclink_controller -gAdco=%d  -gAie=%d -gAie_enable=%d -gApe=%d -genable_mirror=%d -gmodulo_carrier_period=%d -gFIXEDPOINT_BIT=%d -gDATA_WIDTH=%d -gCOEFF_SIZE=%d -gsigma_delta_osr=%d\n\nview wave\nview structure\nview signals\ndo "./wave_config.do"\nrun -all\n\n' % (self.vhdl['Adco'], self.vhdl['Aie'], self.vhdl['Aie_enable'], self.vhdl['Ape'], self.vhdl['enable_mirror'], self.vhdl['modulo_carrier_period'], self.CONTROLLER_FIXEDPOINT_BIT, self.CONTROLLER_DATA_WIDTH, self.COEFF_SIZE, self.model['sigma_delta_osr']) )
        print('Simulation file written to ' + './../firmware/tclink_controller/tb/run_sim_' + self.CONFIGURATION_NAME + '.do')

    #-----------------------------------------------------------------
    #---                  TCLink model function                    ---
    #-----------------------------------------------------------------
    def tclink_model(self, input_signal):
        """
            TCLink model function
                A user provides an input signal and this function will return the TCLink loop signals
    
            arg: [input_signal]
                input_signal: list containing the values of the input signal vs. cycle of the loop sample frequency
            return:
                 [x, err, ctrl, quan, y]
                x           : input signal containing input signal (oversampled with delta-sigma frequency)
                err         : error signal from control loop (DDMTD values oversampled with delta-sigma frequency)
                ctrl        : control signal from the loop controller (oversampled with delta-sigma frequency)
                quan        : delta-sigma quantizer output
                y           : phase output
        """
    
        # Init
        x            = [] ; # Input signal
        err          = [] ; # Error signal
        ctrl         = [] ; # Controller signal
        quan         = [] ; # Sigma-delta quantizer signal
        y            = [] ; # Output
        integral_acc = 0  ;	
        quantizer_ij = 0  ;	
        sigma_ij     = 0  ;
        dco_ij       = 0  ;
        dcomirror_ij = 0  ;
    
        # Main loop for input signals
        for i in range(0,len(input_signal)):
            # Loop controller
            x_i          = input_signal[i]                   ;
            e_i          = x_i - (dco_ij + dcomirror_ij)     ;
            integral_acc = integral_acc + self.model['Ki']*e_i             ;
            ctrl_i       = self.model['Kp']*e_i    + integral_acc          ;
            # Delta-sigma converter                          
            for j in range(0,int(self.user_config['SD_OSR'])):
                delta_ij = ctrl_i/self.user_config['SD_OSR'] - quantizer_ij      ;
                sigma_ij = sigma_ij      + delta_ij          ;
                if(sigma_ij > 0) : quantizer_ij = 1          ;
                else             : quantizer_ij = -1         ;
                dco_ij  = dco_ij + self.model['Kdcoplant']*quantizer_ij    ;
                if(self.user_config['enable_mirror']) : dcomirror_ij  = dcomirror_ij + self.model['Kdcomirror']*quantizer_ij ;                                                    
                # Append results to vectors             
                x.append(x_i)                                ;
                err.append(e_i)			                     ;
                ctrl.append(ctrl_i)                          ;
                quan.append(quantizer_ij)                    ;
                y.append(dco_ij)                             ;
    
        return [x, err, ctrl, quan, y]
