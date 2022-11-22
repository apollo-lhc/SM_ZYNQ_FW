vlib work

########## Compile files ##########
# Source files
# Common
vcom -explicit  -93 "./../../common/bit_synchronizer.vhd"

# lpGBT FPGA
vcom -explicit  -93 "./../lpgbt-fpga/lpgbtfpga_package.vhd"
vcom -explicit  -93 "./../lpgbt-fpga/lpgbtfpga_uplink.vhd"
vcom -explicit  -93 "./../lpgbt-fpga/uplink/*.vhd"

# lpGBT FE
vcom -explicit  -93 "./../lpgbt-fe/lpgbt_fe_tx.vhd"
vlog -reportprogress 300 "./../lpgbt-fe/lpgbt-fe/*.v"

# PRBS GEN / CHK
vcom -explicit  -93 "./../hprbs_framing/prbs_gen.vhd"
vcom -explicit  -93 "./../hprbs_framing/prbs_chk.vhd"

## Test bench file
vcom -explicit  -93 "./tb_lpgbt_symmetric.vhd"
####################################

############ Simulation ############
vsim -gui work.tb_lpgbt_symmetric -t 10ps

view wave
view structure
view signals
do "./sim_lpgbt_symmetric_wave_config.do"
log -r *
run -all
####################################

