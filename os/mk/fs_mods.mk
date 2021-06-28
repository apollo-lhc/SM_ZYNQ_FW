fs_mods:
	# Add common filesystem mods
	sudo install    -o root ${CONFIG_BASE_DIR}/common/file_system/* ${INSTALL_PATH}
	# Add rev specific mods
	sudo install    -o root ${CONFIG_DIR}/file_system/* ${INSTALL_PATH}
