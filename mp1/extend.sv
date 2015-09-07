import lc3b_types::*;

module extend #(parameter outwidth = 16,inwidth=5)
(
	input [inwidth-1:0] in,
	output[outwidth-1:0] out
);

	assign out = $signed(in);

endmodule

