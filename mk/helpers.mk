#################################################################################
# make stuff
#################################################################################
SHELL=/bin/bash -o pipefail

#add path so build can be more generic
MAKE_PATH := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

OUTPUT_MARKUP= 2>&1 | tee -a ../make_log.txt | ccze -A
SLACK_MESG ?= echo

all:
	@echo "Please specify a design to build"
	@$(MAKE) list 

clean_make_log:
	@rm make_log.txt &> /dev/null

#################################################################################
# Slack notifications
#################################################################################
NOTIFY_DAN_GOOD:
	${SLACK_MESG} "FINISHED building FW!"
NOTIFY_DAN_BAD:
	${SLACK_MESG} "FAILED to build FW!"

#################################################################################
# Help 
#################################################################################
#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
#define that builds a list of make rules based on a regex
#ex:
#   $(call LIST_template,REXEX)
define LIST_template = 
@$(MAKE) -pRrq -f $(MAKEFILE_LIST) | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | { grep $(1) || true;} | { grep -v prebuild || true;} | { egrep -v -e '^[^[:alnum:]]' -e '^$@$$' || true;} | column
endef

list:
	@echo
	@echo Apollo SM config:
	$(call LIST_template,rev[[:digit:]]_)
	@echo
	@echo Prebuilds:
	$(call LIST_template,prebuild_)
	@echo
	@echo Vivado:
	$(call LIST_template,open_)
	@echo
	@echo Clean:
	$(call LIST_template,clean_)
	@echo
	@echo Tests:
	$(call LIST_template,test_)
	@echo
	@echo Test-benches:
	$(call LIST_template,tb_)

full_list:
	$(call LIST_template,.)
