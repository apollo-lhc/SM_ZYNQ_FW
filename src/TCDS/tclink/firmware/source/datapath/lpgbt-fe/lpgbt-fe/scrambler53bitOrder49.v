/* Module: scrambler51bitOrder49                                             */ 
/* Created: Paulo Moreira, 2015/09/18                                        */
/* Modified: José Fonseca, 2016/10/21                                        */
/* 2016/05/30 Kulis : Test partterns removed                                 */
/*                    (moved to test pattern generator block)                */
/* Institute: CERN                                                           */
/* Version: 1.0                                                              */

/* Scrambler width: 51 - bits                                                */
/* Scrambler order: 49                                                       */
/* Scrambling recursive equation: Si = Di xnor Si-40 xnor Si-49              */

`timescale 1 ps / 1 ps

module scrambler53bitOrder49 #(parameter INIT_SEED = 53'h1f16348aab1a1a)
    (
    input wire [52:0] data,
    input wire clock,
    input wire reset,
    input wire bypass,
	input wire enable,
    output reg [52:0] scrambledData
    );

wire [52:0] iScrambledData;
wire [52:0] iScrambledDataVoted = iScrambledData;

// Scrambler output register
always @(posedge clock)
    begin
    if (reset == 1'b1) begin
        scrambledData <= INIT_SEED;
	end
    else begin
        if(enable==1'b1) begin
			scrambledData <= iScrambledDataVoted;
		end
	end
end

/*
// synopsys translate_off
initial 
  begin
    scrambledData=$random;
  end
// synopsys translate_on
*/

// Scrambler polynomial and bypass mux  
assign
    iScrambledData[52:49] = (bypass) ? data[52:49] : data[52:49] ~^ data[12:9] ~^ scrambledData[23:20] ~^ data[3:0] ~^ scrambledData[5:2],
    iScrambledData[48:40] = (bypass) ? data[48:40] : data[48:40] ~^ data[8:0] ~^ scrambledData[19:11] ~^ scrambledData[10:2] ~^ scrambledData[50:42],
    iScrambledData[39:0]  = (bypass) ? data[39:0]  : data[39:0] ~^ scrambledData[50:11] ~^ scrambledData[41:2];

endmodule
