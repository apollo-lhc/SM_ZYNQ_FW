/* Module: scrambler58bitOrder58                                        */
/* Created: Paulo Moreira, 2015/09/15                                        */
/* Modified: José Fonseca, 2016/10/21					     */
/* 2016/05/30 Kulis : Test partterns removed                                 */
/*                    (moved to test pattern generator block)                */
/* Institute: CERN                                                           */
/* Version: 1.0                                                              */

/* Scrambler width: 60 - bits                                                */
/* Scrambler order: 58                                                       */
/* Scrambling recursive equation: Si = Di xnor Si-39 xnor Si-58              */

`timescale 1 ps / 1 ps

module scrambler60bitOrder58 #(parameter INIT_SEED = 60'h1faab124cade111)
    (
    input wire [59:0] data,
    input wire clock,
    input wire reset,
    input wire bypass,
	input wire enable,
    output reg [59:0] scrambledData
    );

wire [59:0] iScrambledData;
wire [59:0] iScrambledDataVoted = iScrambledData;

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
    iScrambledData[59:58] = (bypass) ? data[59:58] : data[59:58] ~^ data[20:19] ~^ scrambledData[39:38] ~^ data[1:0] ~^ scrambledData[1:0],
    iScrambledData[57:39] = (bypass) ? data[57:39] : data[57:39] ~^ data[18:0] ~^ scrambledData[37:19] ~^ scrambledData[18:0] ~^ scrambledData[57:39],
    iScrambledData[38:0]  = (bypass) ? data[38:0]  : data[38:0]  ~^ scrambledData[57:19] ~^ scrambledData[38:0];

endmodule
