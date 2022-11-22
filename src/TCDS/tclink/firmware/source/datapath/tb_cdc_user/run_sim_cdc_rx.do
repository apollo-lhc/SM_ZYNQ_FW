vlib work

########## Compile files ##########
# Source files
# Mesochronous CDC
vcom -explicit  -93 "./../cdc_user/cdc_rx.vhd"

# PRBS GEN / CHK
vcom -explicit  -93 "./../hprbs_framing/prbs_gen.vhd"
vcom -explicit  -93 "./../hprbs_framing/prbs_chk.vhd"

## Test bench file
vcom -explicit  -93 "./tb_cdc_rx.vhd"
####################################

########### Simulation ############
set CLOCK_A_RATIO_LIST "8"
#"4 6 8"
set CLOCK_B_RATIO_LIST "1"
#"1 2 3 4 5 6 7 8" 

set idx_A 0
while {$idx_A < [llength $CLOCK_A_RATIO_LIST]} {
  set idx_B 0
  while {$idx_B < [llength $CLOCK_B_RATIO_LIST]} {
    set CLOCK_A_RATIO [lindex $CLOCK_A_RATIO_LIST $idx_A]
    set CLOCK_B_RATIO [lindex $CLOCK_B_RATIO_LIST $idx_B]
    vsim -gui work.tb_cdc_rx -gg_CLOCK_A_RATIO=$CLOCK_A_RATIO -gg_CLOCK_B_RATIO=$CLOCK_B_RATIO -t 10fs
    
	# Uncomment lines below to see wave
    view wave
    view structure
    view signals
    do "./sim_cdc_rx_wave_config.do"
    log -r *
    run 100us
    incr idx_B
  }
  incr idx_A
}
###################################

