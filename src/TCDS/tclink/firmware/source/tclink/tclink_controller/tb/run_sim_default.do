vlib work

## Compile files
# Source files
vcom -explicit  -93 "./../scaler.vhd"
vcom -explicit  -93 "./../dco_controller.vhd"
vcom -explicit  -93 "./../phase_offset_removal.vhd"
vcom -explicit  -93 "./../pi_controller.vhd"
vcom -explicit  -93 "./../sigma_delta_modulator.vhd"
vcom -explicit  -93 "./../tclink_controller.vhd"

## Test bench file
vcom -explicit  -93 "./tb_tclink_controller.vhd"

# Start simulation
vsim -gui  work.tb_tclink_controller -gAdco=1036962  -gAie=0 -gAie_enable=0 -gApe=14 -genable_mirror=1 -gmodulo_carrier_period=2123698228 -gFIXEDPOINT_BIT=16 -gDATA_WIDTH=48 -gCOEFF_SIZE=4 -gsigma_delta_osr=5

view wave
view structure
view signals
do "./wave_config.do"
run -all

