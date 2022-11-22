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
import matplotlib.pyplot as plt

rom_size  = 2**10  ;
width     = 32     ;
amplitude = 2**31-1; 

rom = '('
for i in range(0,rom_size):
    signal = amplitude*math.sin(2*math.pi*i/rom_size)
    signal = round(signal);
    if(signal >= 0): str_signal = 'x"%08x"' % signal
    else          : str_signal = 'x"%08x"' % ((abs(signal) ^ 0xFFFFFFFF) + 1)
    if(i==rom_size-1) : rom = rom + str_signal + ');'
    else              : rom = rom + str_signal + ', '

print(rom)

# Check data visually
data = []
for i in range(0,rom_size):
    if(rom[i] >= 2**31) : data.append((rom[i] ^ 0xFFFFFFFF) + 1)
    else : data.append(rom[i])

plt.plot(data)
plt.show()