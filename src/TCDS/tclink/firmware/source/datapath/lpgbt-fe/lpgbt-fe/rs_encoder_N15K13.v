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
 *  file: rs_encoder_N15K13.v
 *
 *  rs_encoder_N15K13
 *
 *  History:
 *  2016/09    José Fonseca    : Created
 *  2016/10/06 José Fonseca    : Concluded
 * 
 **/

`timescale 1ns/1ps

module rs_encoder_N15K13 #(parameter N=15,
                    parameter K=13,
                    parameter SYMB_BITWIDTH=4)
                   (msg,
                    parity);
  // tmrg do_not_touch

	// Dependent Parameters
	parameter P = N-K;
	parameter INP_BW = SYMB_BITWIDTH*K;
	parameter OUT_BW = SYMB_BITWIDTH*N;
	parameter POL_BW = SYMB_BITWIDTH*P;
	parameter STG_BW = SYMB_BITWIDTH*(P+1);

	// IO Definition
	input      [INP_BW-1:0] msg;
	output reg [POL_BW-1:0] parity;

	// Connecting wires and regs
	wire [STG_BW-1:0] stageOut [K-1:0];
	wire [STG_BW-1:0] multOut  [K-1:0];

	// Generation Variables for automatic module instantiation
	genvar i,j;
	integer k;

  	// ---------------- The Parallel LFSR HDL description  ---------------- //
  
	// In the first layer, the rightmost node is an addition to zero, so
	// we route it directly to the stage output	
	assign stageOut[0][SYMB_BITWIDTH*P +: SYMB_BITWIDTH] = msg[0 +: SYMB_BITWIDTH];

	// Since in the first layer there are no adders, the stageOut is
	// connected to the multiplier output. Hence, the multOut is set to zero.
	assign multOut[0][0 +: SYMB_BITWIDTH*P] = {(SYMB_BITWIDTH*P){1'b0}};

	// The rightmost multOut is never used (we only add the input codeword
	// with the previous node), so it is set to zero. On the other hand,
	// the leftmost node only performs multiplication, so multOut is
	// routed to stageOut.	
	generate 
  	for (i=0; i < K; i = i + 1) begin
  		assign multOut[i][SYMB_BITWIDTH*P  +: SYMB_BITWIDTH] = {SYMB_BITWIDTH{1'b0}};
  		if (i != 0) begin
  			assign stageOut[i][0 +: SYMB_BITWIDTH] = multOut[i][0 +: SYMB_BITWIDTH];
  		end
  	end
	endgenerate		
 
	// Generates the instances of the GF(2^m) of the LFSR parallel network
	// The first line is a particular case...

	// The GF multiplications units in the first stage
	gf_multBy2_4   mult_0_0   (.op(msg[0 +: SYMB_BITWIDTH]),
				   .res(stageOut[0][0 +: SYMB_BITWIDTH]));
	gf_multBy3_4   mult_0_1   (.op(msg[0 +: SYMB_BITWIDTH]),
				   .res(stageOut[0][SYMB_BITWIDTH +: SYMB_BITWIDTH]));

	// The remaining stages..
	generate 
		for (i=1; i < K; i = i + 1) begin
				// The edge GF addition unit
				gf_add_4    add_i   (.op1(msg[i*SYMB_BITWIDTH +: SYMB_BITWIDTH]),
						     .op2(stageOut[i-1][SYMB_BITWIDTH*(P-1) +: SYMB_BITWIDTH]),
						     .res(stageOut[i][SYMB_BITWIDTH*P +: SYMB_BITWIDTH]));
		end
	endgenerate		

	generate
		for(i=1; i < K; i = i + 1) begin
			// The GF multiplication units
			gf_multBy2_4  mult_i_0   (.op(stageOut[i][SYMB_BITWIDTH*P +: SYMB_BITWIDTH]),
					       .res(multOut[i][0 +: SYMB_BITWIDTH]));

			gf_multBy3_4  mult_i_1   (.op(stageOut[i][SYMB_BITWIDTH*P +: SYMB_BITWIDTH]),
					       .res(multOut[i][SYMB_BITWIDTH +: SYMB_BITWIDTH]));
			for (j=1; j < P; j = j + 1) begin
				gf_add_4   add_i_j    (.op1(multOut[i][SYMB_BITWIDTH*j +: SYMB_BITWIDTH]),
						       .op2(stageOut[i-1][SYMB_BITWIDTH*(j-1) +: SYMB_BITWIDTH]),
						       .res(stageOut[i][SYMB_BITWIDTH*j +: SYMB_BITWIDTH]));
			end
		end
	endgenerate

	always @* begin
		//parity <= {stageOut[K-1][0 +: SYMB_BITWIDTH], stageOut[K-1][SYMB_BITWIDTH +: SYMB_BITWIDTH],msg};
		for (k = 0; k < P; k = k + 1) begin
			parity[k*SYMB_BITWIDTH +: SYMB_BITWIDTH] = stageOut[K-1][STG_BW-(k+2)*SYMB_BITWIDTH +: SYMB_BITWIDTH];
		end		
	end

endmodule
