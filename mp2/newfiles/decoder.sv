//####################################################################
//####################################################################
//####################################################################
//################ Created by Nick Moore  ############################
//################  for MP2 in ECE 411 at ############################
//################ University of Illinois ############################
//################ Fall 2015              ############################
//####################################################################
//####################################################################
//####################################################################
//#                                                                  #
//#   decoder.sv                                                     #
//#     Implements the decoder module for the LC3B cache             #
//#     combinational logic unit for controlling the muxes           #
//#     entering the cache sets which choose the data from the       #
//#     current cache line or the data from mem_wdata                #
//#                                                                  #
//#     takes offset as input to select which multiplexor to         #
//#     modify the select line to                                    #
//#     outputs 8 different bits to act as 8 different mux sel lines #
//####################################################################

import cache_types::*;

module decoder
(
	input cache_offset wordsel,
	output logic [7:0] control_byte
);
always_comb begin
	unique case (wordsel)
		3'h0:	control_byte = 8'h1;
		3'h1:	control_byte = 8'h2;
		3'h2:	control_byte = 8'h4;
		3'h3:	control_byte = 8'h8;
		3'h4:	control_byte = 8'h10;
		3'h5:	control_byte = 8'h20;
		3'h6:	control_byte = 8'h40;
		3'h7:	control_byte = 8'h80;
	endcase
end

endmodule : decoder
