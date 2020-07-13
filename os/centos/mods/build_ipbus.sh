#!/bin/bash
cd /tmp/ipbus-software
make -j32 Set=uhal BUILD_PUGIXML=0 BUILD_UHAL_TESTS=1 BUILD_UHAL_PYCOHAL=1
make Set=uhal BUILD_PUGIXML=0 BUILD_UHAL_TESTS=1 BUILD_UHAL_PYCOHAL=1 install

