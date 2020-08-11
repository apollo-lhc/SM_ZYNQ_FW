set hw_dir kernel/hw

#create bit file
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force ../bit/top.bit

#create hwdef file
write_hwdef -file ../${hw_dir}/top.hwdef -force

# create the 
write_sysdef -hwdef ../${hw_dir}/top.hwdef -bit ../bit/top.bit -file ../${hw_dir}/top.hdf -force

#create any debugging files
write_debug_probes -force ../bit/top.ltx                                                                
