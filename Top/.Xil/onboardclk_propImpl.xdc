set_property SRC_FILE_INFO {cfile:/home/pgkounto/Project/hog_SM/SM_ZYNQ_FW/configs/rev2a_xczu7ev/autogen/cores/onboardclk/onboardclk.xdc rfile:../../configs/rev2a_xczu7ev/autogen/cores/onboardclk/onboardclk.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1_p]] 0.1
