#!/bin/bash
ghdl -i tb_TCDS_Monitor2.vhd
ghdl -i ../../src/TCDS/TCDS_Monitor.vhd
ghdl -i ../../src/misc/capture_CDC.vhd
ghdl -i ../../src/misc/counter.vhd
ghdl -i ../../src/misc/data_CDC.vhd
ghdl -i ../../src/misc/DC_data_CDC.vhd
ghdl -i ../../src/misc/pacd.vhd
ghdl -i ../../src/misc/types.vhd
ghdl -m tb_TCDS_Monitor
ghdl -r tb_TCDS_Monitor --stop-time=10us --wave=out.ghw
