import lc3b_types::*;

module zext #(parameter inwidth = 4)
(
	input [inwidth - 1:0] in,
	output lc3b_word out
);

	assign out = $unsigned({in});

endmodule
