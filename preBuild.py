#!/bin/env python

import yaml

def LoadSlave(slave,tclFile,slaveYAMLFile,parentName):
  
  #update the AddSlaves.tcl file
  if 'TCL_CALL' in slave:
    tclFile.write("#"+parentName+slave['NAME']+"\n")
    tclFile.write(slave['TCL_CALL']+"\n\n")

  #Build HDL for this file
  if 'HDL' in slave:
    if 'XML' not in slave:
      raise RuntimeError(slave['NAME']+" has HDL tag, but no XML tag\n")
    print "Use ",slave['XML']," to build ",slave['HDL']," map and PKG files"

  #generate yaml for the kernel and centos build
  if 'UHAL_BASE' in slave:
    if 'XML' in slave:
      slaveYAMLFile.write("  - SLAVE:\n")
      slaveYAMLFile.write("    UHAL_BASE: 0x"+hex(slave['UHAL_BASE'])[2:].zfill(8)+"\n")
      slaveYAMLFile.write("    XML: "+slave['XML']+"\n")      
    else:
      return

  #Handle and additional slaves generated by the TCL command
  if 'SLAVE' in slave:
    if slave['SLAVE'] != None:
      for subSlave in slave['SLAVE']:
        LoadSlave(subSlave,tclFile,slaveYAMLFile,parentName+slave['NAME'])



tclFile=open("src/ZynqPS/AddSlaves.tcl","w")
tclFile.write("#================================================================================\n")
tclFile.write("#  Configure and add AXI slaves\n")
tclFile.write("#================================================================================\n")

slaveYAMLFile=open("os/slaves.yaml","w")
slaveYAMLFile.write("SLAVE:\n");


slavesFile=open("src/slaves.yaml")
slaves=yaml.load(slavesFile)
for slave in slaves['SLAVE']:
  LoadSlave(slave,tclFile,slaveYAMLFile,"")
