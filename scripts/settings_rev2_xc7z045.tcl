
#set the FPGA part number
set FPGA_part xc7Z045FFG676-2

set top top

set outputDir ./

#load list of vhd, xdc, and xci files
#7 series zynq files
source ${apollo_root_path}/files_rev2_xc7z045.tcl

puts "Using path: ${apollo_root_path}"
