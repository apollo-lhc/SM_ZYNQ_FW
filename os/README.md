OS build:

FW build should have populated the hw directory with dtsi files
Add any AXI C2C endpoint dtsi files from CM FW builds
Add other dtsi files (rtc,SGMII) to the folder as well

Makefile builds petalinux kernel for use with the centos image made in the centos subdirectory
Generates BOOT.bin and image.ub in zynq_os/images/linux which get put on parition one of the SDCard

CentOS subdirectory has its own makefile for system building and should be copied (with correct permissions) to the second partition of the SDCARD
