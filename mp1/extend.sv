import lc3b_types::*;

module extend
(
	input [4:0] in,
	output lc3b_word out
);

	assign out = $signed({in});

endmodule

