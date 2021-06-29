fs_mods:
	# Add common filesystem mods
	sudo cp -r ${CONFIG_BASE_DIR}/common/file_system/* ${INSTALL_PATH}
	# Add rev specific mods
	@echo ${CONFIG_DIR}
	sudo cp -r ${CONFIG_DIR}/file_system/* ${INSTALL_PATH}
