.PHONY: doc doc_zynq doc_tcl clean push push_zynq push_tcl

VHDL_SEARCH_PATHS = "INPUT=./main_fw.md ../src/ ../proj/zynq_bd/synth/ ../proj/zynq_bd/hdl/ "$(wildcard  ../proj/zynq_bd/ip/*/synth/)


all: doc

clean:
	@echo "Cleaning up"
	@rm -rf ./html_zynq > /dev/null 2>&1
	@rm -rf ./html_tcl > /dev/null 2>&1

doc : doc_zynq doc_tcl

doc_zynq : 
	@echo "Generating doxygen for Zynq"
	@(cat ./SM_FW.cfg ; echo ${VHDL_SEARCH_PATHS}) | ./doxygen-patched -

doc_tcl :
	@echo "Generating doxygen for TCL"
	@doxygen ./SM_TCL.cfg

push : push_zynq push_tcl

push_zynq : doc_zynq
	@scp -r html_zynq/* apollo@ohm.bu.edu:~/public_html/Doc/SM_FW/

push_tcl : doc_tcl
	@scp -r html_tcl/* apollo@ohm.bu.edu:~/public_html/Doc/SM_TCL/
