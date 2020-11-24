# APOLLO Service Module firmware

## Github branching policy:
We are going to try to follow: https://nvie.com/posts/a-successful-git-branching-model/
The default branch is develop and you should branch off of that.

## Building
The Apollo SM has several different configurations and this build system can be instructed to make any of them.
The differences between these configurations are located in the "configs" directory.
The build process uses Vivado but is directed by makefiles. 

### configs
The configs directory contains directories for each different configuraiton and the name of this directory should match the make rule.
In these folders you will need to have atleast the following three files:
 - files.tcl  
   A tcl file that lists the files to be included
   There are
   - bd_files   : the list of BD names and tcl files to be built
   - vhdl_files : the list of VHDL files this project uses
   - xdc_files  : the list of xdc files for the project
   - xci_files  : the list of IP core xci files used
 - settings.tcl  
   This file primarily lists the FPGA part number
 - slaves.yaml 
   Lists AXI slaves that exist or should be made, their AXI address info, uHAL address/tables, and if they should auto generate AXI slave decoding logic from the uHAL address tables

#### Additional files

     This is where customized top files should be put, but that is not a requirement. 
     This is a good place to put any other config specific files, but it is not a requirement. 
     These files used are always taken from the files.tcl (with the exception of the autogenerated FW info hdl file)

### Building
As mentioned above, make is used to drive the build.  There are three parts to this build:
 - FPGA FW build 
   Located in the main directory (with this file)
   Builds the Zynq FPGA FW   
 - FSBL/uboot/Linux kernel build
   Located in ./kernel
   Builds the files needed to boot the Zynq PS+PL
 - CentOS FS build
   Located in ./os
   Builds the CentOS filesystem used.  
   Requires sudo privilages (for now)

#### Make
Buildable Groups:
  > make list

    - Apollo SM config:
      Different FWs to make (you probably just want one of these)
    - Vivado:
      Drive interactive vivado sessions
    - Clean:
      Clean different parts of the builds
    - Tests:
      Test benches run and compared against golden outputs
    - Test-benches:
      Start interactive test-benches

#### FW
To Build FPGA FW:
  `make revN_xcFPGA`

  Ouput:
  
   - bit/top_revN_xcFPGA.bit
  
   - kernel/hw/*.dtsi_chunk,*.dtsi_post_chunk,hwdef

To Build zynq fsbl+kernel+fs
  First, build FPGA FW
  `make pull_cm
  cd kernel
  make revN_xcFPGA`

  Output:
  
   - kernel/zynq_os/images/linux/BOOT.bin
  
   - kernel/zynq_os/images/linux/image.ub

  Notes: In order to do this you must have a personal github token defined as an env variable
  export GH_TOKEN=<your token here>
  follow this to generate a token https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token


To Build the centos image
   First, build FPGA FW and run the GetReleases script if you haven't already
   > make address_table
   > cd os
   > sudo make clean; sudo make

   Output: (follow os/README for copying instructions)
     os/image

   
### Organization:
  Build scripts are in ./scripts and are called by the Makefile
  
  Zynq block diagram generation tcl scripts are in ./src/ZynqOS
    create.tcl is automatically called by build scripts.
  This relies on the tcl scripts in the submodule in bd.

  HDL & constraint files are in ./src.
  slaves.yaml in ./config lists the slaves to be built and the tcl needed to build them
  Output HDL _map.vhd and _PKG.vhd, and AddSlaves.tcl are autogenerated, but commited to git so UHAL isn't required to do simple builds 

  Linux Kernel & FSBL:
    ./kernel/hw contains device-tree elements and the xilinx hwdef files needed to build the PS system
    ./kernel/zynq_os_mods contains recipes for mods/patches for/of the petalinux system.

  CentOS:
    ./os/address_table contains the build address table and module files
    ./os/mods contains the modifications to the centos system

### Dependencies:
	UHAL is required for HDL builds from address tables
	generation of xml regmaps requires the Jinja2 library for python
