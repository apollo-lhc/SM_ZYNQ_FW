
#set the FPGA part number
set FPGA_part xc7z035fbg676-1

set top top

set outputDir ./

#load list of vhd, xdc, and xci files
#7 series zynq files
source ${apollo_root_path}/files_rev1_xc7zXX.tcl

puts "Using path: ${apollo_root_path}"
