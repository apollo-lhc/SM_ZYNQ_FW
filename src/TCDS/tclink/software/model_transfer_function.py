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
try:
    import matplotlib.pyplot as plt
    have_mpl = True
except ImportError as err:
    have_mpl = False

#-----------------------------------------------------------------
#---                   TCLink   Packages                       ---
#-----------------------------------------------------------------
from tclink_core.tclink_model import TCLinkModel

#-----------------------------------------------------------------
#---                     Parameters                            ---
#-----------------------------------------------------------------
save_fig = True
show_fig = True

#-----------------------------------------------------------------
#---                     Loop simulation                       ---
#-----------------------------------------------------------------
tclink_model = TCLinkModel('default')
tclink_model.print_tclink_model()
tclink_model.write_modelsimdo_file()

A_input = 100.0*(tclink_model.user_config['ddmtd_avg']/tclink_model.model['ddmtd_step'])
freq    = []
gain    = []
# Loop through different sine frequencies to capture transfer-function
for input_freq in [1e-4, 1e-3, 1e-2, 1e-1, 3e-1]:
    # Create input signal for simulation
    N            = int(8*(1.0/input_freq));        # Number of Simulation points
    input_signal = []
    for i in range(0,N):
        input_signal.append(A_input*math.sin(2*math.pi*input_freq*i))

    # Run TCLink simulation model
    [x, err, ctrl, quan, y] = tclink_model.tclink_model(input_signal)

    # Calculate frequency vs. gain curve
    freq.append(input_freq*tclink_model.model['loop_sample_freq'])
    gain.append(20*math.log10(np.std(y[int(3*N*tclink_model.user_config['SD_OSR']/4):])/np.std(x[int(3*N*tclink_model.user_config['SD_OSR']/4):])))

# Save configuration to csv file
with open('./config/' + tclink_model.CONFIGURATION_NAME + '_model.csv','w') as f:
    f.write('# %28s,%30s\n' % ('Freq(Hz)', 'Gain(dB)'))
    for i in range(0,len(freq)):
        f.write('%30.15f,%30.15f\n' % (freq[i], gain[i]))    

if not have_mpl:
    print("Matplotlib not found, so can't produce transfer function plot")
else:
    # Plot transfer function
    plt.semilogx(freq, gain, marker='o', color='b')
    plt.semilogx([tclink_model.model['natural_freq_real'],tclink_model.model['natural_freq_real']], [-30,10], color='k', linestyle=':')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude(dB)')
    plt.title('TCLink Controller Transfer Function')
    plt.axis([tclink_model.model['natural_freq_real']/100, tclink_model.model['natural_freq_real']*100, -30, 10])
    ax = plt.gca()
    ax.yaxis.set_ticks_position('both')
    ax.xaxis.set_ticks_position('both')	
    ax.tick_params(axis='both', which='major', direction='in')
    ax.tick_params(axis='both', which='minor', direction='in')
    ax.annotate('Natural frequency', xy=(tclink_model.model['natural_freq_real'],5.0), size=10, ha='right', va='top', color='k')
    if save_fig:
        fig_file_name = './config/' + tclink_model.CONFIGURATION_NAME + '_model.png'
        plt.savefig(fig_file_name)
        print("Saved transfer function plot to file '{0:s}'".format(fig_file_name))
    if show_fig:
        plt.show()

    plt.close()
