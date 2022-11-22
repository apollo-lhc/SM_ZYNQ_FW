#######################################################
###                  SLAVE
#######################################################
#-----------------------------------------------------
### RXSLIDE MODE
# OBS: This design can only achieve a slave fixed-latency in PMA mode. In order to achieve a fixed-latency in PCS mode, the roulette approach has to be implemented
#-----------------------------------------------------
set_property RXSLIDE_MODE PMA [get_cells -hierarchical -filter {NAME =~ *cmp_gtye4_slave_timing*GTYE4_CHANNEL_PRIM_INST}]
#-----------------------------------------------------