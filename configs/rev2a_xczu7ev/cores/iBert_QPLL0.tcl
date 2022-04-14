set name iBert

set output_path ${apollo_root_path}/configs/${build_name}/cores/

file mkdir ${output_path}

file delete -force ${apollo_root_path}/configs/${build_name}/cores/${name}

#create IP
create_ip -vlnv [get_ipdefs -filter {NAME == ibert_ultrascale_gth}] -module_name ${name} -dir ${output_path}


set_property -dict [list CONFIG.C_SYSCLK_FREQUENCY {200} \
			CONFIG.C_RXOUTCLK_FREQUENCY {250.0} \
			CONFIG.C_RXOUTCLK_GT_LOCATION {QUAD227_0} \
			CONFIG.C_REFCLK_SOURCE_QUAD_4 {MGTREFCLK0_227} \
			CONFIG.C_REFCLK_SOURCE_QUAD_1 {None} \
			CONFIG.C_PROTOCOL_REFCLK_FREQUENCY_1 {100} \
			CONFIG.C_PROTOCOL_QUAD4 {Custom_1_/_5_Gbps} \
			CONFIG.C_PROTOCOL_QUAD1 {None} \
			CONFIG.C_GT_CORRECT {true} \
			CONFIG.C_PROTOCOL_MAXLINERATE_1 {5} \
		       ] [get_ips ${name}]
