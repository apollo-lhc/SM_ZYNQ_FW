.PHONY: doc clean

all: doc

clean:
	@echo "Cleaning up"
	@rm -rf ./html > /dev/null 2>&1

doc : 
	@echo "Generating doxygen"
	@./doxygen-patched ./SM_FW.cfg
	@doxygen ./SM_TCL.cfg


