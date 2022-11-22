#-----------------------------------------------------
# TCLink MASTER DDMTD async clocks - MASTER ONLY
#-----------------------------------------------------
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *cmp_dmtd_phase_meas/DMTD_A/tag_o_reg*/C}]]

