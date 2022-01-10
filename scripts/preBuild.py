#!/usr/bin/env python

import argparse
import sys
import os
import yaml
sys.path.append("./regmap_helper")
import build_vhdl_packages

def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')

yaml.add_representer(type(None), represent_none)

class MyDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(MyDumper, self).increase_indent(flow, False)

#================================================================================
#Generate the MAP and PKG VHDL files for this slave
#================================================================================
def GenerateHDL(name,XMLFile,HDLPath,map_template_file,pkg_template_file):
    print "Generate HDL for",name,"from",XMLFile
    
    #get working directory
    wd=os.getcwd()

    build_vhdl_packages.build_vhdl_packages(True,
                                            False,
                                            False,
                                            os.path.abspath(map_template_file),
                                            None,
                                            os.path.abspath(wd+"/"+HDLPath),
                                            os.path.abspath(wd+"/"+XMLFile),
                                            name)
    




#================================================================================
#process a single slave (or tree us sub-slaves) and update all the output files
#================================================================================
def LoadSlave(name,slave,dtsiYAML,aTableYAML,parentName,map_template_file,pkg_template_file,autogen_path="./"):
    
    fullName=str(name)
    
    print("Processing "+fullName)

    #Build HDL for this file
    if 'HDL' in slave:
        if 'XML' not in slave:
            raise RuntimeError(fullName+" has HDL tag, but no XML tag\n")

        if 'out_dir' not in slave['HDL']:
            out_dir = autogen_path+"/"+name+"/"
            print("  Using (autogen path) "+out_dir+" for HDL generation")
        else:
            out_dir = slave['HDL']['out_dir']
            print("  Using "+out_dir+" for HDL generation")

        if 'map_template' in slave['HDL']:
            map_template_file = "regmap_helper/templates/"+slave['HDL']['map_template']
            print("  Using map template file: "+map_template_file)
        if 'pkg_template' in slave['HDL']:
            pkg_template_file = "regmap_helper/templates/"+slave['HDL']['pkg_template']

        GenerateHDL(fullName,slave['XML'][0],out_dir,map_template_file,pkg_template_file)
    
    #generate yaml for the kernel and centos build
    if 'UHAL_BASE' in slave:
        if 'XML' in slave:
            #update list dtsi files to look for (.dtsi_chunk or .dtsi_post_chunk)
            dtsiYAML[fullName]=None
            #update the address table file          
            aTableYAML[fullName]={
                "UHAL_BASE":"0x"+hex(slave['UHAL_BASE'])[2:].zfill(8),
                "XML":slave['XML']}
      
        else:
            raise RuntimeError(fullName+" has UHAL_BASE tag, but no XML tag\n")

    #Handle and additional slaves generated by the TCL command
    if 'SUB_SLAVES' in slave:
        if slave['SUB_SLAVES'] != None:
            for subSlave in slave['SUB_SLAVES']:
                LoadSlave(subSlave,
                          slave['SUB_SLAVES'][subSlave],
                          dtsiYAML,
                          aTableYAML,
                          fullName,
                          map_template_file,
                          pkg_template_file,
                          autogen_path)





def main(addSlaveTCLPath, dtsiPath, addressTablePath, slavesFileName,map_template_file,pkg_template_file,autogen_path):
    # configure logger
    global log

    
    #dtsi yaml file
    dtsiYAMLFile=open(dtsiPath+"/slaves.yaml","w")
    dtsiYAML = dict()

    #address table yaml file
    addressTableYAMLFile=open(addressTablePath+"/slaves.yaml","w")
    aTableYAML = dict()

    #source slave yaml to drive the rest of the build
    slavesFile=open(slavesFileName)
    slaves=yaml.load(slavesFile)
    for slave in slaves['AXI_SLAVES']:
        #update all the files for this slave
        LoadSlave(slave,
                  slaves["AXI_SLAVES"][slave],
                  dtsiYAML,
                  aTableYAML,
                  "",
                  map_template_file,
                  pkg_template_file,
                  autogen_path)

    dtsiYAML={"DTSI_CHUNKS": dtsiYAML}
    aTableYAML={"UHAL_MODULES": aTableYAML}
  
    dtsiYAMLFile.write(yaml.dump(dtsiYAML,
                                 Dumper=MyDumper,
                                 default_flow_style=False))
    addressTableYAMLFile.write(yaml.dump(aTableYAML,
                                         Dumper=MyDumper,
                                         default_flow_style=False))


if __name__ == "__main__":
    #command line
    parser = argparse.ArgumentParser(description="Create auto-generated files for the build system.")
    parser.add_argument("--slavesFile","-s"      ,help="YAML file storing the slave info for generation",required=True)
    parser.add_argument("--addSlaveTCLPath","-t" ,help="Path for AddSlaves.tcl",required=True)
    parser.add_argument("--addressTablePath","-a",help="Path for address table generation yaml",required=True)
    parser.add_argument("--dtsiPath","-d"        ,help="Path for dtsi yaml",required=True)
    parser.add_argument("--mapTemplate","-m"        ,help="Path for map_template file",required=False)
    parser.add_argument("--pkgTemplate","-p"        ,help="Path for pkg_template file",required=False)
    parser.add_argument("--autogenPath","-g"        ,help="Base path for autogenerated files",required=True)
    args=parser.parse_args()
    main(addSlaveTCLPath   = args.addSlaveTCLPath, 
         dtsiPath          = args.dtsiPath, 
         addressTablePath  = args.addressTablePath, 
         slavesFileName    = args.slavesFile,
         map_template_file = args.mapTemplate,
         pkg_template_file = args.pkgTemplate,
         autogen_path      = args.autogenPath
    )
