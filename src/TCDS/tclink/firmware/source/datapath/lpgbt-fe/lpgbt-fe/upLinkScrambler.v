
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
 *  file: upLinkScrambler.v
 *
 *  upLinkScrambler
 * 
 *  Controll signals :

 *  fecMode:
 *    ‘0’ - FEC 5
 *    ‘1’ - FEC 12
 *
 *  History:
 *  2016/05/30 Szymon Kulis    : Created
 *  2016/10/26 José Fonseca    : Completed
 * 
 **/

module upLinkScrambler(
    // input clocks:
    input          clk,
    // input data:
    input [233:0]  dataFec5,
    input [205:0]  dataFec12,
   
    // controll signals:
    input          fecMode,
    input          txDataRate,
    input          reset,
    input          bypass,
	input          enable,

    // output data:
    output [233:0] scrambledDataFec5,
    output [205:0] scrambledDataFec12

);
  // tmrg default triplicate
  localparam FEC5           = 1'b0;
  localparam FEC12          = 1'b1;
  localparam TxDataRate5G12 = 1'b0;
  localparam TxDataRate10G24= 1'b1;

  /*
  reg clkGate10GFEC12;
  reg clkGate10GFEC5;
  reg clkGate5GFEC12;
  reg clkGate5GFEC5;

  wire clk10GFEC12=clk&clkGate10GFEC12;
  wire clk10GFEC5 =clk&clkGate10GFEC5;
  wire clk5GFEC12 =clk&clkGate5GFEC12;
  wire clk5GFEC5  =clk&clkGate5GFEC5;

  always @(fecMode or txDataRate)
    begin
      clkGate10GFEC12=1'b0;
      clkGate10GFEC5 =1'b0;
      clkGate5GFEC12 =1'b0;
      clkGate5GFEC5  =1'b0;
      case ({txDataRate,fecMode})
        {TxDataRate5G12,  FEC5}: begin clkGate5GFEC5=1'b1; end
        {TxDataRate5G12, FEC12}: begin clkGate5GFEC12=1'b1; end
        {TxDataRate10G24, FEC5}: begin clkGate10GFEC5=1'b1; clkGate5GFEC5=1'b1; end
        {TxDataRate10G24,FEC12}: begin clkGate10GFEC12=1'b1; clkGate5GFEC12=1'b1; end
      endcase
    end
  */

// -----------------------------------------------------------------------------
// --------------------- FEC 5 scramblers --------------------------------------
// -----------------------------------------------------------------------------

// low data rate 
  scrambler58bitOrder58 FEC5L0 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec5[57:0]),
    .reset(reset),
    .scrambledData(scrambledDataFec5[57:0])
  );

  scrambler58bitOrder58 FEC5L1 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec5[115:58]),
    .reset(reset),
    .scrambledData(scrambledDataFec5[115:58])
  );

// high data rate
  scrambler58bitOrder58 FEC5H0 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec5[173:116]),
    .reset(reset),
    .scrambledData(scrambledDataFec5[173:116])
  );

  scrambler60bitOrder58 FEC5H1 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec5[233:174]),
    .reset(reset),
    .scrambledData(scrambledDataFec5[233:174])
  );

// -----------------------------------------------------------------------------
// --------------------- FEC 12 scramblers -------------------------------------
// -----------------------------------------------------------------------------

// low data rate 
  scrambler51bitOrder49 FEC12L0 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec12[50:0]),
    .reset(reset),
    .scrambledData(scrambledDataFec12[50:00])
  );

  scrambler51bitOrder49 FEC12L1 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec12[101:51]),
    .reset(reset),
    .scrambledData(scrambledDataFec12[101:51])
  );

// high data rate
  scrambler51bitOrder49 FEC12H0 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),
    .data(dataFec12[152:102]),
    .reset(reset),
    .scrambledData(scrambledDataFec12[152:102])
  );

  scrambler53bitOrder49 FEC12H1 (
    .bypass(bypass),
    .clock(clk),
	.enable(enable),	
    .data(dataFec12[205:153]),
    .reset(reset),
    .scrambledData(scrambledDataFec12[205:153])
  );  
endmodule

