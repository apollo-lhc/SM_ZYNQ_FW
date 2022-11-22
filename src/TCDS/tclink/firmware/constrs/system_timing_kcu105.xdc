#-----------------------------------------------------
# Clocks
#-----------------------------------------------------
#MASTER + SLAVE
create_clock -period 8.000 -name clk_sys [get_ports clk_sys_p_i]

#MASTER + SLAVE
create_clock -period 24.944 -name clk40 [get_ports clk40_p_i]

#MASTER
create_clock -period 3.118 -name master_trxrefclk [get_ports master_trxrefclk_p_i[0]]

#-----------------------------------------------------
