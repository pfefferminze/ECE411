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
//#   valid_array.sv                                                 #
//#     Implements a "valid" array for cache lines                   #
//#                                                                  #
//#     takes set as a 1 bit input to set the tag for index          #
//#     takes index as input to select which tag to set              #
//#                                                                  #
//#     outputs valid bit selected by index                          #
//####################################################################

module valid_array
(
	input logic set,
	output logic valid,
	input cache_index line_sel,
	input clk,
	input write
);

logic [7:0] data;

initial begin
	data = 8'h0;
end

always_ff @(posedge clk)
	if (set == 1 && write == 1) data[line_sel] = 1;
end

assign valid = data[line_sel];

endmodule : valid_array
