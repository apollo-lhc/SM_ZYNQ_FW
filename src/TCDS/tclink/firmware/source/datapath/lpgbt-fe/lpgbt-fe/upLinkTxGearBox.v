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
 *  file: upLinkTxGearBox.v
 *
 *  upLinkTxGearBox
 *
 *  History:
 *  2017/03/27 Eduardo Brandao de Souza Mendes    : Created
 *  2020/01/28 Eduardo Brandao de Souza Mendes    : Generic implementation for any-size WORD_WIDTH
 **/

`timescale 1 ps / 1 ps

module upLinkTxGearBox #(parameter g_WORD_WIDTH=32, parameter g_DATA_RATE=2) //DATA_RATE 1=5G, 2=10G
    (
	input wire         clock,
	input wire         reset,
	input wire         dataStrobe,
	input wire [255:0] dataFrame,
	input wire [255:0] errorFrame, // dgb only	
	output reg [g_WORD_WIDTH-1:0]  dataWord
    );

	// Wire definition
	reg [2:0] gearboxCounter;

	wire [255:0] dataFrameError = dataFrame ^ errorFrame;
	
	wire [255:0] dataFrameInv;

	// genvar
	genvar i;
	integer CNTR_MAX = (128+128*(g_DATA_RATE-1))/g_WORD_WIDTH;


// Gearbox counter
always @(posedge clock)
    begin
    if (reset == 1'b1)
        gearboxCounter <= 3'd0;
	else
        if(dataStrobe==1'b1 || gearboxCounter==(CNTR_MAX-1))
			gearboxCounter <= 3'd0;
		else
			gearboxCounter <= gearboxCounter + 1;
end

for (i=0; i < 256; i = i + 1) begin
	assign dataFrameInv[i] = dataFrameError[255-i];
end

// Data word
always @(posedge clock)
    begin
    if (reset == 1'b1) begin
        dataWord <= 'd0;
	end
    else begin
		if (g_DATA_RATE=='d2) begin
		    dataWord <= dataFrameInv[gearboxCounter*g_WORD_WIDTH +: g_WORD_WIDTH];
		end else begin
		    dataWord <= dataFrameInv[(gearboxCounter*g_WORD_WIDTH+128) +: g_WORD_WIDTH];
		end
	end
end

endmodule
