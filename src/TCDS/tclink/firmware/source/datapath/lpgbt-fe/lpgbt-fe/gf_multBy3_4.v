module gf_multBy3_4(op, res);

// -------------------------------------------------------------------------- //
// ------------- Triple Modular Redundancy Generator Directives ------------- //
// -------------------------------------------------------------------------- //
// tmrg do_not_touch
// -------------------------------------------------------------------------- //

	input      [3:0] op;
	output     [3:0] res;

	assign res[0] = op[3] ^ op[0];
	assign res[1] = op[1] ^ op[0] ^ op[3];
	assign res[2] = op[2] ^ op[1];
	assign res[3] = op[3] ^ op[2];

endmodule
