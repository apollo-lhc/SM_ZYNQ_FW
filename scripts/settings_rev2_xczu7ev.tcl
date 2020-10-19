
#set the FPGA part number
set FPGA_part xczu7ev-fbvb900-2-i
#XCZU7EVFBVB900I-2

set top top

set outputDir ./

#load list of vhd, xdc, and xci files
source ${apollo_root_path}/files_rev2_xczu7ev.tcl

puts "Using path: ${apollo_root_path}"
