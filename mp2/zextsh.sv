import lc3b_types::*;

module zextsh #(parameter inwidth = 4)
(
	input [inwidth - 1:0] in,
	output lc3b_word out
);

	assign out = $unsigned({in, 1'b0});

endmodule : zextsh 
