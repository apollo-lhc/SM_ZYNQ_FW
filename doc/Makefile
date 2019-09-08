.PHONY: doc clean

VHDL_SEARCH_PATHS = "INPUT=./main_fw.md ../src/ ../bd/zynq_bd/synth/ ../bd/zynq_bd/hdl/ "$(wildcard  ../bd/zynq_bd/ip/*/synth/)


all: doc

clean:
	@echo "Cleaning up"
	@rm -rf ./html > /dev/null 2>&1
	@rm -rf ./html_tcl > /dev/null 2>&1

doc : 
	@echo "Generating doxygen"
	@(cat ./SM_FW.cfg ; echo ${VHDL_SEARCH_PATHS}) | ./doxygen-patched -
	@doxygen ./SM_TCL.cfg


