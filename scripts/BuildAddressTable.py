#!/bin/env python
import argparse


import yaml
import xml.etree.ElementTree as ET

from xml.etree import ElementTree
from xml.dom import minidom

def BuildAddressTable(fileName,top):
    ATFile=open(fileName,"w")
  
    idLen = 0
    addrLen = 0
    moduleLen = 0
    modeLen = 0
    sizeLen = 0
    #find the max length of each type of attribute is
    for child in top:      
        size=len(child.get('id'))
        if(size > idLen):
            idLen=size
        if(child.get('address')):
            size=len(child.get('address'))
            if(size > addrLen):
                addrLen=size
        if(child.get('module')):
            size=len(child.get('module'))
            if(size > moduleLen):
                moduleLen=size
        if(child.get('mode')):
            size=len(child.get('mode'))
            if(size > modeLen):
                modeLen=size
        if(child.get('size')):
            size=len(hex(child.get('size')))
            if(size > sizeLen):
                sizeLen=size
  
    #add the length of the attribute name for padding
    idLen+=5+1
    addrLen+=10+1
    moduleLen+=9+1
    modeLen+=7+1
    sizeLen+=7+1
  
    #reorder data by uhal address
    top[:] = sorted(top,key=lambda child: (child.tag,child.get('address')))
    

    #generate the address table
    ATFile.write("<node id=\"TOP\">\n")
    for child in top:
        #start the node
        ATFile.write("  <node")
        
        #print the node ID
        ATFile.write((" id=\""+child.get('id')+"\"").ljust(idLen))      
        ATFile.write(" ")
  
        #print the address if it exists
        if(child.get('address')):
            ATFile.write((" address=\""+child.get('address')+"\"").ljust(addrLen))
        else:
            ATFILE.write(" ".ljust(addrLen))
        ATFile.write(" ")
        
        #print the module if it exists
        if(child.get('module')):
            ATFile.write((" module=\""+child.get('module')+"\"").ljust(moduleLen))
        else:
            ATFile.write(" ".ljust(moduleLen))
        ATFile.write(" ")      
  
        #print the mode if it exists
        if(child.get('mode')):
            ATFile.write((" mode=\""+child.get('mode')+"\"").ljust(modeLen))
        else:
            ATFile.write(" ".ljust(modeLen))
        ATFile.write(" ")      
  
        #print the mode size if it exists
        if(child.get('size')):
            ATFile.write((" size=\""+hex(child.get('size'))+"\"").ljust(sizeLen))
        else:
            ATFile.write(" ".ljust(sizeLen))
  
  
        ATFile.write("/>\n")
    ATFile.write("<node/>\n")
    


def main():

  parser = argparse.ArgumentParser(description="Build address table.")
  parser.add_argument("--localSlavesYAML","-s"      ,help="YAML file storing the slave info for generation",required=True)
  parser.add_argument("--remoteSlavesYAML","-r"      ,help="YAML file storing remote locations of slave info for generation",required=False,action='append')
  args=parser.parse_args()


  top = ET.Element("node",{"id":"top"})

  slavesFile=open(args.localSlavesYAML)
  slaves=yaml.load(slavesFile)
  for slave in slaves['SLAVE']:
      ET.SubElement(top,"node",
                    {"id":slave['NAME'],
                     "module":slave['XML'],
                     "address":"0x"+hex(slave['UHAL_BASE'])[2:].zfill(8)})
      
  for CM in args.remoteSlavesYAML:
        slavesFile=open(CM)
        slaves=yaml.load(slavesFile)
        for slave in slaves['SLAVE']:
            child = ET.SubElement(top,"node")
            child.set("id",slave['NAME'])
            child.set("address","0x"+hex(slave['UHAL_BASE'])[2:].zfill(8))
            if "XML" in slave:
                child.set("module",slave['XML'])
            if 'XML_MODE' in slave:
                child.set("mode",slave['XML_MODE'])
            if 'XML_SIZE' in slave:
                child.set("size",slave['XML_SIZE'])                



  BuildAddressTable("os/address_apollo.xml",top)


if __name__ == "__main__":
    main()
