set hw_dir kernel/hw

#create bit file
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force ${apollo_root_path}/bit/top_${build_name}.bit

#create hwdef file
write_hwdef -file ${apollo_root_path}/${hw_dir}/top.hwdef -force

# create the hwdef file for old builds
write_sysdef -hwdef ${apollo_root_path}/${hw_dir}/top.hwdef -bit ${apollo_root_path}/bit/top.bit -file ${apollo_root_path}/${hw_dir}/top -force

#build Xilinx's new kind of filee....
write_hw_platform -fixed -minimal -file ${apollo_root_path}/${hw_dir}/top.xsa -force

#create any debugging files
write_debug_probes -force ${apollo_root_path}/bit/top.ltx                                                                
