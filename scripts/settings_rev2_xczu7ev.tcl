
#set the FPGA part number
set FPGA_part xczu7ev-fbvb900-2-i
#XCZU7EVFBVB900I-2

set top top

set outputDir ./

#load list of vhd, xdc, and xci files
#7 series zynq files
source ${apollo_root_path}/files_rev2_xc7z035.tcl

puts "Using path: ${apollo_root_path}"
