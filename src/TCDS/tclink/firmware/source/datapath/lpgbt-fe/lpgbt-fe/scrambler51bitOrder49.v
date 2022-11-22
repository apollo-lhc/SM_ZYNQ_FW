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

module scrambler51bitOrder49 #(parameter INIT_SEED = 51'h7f1835baaca14)
    (
    input wire [50:0] data,
    input wire clock,
    input wire reset,
    input wire bypass,
	input wire enable,
    output reg [50:0] scrambledData
    );

// tmrg default triplicate

wire [50:0] iScrambledData;
wire [50:0] iScrambledDataVoted = iScrambledData;

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
    iScrambledData[50:49] = (bypass)? data[50:49] : data[50:49] ~^ data[10:9] ~^ scrambledData[21:20] ~^ data[1:0] ~^ scrambledData[3:2],
    iScrambledData[48:40] = (bypass)? data[48:40] : data[48:40] ~^ data[8:0] ~^ scrambledData[19:11] ~^ scrambledData[10:2] ~^ scrambledData[50:42],
    iScrambledData[39:0]  = (bypass)? data[39:0]  : data[39:0] ~^ scrambledData[50:11] ~^ scrambledData[41:2];

endmodule
