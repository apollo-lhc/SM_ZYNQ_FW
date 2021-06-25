#location on host and emulated system for the qemu binary
QEMU_PATH=/usr/local/bin
#types of arches we want rules for
QEMU_ARCHS="qemu-aarch64-static qemu-arm-static"

#template for grabbing the qemu requested and putting it in the correct place
define QEMU_template =
 ${QEMU_PATH}/$(1) ${INSTALL_PATH}/${QEMU_PATH}/$(1): | ${INSTALL_PATH}
	wget https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0/$(1)
	chmod +x $(1)
	sudo mkdir -p ${INSTALL_PATH}/$(1)
	sudo mkdir -p ${QEMU_PATH}
	sudo cp -a $(1) ${INSTALL_PATH}/${QEMU_PATH}
	sudo cp -a $(1) ${QEMU_PATH}
	rm -f $(1)
endef

#generate a build rule from the above template for each arch in QEMU_ARCHS
$(foreach arch,$(QEMU_ARCHES),$(eval $(call QEMU_template,$(arch))))
