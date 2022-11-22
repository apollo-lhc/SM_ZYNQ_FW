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
import numpy as np
import matplotlib.pyplot as plt
import time

#-----------------------------------------------------------------
#---                   TCLink   Packages                       ---
#-----------------------------------------------------------------
from tclink_core.tclink_fpga import TCLink

#-----------------------------------------------------------------
#---                     Parameters                            ---
#-----------------------------------------------------------------
save_fig = True
show_fig = True
Master         = 0

#-----------------------------------------------------------------
#---           Loop in Hardware (requires tester)              ---
#-----------------------------------------------------------------

#-----------------------------------------------------------------
#---                  Open sockets                             ---
#-----------------------------------------------------------------
tclink_fpga = TCLink('127.0.0.1', 8555, 'default', 'vcu118', Master)
tclink_fpga.print_tclink_model()

#-----------------------------------------------------------------
#---               Configure TCLink                            ---
#-----------------------------------------------------------------

# Preset VIO probes
tclink_fpga.preset()

# Reset Tx master
print('--- Reset Tx Master ' + str(Master))
tclink_fpga.set_property('master_core_ctrl['+str(Master)+'][mgt_reset_tx_pll_and_datapath]',1)
time.sleep(0.5)
tclink_fpga.set_property('master_core_ctrl['+str(Master)+'][mgt_reset_tx_pll_and_datapath]',0)
tx_ready = 0
while(not tx_ready):
    tx_ready = tclink_fpga.get_property('master_core_stat['+str(Master)+'][mgt_tx_ready]')
    time.sleep(0.5)

time.sleep(2)

# Reset Rx slave
print('--- Reset Rx Slave')
tclink_fpga.set_property('slave_core_ctrl[mgt_reset_rx_pll_and_datapath]',1)
time.sleep(0.5)
tclink_fpga.set_property('slave_core_ctrl[mgt_reset_rx_pll_and_datapath]',0)
rx_ready = tclink_fpga.get_property('slave_core_stat[rx_frame_locked]')
while(not rx_ready):
    rx_ready = tclink_fpga.get_property('slave_core_stat[rx_frame_locked]')
    time.sleep(0.5)

time.sleep(2)

# Reset Tx slave
print('--- Reset Tx Slave (EXTERNAL PLL SHALL BE LOCKED)')
tclink_fpga.set_property('slave_core_ctrl[mgt_reset_tx_pll_and_datapath]',1)
time.sleep(0.5)
tclink_fpga.set_property('slave_core_ctrl[mgt_reset_tx_pll_and_datapath]',0)
tx_ready = tclink_fpga.get_property('slave_core_stat[mgt_tx_ready]')
while(not tx_ready):
    tx_ready = tclink_fpga.get_property('slave_core_stat[mgt_tx_ready]')
    time.sleep(0.5)

time.sleep(2)

# Reset Rx master
print('--- Reset Rx Master')
tclink_fpga.set_property('master_core_ctrl['+str(Master)+'][mgt_reset_rx_datapath]',1)
time.sleep(0.5)
tclink_fpga.set_property('master_core_ctrl['+str(Master)+'][mgt_reset_rx_datapath]',0)
rx_ready = 0
while(not rx_ready):
    rx_ready = tclink_fpga.get_property('master_core_stat['+str(Master)+'][rx_frame_locked]')
    time.sleep(0.5)
	
time.sleep(2)

print('--- Configure TCLink')
# Find TCLink offset
tclink_fpga.tclink_find_offset()

# Close the loop
tclink_fpga.set_property('master_tclink_ctrl['+str(Master)+'][tclink_close_loop]',1)
loop_closed = tclink_fpga.get_property('master_tclink_stat['+str(Master)+'][tclink_loop_closed]')
if(loop_closed):
  print('- The TCLink loop is closed')
else:
  print('- FAILURE: The TCLink loop is not closed, check Rx and Tx status and re-run script')
  
#-----------------------------------------------------------------
#---            Inject signal in tester                        ---
#-----------------------------------------------------------------
freq    = []
gain    = []
# Loop through different sine frequencies to capture transfer-function
print('--- Start frequency sweep')
for fn in [1e-3, 1e-2, 1e-1, 3e-1]:
    print('-- Start sweep for fn: ' + str(fn))
    tclink_fpga.user_config['frequency_sinus'] = fn*tclink_fpga.model['loop_sample_freq']
    tclink_fpga.calculate_model_parameters()
    tclink_fpga.calculate_vhdl_parameters()
    
    tclink_fpga.set_property('master_tclink_ctrl['+str(Master)+'][tclink_debug_tester_fcw]', tclink_fpga.vhdl['tclink_debug_tester_fcw'])
    tclink_fpga.set_property('master_tclink_ctrl['+str(Master)+'][tclink_debug_tester_enable_stimulis]', 1)
    time.sleep(1)

    print('- Acquiring tester data (this may take a few seconds ... )')
    # Acquire tester response
    time_wait = 2.0/tclink_fpga.model['frequency_sinus_real']
    y = tclink_fpga.tclink_get_tester_response(time_wait)

    # Scale response in picoseconds
    for i in range(0, len(y)):
        y[i] = y[i]*tclink_fpga.model['dco_step']

    ## Debug
    #plt.plot(y)
    #plt.show()

    # Calculate standard deviations
    y_std = np.std(y)
    x_std = (tclink_fpga.model['amplitude_sinus_real'])/math.sqrt(2)
    print('- OUT_STD: ' + str(y_std) + ' rms ps')
    print('- IN_STD : ' + str(x_std) + ' rms ps')
    # Calculate frequency vs. gain curve
    freq.append(tclink_fpga.model['frequency_sinus_real'])
    gain.append(20*math.log10(y_std/x_std))

tclink_fpga.set_property('master_tclink_ctrl['+str(Master)+'][tclink_debug_tester_enable_stimulis]', 0)
tclink_fpga.set_property('master_tclink_ctrl['+str(Master)+'][tclink_close_loop]',0)

# Save configuration to csv file
with open('./config/' + tclink_fpga.CONFIGURATION_NAME + '_fpga.csv','w') as f:
    f.write('# %28s,%30s\n' % ('Freq(Hz)', 'Gain(dB)'))
    for i in range(0,len(freq)):
        f.write('%30.15f,%30.15f\n' % (freq[i], gain[i]))    

# Plot transfer function
plt.semilogx(freq, gain, marker='o', color='b')
plt.semilogx([tclink_fpga.model['natural_freq_real'],tclink_fpga.model['natural_freq_real']], [-30,10], color='k', linestyle=':')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude(dB)')
plt.title('TCLink Controller Transfer Function')
plt.axis([tclink_fpga.model['natural_freq_real']/100, tclink_fpga.model['natural_freq_real']*100, -30, 10])
ax = plt.gca()
ax.yaxis.set_ticks_position('both')
ax.xaxis.set_ticks_position('both')	
ax.tick_params(axis='both', which='major', direction='in')
ax.tick_params(axis='both', which='minor', direction='in')
ax.annotate('Natural frequency', xy=(tclink_fpga.model['natural_freq_real'],5.0), size=10, ha='right', va='top', color='k')	
if save_fig:
    fig_file_name = './config/' + tclink_fpga.CONFIGURATION_NAME + '_fpga.png'
    plt.savefig(fig_file_name)
    print("Saved transfer function plot to file '{0:s}'".format(fig_file_name))
if show_fig:
    plt.show()
plt.close()