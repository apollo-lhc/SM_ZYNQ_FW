#!/bin/bash

rm work-obj93.cf
ghdl -a --ieee=synopsys ../../src/misc/types.vhd
ghdl -a --ieee=synopsys ../../src/fw_version.vhd
ghdl -a --ieee=synopsys ../../src/misc/Xilinx/rams_sp_wf.vhd
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/axiRegWidthPkg_32.vhd 
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/axiRegPkg.vhd 
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/axiReg.vhd 
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/axiRegMaster.vhd
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/axiRegBlocking.vhd
ghdl -a --ieee=synopsys ../../regmap_helper/axiReg/bramPortPkg.vhd
ghdl -a --ieee=synopsys ../../src/MEM_TEST/MEM_TEST_PKG.vhd
ghdl -a --ieee=synopsys ../../src/MEM_TEST/MEM_TEST_map.vhd
ghdl -a --ieee=synopsys ../../src/MEM_TEST/Mem_test.vhd
ghdl -a --ieee=synopsys tb_bram_regmap.vhd
ghdl -e --ieee=synopsys tb_bram_regmap
ghdl -r --ieee=synopsys tb_bram_regmap --stop-time=30000ns --wave=test.ghw 



