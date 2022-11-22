#!/usr/bin/env python

import logging
import os
import csv
import time
import math
from . driver_comm             import DriverComm
from . tclink_model import TCLinkModel
from . vio_probes_default_vcu118  import default_probes as default_probes_vcu118
from . vio_probes_default_kcu105  import default_probes as default_probes_kcu105

# -------------------------------------------------------------
#  -------------- Class TCLink (low-layer) ------------
# -------------------------------------------------------------
class TCLink(DriverComm, TCLinkModel):

    # --------------- Constructor ---------------
    def __init__(self, ip='127.0.0.1', port=8555, tclink_config='default', example_design='vcu118', master_number=0, logger_name=None):
        DriverComm.__init__(self, ip, port, logger_name)
        TCLinkModel.__init__(self, tclink_config)

        self.exdsg     = example_design
        self.masternbr = master_number   		
        if(self.exdsg == 'vcu118'):
            self.default_probes = default_probes_vcu118
            self.prefix_master = 'master_tclink_ctrl['+str(self.masternbr)+']['
        elif(self.exdsg == 'kcu105'):
            self.default_probes = default_probes_kcu105
            self.prefix_master = 'master_tclink_ctrl['+str(self.masternbr)+']['

        self.probes = {}
        self.tclink_update_probes()


    # ------------- FPGA Programming ------------    
    def fpga_program(self):
        self.query('fpga_program\n')
        return 1

    # --------------- VIO Control ---------------    
    def set_property(self, property, value):

        try:
            bits = self.probes[property]['size']
        except KeyError:
            self.logger.warn('TCLink: Probe '+property+' does not exist')
            return -1
        if(self.probes[property]['dir']=='in'):
            self.logger.warn('TCLink: Probe '+property+'is of type input, cannot set property')
            return -1
        #print(('vio_w %s %0'+str(math.ceil(bits/4))+'x\n') % (property, value))
        self.query(('vio_w %s %0'+str(math.ceil(bits/4))+'x\n') % (property, value))
        return 1

    def get_property(self, property):
        try:
            dir = self.probes[property]['dir']
        except KeyError:
            self.logger.warn('TCLink: Probe '+property+' does not exist')
            return -1
        if(dir=='in'):
            return int(self.query(('vio_ri %s\n') % (property)),16)
        else:
            return int(self.query(('vio_ro %s\n') % (property)),16)

    def preset(self):
        for property in self.probes.keys():
            if(self.probes[property]['dir']=='out'):
                self.set_property(property, self.probes[property]['init'])
        return 1

    def print_probes(self, print_on = 1):   
        str_print = ('|'+ '-' * 108 + '|\n')
        str_print = str_print + ('|%60s | %3s | %4s | %15s| %15s|\n' % ('PROPERTY', 'DIR', 'SIZE', 'INIT', 'CURRENT'))
        str_print = str_print + ('|'+ '-' * 108 + '|\n')
        for property in self.probes.keys():
            if(self.probes[property]['dir'] == 'out'):        
                str_print = str_print + ('|%60s | %3s | %4d | %15d| %15d|\n' % (property, self.probes[property]['dir'], self.probes[property]['size'], self.probes[property]['init'], self.get_property(property)))
            else:
                str_print = str_print + ('|%60s | %3s | %4d | %15s| %15d|\n' % (property, self.probes[property]['dir'], self.probes[property]['size'], '-',self.get_property(property)))
        str_print = str_print + ('|'+ '-' * 108 + '|\n')
        if(print_on) : print(str_print)

    def write_probes(self):
        str_print = self.print_probes(0)
        with open('./config/' + self.CONFIGURATION_NAME + '_probes.csv', 'w') as f:
            f.write(str_print)
        print('Probes dictionary written to csv file ' + './config/' + self.CONFIGURATION_NAME + '_probes.csv')
        
    # ------------- TCLink --------------- 
    def tclink_update_model(self, tclink_config):
        self.load_configuration(tclink_config)
        self.tclink_update_probes()

    def tclink_update_probes(self):
        self.probes = self.default_probes
        self.probes[self.prefix_master + "tclink_metastability_deglitch]"]["init"] = self.vhdl['metastability_deglitch']
        self.probes[self.prefix_master + "tclink_phase_detector_navg]"]["init"]    = self.vhdl['phase_detector_navg']
        self.probes[self.prefix_master + "tclink_modulo_carrier_period]"]["init"]  = self.vhdl['modulo_carrier_period']
        self.probes[self.prefix_master + "tclink_master_rx_ui_period]"]["init"]    = self.vhdl['master_rx_ui_period']		
        self.probes[self.prefix_master + "tclink_Aie]"]["init"]                    = self.vhdl['Aie']
        self.probes[self.prefix_master + "tclink_Aie_enable]"]["init"]             = self.vhdl['Aie_enable']
        self.probes[self.prefix_master + "tclink_Ape]"]["init"]                    = self.vhdl['Ape']
        self.probes[self.prefix_master + "tclink_sigma_delta_clk_div]"]["init"]    = self.vhdl['sigma_delta_clk_div']
        self.probes[self.prefix_master + "tclink_enable_mirror]"]["init"]          = self.vhdl['enable_mirror']
        self.probes[self.prefix_master + "tclink_Adco]"]["init"]                   = self.vhdl['Adco']
        self.probes[self.prefix_master + "tclink_debug_tester_fcw]"]["init"]       =  self.vhdl['tclink_debug_tester_fcw']
        self.probes[self.prefix_master + "tclink_debug_tester_nco_scale]"]["init"] = self.vhdl['tclink_debug_tester_nco_scale']

    def tclink_find_offset(self): 
        self.set_property(self.prefix_master + 'tclink_offset_error]', 0)
        time.sleep(1)
        phase_detected_actual = self.get_property('master_tclink_stat['+str(self.masternbr)+'][tclink_error_controller]') 
        self.set_property(self.prefix_master + 'tclink_offset_error]', phase_detected_actual)

    def tclink_get_tester_response(self, waiting_time_to_fill = 1): 
        self.set_property(self.prefix_master + 'tclink_debug_tester_enable_stock_out]', 1)
        if(waiting_time_to_fill > 5): time.sleep(waiting_time_to_fill)
        else                        : time.sleep(5)
        self.set_property(self.prefix_master + 'tclink_debug_tester_enable_stock_out]', 0)
        data = []        
        for i in range(0,1024):
            self.set_property(self.prefix_master + 'tclink_debug_tester_addr_read]', i)
            data.append(self.get_property('master_tclink_stat['+str(self.masternbr)+'][tclink_debug_tester_data_read]'))
            if(data[i]>=2**15) : data[i] = -1*((data[i]^0xFFFF)+1)
        return data

    # ------------- SYSMON METHODS --------------
    def refresh_sysmon(self):        	
        self.query('sysmon_refresh \n')

    def get_property_sysmon(self, property_name):        	
        return float(self.query('sysmon_r ' + property_name + ' \n'))

    def save_sysmon_state(self, name_file):
        self.refresh_sysmon()
        property_list = ['TEMPERATURE','MAX_TEMPERATURE','MIN_TEMPERATURE',
            'VCCINT'     ,'MAX_VCCINT'     ,'MIN_VCCINT',     
            'VCCAUX'     ,'MAX_VCCAUX'     ,'MIN_VCCAUX',     
            'VCCBRAM'    ,'MAX_VCCBRAM'    ,'MIN_VCCBRAM',    
            'VUSER0'     ,'MAX_VUSER0'     ,'MIN_VUSER0',     
            'VUSER1'     ,'MAX_VUSER1'     ,'MIN_VUSER1',     
            'VUSER2'     ,'MAX_VUSER2'     ,'MIN_VUSER2',     
            'VUSER3'     ,'MAX_VUSER3'     ,'MIN_VUSER3']
			
        # Create Formatted Vector
        fieldnames = []
        measurements = {}
        for i in range(0,len(property_list)):
            fieldnames.append('%20s' % property_list[i])
            measurements[fieldnames[i]] = '%20.10f' % self.get_property_sysmon(property_list[i])

        # Save Measurement
        # Check if file exists	
        file_exists = os.path.isfile(name_file + '.csv')		
        with open(name_file + '.csv', 'a') as csvfile:
            writer = csv.DictWriter(
                csvfile,
                fieldnames=fieldnames,
                delimiter=',',
                lineterminator='\n')

            if (not file_exists) : writer.writeheader()

            writer.writerow(measurements)