#from https://forums.xilinx.com/t5/Embedded-Linux/Pinctrl-for-using-gem0-MIO-interface/td-p/1008395

SRC_URI_append += " file://0001-MIO-pin-26-added-to-pinctrl-ethernet0-group.patch"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
