
/** ****************************************************************************
 *  lpGBTX                                                                     *
 *  Copyright (C) 2011-2016 GBTX Team, CERN                                    *
 *                                                                             *
 *  This IP block is free for HEP experiments and other scientific research    *
 *  purposes. Commercial exploitation of a chip containing the IP is not       *
 *  permitted.  You can not redistribute the IP without written permission     *
 *  from the authors. Any modifications of the IP have to be communicated back *
 *  to the authors. The use of the IP should be acknowledged in publications,  *
 *  public presentations, user manual, and other documents.                    *
 *                                                                             *
 *  This IP is distributed in the hope that it will be useful, but WITHOUT ANY *
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *
 *  FOR A PARTICULAR PURPOSE.                                                  *
 *                                                                             *
 *******************************************************************************
 *
 *  file: upLinkFECEncoder.v
 *
 *  upLinkFECEncoder
 * 
 *  Control flags :

 *  drMode:
 *    ‘0’ - 5.12  Gbps
 *    ‘1’ - 10.24 Gbps
 *
 *  History:
 *  2016/05/30 Szymon Kulis    : Created
 *  2016/10/19 José Fonseca    : Updated
 **/

module upLinkFECEncoder(
	// input data:
	input [233:0]  dataFec5,
	input [205:0]  dataFec12,
  
	// Control flag  
	input drMode,
   
	// output FEC codes:
	output [19:0]  fec5,
	output [47:0]  fec12
);
// -------------------------------------------------------------------------- //
// ------------- Triple Modular Redundancy Generator Directives ------------- //
// -------------------------------------------------------------------------- //
// tmrg do_not_touch
// -------------------------------------------------------------------------- //

// -----------------------------------------------------------------------------
// ---------------------  FEC 5 Encoders  --------------------------------------
// -----------------------------------------------------------------------------

  // wire [144:0] FEC5virtFrame_C0 = {29'b0, dataFec5[115:0]};
  // wire [144:0] FEC5virtFrame_C1 = {29'b0, dataFec5[115:0]};
  
  wire [144:0] FEC5virtFrame_C0;
  wire [144:0] FEC5virtFrame_C1;

  assign FEC5virtFrame_C0 = (drMode) ? {26'd0, dataFec5[233:232], dataFec5[116:0]} : {29'd0, dataFec5[115:0]};
  assign FEC5virtFrame_C1 = {29'd0, dataFec5[231:117]};


  rs_encoder_N31K29 FEC5_C0 (.msg(FEC5virtFrame_C0), .parity(fec5[9:0])); 

  rs_encoder_N31K29 FEC5_C1 (.msg(FEC5virtFrame_C1), .parity(fec5[19:10])); 

// -----------------------------------------------------------------------------
// ---------------------  FEC 12 Encoders --------------------------------------
// -----------------------------------------------------------------------------

  wire [51:0] FEC12virtFrame_C0;
  wire [51:0] FEC12virtFrame_C1;
  wire [51:0] FEC12virtFrame_C2;
  wire [51:0] FEC12virtFrame_C3;
  wire [51:0] FEC12virtFrame_C4;
  wire [51:0] FEC12virtFrame_C5;

  assign FEC12virtFrame_C0 = (drMode) ? {16'd0, dataFec12[135:134], dataFec12[33:0]}   : {16'd0, dataFec12[67:66], dataFec12[33:0]};
  assign FEC12virtFrame_C1 = (drMode) ? {16'd0, dataFec12[169:168], dataFec12[67:34]}  : {18'd0, dataFec12[101:100], dataFec12[65:34]};
  assign FEC12virtFrame_C2 = (drMode) ? {16'd0, dataFec12[203:202], dataFec12[101:68]} : {20'd0, dataFec12[99:68]};
  assign FEC12virtFrame_C3 = {18'd0, dataFec12[205:204], dataFec12[133:102]}; 
  assign FEC12virtFrame_C4 = {20'd0, dataFec12[167:136]};
  assign FEC12virtFrame_C5 = {20'd0, dataFec12[201:170]};

  rs_encoder_N15K13 FEC12_C0 (.msg(FEC12virtFrame_C0), .parity(fec12[7:0])); 

  rs_encoder_N15K13 FEC12_C1 (.msg(FEC12virtFrame_C1), .parity(fec12[15:8])); 

  rs_encoder_N15K13 FEC12_C2 (
    .msg(FEC12virtFrame_C2),
    .parity(fec12[23:16])
  ); 

  rs_encoder_N15K13 FEC12_C3 (
    .msg(FEC12virtFrame_C3),
    .parity(fec12[31:24])
  ); 

  rs_encoder_N15K13 FEC12_C4 (
    .msg(FEC12virtFrame_C4),
    .parity(fec12[39:32])
  ); 

  rs_encoder_N15K13 FEC12_C5 (
    .msg(FEC12virtFrame_C5),
    .parity(fec12[47:40])
  ); 

endmodule

