import lc3b_types::*;

module extend #(parameter inwidth = 5)
(
	input [inwidth - 1:0] in,
	output lc3b_word out
);

	assign out = $signed({in});

endmodule

