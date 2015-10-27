module mux3 #(parameter width = 16)
(
	input [1:0] sel,	
	input [width-1:0] a, b,c,
	output logic [width-1:0] f
);

always_comb
begin
	if (sel == 2'b10)
		f = c;
	else if (sel == 2'b01)
		f = b;
	else f = a;
end

endmodule : mux3
