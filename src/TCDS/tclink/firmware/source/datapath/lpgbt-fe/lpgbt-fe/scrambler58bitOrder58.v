/* Module: scrambler58bitOrder58                                        */
/* Created: Paulo Moreira, 2015/09/15                                        */
/* 2016/05/30 Kulis : Test partterns removed                                 */
/*                    (moved to test pattern generator block)                */
/* Institute: CERN                                                           */
/* Version: 1.0                                                              */

/* Scrambler width: 58 - bits                                                */
/* Scrambler order: 58                                                       */
/* Scrambling recursive equation: Si = Di xnor Si-39 xnor Si-58              */

`timescale 1 ps / 1 ps

module scrambler58bitOrder58 #(parameter INIT_SEED = 58'h112abaa1231ba11)
    (
    input wire [57:0] data,
    input wire clock,
    input wire reset,
    input wire bypass,
	input wire enable,
    output reg [57:0] scrambledData
    );

wire [57:0] iScrambledData;
wire [57:0] iScrambledDataVoted = iScrambledData;

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
    iScrambledData[57:39] = (bypass)? data[57:39] : data[57:39] ~^ data[18:0] ~^ scrambledData[37:19] ~^ scrambledData[18:0] ~^ scrambledData[57:39],
    iScrambledData[38:0]  = (bypass)? data[38:0]  : data[38:0]  ~^ scrambledData[57:19] ~^ scrambledData[38:0];

endmodule
