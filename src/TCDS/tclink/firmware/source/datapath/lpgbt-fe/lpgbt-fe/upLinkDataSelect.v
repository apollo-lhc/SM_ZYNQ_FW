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
 *  file: upLinkDataSelect.v
 *
 *  upLinkDataSelect
 *
 *  Controll signals :

 *  fecMode:
 *    ‘0’ - FEC 5
 *    ‘1’ - FEC 12
 *
 *  History:
 *  2016/05/30 Szymon Kulis    : Created
 *  2016/10/19 José Fonseca    : Modified
 *  2020/01/27 Eduardo Mendes  : LPGBT-FPGA prototype
 **/

module upLinkDataSelect(

    // input data:
    input  [229:0] txDataFrame,
    input  [1:0]   txIC,
    input  [1:0]   txEC,


    // controll signals:
    input          fecMode,
    input          dataRate,

    // output data:
    output reg [233:0] dataFec5,
    output reg [205:0] dataFec12
);

  // tmrg default triplicate

  localparam FEC5  = 1'b0;
  localparam FEC12 = 1'b1;
  localparam DR5G  = 1'b0;
  localparam DR10G = 1'b1;

  always @* begin
      if (fecMode == FEC5) begin
        dataFec12 = 0;
        if (dataRate == DR10G) begin
          dataFec5 = {txIC, txEC, txDataFrame[229:0]};
        end
        else begin
          dataFec5 = {118'd0, txIC, txEC, txDataFrame[111:0]};
        end
      end
      else begin
        dataFec5=0;
       	if (dataRate == DR10G) begin
          dataFec12 = {txIC, txEC, txDataFrame[201:0]};
        end
        else begin
          dataFec12 = {104'd0, txIC, txEC, txDataFrame[97:0]};
        end
      end
    end
endmodule
