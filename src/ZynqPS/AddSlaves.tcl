#================================================================================
#  Configure and add AXI slaves
#  Auto-generated by 
#================================================================================
#SERV
[AXI_PL_DEV_CONNECT SERV      ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA3C20000 8K]

#CM2_UART
[AXI_IP_UART 115200 ${IRQ_ORR}/in1 CM2_UART   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0150000 8K]

#SLAVE_I2C
[AXI_PL_DEV_CONNECT SLAVE_I2C ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0008000 8K]

#CM
[AXI_PL_DEV_CONNECT CM        ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA000A000 8K]

#PL_MEM
[AXI_IP_BRAM PL_MEM ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0000000 8K]

#SM_INFO
[AXI_PL_DEV_CONNECT SM_INFO   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA000C000 8K]

#AXI_MON
[AXI_IP_AXI_MONITOR [list ${ZYNQ_NAME}/M_AXI_HPM0_FPD ${ZYNQ_NAME}/M_AXI_HPM1_FPD] [list ${AXI_MASTER_CLK} ${AXI_MASTER_CLK}] [list ${AXI_MASTER_RSTN} ${AXI_MASTER_RSTN}] ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} AXI_MON ${AXI_C2C_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} ]

#PLXVC
[AXI_PL_DEV_CONNECT PLXVC     ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0010000 64K]

#C2C
[AXI_C2C_MASTER C2C1          ${AXI_C2C_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 1        ${INIT_CLK} 100 0x50A000000 32M 0x503c40000 64K]

#C2C2
[AXI_C2C_MASTER C2C2          ${AXI_C2C_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} C2C1_PHY ${INIT_CLK} 100 0x50C000000 32M 0x503d40000 64K]

#SI
[AXI_IP_I2C SI                ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA1600000 8K]

#XVC_LOCAL
[AXI_IP_LOCAL_XVC XVC_LOCAL   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0030000 64K]

#ESM_UART
[AXI_IP_UART 115200 ${IRQ_ORR}/in2 ESM_UART   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0160000 8K]

#CM1_UART
[AXI_IP_UART 115200 ${IRQ_ORR}/in0 CM1_UART   ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0140000 8K]

#MONITOR
[AXI_IP_SYS_MGMT 0 MONITOR      ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} ${AXI_MASTER_CLK_FREQ} 0xA0040000 64K 0]

