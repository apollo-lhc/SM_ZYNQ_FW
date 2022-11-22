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
 *  file: upLinkTxDataPath.v
 *
 *  upLinkTxDataPath
 *
 *  Controll signals :
 *  txDataRate:
 *    ‘0’ - 5.12 Gb/s
 *    ‘1’ - 10.24 Gb/s
 *
 *  fecMode:
 *    ‘0’ - FEC 5
 *    ‘1’ - FEC 12
 *
 *  History:
 *  2016/05/20 Szymon Kulis    : Created
 *  2016/10/25 José Foseca     : Modified
 *  2016/12/08 Szymon Kulis    : BERT generator added
 *  2017/03/28 Eduardo Mendes  : LPGBT-FPGA prototype
 *  2020/01/27 Eduardo Mendes  : Added txDataFrame instead of high/low/dummy to be consistent with lPGBT-FPGA
 **/


module upLinkTxDataPath (
    // input cloks:
    input          clk,

    // input data:
	input          dataEnable,	
    input  [229:0] txDataFrame,
    input  [1:0]   txIC,
    input  [1:0]   txEC,


    // controll signals
    input          scramblerBypass,
    input          interleaverBypass,
    input          fecMode,
    input          txDataRate,
    input          scramblerReset,
    // output data
    output  [255:0] upLinkFrame
);

// -------------------------------------------------------------------------- //
// ------------- Triple Modular Redundancy Generator Directives ------------- //
// -------------------------------------------------------------------------- //
// tmrg default triplicate
// tmrg do_not_triplicate upLinkFrame
// -------------------------------------------------------------------------- //

  wire [233:0] dataFec5;
  wire [205:0] dataFec12;

  // combinatorial only
  upLinkDataSelect ULDS(
    .dataFec12(dataFec12),
    .dataFec5(dataFec5),
    .dataRate(txDataRate),
    .fecMode(fecMode),
    .txDataFrame(txDataFrame),
    .txEC(txEC),
    .txIC(txIC)
  );

  wire [233:0] scrambledDataFec5;
  wire [205:0] scrambledDataFec12;

  // +1 clock cycle
  upLinkScrambler UPS (
    .bypass(scramblerBypass),
    .clk(clk),
	.enable(dataEnable),
    .dataFec12(dataFec12),
    .dataFec5(dataFec5),
    .fecMode(fecMode),
    .reset(scramblerReset),
    .scrambledDataFec12(scrambledDataFec12),
    .scrambledDataFec5(scrambledDataFec5),
    .txDataRate(txDataRate)
  );

 (* KEEP = "TRUE" *)  wire [19:0] fec5 ;
 (* KEEP = "TRUE" *)  wire [47:0] fec12;

  // combinatorial only
  upLinkFECEncoder ULFE (
    .dataFec12(scrambledDataFec12),
    .dataFec5(scrambledDataFec5),
    .fec12(fec12),
    .fec5(fec5),
    .drMode(txDataRate)
  );

  // combinatorial only  
  upLinkInterleaver ULI (
    .bypass(interleaverBypass),
    .dataFec12(scrambledDataFec12),
    .dataFec5(scrambledDataFec5),
    .fec12(fec12),
    .fec5(fec5),
    .fecMode(fecMode),
    .txDataRate(txDataRate),
    .upLinkFrame(upLinkFrame)
  );

endmodule
