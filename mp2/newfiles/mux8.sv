module mux8 #(parameter width = 16)
(
	input [2:0] sel,	
	input [width-1:0] a, b,c,d,e,f,g,h,
	output logic [width-1:0] i
);

always_comb
begin
	unique case (sel)
		3'b000: i = a;
		3'b001: i = b;
		3'b010: i = c;
		3'b011: i = d;
		3'b100: i = e;
		3'b101: i = f;
		3'b110: i = g;
		3'b111: i = h;
		//default: i = a;
	endcase
//	if (sel == 3'b001)
//		i = b;
//	else if (sel == 3'b010)
//		i = c;
//	else if (sel == 3'b011)
//		i = d;
//	else if (sel == 3'b100)
//		i = e;
//	else if (sel == 3'b101)
//		i = f;
//	else if (sel == 3'b110)
//		i = g;
//	else if (sel == 3'b111)
//		i = h;
//	else f = a;
end

endmodule : mux8
