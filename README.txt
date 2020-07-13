APOLLO Service Module firmware

Github branching policy:
We are going to try to follow: https://nvie.com/posts/a-successful-git-branching-model/
The default branch is develop and you should branch off of that.



To Build FPGA FW:
  >make
  Ouput:
    bit/top.bit
    os/hw/*.dtsi_chunk,*.dtsi_post_chunk,hwdef

To Build zynq fsbl+kernel+fs
  First, build FPGA FW
  >cd os
  >make

  Output:
    os/zynq_os/images/linux/BOOT.bin
    os/zynq_os/images/linux/image.ub



Organization:
  Build scripts are in ./scripts and are called by the Makefile
  
  Zynq block diagram generation tcl scripts are in ./src/ZynqOS
    create.tcl is automatically called by build scripts.
  This relies on the tcl scripts in the submodule in bd.

  HDL & constraint files are in ./src with top.vhd as the top module.

  OS:
    ./os/hw contains device-tree elements and the xilinx hwdef files needed to build the PS system
    ./os/zynq_os_mods contains recipes for mods/patches for/of the petalinux system.

Dependencies:
	generation of xml regmaps requires the Jinja2 library for python
