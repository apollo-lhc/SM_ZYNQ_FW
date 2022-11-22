module gf_multBy3_5(op, res);

// -------------------------------------------------------------------------- //
// ------------- Triple Modular Redundancy Generator Directives ------------- //
// -------------------------------------------------------------------------- //
// tmrg do_not_touch
// -------------------------------------------------------------------------- //

	input      [4:0] op;
	output     [4:0] res;

	assign res[0] = op[4] ^ op[0];
	assign res[1] = op[1] ^ op[0];
	assign res[2] = op[2] ^ op[1] ^ op[4];
	assign res[3] = op[3] ^ op[2];
	assign res[4] = op[4] ^ op[3];

endmodule
