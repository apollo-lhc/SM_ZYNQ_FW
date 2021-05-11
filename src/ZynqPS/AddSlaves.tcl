#================================================================================
#  Configure and add AXI slaves
#  Auto-generated by 
#================================================================================
#CM2_UART
{'baud_rate': '115200', 'command': 'AXI_IP_UART', 'irq_port': '${::IRQ_ORR}/in1', 'addr': {'range': '8K', 'offset': '0xA0150000'}, 'axi_control': '${::AXI_MASTER_CTRL}'}

#SLAVE_I2C
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '8K', 'offset': '0xA0008000'}}

#CM
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '8K', 'offset': '0xA000A000'}}

#SM_INFO
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '8K', 'offset': '0xA000C000'}}

#AXI_MON
{'mon_axi': ['${::ZYNQ_NAME}/M_AXI_HPM0_FPD', '${::ZYNQ_NAME}/M_AXI_HPM1_FPD'], 'axi_control': '${::AXI_C2C_CTRL}', 'mon_axi_clk': ['${::AXI_MASTER_CLK}', '${::AXI_MASTER_CLK}'], 'command': 'AXI_IP_AXI_MONITOR', 'core_rstn': '${::AXI_MASTER_RSTN}', 'mon_axi_rstn': '${::AXI_MASTER_RSTN} ${::AXI_MASTER_RSTN}', 'core_clk': '${::AXI_MASTER_CLK}'}

#TCDS_2
{'axi_control': {'axi_rstn': '${::AXI_MASTER_RSTN}', 'axi_freq': '125000000', 'axi_clk': 'clk_125', 'axi_interconnect': '${::AXI_INTERCONNECT_NAME}'}, 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '4K', 'offset': '0xA0170000'}}

#ESM_UART
{'baud_rate': '115200', 'command': 'AXI_IP_UART', 'irq_port': '${::IRQ_ORR}/in2', 'addr': {'range': '8K', 'offset': '0xA0160000'}, 'axi_control': '${::AXI_MASTER_CTRL}'}

#CM1_UART
{'baud_rate': '115200', 'command': 'AXI_IP_UART', 'irq_port': '${::IRQ_ORR}/in0', 'addr': {'range': '8K', 'offset': '0xA0140000'}, 'axi_control': '${::AXI_MASTER_CTRL}'}

#MONITOR
{'enable_i2c_pins': 0, 'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_IP_SYS_MGMT', 'addr': {'range': '64K', 'offset': '0xA0040000'}}

#SERV
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '8K', 'offset': '0xA3C20000'}}

#PL_MEM
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_IP_BRAM', 'addr': {'range': '8K', 'offset': '0xA0000000'}}

#PLXVC
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '64K', 'offset': '0xA0010000'}}

#C2C
{'axi_control': {'axi_rstn': '${::AXI_MASTER_RSTN}', 'axi_freq': '${::AXI_MASTER_CLK_FREQ}', 'axi_clk': '${::AXI_MASTER_CLK}', 'axi_interconnect': '${::AXI_C2C_INTERCONNECT_NAME}'}, 'addr': {'range': '32M', 'offset': '0xB8000000'}, 'addr_lite': {'range': '64K', 'offset': '0xB3c40000'}, 'device_name': 'C2C1', 'init_clk': '${::INIT_CLK}', 'command': 'AXI_C2C_MASTER', 'primary_serdes': '1', 'refclk_freq': '100'}

#C2C2
{'axi_control': {'axi_rstn': '${::AXI_MASTER_RSTN}', 'axi_freq': '${::AXI_MASTER_CLK_FREQ}', 'axi_clk': '${::AXI_MASTER_CLK}', 'axi_interconnect': '${::AXI_C2C_INTERCONNECT_NAME}'}, 'addr': {'range': '32M', 'offset': '0xBC000000'}, 'addr_lite': {'range': '64K', 'offset': '0xB3e40000'}, 'device_name': 'C2C2', 'init_clk': '${::INIT_CLK}', 'command': 'AXI_C2C_MASTER', 'primary_serdes': 'C2C1_PHY', 'refclk_freq': '100'}

#C2C22b
{'axi_control': {'axi_rstn': '${::AXI_MASTER_RSTN}', 'axi_freq': '${::AXI_MASTER_CLK_FREQ}', 'axi_clk': '${::AXI_MASTER_CLK}', 'axi_interconnect': '${::AXI_C2C_INTERCONNECT_NAME}'}, 'addr': {'range': '32M', 'offset': '0xBE000000'}, 'addr_lite': {'range': '64K', 'offset': '0xB3f40000'}, 'device_name': 'C2C2b', 'init_clk': '${::INIT_CLK}', 'command': 'AXI_C2C_MASTER', 'primary_serdes': 'C2C1_PHY', 'refclk_freq': '100'}

#C2C1b
{'axi_control': {'axi_rstn': '${::AXI_MASTER_RSTN}', 'axi_freq': '${::AXI_MASTER_CLK_FREQ}', 'axi_clk': '${::AXI_MASTER_CLK}', 'axi_interconnect': '${::AXI_C2C_INTERCONNECT_NAME}'}, 'addr': {'range': '32M', 'offset': '0xBA000000'}, 'addr_lite': {'range': '64K', 'offset': '0xB3d40000'}, 'device_name': 'C2C1b', 'init_clk': '${::INIT_CLK}', 'command': 'AXI_C2C_MASTER', 'primary_serdes': 'C2C1_PHY', 'refclk_freq': '100'}

#SI
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_IP_I2C', 'addr': {'range': '8K', 'offset': '0xA1600000'}}

#LDAQ
{'axi_control': '${::AXI_MASTER_CTRL}', 'command': 'AXI_PL_DEV_CONNECT', 'addr': {'range': '4K', 'offset': '0xA0180000'}}

