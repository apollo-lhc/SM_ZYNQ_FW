#!/bin/bash
SRC_PATH=/home/dan/Apollo/SM_ZYNQ_FW/src/TCDS/top-secret/
DEST_PATH=../../../
DEST_SRC_PATH=${DEST_PATH}src/TCDS/top_secret/
DEST_ADDR_PATH=${DEST_PATH}address_table/modules/
cp   ${SRC_PATH}components/counters/firmware/hdl/unlock_counter.vhd                               ${DEST_SRC_PATH}counters/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface.vhd			  ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface_choice_mgt_usp_gth.vhd    ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface_choice_speed_10g.vhd	  ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface_mgt.vhd		          ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface_pkg.vhd		          ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_interface/firmware/hdl/tcds2_interface_with_mgt.vhd		  ${DEST_SRC_PATH}tcds2_interface/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_choice_speed_10g.vhd			  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_link_pkg.vhd				  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_link_speed_pkg.vhd			  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_streams_pkg.vhd			  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/ttc2_frame_splitter.vhd			  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tts2_frame_builder.vhd			  ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_link_medium_pkg.vhd                      ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/tcds2_link/firmware/hdl/tcds2_link_csr_pkg.vhd                         ${DEST_SRC_PATH}tcds2_link/firmware/hdl/
cp   ${SRC_PATH}components/constants/firmware/hdl/constants_tcds2.vhd                             ${DEST_SRC_PATH}constants/firmware/hdl/
cp   ${SRC_PATH}components/board_and_fw_id/firmware/hdl/board_and_fw_id_pkg.vhd                   ${DEST_SRC_PATH}board_and_fw_id/firmware/hdl

#address table
mkdir -p ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_interface/addr_table/ipbus_tcds2_interface_accessor.xml	  ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_link_csr_master.xml                   	  ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_link_csr_master_control.xml              ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_link_csr_master_status.xml               ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_frame_spy.xml                   	  ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_ttc2_spy.xml                    	  ${DEST_ADDR_PATH}/top_secret/
cp     ${SRC_PATH}components/tcds2_link/addr_table/tcds2_tts2_spy.xml                             ${DEST_ADDR_PATH}/top_secret/
