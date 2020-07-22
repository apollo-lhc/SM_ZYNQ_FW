#!/bin/env python

import yaml

def LoadSlave(slave,tclFile,slaveYAMLFile,parentName):
  if 'TCL_CALL' in slave:
    tclFile.write("#"+parentName+slave['NAME']+"\n")
    tclFile.write(slave['TCL_CALL']+"\n\n")

  if 'UHAL_BASE' in slave:
    if 'XML' in slave:
      slaveYAMLFile.write("  - SLAVE:\n")
      slaveYAMLFile.write("    UHAL_BASE: 0x"+hex(slave['UHAL_BASE'])[2:].zfill(8)+"\n")
      slaveYAMLFile.write("    XML: "+slave['XML']+"\n")      
      #slaveYAMLFile.write("    DTSI: \n")
      #if slave['TCL_CALL'].find("AXI_IP_") >=0:
      #  slaveYAMLFile.write(parentName+slave['NAME']+".dtsi_post_chunk\n")
      #elif slave['TCL_CALL'].find("AXI_PL_DEV_CONNECT") >=0:
      #  slaveYAMLFile.write(parentName+slave['NAME']+".dtsi_chunk\n")
      #else:
      #  return
    else:
      return
  elif 'SLAVE' in slave:
    if slave['SLAVE'] != None:
      for subSlave in slave['SLAVE']:
        LoadSlave(subSlave,tclFile,slaveYAMLFile,parentName+slave['NAME'])



tclFile=open("temp/AddSlaves.tcl","w")
tclFile.write("#================================================================================\n")
tclFile.write("#  Configure and add AXI slaves\n")
tclFile.write("#================================================================================\n")

slaveYAMLFile=open("temp/slaves.yaml","w")
slaveYAMLFile.write("SLAVE:\n");


slavesFile=open("src/slaves.yaml")
slaves=yaml.load(slavesFile)
for slave in slaves['SLAVE']:
  LoadSlave(slave,tclFile,slaveYAMLFile,"")
