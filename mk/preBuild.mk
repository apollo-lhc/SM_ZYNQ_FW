CACTUS_ROOT:="/opt/cactus"
CACTUS_LD_PATH:=$(CACTUS_ROOT)"/lib/"

#################################################################################
# Clean
#################################################################################
clean_prebuild:
	@echo "Cleaning up prebuild autogenerated files"
	@rm -f $(ADDSLAVE_TCL_PATH)/AddSlaves*.tcl 
	@rm -f $(ADDRESS_TABLE_CREATION_PATH)/slaves*.yaml
	@rm -rf $(ADDRESS_TABLE_CREATION_PATH)/address_table/*
	@rm -f $(SLAVE_DTSI_PATH)/slaves*.yaml

#################################################################################
# prebuild 
#################################################################################

$(SLAVE_DTSI_PATH)/slaves_%.yaml $(ADDRESS_TABLE_CREATION_PATH)/slaves_%.yaml $(ADDSLAVE_TCL_PATH)/AddSlaves_%.tcl : $(SLAVE_DEF_FILE_BASE)%.yaml
	LD_LIBRARY_PATH=$(CACTUS_LD_PATH) ./scripts/preBuild.py \
			                     -s $^ \
				             -t $(ADDSLAVE_TCL_PATH) \
				             -a $(ADDRESS_TABLE_CREATION_PATH) \
				             -d $(SLAVE_DTSI_PATH)

prebuild_% : $(SLAVE_DTSI_PATH)/slaves_%.yaml $(ADDRESS_TABLE_CREATION_PATH)/slaves_%.yaml $(ADDSLAVE_TCL_PATH)/AddSlaves_%.tcl

